#!/bin/sh
set -e
APT_GET="DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 apt-get -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y"

echo "Adding required packages"
eval ${APT_GET} update
eval ${APT_GET} upgrade
eval ${APT_GET} install systemd-container

echo "Installing simulation"
install bin/* /usr/local/bin
install sbin/* /usr/local/sbin
install -m 644 user/* /etc/systemd/user
