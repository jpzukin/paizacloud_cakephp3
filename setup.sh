#!/bin/sh

# スクリプト直下をカレントディレクトリする
script_dir=$(dirname $(readline -f $0))
cd ${script_dir}

# PHP拡張の追加
# - intl PHP 拡張
# - zip PHP 拡張
sudo sh <<-SCRIPT
	apt-get update
	apt-get upgrade -y
	apt-get install -y \
		php7.0-intl \
		php7.0-zip
SCRIPT

# Apache2 httpdの設定
# - ServerName
# - rewriteモジュールの有効化
sudo sh <<-SCRIPT
	echo ServerName $(hostname).paiza-user.cloud > /etc/apache2/conf-available/fqdn.conf
	a2enconf fqdn.conf
	a2enmod rewrite
	service apache2 restart
SCRIPT

# データベースの設定
# - データベースの作成
# - userの追加
if [ ! -f database.sql ]; then
	echo CakePHP3用のデータベースの作成
	cat <<-'SQL' > database.sql 
		tee result.log

		GRANT ALL ON my_app.* TO my_app@localhost IDENTIFIED BY 'Pa$$w0rd';

		CREATE DATABASE IF NOT EXISTS my_app DEFAULT CHARACTER SET utf8;

		SHOW CREATE USER my_app@localhost;
		SHOW GRANTS FOR my_app@localhost;
		SHOW CREATE DATABASE my_app;

		notee
	SQL
	mysql -u root < database.sql
fi

# CakePHP3のプロジェクト作成する
cd ~/public_html

if [ ! -d ~/public_html/my_app_name ]; then
  composer  create-project --prefer-dist cakephp/app my_app_name --no-progress --profile
fi

# CakePHP3のデータベース接続情報を変更する
# - passwordの変更
if [ -f ~/public_html/my_app_name/config/app.php ]; then
  sed -i -e 's/secret/Pa$$w0rd/' ~/public_html/my_app_name/config/app.php
fi
