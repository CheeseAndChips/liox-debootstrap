#!/bin/bash
set -e
if [ -d ./mnt ]
then
	umount -R ./mnt || true
	rmdir ./mnt
fi
losetup -D
