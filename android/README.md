# SkyWay AI Noise Canceller Library for Android のインストール方法

ライブラリをインストールする前に、環境変数を設定する必要があります。 appId と secret の値を差し替えて、以下のコマンドを実行してください。
```
export SKYWAY_APP_ID="your-app-id"
export SKYWAY_SECRET_KEY="your-app-secret"
```

以下のコマンドを実行して、ライブラリをインストールします。

```
curl -fsSL https://raw.githubusercontent.com/skyway/ai-noise-canceller/refs/heads/main/tools/android/install.sh | bash
```

> [!NOTE]
> 上記のシェルスクリプトを実行するには、Apache Maven というビルドツールがインストールされている必要があります。
> 
> macOS（Homebrew使用）の場合は、以下のコマンドでインストールできます：
> ```sh
> brew install maven
> ```
> その他の OS でのインストール方法は、[Apache Maven Project](https://maven.apache.org/install.html)をご確認ください。
> 
> インストール後、以下のコマンドでバージョンを確認できます：
> ```sh
> mvn -v 
> ```

上記のコマンドを実行すると、カレントディレクトリ直下の tmp ディレクトリに最新版の AI Noise Canceller がダウンロードされ、Maven ローカルリポジトリに追加されます。

Maven ローカルリポジトリに追加されたら、導入先のプロジェクトを開き、settings.gradle にて Maven ローカルリポジトリを参照するよう設定を追加します。
```
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        mavenLocal() // ローカルの ai-noise-canceller を参照するために追加
    }
}
```

次に、build.gradle に以下のように依存関係を追加すれば、ライブラリの導入は完了です。
```
dependencies {
    ...
    implementation 'com.ntt.skyway.audio:ai-noise-canceller:x.x.x'
}
```

> [!TIP]
> `--download-only` の引数を付与することで、 ライブラリのみの取得が可能です。
> この場合、 Apache Maven ビルドツールをインストールする必要はありません。  
> ```sh
> # tmp ディレクトリに保存
> curl -fsSL https://raw.githubusercontent.com/skyway/ai-noise-canceller/refs/heads/main/tools/android/install.sh | bash -s -- --download-only --dest="tmp"
> ```
> 取得したライブラリが手元にあれば、unzipして com/ntt/skyway/audio/ai-noise-canceller/${version}/の中にある ai-noise-canceller-x.x.x.aar を手動でProjectに追加することができます。

> [!WARNING]
> 上記で実行するシェルスクリプトは、 端末内で [Skyway Admin Auth Token](https://skyway.ntt.com/ja/docs/user-guide/authentication/skyway-admin-auth-token/) を生成※しライブラリ取得の認証に利用しています。
> この SkyWay Admin Auth Token は、アプリケーションの管理者（サーバー）用APIを利用する際に必要なトークンであり、本トークンが流出した場合は第三者に管理者（サーバー）用APIを悪用されてしまう恐れがあります。
> 取り扱いには十分に気をつけてください。
>
> ※ SkyWay Admin Auth Token の有効期限は1時間です