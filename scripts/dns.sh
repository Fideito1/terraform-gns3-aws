#!/bin/bash

apt update -y
apt install -y bind9 bind9utils dnsutils

systemctl enable bind9
systemctl start bind9

echo "Servidor DNS SRI desplegado correctamente" > /etc/motd