# SkyWay AI Noise Canceller

# 本リポジトリの運用方針について

このリポジトリは公開用のミラーリポジトリであり、こちらで開発は行いません。

## Issue / Pull Request

受け付けておりません。

Enterprise プランをご契約のお客様はテクニカルサポートをご利用ください。
詳しくは[SkyWay サポート](https://support.skyway.ntt.com/hc/ja)をご確認ください。

# ライブラリのインストール方法

ライブラリをインストールする前に、環境変数を設定する必要があります。
appId と secret の値を差し替えて、以下のコマンドを実行してください。

```sh
export SKYWAY_APP_ID="your-app-id"
export SKYWAY_SECRET_KEY="your-app-secret"
```

以下のコマンドを実行して、ライブラリをインストールします。

```sh
curl -fsSL https://raw.githubusercontent.com/skyway/ai-noise-canceller/refs/heads/main/tools/js/install.sh | bash
```

上記のコマンドにより、`tmp` ディレクトリに最新版バージョンの AI Noise Canceller がダウンロードされ、 `node_modules`に追加されます。
ライブラリのインストールが完了したら、`tmp` 配下にある `tgz` ファイルは削除してしまって構いません。

> [!TIP]
> `--download-only` の引数を付与することで、 ライブラリのみの取得が可能です。
> ```sh
> # tmp ディレクトリに保存
> curl -fsSL https://raw.githubusercontent.com/skyway/ai-noise-canceller/refs/heads/main/tools/js/install.sh | bash -s -- --download-only --dest="tmp"
> ```
> 取得したライブラリが手元にあれば、パッケージマネージャーを利用して追加できます。
> ```sh
> # npmを用いた場合
> npm install ./tmp/skyway-ai-noise-canceller-x.x.x.tgz
> ```

> [!WARNING]
> 上記で実行するシェルスクリプトは、 端末内で [Skyway Admin Auth Token](https://skyway.ntt.com/ja/docs/user-guide/authentication/skyway-admin-auth-token/) を生成※しライブラリ取得の認証に利用しています。
> この SkyWay Admin Auth Token は、アプリケーションの管理者（サーバー）用APIを利用する際に必要なトークンであり、本トークンが流出した場合は第三者に管理者（サーバー）用APIを悪用されてしまう恐れがあります。
> 取り扱いには十分に気をつけてください。
>
> ※ SkyWay Admin Auth Token の有効期限は1時間です


# ドキュメント

## 公式サイト

[https://skyway.ntt.com/ja/docs/user-guide/ai-noise-canceller/](https://skyway.ntt.com/ja/docs/user-guide/ai-noise-canceller/)

## API リファレンス

- [AI Noise Canceller ライブラリ](https://skyway.ntt.com/ja/docs/api-reference/ai-noise-canceller/)

# 利用規約

本ライブラリ「SkyWay AI Noise Canceller」は OSS ではありません。
ソフトウェアやそのアーカイブに対して以下のような行為を禁止しております。
- 改変
- リバースエンジニアリング
- 公開リポジトリへのアップロード

詳しくは利用規約をご確認ください。
[SkyWay利用規約](https://skyway.ntt.com/ja/terms/)

# License

- [LICENSE](/LICENSE)
- [THIRD_PARTY_LICENSE](/THIRD_PARTY_LICENSE)
