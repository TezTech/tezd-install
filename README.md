## Tezos Daemon Install

**Update distro**
```
sudo apt-get update
sudo apt-get dist-upgrade -y
```

**Create admin account**
```
adduser tezos
adduser tezos sudo
su - tezos
```

**Install**
```
sh <(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-install.sh)
```

**Run**
```
sh tezd.sh run
```

**Notes - only works on ubuntu for now**
