# MkDocs簡易構築
初期設定とサンプルを配置してmkdocsを簡易的に立ち上げられるようにしたもの。

## 起動方法
docker環境を前提とする。
ドキュメント更新を確認する用のサイトプレビューを表示するところまで。
```
git clone https://github.com/ShunsukeNONOMURA/mkdocs-master.git
docker compose up --build
```

## 導入情報
サンプル記事として `volume/docs/000-mkdocs/installation.md` にて記載。
起動後に http://localhost:48000/mkdocs/000-mkdocs/installation.html で辿れるように設定。