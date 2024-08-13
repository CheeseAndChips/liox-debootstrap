#!/bin/bash

set -e

HOSTNAME="lioxbox"
TIMEZONE="Europe/Vilnius"
BUILD_DIR="./mnt"
BUILD_IMAGE="./liox_tmp/image.raw"
IMAGE_SIZE_MB=8192
ARCH="amd64"
CACHE_DIR="./liox_tmp/cache"
CHROOT_CACHE_DIR="./liox_tmp/chroot_cache"

# CACHE_DIR=$(realpath $CACHE_DIR)
# CHROOT_CACHE_DIR=$(realpath $CHROOT_CACHE_DIR)
