## Tezos Daemon Install

Follow these instructions to quickly and easilly setup a working tezos-node with minimal bootstrapping time. We utilize the QuckSync script by TzDutch to speed this up. Once installed, you can utilise the tezos-client commands via tezd client.

We have also included a proxy server in nodejs. This setup is perfect to run remote nodes. Currently, baking can be done but it is not handled by the tezd script.

**Easy one-liner**
```
sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-full.sh)"
```
This command will update your distro, install tezd, tzproxy and add both scripts to run on boot. Otherwise you can manually run commands below.

**Update distro - currently only Ubuntu 16.04 is supported, but we are looking to expand this**
```
sudo apt-get update && apt-get dist-upgrade -y
```

**Install tezd**
```
sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)"
```
Note: This can take approx. 40 minutes depending on your connection speed. There may be a couple of prompts on screen during the first 10 minutes.

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
sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-proxy-install.sh)"
```

**You can add the scripts to your crontab to start on boot**
```
(crontab -l ; echo "@reboot tezd start") | crontab 
(crontab -l ; echo "@reboot sh $HOME/tzproxy/start.sh") | crontab 
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
## Credits
- Shaun Belcher for his [Fast Build script](https://medium.com/@shaunbelcher/building-tezos-on-ubuntu-fast-build-b2397bf01678)
- Fred Yankowski for his [work on setting up nodes](https://github.com/tezoscommunity/FAQ/blob/master/Compile_Mainnet.md)
- TZDutch for their [QuickSync script](https://www.tzdutch.com/quicksync/)
