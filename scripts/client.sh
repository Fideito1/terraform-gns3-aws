#!/bin/bash

apt update -y
apt install -y dnsutils curl iputils-ping net-tools traceroute

echo "Cliente SRI desplegado correctamente" > /etc/motd