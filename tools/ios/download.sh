#!/bin/bash

g_skyway_admin_auth_token=""
g_download_file_path=""
g_signed_url=""

is_available() {
  command -v "$1" >/dev/null 2>&1
}

get_color_code() {
  local color=$1
  local keys=("reset" "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" "bold")
  local values=(0 30 31 32 33 34 35 36 37 1)
  local color_code=0

  for i in "${!keys[@]}"; do
    if [ "${keys[$i]}" == "$color" ]; then
      color_code="${values[$i]}"
      break
    fi
  done

  printf "%s" "$color_code"
}

# Print message with a newline
println_message() {
  local message="$1"
  local color_code
  color_code="$(get_color_code "${2:-reset}")"

  printf "\e[${color_code}m%s\e[0m\n" "$message"
}

# Print message without a newline
print_message() {
  local message="$1"
  local color_code
  color_code="$(get_color_code "${2:-reset}")"

  printf "\e[${color_code}m%s\e[0m" "$message"
}

abort() {
  printf "\r"
  print_message "Error: " "red"
  println_message "$@"
  exit 1
}

make_payload() {
  local iat # Current Unix timestamp (seconds)
  local jti # Generate random UUID
  local exp # Current Unix timestamp + 1 hour (60 seconds * 60 minutes)
  local payload
  local appId=$1

  iat=$(date +%s)
  jti=$(uuidgen | tr 'A-F' 'a-f')
  exp=$((iat + 60 * 60))
  payload=$(
    printf \
      '{"iat": %d, "jti": "%s", "exp": %d, "appId": "%s"}' \
      "$iat" \
      "$jti" \
      "$exp" \
      "$appId"
  )

  printf "%s" "$payload"
}

base64_noline() {
  if command -v base64 >/dev/null 2>&1; then
    local base64_help_output=$(base64 --help 2>&1 || true)
    if printf '%s' "$base64_help_output" | grep -q -- '-w'; then
      base64 -w 0
    elif printf '%s' "$base64_help_output" | grep -q -- '-b'; then
      base64 -b 0
    else
      base64 | tr -d '\n'
    fi
  elif command -v uuencode >/dev/null 2>&1; then
    local tmpfile=$(mktemp)
    cat >"$tmpfile"
    uuencode -m "$tmpfile" dummy | sed '1d;$d' | tr -d '\n'
    rm -f "$tmpfile"
  else
    echo "Error: base64_noline is not supported on this system. Neither 'base64' nor 'uuencode' command found." >&2
    exit 1
  fi
}

# Base64 encoding function for URL-safe encoding
# This function is used for encoding the header and payload in JWT (JSON Web Token)
base64_url_encode() {
  local input="${*:-$(cat)}" # Read input from arguments or from stdin (default)

  # Perform base64 encoding, then modify the result to be URL-safe
  # Replace '+' with '-', '/' with '_', and remove '=' padding
  printf "%s" "$input" | base64_noline | tr '+/' '-_' | tr -d '='
}

# Generate HMAC-SHA256 signature
# This function generates a signature using the given data and secret key.
# It encodes the result using Base64 with URL-safe characters and removes padding
signature() {
  local data="$1"
  local secret="$2"

  # Compute HMAC-SHA256 hash of the data using the secret key, then:
  # - Encode the result in Base64
  # - Convert '+' to '-', '/' to '_', and remove '=' padding for URL safety
  printf "%s" "$data" | openssl dgst -sha256 -hmac "$secret" -binary \
    | base64_noline | tr '+/' '-_' | tr -d '='
}

# Generate a JWT (JSON Web Token)
# This function takes a payload and a secret, and generates a JWT with HS256 algorithm
generate_jwt() {
  local header='{"alg":"HS256","typ":"JWT"}'
  local appId="$1"
  local secret="$2"

  local payload
  local encoded_header
  local encoded_payload
  local signature

  payload="$(make_payload "$SKYWAY_APP_ID")"
  encoded_header=$(base64_url_encode "$header")
  encoded_payload=$(base64_url_encode "$payload")
  signature=$(signature "${encoded_header}.${encoded_payload}" "$secret")

  g_skyway_admin_auth_token="${encoded_header}.${encoded_payload}.${signature}"
}

# Download a file from the given URL and save it to the specified directory
# If the directory doesn't exist, it will be created. The filename is derived from the URL.
download_file() {
  local url="$1"
  local download_dir="${2:-tmp}"

  if [ ! -d "$download_dir" ]; then
    mkdir -p "./$download_dir"
  fi

  local url_without_query="${url%%\?*}"
  local filename="${url_without_query##*/}"

  g_download_file_path="./$download_dir/$filename"

  local dl_cmd="curl -f -s -o $g_download_file_path $url"
  eval "$dl_cmd"

  if [ ! -f "$g_download_file_path" ]; then
    abort "The file $g_download_file_path was not found."
  fi

}

