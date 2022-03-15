#!/bin/bash
sudo apt update && sudo apt upgrade -y
# installing system monitoring utility
sudo apt-get install htop libgomp1
# allocate 2G to /swapfile mountpoint
sudo fallocate -l 2G /swapfile
# give user read/write but can't execute
sudo chmod 600 /swapfile
# /swapfile as swap partition
sudo mkswap /swapfile
# enable swap
sudo swapon /swapfile
# backup fstab
sudo cp /etc/fstab /etc/fstab.bak
# make changes permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# restart
sudo reboot