---
tags:
  - MkDocs
---
# 導入
MkDocsを導入検討した際の情報について記述する。

## 背景
勉強したり経験したりすることで自分の中に構築された知見を何かに書き留めたい状況がよくある。定期的に知見をアウトプットすることで、下記のようなメリットがあるためだ。

- 覚えておくべき事柄を減らすことができ、脳の記憶領域を解放できる。
- 文章として体系化しつつ、考察と情報整理ができる。
- 自分の頭の中を可視化することで、他者に向けた情報展開や議論がしやすくなる。

知見をアウトプットするツールとしては、CMS（Contents Management System）やSSG (Static Site Generator) などツールを用いることでナレッジベースを形成することがある。

元々は[Knowledge](https://information-knowledge.support-project.org/ja/)を利用していたものの、利用を進めていくうえで下記のような不満が蓄積することになった。

- DBで情報管理するので、部分的なバックアップや情報展開がやりにくい。
- Dockerでインフラ管理していたが、時々RDBの採番がおかしくなるので見た目上気にいらない。
- 基本的にwebページ上での編集を前提とするので、ローカル環境で書き留めた記事がある際にコピペ発生して面倒。直接ホットリロード的にWebサイト更新したい。
- 一部のMarkdown記述が利用できない。Tomcat製で筆者が不慣れの技術領域のため拡張する場合のコストが高く、既に開発が終わっているため今後拡張される見込みもない。

そこで、ツールの調査を進めつつ、新たに知見を書き留める仕組みを導入するに至った。

## ツール要件

要件として下記の要素を設定した。

- Markdown記述可能
    - 基本的な記述が一通り可能
    - プラグインによって拡張可能
- リアルタイムに更新結果をプレビュー可能
- 日本語検索
- 目次やページリストの自動生成
- レスポンシブ対応
- Git連携
- 外部サービスに非依存
    - Qiita, Zennなど

## ツール候補
候補として下記のようなツールを検討し、MkDocsを今回採用した。

- [MkDocs](https://www.mkdocs.org/)
    - プラグインを用いることでツール要件を一通り満たせる
    - [Pydantic](https://docs.pydantic.dev/latest/)や[FastAPI](https://fastapi.tiangolo.com/ja/) といったライブラリリファレンスとしての利用実績がある
- [Raito](https://arnaud.at/raito/#/)
    - プラグインの多彩さがMkDocsの方が優位と感じたので見送り
- [Pico](https://picocms.org/)
    - 先にMkDocsを採用することに決めたので見送り
- [MDwiki](http://dynalon.github.io/mdwiki/#!index.md)
    - 更新が止まっているらしいので見送り
- [Wordpress](https://ja.wordpress.org/)
    - 集客目的でもなく、そこまでのリッチさを求めなかったので見送り
    - 脆弱性の指摘が多いので、セキュリティ観点でも見送り


## MkDocs
[MkDocs](https://www.mkdocs.org/)とはMarkdownでドキュメントサイトが簡単に作れる強力な静的サイトジェネレーターである。  

### 主な設定
#### Dockerfile
```Dockerfile
FROM alpine:3.12

RUN apk update \
  && apk add --no-cache gcc libc-dev python3 py3-pip python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install mkdocs mkdocs-material plantuml-markdown python-markdown-math pygments pymdown-extensions

RUN pip3 install python-markdown-math mkdocs-awesome-pages-plugin

RUN mkdir -p /root/projects
```

- alpine環境に必要なライブラリをインストール
- ライブラリを追加したい際は、Dockerfileを編集する

#### docker-compose.yml
```yaml
version: "3"
services:
  app:
    container_name: mkdocs
    build:
      context: .
      dockerfile: Dockerfile
    tty: true
    stdin_open: true
    ports:
      - "48000:48000"
    working_dir: /root/projects/volume
    command: /usr/bin/mkdocs serve
    restart: always
    volumes:
      - type: bind
        source: "./volume"
        target: "/root/projects/volume"
```

- volumeをマウント
- `docker compose up` 時にserve実行
- 48000ポートをフォワーディング

#### .gitignore
```gitignore
volume/site/
```

- buildしたファイル群のvolume/site/のみ排除する設定

#### mkdocs.yml
長いので記述割愛。主な設定をここでは記述。

- 48000ポートで起動
- /mkdocsをルートとする
- 主な導入した追加拡張
    - plugins
        - [search](https://squidfunk.github.io/mkdocs-material/setup/setting-up-site-search/)
            - 検索
        - [autolinks](https://github.com/zachhannum/mkdocs-autolinks-plugin)
            - 自動リンク
        - [awesome-pages](https://github.com/lukasgeiter/mkdocs-awesome-pages-plugin)
            - ページメタデータ管理
        - [tags](https://squidfunk.github.io/mkdocs-material/setup/setting-up-tags/)
            - タグの追加
    - markdown_extensions
        - [pymdownx.superfences](https://facelessuser.github.io/pymdown-extensions/extensions/superfences/)
            - mermaid追加
        - [mdx_math](https://github.com/mitya57/python-markdown-math/tree/master)
            - 数式追加

### ドキュメント作成時の主な作業
- volume/docs以下にドキュメントを作成
- プラグインの追加
    - volume/mkdocs.ymlにプラグイン設定
    - 追加のライブラリが必要であればDockerfileにライブラリ追加してimageを再ビルドする
    - 必要な連携サーバーがあれば起動する
- 静的コンテンツとして配布できるようにビルド

### 参考
- [最高のソフトウェアドキュメント製作ツール(mkdocs + plantuml + mermaid.js)をdockerで作成する](https://qiita.com/ryohei_takasugi/items/d8110ebbb25e87a007ae)
- [MkDocs拡張機能 フォルダの名前を書き換える (Awesome-Pages)](https://kurotorimkdocs.gitlab.io/kurotorimemo/040-Documents/MkDocs/Extension/#awesome-pages)
- [MKDocsで数式を書く方法](https://enu23456.hatenablog.com/entry/2022/11/22/214014)
- [The best MkDocs plugins and customizations](https://chrieke.medium.com/the-best-mkdocs-plugins-and-customizations-fc820eb19759)