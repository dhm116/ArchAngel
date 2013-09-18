#!/bin/bash

nodeVersion="0.10.18"

echo "Installing dependencies"
sudo apt-get update -qq && apt-get install -qq g++ postgresql git redis-server

echo "Checking if NodeJS v$nodeVersion is installed"
n=$(node --version 2>/dev/null)
if [ "$n" != "v$nodeVersion" ]; then
	echo "Downloading NodeJS v$nodeVersion"
	wget http://nodejs.org/dist/v0.10.18/node-v$nodeVersion.tar.gz
	tar xvf node-v$nodeVersion.tar.gz

	echo "Building and installing NodeJS"
	cd node-v$nodeVersion && ./configure && make && sudo make install

	echo "Installing global node modules"
	sudo npm install -g coffee-script
	sudo npm install -g express
	sudo npm install -g brunch
	sudo npm install -g mocha
fi
echo "All done"