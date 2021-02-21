#!/bin/bash
wget https://github.com/grodstrike/bee-admin/raw/main/cashout.sh ~/cashout.sh

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 */6 * * * /bin/bash ~/cashout.sh cashout-all » ~/cash.log   2>&1 " >> mycron
#install new cron file
crontab mycron
rm mycron
