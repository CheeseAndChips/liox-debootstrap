#!/bin/bash

set -e

HOSTNAME="lioxbox"
TIMEZONE="Europe/Vilnius"
BUILD_DIR="./mnt"
BUILD_IMAGE="./image.raw"
IMAGE_SIZE_MB=8192
ARCH="amd64"
CACHE_DIR="./cache"

CACHE_DIR=$(realpath $CACHE_DIR)
