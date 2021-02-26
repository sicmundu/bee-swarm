#!/bin/bash
#
# This is tool for export private key from Swarm
#
#

echo "
+----------------------------------------------------------------------
| Export private key from Swarm for CentOS/Ubuntu/Debian
+----------------------------------------------------------------------
| Copyright © 2015-2021 All rights reserved.
+----------------------------------------------------------------------
| https://t.me/ru_swarm Russian offical Swarm Bee TG
+----------------------------------------------------------------------
";sleep 5
PM="apt-get"



if [ $(id -u) != "0" ]; then
    echo "You need to be rood to run this tool. (Type: sudo su)"
    exit 1
fi

# check os
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
	if [[ $(command -v yum) ]]; then
		PM="yum"
	fi
else
	echo -e "
	This scripts does not support your system.
	Note: Only support Ubuntu 16+ / Debian 8+ / CentOS 7+ system
	" && exit 1
fi

Install_Main() {
	wget https://golang.org/dl/go1.16.linux-amd64.tar.gz
	tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
	export PATH=$PATH:/usr/local/go/bin
	wget https://raw.githubusercontent.com/ethersphere/exportSwarmKey/master/pkg/main.go
	wget https://raw.githubusercontent.com/ethersphere/exportSwarmKey/master/go.mod
	wget https://raw.githubusercontent.com/ethersphere/exportSwarmKey/master/go.sum
	echo 'Версия Go: '; go version

}