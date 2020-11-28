#!/bin/bash

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

if [ -a grub_backup.txt ]
	then 
	mv grub_backup.txt /etc/sysconfig/grub
fi

grub2-mkconfig -o /etc/grub2-efi.cfg

rm /sbin/vfio-pci-override-vga.sh

rm /etc/dracut.conf.d/local.conf

if [ -a local.conf.backup ]
	then 
	mv local.conf.backup /etc/dracut.conf.d/local.conf
fi


if [ -a modprobe.backup ]
	then 
	mv modprobe.backup /etc/modprobe.d/local.conf
fi

dracut -f --kver `uname -r`

