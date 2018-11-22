## Tezos Daemon Install

**Update distro**
```
sudo apt-get update && apt-get dist-upgrade -y
```

**Install**
```
sudo sh <(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)
```

**Run**
```
sh tezd.sh run
```

**You can also install and run a simple nodejs RPC server**
```
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
sudo npm install -g forever
git clone -b master https://github.com/TezTech/tzproxy.git
cd tzproxy
npm install
forever start index.js
```

**Notes - only works on ubuntu for now**
