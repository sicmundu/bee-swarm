#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Ошибка: Вы должны быть root, чтобы запустить этот скрипт. (Введите: sudo su)"
    exit 1
fi


homedir=$HOME
passdir='/root/bee-pass.txt'

if [ ! -f $passdir ]; then
	date "+【%Y-%m-%d %H:%M:%S】 Генерация /root/bee-pass.txt" 2>&1 | tee -a /root/run.log
	echo "Введите пароль для ноды (он будет хранится тут $passdir):"
	read  n
	echo  $n > $passdir;
	date "+【%Y-%m-%d %H:%M:%S】 Ваш пароль от ноды: " && cat $passdir  2>&1 | tee -a /root/run.log
fi

echo 'Установка пакетов'

date "+【%Y-%m-%d %H:%M:%S】 Установка пакетов" 2>&1 | tee -a /root/run.log
sudo apt-get update
sudo apt -y install curl wget tmux jq

echo 'Установка Swarm Bee'

date "+【%Y-%m-%d %H:%M:%S】 Установка Swarm Bee" 2>&1 | tee -a /root/run.log
curl -s https://raw.githubusercontent.com/ethersphere/bee/master/install.sh | TAG=v0.5.0 bash

echo 'Установка Bee Clef'

date "+【%Y-%m-%d %H:%M:%S】 Установка Bee Clef" 2>&1 | tee -a /root/run.log
wget https://github.com/ethersphere/bee-clef/releases/download/v0.4.7/bee-clef_0.4.7_amd64.deb && dpkg -i bee-clef_0.4.7_amd64.deb

echo 'Создание конфига'

date "+【%Y-%m-%d %H:%M:%S】 Создание конфига" 2>&1 | tee -a /root/run.log
echo "api-addr: :1633
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
nat-addr: ""
network-id: "1"
p2p-addr: :1634
p2p-quic-enable: false
p2p-ws-enable: false
password: ""
password-file: "/root/bee-pass.txt"
payment-early: "1000000000000"
payment-threshold: "10000000000000"
payment-tolerance: "50000000000000"
resolver-options: []
standalone: false
swap-enable: true
swap-endpoint: https://goerli.prylabs.net
swap-factory-address: ""
swap-initial-deposit: "100000000000000000"
tracing-enable: false
tracing-endpoint: 127.0.0.1:6831
tracing-service-name: bee
verbosity: 1
welcome-message: ""
" >> $homedir/bee-default.yaml

echo 'Установка скрипта для обналичивания чеков'
date "+【%Y-%m-%d %H:%M:%S】 'Установка скрипта для обналичивания чеков" 2>&1 | tee -a /root/run.log
wget https://github.com/grodstrike/bee-swarm/raw/main/cashout.sh && cp cashout.sh /root/cashout.sh
sudo chmod 777 /root/cashout.sh
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 * * * * /bin/bash /root/cashout.sh cashout-all >> /root/cash.log >/dev/null 2>&1" >> mycron
#install new cron file
crontab mycron
rm mycron
sudo systemctl restart cron

date "+【%Y-%m-%d %H:%M:%S】 'Установка сервиса Swarm Bee" 2>&1 | tee -a /root/run.log
echo "
[Unit]
Description=Bee Bzz Bzzzzz service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=60
User=root
ExecStart=/usr/local/bin/bee start --config $homedir/bee-default.yaml
[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/bee.service
systemctl daemon-reload
systemctl enable bee
systemctl start bee

echo ''
echo -e "\e[42mУстановка завершена!\e[0m"; echo ''; echo 'Ваш пароль от ноды:' && cat $passdir && echo '' && echo 'Хранится по пути: $passdir'
echo 'Пополните токенами по инструкции https://telegra.ph/gbzz-geth-02-22'
echo ''
echo -e 'Запущена ли нода? Проверьте командой \e[42msystemctl status bee\e[0m'
echo ''

