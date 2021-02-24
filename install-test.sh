#!/bin/bash
#
# Скрипт установки Swarm Bee node
#
#
#
# thanks to root#2682

echo "
+----------------------------------------------------------------------
| Установка Swarm Bee  для CentOS/Ubuntu/Debian
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
cashlogPath='/root/bee-cash.log'
passPath='/root/bee-pass.txt'
swapEndpoint='https://goerli.prylabs.net'
cashScriptPath='/root/cashout.sh'
homedir=$HOME
externalIp=$(wget -O - -q icanhazip.com)


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
    echo "Ошибка: Вы должны быть {red}root{none}, чтобы запустить этот скрипт. (Введите: sudo su)"
    exit 1
fi

createSwarmService(){
    date "+【%Y-%m-%d %H:%M:%S】 Installing the Swarm Bee service" 2>&1 | tee -a $logPath
	if [ ! -f /etc/systemd/system/bee.service ]; then
	cat >> /etc/systemd/system/bee.service << EOE
[Unit]
Description=Bee Bzz Bzzzzz service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/local/bin/bee start --config ${homedir}/bee-default.yaml
[Install]
WantedBy=multi-user.target
EOE
echo 'Сервис уже установлен'
else date "+【%Y-%m-%d %H:%M:%S】 Сервис уже установлен" 2>&1 | tee -a $logPath
fi

systemctl daemon-reload
systemctl enable bee
systemctl start bee
}

getCashoutScript(){

if [ ! -f $cashScriptPath ]; then
date "+【%Y-%m-%d %H:%M:%S】 Установка скрипта для обналичивания чеков" 2>&1 | tee -a $logPath
echo 'Установка скрипта для обналичивания чеков';sleep 2

wget -O $cashScriptPath https://github.com/grodstrike/bee-swarm/raw/main/cashout.sh && chmod a+x $cashScriptPath
else
date "+【%Y-%m-%d %H:%M:%S】 '$cashScriptPath' Файл уже есть" 2>&1 | tee -a $logPath
fi

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "*/60 * * * * /bin/bash $cashScriptPath cashout-all >> $cashlogPath >/dev/null 2>&1" >> mycron
#install new cron file
crontab mycron
rm -f mycron
systemctl restart crond

}



createConfig(){
date "+【%Y-%m-%d %H:%M:%S】 Создание конфига" 2>&1 | tee -a $logPath
echo 'Создание конфига..'; sleep 2
if [ ! -f $homedir/bee-default.yaml ]; then
cat >> $homedir/bee-default.yaml << EOF
api-addr: :1633
bootnode:
- /dnsaddr/bootnode.ethswarm.org
clef-signer-enable: false
clef-signer-endpoint: ""
config: /root/.bee.yaml
cors-allowed-origins: []
data-dir: /root/.bee
db-capacity: "5000000"
debug-api-addr: :1635
debug-api-enable: true
gateway-mode: false
global-pinning-enable: false
help: false
nat-addr: "${externalIp}"
network-id: "1"
p2p-addr: :1634
p2p-quic-enable: false
p2p-ws-enable: false
password: ""
password-file: ${passPath}
payment-early: "1000000000000"
payment-threshold: "10000000000000"
payment-tolerance: "50000000000000"
resolver-options: []
standalone: false
swap-enable: true
swap-endpoint: ${swapEndpoint}
swap-factory-address: ""
swap-initial-deposit: "100000000000000000"
tracing-enable: false
tracing-endpoint: 127.0.0.1:6831
tracing-service-name: bee
verbosity: 3
welcome-message: "Hello from Russian Bees https://t.me/ru_swarm"
EOF
else date "+【%Y-%m-%d %H:%M:%S】 Конфиг файл уже создан" 2>&1 | tee -a $logPath
fi
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
curl -s https://raw.githubusercontent.com/ethersphere/bee/master/install.sh | TAG=v0.5.0 bash

echo 'Установка Bee Clef..'; sleep 2

date "+【%Y-%m-%d %H:%M:%S】 Установка Bee Clef" 2>&1 | tee -a /root/run.log
wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb && dpkg -i bee-clef_0.4.7_amd64.deb

wget https://github.com/doristeo/SwarmBeeBzzz/raw/main/local-dash.sh
chmod +x local-dash.sh



createConfig
getCashoutScript
createSwarmService

echo ''
echo "
+----------------------------------------------------------------------"
echo -e "\e[42mУстановка завершена!\e[0m"; echo ''; echo 'Пароль вашей ноды:' && cat $passPath && echo '' && echo 'Хранится по пути: '; echo $passPath
echo "
+----------------------------------------------------------------------"
echo ''
echo -e 'Запущена ли нода? Проверьте командой \e[42msystemctl status bee\e[0m'
echo -e 'Показать логи \e[42mjournalctl -f -u bee\e[0m'
sleep 10
address="0x`cat ~/.bee/keys/swarm.key | jq '.address'|sed 's/\"//g'`" && echo "Ваш кошелек ноды:" && echo ${address}
echo "
+----------------------------------------------------------------------"
echo -e " Далее вам нужно пополнить баланс кошелька тестовыми токенами. Переходим по ссылке https://discord.gg/r9sBAqnw , далее переходим в чат #faucet-request и вводим \e[42msprinkle ${address}\e[0m"
echo -e "Инструкция по пополнению токенами https://telegra.ph/gbzz-geth-02-22"
echo "
+----------------------------------------------------------------------"
echo ''

}

Install_Main