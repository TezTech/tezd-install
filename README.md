## Tezos Daemon Install

**Update distro - currently only Ubuntu 16.04 is supported, but we are looking to expand this**
```
sudo apt-get update && apt-get dist-upgrade -y
```

**Install tezd**
```
sh <(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)
```

**You can also install and run a simple nodejs RPC server**
```
cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
sudo npm install -g forever
git clone -b master https://github.com/TezTech/tzproxy.git
cd tzproxy
npm install
forever start index.js
```

Or you can use the sh script
```
sh <(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-proxy-install.sh)
```

**You can add the scripts to your crontab to start on boot**
```
(crontab -l ; echo "@reboot tezd start") | crontab 
(crontab -l ; echo "@reboot forever ~/tzproxy/index.php start") | crontab 
```

**Commands**
```
#Start your node and configure your identity and setup if it's not setup already
tezd start

#Stop and restart
tezd stop
tezd restart

#Start clears out an existing identity and config, and runs tezd start
tezd setup

#Update your node to the latest commit of the current branch. Doesn't run make build-deps, so only works for small updates
tezd update

#Rebuild your node to the latest version. Use this if update fails
tezd rebuild

```
