#!/bin/bash

set -e

HOSTNAME="lioxbox"
TIMEZONE="Europe/Vilnius"

printf "UUID=$UUID\t/\text4\terrors=remount-ro\t0 1" > /etc/fstab

apt -y install lsb-release
CODENAME=$(lsb_release --codename --short)
cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ $CODENAME main contrib non-free
deb-src https://deb.debian.org/debian/ $CODENAME main contrib non-free

deb https://security.debian.org/debian-security $CODENAME-security main contrib non-free
deb-src https://security.debian.org/debian-security $CODENAME-security main contrib non-free

deb https://deb.debian.org/debian/ $CODENAME-updates main contrib non-free
deb-src https://deb.debian.org/debian/ $CODENAME-updates main contrib non-free
EOF

apt -y update

rm /etc/localtime
echo $TIMEZONE > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt -y install locales
sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen
sed -i "s/# lt_LT.UTF-8/lt_LT.UTF-8/" /etc/locale.gen
locale-gen

echo $HOSTNAME > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1 localhost
127.0.1.1 $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

apt -y install linux-image-amd64 firmware-linux network-manager grub2

echo "root:$ROOT_PASSWD" | chpasswd

echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
update-grub
grub-install --root-directory / $IMAGE_LODEVICE
