# PiratePay-Installer

Solution to install [PiratePay](https://github.com/CryptocurrencyCheckout/PiratePay) on [Ubuntu 20.04](https://ubuntu.com/download) (Desktop/Server)

## Requirements

You need the [pirate deamon](https://github.com/PirateNetwork/pirate) and curl to run the one-liner install script below : `sudo apt install curl`
If you don't have the deamon yet, you can run this one-liner to install dependencies and build from source :

```shell
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/get-pirate.sh | bash
```

## Install

```shell
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/install.sh | bash
```

## Subdomain Install

Run this after install :

```shell
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/subdomain.sh | bash
```

You'll be prompted to enter your `https://subdomain.website.com` **including https://**

Add the following "A" record to your DNS configuration :

```
Type: A

Name: piratepay.mywebsite.com

Content: [your public ip]

TTL: Auto
```

This should work out of the box for **VPS**, but if you host this at home, you might need to forward ports through your network router, and you may need a 3rd party service like [DynDNS](https://account.dyn.com/) or [No-IP](https://www.noip.com/) to get a static IP for your device.

## Security note

This install method is convinient but can have severe security issues in case of maintainter account or publishing keys compromision.
Installing \*.deb package is much safer, might eventually get done once I have this app working.

## License

Software is distributed under [MIT License](https://mit-license.org/) see [LICENCE.md](https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/LICENCE.md) for more information.
