#!/bin/bash
#
# Скрипт установки Swarm Bee node
#
#
#
# 

echo "
+----------------------------------------------------------------------
| Установка Swarm Bee  для Ubuntu/Debian 1.0.0
+----------------------------------------------------------------------
| Copyright © 2015-2021 All rights reserved.
+----------------------------------------------------------------------
| https://t.me/ru_swarm Russian offical Swarm Bee TG
+----------------------------------------------------------------------
";sleep 5

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=ru_RU.UTF-8


# пути к осноаным файлам
logPath='/root/bee-run.log'
cashlogPath='/root/cash.log'
passPath='/root/bee-pass.txt'
swapEndpoint='https://rpc.slock.it/goerli'
cashScriptPath='/root/cashout.sh'
homedir=$HOME
externalIp=$(curl -4 ifconfig.io)



red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

if [ $(id -u) != "0" ]; then
    echo "Ошибка: Вы должны быть root, чтобы запустить этот скрипт. (Введите: sudo su)"
    exit 1
fi

# Функция установки Bee в сервис
createSwarmService(){
    date "+【%Y-%m-%d %H:%M:%S】 Installing the Swarm Bee service" 2>&1 | tee -a $logPath
	if [ ! -f /etc/systemd/system/bee.service ]; then
	cat >> /etc/systemd/system/bee.service << EOF
[Unit]
Description=Bee Bzz Bzzzzz service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/bin/bee start --config /etc/bee/bee.yaml
StandardOutput=append:/var/log/bee.log
StandartError=append:/var/log/bee-err.log
[Install]
WantedBy=multi-user.target
EOF
echo 'Сервис уже установлен'
else date "+【%Y-%m-%d %H:%M:%S】 Сервис уже установлен" 2>&1 | tee -a $logPath
fi

# Перезапуск сервисов
systemctl daemon-reload

# Добавление ноды в автозапуск
systemctl enable bee

# Запуск ноды
systemctl start bee
}





createConfig(){
date "+【%Y-%m-%d %H:%M:%S】 Создание конфига" 2>&1 | tee -a $logPath
echo 'Создание конфига..'; sleep 2
cat >> /etc/bee/bee.yaml << EOF
api-addr: :1633
clef-signer-enable: false
config: /root/bee-default.yaml
data-dir: /var/lib/bee
db-capacity: "5000000"
db-open-files-limit: 500
debug-api-addr: :1635
full-node: true
mainnet: true
debug-api-enable: true
gateway-mode: false
global-pinning-enable: false
help: false
nat-addr: "${externalIp}:1634"
network-id: "1"
password: ""
password-file: ${passPath}
swap-enable: true
swap-endpoint: ${swapEndpoint}
swap-initial-deposit: "0"

verbosity: info
welcome-message: "Hello from Russian Bees https://t.me/ru_swarm"
EOF

}

function Install_Main() {
if [ ! -f $passPath ]; then
date "+【%Y-%m-%d %H:%M:%S】 Генерация /root/bee-pass.txt" 2>&1 | tee -a /root/run.log
echo "Введите пароль для ноды (он будет хранится тут $passPath):"
read  n
echo  $n > $passPath;
date "+【%Y-%m-%d %H:%M:%S】 Ваш пароль от ноды: " && cat $passPath  2>&1 | tee -a /root/run.log
fi

echo 'Установка пакетов...'; sleep 2

date "+【%Y-%m-%d %H:%M:%S】 Установка пакетов" 2>&1 | tee -a /root/run.log
sudo apt-get update
sudo apt -y install curl wget tmux jq

echo 'Установка Swarm Bee..'; sleep 2
date "+【%Y-%m-%d %H:%M:%S】 Установка Swarm Bee" 2>&1 | tee -a /root/run.log
wget https://github.com/ethersphere/bee/releases/download/v1.0.0/bee_1.0.0_amd64.deb
sudo dpkg -i bee_1.0.0_amd64.deb


createConfig
createSwarmService

echo ''
echo "
+----------------------------------------------------------------------"
echo -e "\e[42mУстановка завершена!\e[0m"; echo ''; echo 'Пароль вашей ноды:' && cat $passPath && echo '' && echo 'Хранится по пути: '; echo $passPath
echo "
+----------------------------------------------------------------------"


}

Install_Main
