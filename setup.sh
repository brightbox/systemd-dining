#!/bin/sh
set -e
APT_GET="DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 apt-get -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef -y"

echo "Adding required packages"
eval ${APT_GET} update
eval ${APT_GET} upgrade
eval ${APT_GET} install sendmail mailutils systemd-container finger inotify-tools

echo "Installing simulation"
install bin/* /usr/local/bin
install sbin/* /usr/local/sbin
install -m 644 user/* /etc/systemd/user
install -m 644 skel/.forward -T /etc/skel/.forward
mkdir -p /etc/skel/.config/systemd/user/default.target.wants
ln -sf /etc/systemd/user/select-seat.path /etc/systemd/user/select-seat.service /etc/skel/.config/systemd/user/default.target.wants

echo "Adding Philosophers group"
getent group philosophers > /dev/null || addgroup philosophers
