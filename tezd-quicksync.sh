#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or using sudo!"
  exit
fi
HPATH=/usr/lib/tezd
	echo "Downloading quicksync..."
	mkdir $HPATH/.tezos-node
	cd $HPATH/.tezos-node
	cat > version.json << EOF
{ "version": "0.0.1" }
EOF

	wget http://quicksync.tzdutch.com/latest.tar.lz4
	lz4 -d latest.tar.lz4 | tar xf -
	rm -f latest.tar.lz4

	cd $HPATH
	chown -Rf tezd:tezd $HPATH/.tezos-node
