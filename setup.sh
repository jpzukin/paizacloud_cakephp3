#!/bin/sh

script_dir=$(dirname $(readlink -f $0))

cd ${script_dir}

# PHP拡張の追加とApache httpdの設定
sudo sh << SCRIPT
  sudo apt-get update
  sudo apt-get upgrade -y

  sudo apt-get install -y php7.0-intl php7.0-zip

  echo ServerName $(hostname) > /etc/apache2/conf-available/fqdn.conf
  a2enconf fqdn.conf
  a2enmod rewrite
  service apache2 restart
SCRIPT

# データベースの設定
if [ ! -f database.sql ]; then
echo CakePHP3用のデータベースの作成
cat << SQL > database.sql 
  tee result.log

  GRANT ALL ON my_app.* TO my_app@localhost IDENTIFIED BY 'Pa\$\$w0rd';

  CREATE DATABASE IF NOT EXISTS my_app DEFAULT CHARACTER SET utf8;

  SHOW CREATE USER my_app@localhost;
  SHOW GRANTS FOR my_app@localhost;
  SHOW CREATE DATABASE my_app;

  notee
SQL
mysql -u root < database.sql
fi

# CakePHP3のプロジェクト作成
cd ~/public_html

if [ ! -d ~/public_html/my_app_name ]; then
  echo CakePHP3のプロジェクトを作成
  composer  create-project --prefer-dist cakephp/app my_app_name --no-progress --profile
fi

if [ -f ~/public_html/my_app_name/config/app.php ]; then
  echo "CakePHP3のデータベース接続情報(password)を変更"
  sed -i -e "s/secret/Pa\$\$w0rd/" ~/public_html/my_app_name/config/app.php
fi
