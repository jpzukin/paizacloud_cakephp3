#1/bin/sh

shell_dir=$(dirname $(readlink -f $0))
cd ${shell_dir}

# Parameters
#   - Database name
#   - Database username
#   - Database password
#   - Application name
db_name='my_app'
db_user='my_app'
db_pass='Pa$$w0rd'
app_name='my_app_name'

# Install a PHP Extention:
#   - intl PHP Extention
#   - zip PHP Extention
pkg_list=""
(dpkg -l php7.2-intl | grep ^ii) || pkg_list="${pkg_list} php7.2-intl"
(dpkg -l php7.2-zip  | grep ^ii) || pkg_list="${pkg_list} php7.2-zip"
if [ "${pkg_list}" != "" ]; then
	sudo sh <<-EOS
		DEBIAN_FRONTEND=noninteractive
		apt-get update -y
		apt-get upgrade -y
		apt-get install -y ${pkg_list}
	EOS
fi

# Setting a Apache httpd Module/conf:
#   - rewrite module
#   - fqdn conf
if [ ! -f /etc/apache2/conf-available/fqdn.conf ]; then
	sudo sh <<-EOS
		echo ServerName $(hostname).paiza-user.cloud > /etc/apache2/conf-available/fqdn.conf
		a2enconf fqdn.conf
		a2enmod rewrite
		service apache2 restart
	EOS
fi

# Install a Composer plugin:
#  - hirak/prestissimo - composer parallel install plugin.
if [ ! -d ~/.composer/vendor/hirak/prestissimo ]; then
	composer global require "hirak/prestissimo"
fi

# Creating the Database
if [ ! -f database.sql ]; then
	cat <<-EOS > database.sql
		CREATE DATABASE IF NOT EXISTS ${db_name} DEFAULT CHARACTER SET utf8;
		GRANT ALL ON ${db_name}.* TO ${db_user}@localhost IDENTIFIED BY '${db_pass}'
	EOS
	mysql -u root < database.sql
fi

# Getting CakePHP
if [ ! -d ~/public_html/${app_name} ]; then
	echo "Getting CakePHP..."
	cd ~/public_html
	composer create-project --prefer-dist cakephp/app ${app_name} --no-progress --profile
fi

# Database Configuration
if [ -d ~/public_html/${app_name} ]; then
	cd ~/public_html/${app_name}
	sed -i -E "s/(password.+)secret/\1${db_pass}/" config/app.php
	sed -i -E "s/(database.+)my_app/\1${db_name}/" config/app.php
	sed -i -E "s/(username.+)my_app/\1${db_user}/" config/app.php
fi
