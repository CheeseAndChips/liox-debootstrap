#!/bin/bash

set -e

BUILD_DIR="./mnt"
BUILD_IMAGE="./image.raw"
IMAGE_SIZE_MB=4096
ARCH="amd64"

if [ -d $BUILD_DIR ]
then
	echo "Directory \`$BUILD_DIR\` exists"
	exit 1
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

echo -n "Enter root password: "
read -s ROOT_PASSWD
echo ""

dd if=/dev/zero of=$BUILD_IMAGE bs=1M count=$IMAGE_SIZE_MB status=progress
mkdir $BUILD_DIR
parted image.raw mklabel msdos
echo -e '1M,+,L' | sudo sfdisk $BUILD_IMAGE

echo -e '1M,+,L' | sfdisk ./image.raw
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
cp ./chroot-script.sh $BUILD_DIR
UUID=$(lsblk -f $IMAGE_ROOTPART | tail -n 1 | tr -s " " | cut -d " " -f 4)
chroot $BUILD_DIR /bin/bash -c \
	"UUID="$UUID" \
	ROOT_PASSWD="$ROOT_PASSWD" \
	IMAGE_LODEVICE="$IMAGE_LODEVICE" \
	/bin/bash /chroot-script.sh"

umount -R $BUILD_DIR
losetup -D
rmdir $BUILD_DIR
