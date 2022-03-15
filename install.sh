#!/bin/bash

# prompt user
echo "Enter your static ip if you arrr on VPS (just press enter if you're on localhost)"
read $APP_URL
if [ $APP_URL -z ]
then
    $APP_URL="localhost"
fi

# update system
sudo apt update && sudo apt upgrade

# install git, wget, curl, openssl and software-properties-common
sudo apt install git wget curl unzip openssl software-properties-common -y

# navigate to $HOME for consistent install
cd ~

# create ~/.komodo/PIRATE data folder, give $USER rwx, $GROUP rx, $OTHERS rx
# r = read, w = write, x = execute 
mkdir -p /home/$USER/.komodo/PIRATE && chmod 755 /home/$USER/.komodo/PIRATE

# download PirateChain Bootstrap file
# wget -N --no-check-certificate --progress=dot:giga --continue --retry-connrefused --waitretry=3 --timeout=30 https://eu.bootstrap.dexstats.info/PIRATE-bootstrap.tar.gz -P /home/$USER/.komodo/PIRATE

# extract Boostrap file
# tar -xzvf /home/$USER/.komodo/PIRATE/PIRATE-bootstrap.tar.gz -C /home/$USER/.komodo/PIRATE

# navigate to home folder to ensure consistent installs
cd ~

# download latest Pirate wallet release
wget --no-check-certificate --content-disposition https://github.com/PirateNetwork/pirate/releases/download/v5.4.2/pirate-qt-ubuntu1804-v5.4.2.deb -P /home/$USER/

# install Pirate Wallet
dpkg -i pirate-qt-ubuntu1804-v5.4.2.deb

# fetch zcash parameters
/home/$USER/komodo/fetch-params.sh

# generate three high-difficulty passwords
PASS_WALLET=$(openssl rand 60 | openssl base64 -A)
PASS_MYSQL=$(openssl rand 60 | openssl base64 -A)
PASS_REDIS=$(openssl rand 60 | openssl base64 -A)

# replace rpc password with high-difficulty password freshly generated
sed -i /home/$USER/.komodo/PIRATE/PIRATE.conf -e "s/rpcpassword=/rpcpassword=$PASS_WALLET/g"

# navigate to home folder to ensure consistent installs
cd ~

# install nginx and mysql-server
sudo apt install nginx mysql-server -y

# setup mysql
sudo mysql_secure_installation -y

# root into mysql, create database 'piratepay' grant all to piratepay
mysql -u root -p $PASS_MYSQL << EOF
CREATE DATABASE piratepay DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON piratepay.* TO 'piratepay'@'localhost' IDENTIFIED BY '$PASS_MYSQL';
FLUSH PRIVILEGES;
QUIT;
EOF

# add php specific ppa
sudo add-apt-repository ppa:ondrej/php

# install php
sudo apt-get install php7.3 php7.3-fpm php7.3-mysql php7.3-mbstring php7.3-imagick php7.3-xml php7.3-bcmath php7.3-intl php7.3-zip -y

# setting fix
sudo sed -i /etc/php/7.3/fpm/php.ini -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g'

# add php to system boot
sudo systemctl restart php7.3-fpm

# download custom nginx config file from github
wget https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/default -P /home/$USER

# delete previous nginx config
sudo rm -f /etc/nginx/sites-available/default

# move our config file in nginx config
sudo mv default /etc/nginx/sites-available/default

# install Redis and Supervisor
sudo apt-get install git redis-server supervisor -y

# add password auth to Redis
sudo sed -i /etc/redis/redis.conf -e "s/# requirepass foobared/requirepass $PASS_REDIS/g"

# navigate to home folder to ensure consistent installs
cd ~

# download composer
curl -sS https://getcomposer.org/installer | php

# move composer in system binaries
sudo mv composer.phar /usr/local/bin/composer

# move into /var/www
cd /var/www

# git clone PiratePay
sudo git clone https://github.com/CryptocurrencyCheckout/PiratePay.git

# move into PiratePay
cd PiratePay

# replace user with local user
sudo sed -i horizon.conf -e "s/user=ubuntu/user=$USER/g"

# move horizon.conf to Supervisor folder
sudo mv horizon.conf /etc/supervisor/conf.d/horizon.conf

# reload, update & start Supervisor
sudo supervisorctl reread && sudo supervisorctl update && sudo supervisorctl start horizon

# changing some permissions
sudo chown -R www-data:ubuntu /var/www/PiratePay
sudo find /var/www/PiratePay -type f -exec chmod 664 {} \;
sudo find /var/www/PiratePay -type d -exec chmod 775 {} \;

# install our stack with composer
composer install --no-dev

# create .env file from .env.example
cp .env.example .env

# replace respectives occurences 
sed -i "5i APP_URL=$APP_URL" .env
sed -i "10i PIRATE_PASSWORD=$PASS_WALLET" .env
sed -i "23i DB_PASSWORD=$PASS_MYSQL" .env
sed -i "32i REDIS_PASSWORD=$PASS_REDIS" .env

# migrate database & generate encryption keys
php artisan migrate && php artisan key:generate && php artisan passport:install --length=512 --force

# reboot system
sudo reboot