# 筆跡アプリ
筆跡をパスワード代わりに使うアプリ

筆跡を機械学習により、どのユーザーが書いたかどうか・本当に本人かどうかを確認する実験アプリです。

## 環境 動作確認済み
 - Ubuntu 20.04 LTS
 - Ruby 3.1
 - Python 3.8
 - TensorFlow 2.6.0

## 依存するツール
 - ImageMagick
 - TensorFlowなどのPythonライブラリ

## 構造
### 筆跡認証
RubyからTensorFlowをPyCallを介して使っています。学習のジョブと認証のジョブがあり、それらのジョブではバグを避けるために新しいプロセスを作成しています。10枚以上登録されたときに、学習ジョブが実行されます。

### ユーザー認証
sorceryを使って実装しています。このアプリの目的は筆跡を使ってユーザー認証することなので、実装した機能は最小限です。本人として確認が取れた場合は、ログインします。パスワードはユーザーが入力するのではなく、内部でパスワードとして`"password"`という文字列を自動的に入力します。

## 改善予定・やること
 - 書くスピードを踏まえた認識
 - 認識精度の改善
 - 簡易的なSNS機能などの実装
 - 認識などの高速化
