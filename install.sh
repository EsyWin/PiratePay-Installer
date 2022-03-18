#!/bin/bash
cd ~
sudo add-apt-repository ppa:ondrej/php
sudo apt update 
sudo apt upgrade -y
sudo apt install screen wget openssl redis-server supervisor nginx mysql-server php7.3 php7.3-fpm php7.3-mysql php7.3-mbstring php7.3-imagick php7.3-xml php7.3-bcmath php7.3-intl php7.3-zip -y
PASS_WALLET=$(openssl rand 60 | openssl base64 -A)
PASS_MYSQL=$(openssl rand 60 | openssl base64 -A)
PASS_REDIS=$(openssl rand 60 | openssl base64 -A)
# create *.sql mysql_secure_installation
cat << EOF > mysql_secure_installation.sql
UPDATE mysql.user SET Password=PASSWORD('${PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
# install
sudo mysql -sfu root < "mysql_secure_installation.sql"
# create piratepay database with auth root
sudo mysql -u root << EOF
CREATE DATABASE piratepay DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON piratepay.* TO 'piratepay'@'localhost' IDENTIFIED BY '${PASS_MYSQL}';
FLUSH PRIVILEGES;
QUIT;
EOF

sed -i "2i rpcpassword=$PASS_WALLET" /home/$USER/.komodo/PIRATE/PIRATE.conf
sed -i "1i rpcuser=piratepay" /home/$USER/.komodo/PIRATE/PIRATE.conf
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini 
sudo systemctl restart php7.3-fpm
wget https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/default -P /home/$USER
sudo rm -f /etc/nginx/sites-available/default
sudo mv default /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx
sudo sed -i 's/# requirepass foobared/requirepass $PASS_REDIS/g' /etc/redis/redis.conf 
sudo systemctl restart redis.service
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
cd /var/www
sudo git clone https://github.com/CryptocurrencyCheckout/PiratePay.git
cd PiratePay
sudo cp .env.example .env
sudo sed -i 's/APP_URL=YOUR WEBSITE IP OR URL <-----/APP_URL=localhost/g' .env
sudo sed -i 's/PIRATE_PASSWORD= YOUR PIRATE RPC PASSWORD <-----/PIRATE_PASSWORD=$PASS_WALLET/g' .env
sudo sed -i 's/DB_PASSWORD= YOUR MYSQL PASSWORD <-----/DB_PASSWORD=$PASS_MYSQL/g' .env
sudo sed -i 's/REDIS_PASSWORD=YOUR REDIS PASSWORD <-----/REDIS_PASSWORD=$PASS_REDIS/g' .env
sudo sed -i 's/user=ubuntu/user=$USER/g' horizon.conf
sudo mv horizon.conf /etc/supervisor/conf.d/horizon.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start horizon
sudo chown -R www-data:$USER /var/www/PiratePay
sudo find /var/www/PiratePay -type f -exec chmod 664 {} \;
sudo find /var/www/PiratePay -type d -exec chmod 775 {} \;
composer install --no-dev
php artisan migrate && php artisan key:generate && php artisan passport:install --length=512 --force
