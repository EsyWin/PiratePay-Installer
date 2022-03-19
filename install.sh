#!/bin/bash
pirate=$USER
sudo -i
echo 'Change root password :'
read rootpassword;
{
    $root_password;
    $root_password;
} | passwd root
cd ~
add-apt-repository ppa:ondrej/php
apt update 
apt upgrade -y
apt install wget openssl redis-server supervisor nginx mysql-server php7.3 php7.3-fpm php7.3-mysql php7.3-mbstring php7.3-imagick php7.3-xml php7.3-bcmath php7.3-intl php7.3-zip -y
PASS_WALLET=$(openssl rand 60 | openssl base64 -A)
PASS_MYSQL=$(openssl rand 60 | openssl base64 -A)
PASS_REDIS=$(openssl rand 60 | openssl base64 -A)
# install mysql
mysql_secure_installation --use-default
# create piratepay database with auth root
mysql -u root<< EOF
CREATE DATABASE piratepay DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON piratepay.* TO 'piratepay'@'localhost' IDENTIFIED BY '${PASS_MYSQL}';
FLUSH PRIVILEGES;
QUIT;
EOF
# replace config
sed -i "2i rpcpassword=$PASS_WALLET" /home/$pirate/.komodo/PIRATE/PIRATE.conf
sed -i "1i rpcuser=$pirate" /home/$pirate/.komodo/PIRATE/PIRATE.conf
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini
# restart php-fpm
systemctl restart php7.3-fpm
# download nginx config file
wget https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/default -P /home/$pirate
# remove original nginx config
rm -f /etc/nginx/sites-available/default
# replace nginx config
mv default /etc/nginx/sites-available/default
# check config
nginx -t
# reload nginx
systemctl reload nginx
# replace redis config to require a password randomly generated
sed -i 's/# requirepass foobared/requirepass $PASS_REDIS/g' /etc/redis/redis.conf
# restart redis
systemctl restart redis.service
cd ~
# install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
cd /var/www
# install piratepay
git clone https://github.com/CryptocurrencyCheckout/PiratePay.git
cd PiratePay
cp .env.example .env
sed -i 's/APP_URL=YOUR WEBSITE IP OR URL <-----/APP_URL=localhost/g' .env
sed -i 's/PIRATE_PASSWORD= YOUR PIRATE RPC PASSWORD <-----/PIRATE_PASSWORD=$PASS_WALLET/g' .env
sed -i 's/DB_PASSWORD= YOUR MYSQL PASSWORD <-----/DB_PASSWORD=$PASS_MYSQL/g' .env
sed -i 's/REDIS_PASSWORD=YOUR REDIS PASSWORD <-----/REDIS_PASSWORD=$PASS_REDIS/g' .env
# update supervisor config
sed -i 's/user=ubuntu/user=$USER/g' horizon.conf
mv horizon.conf /etc/supervisor/conf.d/horizon.conf
supervisorctl reread
supervisorctl update
supervisorctl start horizon
chown -R www-data:$pirate /var/www/PiratePay
find /var/www/PiratePay -type f -exec chmod 664 {} \;
find /var/www/PiratePay -type d -exec chmod 775 {} \;
composer install --no-dev
php artisan migrate
php artisan key:generate
php artisan passport:install --length=512 --force
