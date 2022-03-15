# PiratePay-Installer

Solution to install [PiratePay](https://github.com/CryptocurrencyCheckout/PiratePay) on [Ubuntu 20.04](https://ubuntu.com/download) (Desktop/Server)

## Usage

Basic install assuming you already have the Pirate deamon :

```bash
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/install.sh | bash
```

Run this to build the Pirate deamon from source, download bootstrap and sync :

```bash
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/get-pirate.sh | bash
```

Run this if you're on a system without swap file :

```bash
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/create-swap.sh | bash
```

Run this to install on your website subdomain after Basic install

```bash
sudo curl -sSf https://raw.githubusercontent.com/EsyWin/PiratePay-Installer/main/subdomain.sh | bash
```

You'll be prompted to enter your https://subdomain.website.com **including https://**

Add the following "A" record to your DNS configuration :

```
Type: A

Name: piratepay.mywebsite.com

Content: [your public ip]

TTL: Auto
```

## Security note

This method is convinient but can have security flaws in case of account or publishing keys compromision

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
