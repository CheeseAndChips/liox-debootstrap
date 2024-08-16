#!/bin/bash
qemu-system-x86_64 -smp 2 -m 4G -accel kvm -cpu host -machine q35 -drive file=./liox_tmp/image.raw,format=raw --drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd -drive if=pflash,format=raw,file=./OVMF_VARS.4m.fd -nic none #-nic user,model=e1000 
