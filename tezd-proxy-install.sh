#!/bin/bash
cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
sudo npm install -g forever
git clone -b master https://github.com/TezTech/tzproxy.git
cd tzproxy
npm install
cat > start.sh << EOF
#!/bin/bash
forever start $HOME/tzproxy/index.js
EOF
cd ~
sh ~/tzproxy/start.sh
exit
