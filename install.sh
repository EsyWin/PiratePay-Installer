#!/bin/bash
sudo add-apt-repository ppa:ondrej/php
# update system
sudo apt update 
sudo apt upgrade -y
# install git, wget, curl, openssl and software-properties-common
sudo apt install screen wget openssl redis-server supervisor nginx mysql-server php7.3 php7.3-fpm php7.3-mysql php7.3-mbstring php7.3-imagick php7.3-xml php7.3-bcmath php7.3-intl php7.3-zip -y
# generate three high-difficulty passwords
PASS_WALLET=$(openssl rand 60 | openssl base64 -A)
PASS_MYSQL=$(openssl rand 60 | openssl base64 -A)
PASS_REDIS=$(openssl rand 60 | openssl base64 -A)
# pass answers to prompts
{ 
  echo '$PASS_MYSQL';
  echo '$PASS_MYSQL';
  echo 'Y';
  echo '1';
  echo 'Y';
  echo 'Y';
  echo 'Y';
  echo 'Y';
  echo 'Y';
}  | sudo mysql_secure_installation

# replace rpcpassword & rpcuser
sed -i "2i rpcpassword=$PASS_WALLET" /home/$USER/.komodo/PIRATE/PIRATE.conf
sed -i "1i rpcuser=piratepay" /home/$USER/.komodo/PIRATE/PIRATE.conf
# root into mysql, create database 'piratepay' grant all to piratepay
mysql -u root -p$PASS_MYSQL << EOF
CREATE DATABASE piratepay DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON piratepay.* TO 'piratepay'@'localhost' IDENTIFIED BY '$PASS_MYSQL';
FLUSH PRIVILEGES;
QUIT;
EOF
# setting fix
sudo sed -i /etc/php/7.3/fpm/php.ini "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g"
# add php to system boot
sudo systemctl restart php7.3-fpm
# download our config file to replace default
wget https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/default -P /home/$USER
sudo rm -f /etc/nginx/sites-available/default
sudo mv default /etc/nginx/sites-available/default
# ensure nginx install & reload nginx deamon
sudo nginx -t
sudo systemctl reload nginx
# replace Redis password
sudo sed -i /etc/redis/redis.conf "s/# requirepass foobared/requirepass $PASS_REDIS/g"
sudo systemctl restart redis.service
cd ~
# get composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
# piratepay install
cd /var/www
sudo git clone https://github.com/CryptocurrencyCheckout/PiratePay.git
cd PiratePay
# replace user in horizon.conf, relplace config file and reload supervisor
sudo sed -i "6i user=$USER" horizon.conf
sudo mv horizon.conf /etc/supervisor/conf.d/horizon.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start horizon
# batch chmod
sudo chown -R www-data:$USER /var/www/PiratePay
sudo find /var/www/PiratePay -type f -exec chmod 664 {} \;
sudo find /var/www/PiratePay -type d -exec chmod 775 {} \;
# install our stack with composer
composer install --no-dev
# create .env file from .env.example
sudo cp .env.example .env
# replace with our config
sudo sed -i "5i APP_URL=localhost" .env
sudo sed -i "10i PIRATE_PASSWORD=$PASS_WALLET" .env
sudo sed -i "23i DB_PASSWORD=$PASS_MYSQL" .env
sudo sed -i "32i REDIS_PASSWORD=$PASS_REDIS" .env
# migrate database & generate encryption keys
php artisan migrate && php artisan key:generate && php artisan passport:install --length=512 --force
