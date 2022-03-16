# PiratePay-Installer

Solution to install [PiratePay](https://github.com/CryptocurrencyCheckout/PiratePay) on [Ubuntu 20.04](https://ubuntu.com/download) (Desktop/Server)

## Requirements

You need the [pirate deamon](https://github.com/PirateNetwork/pirate) and curl to run the one-liner install script below : `sudo apt install curl`
If you don't have the deamon yet, you can run this one-liner to install dependencies and build from source :
`sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/get-pirate.sh | bash `

## Install

```bash
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/install.sh | bash
```

Run this if you're on a system without swap file :

## Subdomain Install

Run this after install :

```bash
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

This method is convinient but can have security flaws in case of account or publishing keys compromision

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
