HPATH=/usr/lib/tezd
echo "Updating scripts..."
rm -rf $HPATH/scripts 
rm -f /bin/tezd
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
su tezd -c "cd $HPATH/tezos && git fetch && git rebase && eval \\\$(opam env) && make && cd $HPATH"
sh $HPATH/scripts/start.sh
EOF
cat > rebuild.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
cd $HPATH/tezos
su tezd -c 'sh -c "\$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-rebuild.sh)"'
su tezd -c "eval \\\$(opam env) && sh -c '\$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/custom_install_build_deps.sh)'  && make"
sh $HPATH/scripts/start.sh
EOF
cat > setup.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
if [ -f "$HPATH/.tezos-node/config.json" ]; then rm -f "$HPATH/.tezos-node/config.json"; fi
if [ -f "$HPATH/.tezos-node/identity.json" ]; then rm -f "$HPATH/.tezos-node/identity.json"; fi
sh $HPATH/scripts/start.sh
EOF
cat > update_scripts.sh << EOF
#!/bin/bash
sh $HPATH/scripts/stop.sh
sh -c "\$(curl -sL https://raw.githubusercontent.com/TezTech/tezd-install/master/tezd-update-scripts.sh)"
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
if test "\$1" = 'update_scripts'; then
	sh $HPATH/scripts/update_scripts.sh
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

chmod a+rwx,g-w,o-w /bin/tezd
chown -Rf tezd:tezd $HPATH/scripts
tezd start
