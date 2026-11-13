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

`--with-fish` はHomebrewでFishを導入し、設定をリンクした後、Fisherとプラグインをセットアップします。Homebrewは事前にインストールしてください。既存の設定は `~/.local/state/dotfiles-backup/` にバックアップしてからシンボリックリンクを作成します。
