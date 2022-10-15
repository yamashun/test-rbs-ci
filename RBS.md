Rubyの静的型解析の方針やルールについて記載します。

Rubyの静的型解析に関するツールはいくつか存在しますが、このリポジトリでは[RBS](https://github.com/ruby/rbs)、[Steep](https://github.com/soutaro/steep)、[TypeProf](https://github.com/ruby/typeprof)、[RBS Collection](https://github.com/ruby/gem_rbs_collection)、[RBS Rails](https://github.com/pocke/rbs_rails)を使用しています。

# Steepによる型検査
まずは型検査を実行できるか確認します。

## gemのrbsを取得
型検査を行う前にRBS Collectionを使ってローカルにgemの型情報をダウンロードします。


```sh
$ bundle exec rbs collection install
```

コマンドを実行すると `.gem_rbs_collection` にrbsファイルがダウンロードされていることが確認できます。
gemの更新などが発生する場合は再実行して更新が必要です。

## 型検査の実行

```
$ bundle exec steep check
```

# IDEによるチェックと入力補完の有効化
## Visual Studio Code
### Extensionsの追加
steepで検索すると[このExtension](https://github.com/soutaro/steep-vscode)が出てくるので追加します。

### 動かし方
VS Codeのコマンドパレットで `Steep: Restart all`を実行します。

これでコードを書く時に型のチェックや入力補完が動くはずです。


## Other IDE
TODO: RubyMine などでも利用できるはずですが、動作未確認です。


# 型定義ファイルのディレクトリ構成

```
.
├── .gem_rbs_collection: rbs collectionで自動生成するRBS(git管理対象外)
├── sig
│   ├── app: ./app配下のRBSファイル
│   ├── gems: rbs collectionで管理していないgemのRBSファイル、rbs collectionで管理しているgemのrbsのpathch
│   ├── lib: ./lib配下のRBSファイル
|   ├── standard_lib: RBSが準備されていない標準ライブラリのRBS、パッチを当てたい標準ライブラリのRBS
│   └── rbs_rails: rbs_railsで自動生成するRBSファイル
│       └── app
```

# RBSの更新
## 更新の方針
自動生成されるRBSは更新するとライブラリ側に更新があった場合にコンフリクトしてしまうため更新せずに、手動で作成したRBSを更新するようにします。

手動更新の対象外
- .gem_rbs_collection
- sig/rbs_rails

可能な限りuntypedは使わずにRBSを作りましょう。
但し複雑なgemなどでは型チェックのエラーを解消したり正しい型を書くのがかなり大変なので、メンテナンスコストを考慮して無理をせずにuntypeなどを使ってとりあえずエラーを解消する形で問題ないです。

## rbs collectionで追加したgemのrbsを修正したい場合
`sig/gems/{gem name}/hoge_patch.rbs` にRBSを追加して修正する。

## RBSが用意されていないgemを追加した場合
以下のいずれかの方法でRBSを作成します

### gemのソースコードから型定義ファイルを自動生成

```sh
# gemのインストール先のディレクトリに移動
$ cd /path/to/{gem name}
# rbs prototype rbコマンドでsig/gems配下にrbsを保存する
$ rbs prototype rb --out-dir=/path/to/app/sig/gems/{gem name} lib

```

### 手動で一部の定義を追加
動的なメソッド定義や複雑な依存関係を持つgemなどは、自動で生成に失敗したり、生成後の状態では使えない場合が多いです。
その状態でエラーが消えて使える状態にするのは工数がかかりすぎるため、アプリケーション側で呼び出すパブリックメソッドなどに絞ってRBSを手動で追加します。

### rbs collectionにPRを作成
時間に余裕がある場合は [RBS Collection](https://github.com/ruby/gem_rbs_collection) への追加も検討しましょう。


## Railsのgemを更新した場合
以下を実行して自動生成されるRBSファイルを更新します。

```
$ bundle exec rbs collection install
$ bundle exec rails rbs_rails:all
```

## Railsに関するgemを手動更新する場合
`sig/rbs_rails` のファイルを直接更新すると自動生成したRBSとコンフリクトするため、 `sig/patch_rails.rbs` を修正する。

## テーブルのスキーマを変更した場合
modelの型定義にカラム情報を追加したいためridgepole実行後にrbs_railsコマンドを実行する必要がある。`script/change_schema.sh` を実行するとridgepole apply後にrbs_railsコマンドが実行されて変更後のスキーマの型情報が反映される。

```
$ script/change_schema.sh
```

## 自前のファイルに対するRBSファイルを生成する場合
`sig/app` 以下にファイルを作成していきます。
`script/generate_rbs_template.rb` にテンプレートを生成するscriptがあるので、それを使うと楽に生成できます。

```sh
# 引数に生成元のrbファイルのパスを指定する
$ ruby script/generate_rbs_template.rb app/models/content_item.rb
```

## エラーを回避できない場合
自動生成されるファイルの型が誤っている等でどうしてもCIのチェックをクリアできない場合は、以下のコマンドでチェックエラーの対象から外すことで回避できます。

```
$ bundle exec steep check --save-expectations
```

このコマンドで `steep_expectations.yml` が更新されます。

## 最後に
良い方法を見つけたらこのドキュメントもどんどん更新していきましょう！
