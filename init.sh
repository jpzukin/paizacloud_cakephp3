#1/bin/sh

$shell_dir=$(dirname $(readlink -f $0))
cd ${shell_dir}

# Parameters
#   - Database name
#   - Database username
#   - Database password
#   - Application name
$database_name='my_app'
$database_user='my_app'
$database_pass='Pa$$word'
$app_name='my_app_name'

# Install a PHP Extention:
#   - intl PHP Extention
#   - zip PHP Extention
$pkg_list=""
(dpkg -l php7.0-intl | grep ^ii) || $pkg_list="${pkg_list} php7.0-intl"
(dpkg -l php7.0-zip  | grep ^ii) || $pkg_list="${pkg_list} php7.0-zip"
if [ "${pkg_list}" -ne "" ]; then
	sudo sh <<-EOS
		apt-get update
		apt-get upgrade
		apt-get install -y ${pkg_list}
	EOS
fi

# Install a Composer plugin:
#  - hirak/prestissimo - composer parallel install plugin.
composer global show | grep "hirak/prestissimo"
if [ $? -eq 1 ]; then
	composer global require "hirak/prestissimo"
fi

# Creating the Database
if [ ! -f database.sql ]; then
	cat <<-EOS > database.sql
		CREATE DATABASE ${database_name} IF NOT EXISTS DEFAULT CHARACTER SET utf8;
		GRANT ALL ON ${database_name}.* TO ${database_user}@localhost IDENTIFIED BY ${database_pass}
	EOS
	mysql -u root < database.sql
fi

# Getting CakePHP
if [ ! -d ${application_name} ]; then
	cd ~/public_html
	composer create-project --prefer-dist ${application_name} --no-progress --profile
fi
