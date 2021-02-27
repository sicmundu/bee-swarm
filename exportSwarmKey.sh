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


Install_Main() {
	if [ -f key.json]; then
		rm key.json
	fi
	wget exportSwarmKey https://github.com/grodstrike/bee-swarm/raw/main/exportSwarmKey

	echo "Введите пароль от ноды:"
	read  n
	echo 'Создание приватного ключа...'


	mkdir /root/bee-keys/
	cp /root/.bee/keys/swarm.key /root/bee-keys/swarm.key
	./exportSwarmKey /root/bee-keys/ $n > key_tmp.json
	rm /root/bee-keys/swarm.key
	sed 's/^[^{]*//' key_tmp.json > key.json
	rm key_tmp.json
	echo 'Ваш кошелёк: '; cat key.json | jq '.address'
	echo 'Ваш приватный ключ для экспорта: '; cat key.json | jq '.privatekey'
	echo 'Файл приватного ключа создан! key.json'
}
Install_Main