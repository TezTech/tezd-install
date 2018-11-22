#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or using sudo!"
  exit
fi
HPATH=/usr/lib/tezd
echo "Running TezTech Tezos Daemon (tezd)..."

echo "Installing deps..."
if ! grep -q "^deb .*ansible/bubblewrap" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	echo "Installing bubblewrap PPA..."
	echo -e "\n" | sudo add-apt-repository ppa:ansible/bubblewrap
fi
if ! grep -q "^deb .*git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	echo "Installing git-core PPA..."
	echo -e "\n" | sudo add-apt-repository ppa:git-core/ppa
fi
sudo apt-get update
sudo apt-get install -y wget liblz4-tool patch unzip make gcc m4 git g++ aspcud bubblewrap curl bzip2 rsync libev-dev libgmp-dev pkg-config libhidapi-dev

echo "Installing opam..."
wget https://github.com/ocaml/opam/releases/download/2.0.0/opam-2.0.0-x86_64-linux
sudo mv opam-2.0.0-x86_64-linux /usr/local/bin/opam
sudo chmod a+x /usr/local/bin/opam

echo "Creating tezd user..."
useradd -r tezd --shell /bin/bash --home $HPATH -m
adduser tezd sudo

su tezd -c "opam init -y --compiler=4.06.1"
su tezd -c "eval \$(opam env)"
cd $HPATH

echo "Building tezos-core..."
su tezd -c "git clone -b mainnet https://gitlab.com/tezos/tezos.git"
sleep 5
cd $HPATH/tezos
su tezd -c "sh -c '$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/custom_install_build_deps.sh)' && eval \$(opam env) && make"
cd $HPATH

echo "Building scripts..."
mkdir $HPATH/scripts
cd $HPATH/scripts
cat > start.sh << EOF
#!/bin/bash
echo "Starting tezd...\n"
if [ ! -f "$HPATH/.tezos-node/config.json" ]; then 
	echo "Creating config..."
	PEERS=\$(curl -s 'http://api5.tzscan.io/v1/network?state=running&p=0&number=50' | grep -Po '::ffff:([0-9.:]+)' | sed ':a;N;\$!ba;s/\n/ /g' | sed 's/::ffff:/--peer=/g')
	su tezd -c "$HPATH/tezos/tezos-node config init --data-dir $HPATH/.tezos-node --rpc-addr 127.0.0.1:8732 \$PEERS"
fi
if [ ! -f "$HPATH/.tezos-node/identity.json" ]; then 
  su tezd -c "$HPATH/tezos/tezos-node identity generate 26. --data-dir $HPATH/.tezos-node"; 
    fi
echo "Starting node..."
su tezd -c "nohup $HPATH/tezos/tezos-node run > $HPATH/node.log &"
exit
EOF
cat > stop.sh << EOF
#!/bin/bash
echo "Stopping tezd...\n"
pkill -9 tezos-node
EOF
cat > restart.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
sh $HPATH/scripts/start.sh
EOF
cat > update.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
su tezd -c "cd $HPATH/tezos && git fetch && git rebase && eval \$(opam env) && make && cd $HPATH"
sh $HPATH/scripts/start.sh
EOF
cat > rebuild.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
cd $HPATH/tezos
su tezd -c 'sh -c "\$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-rebuild.sh)"'
su tezd -c "\$(opam env) && make build-deps && make"
sh $HPATH/scripts/start.sh
EOF
cat > setup.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
if [ -f "$HPATH/.tezos-node/config.json" ]; then rm -f "$HPATH/.tezos-node/config.json"; fi
if [ -f "$HPATH/.tezos-node/identity.json" ]; then rm -f "$HPATH/.tezos-node/identity.json"; fi
sh $HPATH/scripts/start.sh
EOF
cd $HPATH
cat > /bin/tezd << EOF
#!/bin/bash
if test "\$1" = 'stop'; then
	sh $HPATH/scripts/stop.sh
fi
if test "\$1" = 'start';  then
	sh $HPATH/scripts/start.sh
fi
if test "\$1" = 'restart'; then
	sh $HPATH/scripts/restart.sh
fi
if test "\$1" = 'update'; then
	sh $HPATH/scripts/update.sh
fi
if test "\$1" = 'rebuild'; then
	sh $HPATH/scripts/rebuild.sh
fi
if test "\$1" = 'setup'; then
	sh $HPATH/scripts/setup.sh
fi
if test "\$1" = 'client'; then
  su tezd -c "$HPATH/tezos/tezos-\$@"; 
fi
EOF


if [ ! -d "$HPATH/.tezos-node" ]; then 
	echo "Downloading quicksync..."
	mkdir $HPATH/.tezos-node
	cd $HPATH/.tezos-node
	wget http://quicksync.tzdutch.com/latest.tar.lz4
	lz4 -d latest.tar.lz4 | tar xf -
	cat > version.json << EOF
{ "version": "0.0.1" }
EOF
	cd $HPATH
fi

chmod a+rwx,g-w,o-w /bin/tezd
chown -Rf tezd:tezd $HPATH/.tezos-node
chown -Rf tezd:tezd $HPATH/scripts
chown -Rf tezd:tezd $HPATH/tezd.sh

tezd setup
echo "tezd install complete!"
