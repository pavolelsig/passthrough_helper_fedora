#!/bin/bash

dnf update

dnf install qemu qemu-img nano

dnf groupinstall "Virtualization"

nano /etc/sysconfig/grub

grub2-mkconfig -o /etc/grub2-efi.cfg

cp vfio-pci-override-vga.sh /sbin/vfio-pci-override-vga.sh

chmod 755 /sbin/vfio-pci-override-vga.sh

echo "install vfio-pci /sbin/vfio-pci-override-vga.sh" > /etc/modprobe.d/local.conf

cp local.conf /etc/dracut.conf.d/local.conf

dracut -f --kver `uname -r`
