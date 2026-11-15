# dotfiles

macOSの開発環境設定を管理します。

## 管理対象

- Fish
- AeroSpace
- Gitの共通ignore
- Claude Codeのagentsとcommands

## インストール

```sh
./install.sh --with-fish
```

`--with-fish` はHomebrewでFishを導入し、設定をリンクした後、FisherとプラグインをセットアップしてFishをログインシェルに設定します。`/etc/shells` への登録で管理者パスワード、ログインシェルの変更でユーザーパスワードを求められる場合があります。Homebrewは事前にインストールしてください。既存の設定は `~/.local/state/dotfiles-backup/` にバックアップしてからシンボリックリンクを作成します。

インストールスクリプトを実行すると、Gitのグローバル作者名とメールアドレスを `miyakei1225` / `miyakeionigiri@yahoo.co.jp` に設定します。

Raycast、Karabiner-Elements、Visual Studio Code、Cursor、AeroSpace、iTerm2、Herdr、Inshellisense、Meslo LG Nerd Fontも未導入の場合にインストールし、iTerm2のデフォルトプロファイルにフォントとIceberg配色を設定するには、次を実行します。

```sh
./install.sh --with-apps
```

Fishもアプリもまとめてセットアップする場合は `./install.sh --with-fish --with-apps` を実行します。どちらのオプションも省略した場合、アプリのインストールは行いません。

Inshellisense は初期化ファイルを作成し、Fish設定末尾から読み込まれます。Fishではないシェルが起動している場合は、iTerm2のプロファイルでFishを指定してください。対応コマンドでは、入力中に候補メニューを表示します。AWS CLI (`aws`) はInshellisenseの補完仕様に含まれません。

既存環境へInshellisenseだけを追加する場合は、次を実行してください。

```sh
brew tap microsoft/inshellisense https://github.com/microsoft/inshellisense
brew install inshellisense
./install.sh --with-inshellisense
```

`--with-apps` は未導入アプリをスキップし、Inshellisenseの初期化ファイルを用意します。Fish設定はユーザー名に依存しないパスからこれを読み込みます。

`--with-apps` は、iTerm2が終了していて既存の設定がある場合、現在のデフォルトプロファイルに **MesloLGS NF** と暗い青系の **Iceberg** 配色を設定します。暗い配色に固定し、macOSの外観設定には連動しません。既存のフォントサイズは維持します。iTerm2が起動中なら終了後に同じコマンドを再実行してください。iTerm2を初めて起動する前なら、一度起動して終了してから再実行します。Fishプロンプトのアイコンが反映されない場合は、**Settings > Profiles > Text > Font** で設定を確認してください。
