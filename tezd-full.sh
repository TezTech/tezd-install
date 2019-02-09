#!/bin/bash
sudo apt-get update && apt-get dist-upgrade -y

sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)"
sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tzproxy/master/install.sh)"

(crontab -l ; echo "@reboot tezd start") | crontab
