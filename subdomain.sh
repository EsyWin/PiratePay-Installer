#!/bin/bash
echo 'enter your https://subdomain.domain.com address for piratepay'
read DOMAIN_ADDRESS
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo sed sed -i "46i server_name $DOMAIN_ADDRESS" /etc/nginx/sites-enabled/default
sudo certbot --nginx
sudo certbot renew --dry-run
sudo sed -i "5i APP_URL=$DOMAIN_ADDRESS" /var/www/PiratePay/.env