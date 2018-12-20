#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or using sudo!"
  exit
fi
HPATH=/usr/lib/tezd
echo "Installing TezTech Tezos Daemon (tezd)..."

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
su tezd -c "git clone -b alphanet https://gitlab.com/tezos/tezos.git"
sleep 5
cd $HPATH/tezos
su tezd -c "sh -c '$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/custom_install_build_deps.sh)' && eval \$(opam env) && make"
cd $HPATH

sh -c "$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-update-scripts.sh)"

if [ ! -d "$HPATH/.tezos-node" ]; then 
	mkdir $HPATH/.tezos-node
	cd $HPATH/.tezos-node
	cat > version.json << EOF
{ "version": "0.0.1" }
EOF
	cd $HPATH
	chown -Rf tezd:tezd $HPATH/.tezos-node
fi

tezd setup
echo "tezd install complete!"
