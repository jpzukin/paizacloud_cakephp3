## はじめに

PaizaCloudでCakePHP3のチュートリアル環境を準備するスクリプトです。

[PaizaCloud](https://paiza.cloud/ja/)のサーバー限定です。

## 利用方法

cloneしてinit.shを実行すると、約10分くらいで終了します。

```bash
~$ git clone https://github.com/jpzukin/paizacloud_cakephp3.git
~$ ./paizacloud_cakephp3/init.sh
```

## データベース名、ユーザー名/パスワード、アプリ名の変更方法

init.shの先頭でシェル変数として定義されている値を変更します。

```sh
db_name='my_app'
db_user='my_app'
db_pass='Pa$$w0rd'
app_name='my_app_name'
```

注意：パスワードは簡単すぎるとmysqlに拒否されます。

## 備考

べき等性などは考慮していません。

CakePHP3のチュートリアルが可能な環境を準備だけが目的です。

