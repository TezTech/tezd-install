#!/bin/bash
cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
sudo npm install -g forever
git clone -b master https://github.com/TezTech/tzproxy.git
cd tzproxy
npm install
forever start index.js
