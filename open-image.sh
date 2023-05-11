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

mkdir $BUILD_DIR

IMAGE_LODEVICE=$(losetup -f $BUILD_IMAGE --partscan --show)
IMAGE_ROOTPART=${IMAGE_LODEVICE}p1
mount $IMAGE_ROOTPART $BUILD_DIR
mount --make-rslave --rbind /proc $BUILD_DIR/proc
mount --make-rslave --rbind /sys $BUILD_DIR/sys
mount --make-rslave --rbind /dev $BUILD_DIR/dev
mount --make-rslave --rbind /run $BUILD_DIR/run

set +e
chroot $BUILD_DIR /bin/bash -c "HOSTNAME=$HOSTNAME /bin/bash"
set -e

umount -R $BUILD_DIR
losetup -D
rmdir $BUILD_DIR
