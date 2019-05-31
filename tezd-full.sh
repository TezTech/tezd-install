#!/bin/bash
sudo dpkg --configure -a
sudo apt-get update

sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)"
sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tzproxy/master/install.sh)"

(crontab -l ; echo "@reboot tezd start") | crontab
