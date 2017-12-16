#!/bin/sh

script_dir=$(dirname $(readlink $0))

cd ${script_dir}

sudo sh << SCRIPT
  sudo apt-get update
  sudo apt-get upgrade -y

  sudo apt-get install -y php7.0-intl php7.0-zip

  echo "ServerName $HOSTNAME > /etc/apache2/conf-available/fqdn.conf"
  a2enconf fqdn.conf
  a2enmod rewrite
  service apache2 restart
SCRIPT

if [ -f database.sql ]; then
cat << SQL > database.sql 
  tee result.log

  GRANT ALL ON my_app.* TO my_app@localhost IDENTIFIED BY 'Pa$$w0rd';

  CREATE DATABASE IF NOT EXISTS my_app DEFAULT CHARACTER SET utf8;

  SHOW CREATE USER my_app@localhost;
  SHOW GRANTS FOR my_app@localhost;
  SHOW CREATE DATABASE my_app;

  notee
SQL
mysql u root < database.sql
fi

cd ~/public_html
conposer create-project --prefer-dist cakephp/app my_app_name --no-progress --profile
