#!/bin/bash

set -e

source config.sh

PATH=$PATH:/usr/sbin

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
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "lt_LT.UTF-8 UTF-8" >> /etc/locale.gen
echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
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

apt -y install linux-image-amd64 firmware-linux network-manager grub2 \
task-laptop \
plasma-desktop kwin-x11 sddm sddm-theme-breeze xserver-xorg \
dolphin konsole kwrite ark gwenview okular \
firefox-esr wget \
libreoffice-writer libreoffice-calc libreoffice-impress \
libreoffice-kf5 libreoffice-plasma \
xserver-xorg-video-all \
vim-gtk joe gedit scite geany geany-plugins codeblocks codeblocks-contrib \
kate \
zsh mc emacs nano git \
make gcc g++ gdb ddd valgrind \
python3 \
strace lsof tree curl dnsutils screen \
iotop tmux htop kpartx tsocks units mlocate \
bridge-utils bash-completion rfkill apt-file ntp locales \
iptables-persistent \
localepurge \
gdb-doc manpages \
python3-requests \
kcalc apt-transport-https

mkdir -p /etc/apt/trusted.gpg.d/
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/ms-vscode-keyring.gpg
apt -y update
apt -y install sublime-text code

useradd -m -s /bin/bash -p ${D0_PWD_HASH} d0
useradd -m -s /bin/bash -p ${D1_PWD_HASH} d1
useradd -m -s /bin/bash -p ${D2_PWD_HASH} d2
useradd -m -s /bin/bash -p ${LIOADMIN_PWD_HASH} lioadmin
usermod -a -G sudo lioadmin

echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
update-grub
grub-install --root-directory / $IMAGE_LODEVICE
