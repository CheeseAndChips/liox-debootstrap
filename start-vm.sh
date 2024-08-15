#!/bin/bash
qemu-system-x86_64 -smp 2 -m 4G -accel kvm -cpu host -machine q35 -drive file=./image.raw,format=raw -bios /usr/share/ovmf/OVMF.fd -net none
