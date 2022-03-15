#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool libncurses-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqrencode-dev libdb++-dev ntp ntpdate nano software-properties-common curl libevent-dev libcurl4-gnutls-dev cmake clang libsodium-dev -y
cd ~
git clone https://github.com/PirateNetwork/pirate --branch master
cd pirate
./zcutil/fetch-params.sh
./zcutil/build.sh -j$(nproc - 1)
./pirated -bootstrap=2