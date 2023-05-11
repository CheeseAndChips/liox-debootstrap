#!/bin/bash

set -e

if [ $(id -u) -ne 0 ]
then
	echo "Script must be run as root"
	exit 1
fi

source config.sh

if [ -d $BUILD_DIR ]
then
	echo "Directory \`$BUILD_DIR\` exists"
	exit 1
fi

if [ ! -d $CACHE_DIR ]
then
	mkdir $CACHE_DIR
fi

if [ -f $BUILD_IMAGE ]
then
	read -p "Image \`$BUILD_IMAGE\` already exists. Rebuild? [y/N] " prompt
	if [[ $prompt != "y" && $prompt != "Y" ]]
	then
		echo "Aborting..."
		exit 2
	fi
fi

echo -n "Enter lioadmin user "
LIOADMIN_PWD_HASH=$(mkpasswd -m sha-512)

echo -n "Enter d0 user "
D0_PWD_HASH=$(mkpasswd -m sha-512)

echo -n "Enter d1 user "
D1_PWD_HASH=$(mkpasswd -m sha-512)

echo -n "Enter d2 user "
D2_PWD_HASH=$(mkpasswd -m sha-512)

dd if=/dev/zero of=$BUILD_IMAGE bs=1M count=$IMAGE_SIZE_MB status=progress
mkdir $BUILD_DIR
parted image.raw mklabel msdos
echo -e '1M,+,L' | sfdisk $BUILD_IMAGE
IMAGE_LODEVICE=$(losetup -f $BUILD_IMAGE --partscan --show)
IMAGE_ROOTPART=${IMAGE_LODEVICE}p1
echo "Image device $IMAGE_LODEVICE"
mkfs.ext4 $IMAGE_ROOTPART

mount $IMAGE_ROOTPART $BUILD_DIR
debootstrap --cache-dir=$(realpath "./cache") --arch $ARCH stable $BUILD_DIR https://deb.debian.org/debian

mount --make-rslave --rbind /proc $BUILD_DIR/proc
mount --make-rslave --rbind /sys $BUILD_DIR/sys
mount --make-rslave --rbind /dev $BUILD_DIR/dev
mount --make-rslave --rbind /run $BUILD_DIR/run
cp ./chroot-script.sh ./config.sh $BUILD_DIR
cp -r ./includes.chroot/* $BUILD_DIR
UUID=$(lsblk -f $IMAGE_ROOTPART | tail -n 1 | tr -s " " | cut -d " " -f 4)
chroot $BUILD_DIR /bin/bash -c \
	"UUID="$UUID" \
	D0_PWD_HASH="${D0_PWD_HASH}" \
	D1_PWD_HASH="${D1_PWD_HASH}" \
	D2_PWD_HASH="${D2_PWD_HASH}" \
	LIOADMIN_PWD_HASH="${LIOADMIN_PWD_HASH}" \
	IMAGE_LODEVICE="$IMAGE_LODEVICE" \
	/bin/bash /chroot-script.sh"

umount -R $BUILD_DIR
losetup -D
rmdir $BUILD_DIR
