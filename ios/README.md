# SkyWay AI Noise Canceller Library for iOS のインストール方法

ライブラリをインストールする前に、環境変数を設定する必要があります。
appId と secret の値を差し替えて、以下のコマンドを実行してください。

```sh
export SKYWAY_APP_ID="your-app-id"
export SKYWAY_SECRET_KEY="your-app-secret"
```

以下のコマンドを実行して、ライブラリをダウンロードします。

```sh
curl -fsSL https://raw.githubusercontent.com/skyway/ai-noise-canceller/refs/heads/main/tools/ios/download.sh | bash
```

上記のコマンドにより、`tmp` ディレクトリに最新版バージョンの AI Noise Canceller がダウンロードされます。
環境に合わせて Project に追加してください。
Swift Package Manager を用いる場合、Xcode から Project を選択し、 Package Dependencies を選択します。
左下 `+` ボタンからパッケージ検索のモーダルを表示させ、画面下の `Add Local...` を押下します。
ダウンロードした skyway-ai-noise-canceller ディレクトリを選択し Add Package を押下します。
SkyWayAINoiseCanceller と voiceomnia を追加する Target を設定し、 Add Package を押下します。

> [!WARNING]
> 上記で実行するシェルスクリプトは、 端末内で [Skyway Admin Auth Token](https://skyway.ntt.com/ja/docs/user-guide/authentication/skyway-admin-auth-token/) を生成※しライブラリ取得の認証に利用しています。
> この SkyWay Admin Auth Token は、アプリケーションの管理者（サーバー）用APIを利用する際に必要なトークンであり、本トークンが流出した場合は第三者に管理者（サーバー）用APIを悪用されてしまう恐れがあります。
> 取り扱いには十分に気をつけてください。
>
> ※ SkyWay Admin Auth Token の有効期限は1時間です
