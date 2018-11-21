#!/bin/bash
echo "Running TezTech Tezos Daemon (tezd)..."
mkdir tezd
cd tezd
current_dir=$PWD
echo $PWD

echo "Building Tezos Core..."
if ! grep -q "^deb .*ansible/bubblewrap" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	echo "Installing bubblewrap PPA..."
	echo -e "\n" | sudo add-apt-repository ppa:ansible/bubblewrap
fi
if ! grep -q "^deb .*git-core/ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	echo "Installing git-core PPA..."
	echo -e "\n" | sudo add-apt-repository ppa:git-core/ppa
fi
echo "Installing deps..."
sudo apt-get update
sudo apt-get install -y wget liblz4-tool patch unzip make gcc m4 git g++ aspcud bubblewrap curl bzip2 rsync libev-dev libgmp-dev pkg-con$
echo "Installing opam..."
wget https://github.com/ocaml/opam/releases/download/2.0.0/opam-2.0.0-x86_64-linux
sudo mv opam-2.0.0-x86_64-linux /usr/local/bin/opam
sudo chmod a+x /usr/local/bin/opam
yes | opam init --compiler=4.06.1
eval $(opam env)

echo "Installing tezos..."
git clone -b mainnet https://gitlab.com/tezos/tezos.git
cd tezos

echo "Getting build deps..."
make build-deps
eval $(opam env)
echo "Making..."
make
cd $current_dir
echo "Tezos Core built!"

echo "Building TZProxy..."
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
sudo npm install -g forever
git clone -b master https://github.com/TezTech/tzproxy.git
cd tzproxy
npm install
cd $current_dir
echo "TZProxy built!"

echo "Building scripts..."
mkdir scripts
cd scripts
cat > run.sh << EOF
#!/bin/bash
echo "Running tzProxy...\n"
if [ ! -f "$current_dir/.tezos-node/config.json" ]; then echo "Creating config..."; $current_dir/tezos/tezos-node config init --rpc-addr 127.0.0.1:8732; fi
if [ ! -f "$current_dir/.tezos-node/identity.json" ]; then $current_dir/tezos/tezos-node identity generate 26.; fi
echo "Starting node..."
nohup $current_dir/tezos/tezos-node run > $current_dir/node.log &
echo "Starting proxy..."
forever -o $current_dir/proxy.log start $current_dir/proxy/index.js
EOF
cat > stop.sh << EOF
#!/bin/bash
echo "Stopping tzProxy...\n"
forever stopall
pkill -9 tezos-node
EOF
cat > restart.sh << EOF
#!/bin/bash
sh stop.sh
sh run.sh
EOF
cat > update.sh << EOF
#!/bin/bash
sh stop.sh
cd tezos && git checkout mainnet && git pull && eval $(opam env) && make && cd $current_dir
sh run.sh
EOF
cd $current_dir
echo "scripts built!"
echo "Downloading quicksync..."
mkdir .tezos-node
cd .tezos-node
wget http://quicksync.tzdutch.com/latest.tar.lz4
lz4 -d latest.tar.lz4 | tar xf -
cat > version.json << EOF
{ "version": "0.0.1" }
EOF
cd $current_dir
echo "quicksync done!"

cat > tezd.sh << EOF
#!/bin/bash
if test "$1" = 'stop'; then
	sh scripts/stop.sh
fi
if test "$1" = 'run';  then
	sh scripts/run.sh
fi
if test "$1" = 'restart'; then
	sh scripts/restart.sh
fi
if test "$1" = 'update'; then
	sh scripts/update.sh
fi
EOF
echo "tezd install successful!"

