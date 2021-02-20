=#!/bin/bash
wget https://gpostrelov.ru/keys.zip
apt-get install unzip
unzip keys.zip -d /home/kestro_pos/
rm -r /root/.bee/keys
cp -r /home/kestro_pos/keys /root/.bee/keys