# Fetch a signed URL from the server using the provided token and version
get_signed_url() {
  local server="$1"
  local token="$2"
  local version="$3"

  local url="$server/v1/libs/noise-canceller?lib_version=$version&platform=ios-sdk"
  g_signed_url=$(
    curl -f -s -H "authorization: Bearer $token" "$url" | jq .url
  )

  if [[ -z "$g_signed_url" || "$g_signed_url" == "null" ]]; then
    abort "Failed to retrieve signed_url from API response."
  fi
}

# Generate a JWT token, retrieve the signed URL, and download the corresponding library file
download_library_file() {
  local server="$1"
  local version="${2:-latest}"
  local download_dir="$3"

  generate_jwt "$SKYWAY_APP_ID" "$SKYWAY_SECRET_KEY"
  get_signed_url "$server" "$g_skyway_admin_auth_token" "$version"
  download_file "$g_signed_url" "$download_dir"
}

# This function checks if the required tools are available on the system.
# If any of the specified tools are missing, it prints a message listing
# the missing tools and exits the script with a non-zero status.
check_required_tools() {
  local tools=("$@")
  local missing_tools=()

  for tool in "${tools[@]}"; do
    if ! is_available "$tool"; then
      missing_tools+=("$tool")
    fi
  done

  if [ ${#missing_tools[@]} -gt 0 ]; then
    print_message "Error: " "red"
    print_message "The following tools are not installed -"
    for missing_tool in "${missing_tools[@]}"; do
      print_message " $missing_tool" "magenta"
    done
    println_message ""
    println_message "Please install the missing tools before proceeding." "yellow"
    exit 1
  fi
}

load_and_validate_env() {
  local env_file="$1"
  if [ -n "$env_file" ] && [ -f "$env_file" ]; then
    print_message "Loading environment variables from "
    print_message "$env_file" "cyan"
    print_message " file..."
    #shellcheck disable=SC1090
    source "$env_file"
    println_message "success!" "green"
  fi

  if [ -z "$SKYWAY_APP_ID" ]; then
    abort "SKYWAY_APP_ID is not set!"
  fi

  if [ -z "$SKYWAY_SECRET_KEY" ]; then
    abort "SKYWAY_SECRET_KEY is not set!"
  fi
}

usage() {
  println_message "Usage: $0 [options]"
  println_message ""
  println_message "Options:"
  println_message "  -v, --version=<ver>   Specify version (e.g., 1.0.0 or 'latest')"
  println_message "  -d, --dest=<dir>      Specify download directory"
  println_message "  --env-file=<file>     Specify the environment file"
  println_message ""
  println_message "Examples:"
  println_message "  $0 --version=1.0.0 --dest=/path/to/dir"
  println_message "  $0 --env-file=/path/to/env/file"
}

main() {
  local need_download=true
  local version=""
  local download_dir=""
  local env_file=""
  local default_server="https://noise-cancelling.skyway.ntt.com"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -v=* | --version=*)
        version="${1#*=}"
        shift
        ;;
      -v | --version)
        version="$2"
        shift 2
        ;;
      -d=* | --dest=*)
        download_dir="${1#*=}"
        shift
        ;;
      -d | --dest)
        download_dir="$2"
        shift 2
        ;;
      --env-file=*)
        env_file="${1#*=}"
        shift
        ;;
      --env-file)
        env_file="$2"
        shift 2
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Perform a format check on the variable `version`.
  if [ -n "$version" ] && ! [[ "$version" =~ ^([0-9]+\.[0-9]+\.[0-9]+|latest)$ ]]; then
    abort "Version format is invalid. Expected format is <major>.<minor>.<patch> (e.g., v1.0.0) or 'latest'."
  fi

  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    version="v$version"
  fi

  local tools=("curl" "jq" "uuidgen" "openssl" "date" "unzip")
  # Check if the necessary tools exist
  check_required_tools "${tools[@]}"

  load_and_validate_env "$env_file"

  local server="${SERVER:-$default_server}"
  if $need_download; then
    print_message "Downloading library..."
    download_library_file "$server" "$version" "$download_dir"
    println_message "Done!" "green"
    print_message "Successfully downloaded to "
    println_message "$g_download_file_path!" "cyan"
  fi
}

main "$@"
