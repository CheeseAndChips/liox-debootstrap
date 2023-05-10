#!/bin/bash

set -e

if [ -d ./mnt ]
then
	umount -R ./mnt
fi
losetup -D
rm -rf image.raw ./mnt
