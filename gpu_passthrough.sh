#!/bin/bash

#Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

if [ -a /sbin/vfio-pci-override-vga.sh ]
	then 
	echo "Please uninstall Passthrough Helper first! Then run gpu_passthrough.sh again."
	exit
fi

echo "Installing required packages"

dnf install qemu qemu-img nano -y

dnf groupinstall "Virtualization" -y


###Creating backups
echo  "Creating backups"

cat /etc/sysconfig/grub > grub_backup.txt

if [ -a /etc/modprobe.d/local.conf ]
	then 
	mv /etc/modprobe.d/local.conf modprobe.backup
fi

if [ -a /etc/dracut.conf.d/local.conf ]
	then 
	mv /etc/dracut.conf.d/local.conf local.conf.backup
fi

chmod +x uninstall.sh

cp /etc/sysconfig/grub new_grub

###
#Detecting CPU
CPU=$(lscpu | grep GenuineIntel | rev | cut -d ' ' -f 1 | rev )

INTEL="0"

if [ "$CPU" = "GenuineIntel" ]
	then
	INTEL="1"
fi

#Building string Intel or AMD iommu=on
if [ $INTEL = 1 ]
	then
	IOMMU="intel_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1"
	echo "Set Intel IOMMU On"
	else
	IOMMU="amd_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1"
	echo "Set AMD IOMMU On"
fi

#Putting together new grub string
OLD_OPTIONS=`cat new_grub | grep GRUB_CMDLINE_LINUX | cut -d '"' -f 1,2`

NEW_OPTIONS="$OLD_OPTIONS $IOMMU\""
echo $NEW_OPTIONS

#Rebuilding grub 
sed -i -e "s|^GRUB_CMDLINE_LINUX.*|${NEW_OPTIONS}|" new_grub

#User verification of new grub and prompt to manually edit it
echo 
echo "Grub was modified to look like this: "
echo `cat new_grub | grep "GRUB_CMDLINE_LINUX"`
echo 
echo "Do you want to edit it? y/n"
read YN

if [ $YN = y ]
then
nano new_grub
fi

cp new_grub /etc/sysconfig/grub

#Copying necessary scripts
echo "Getting GPU passthrough scripts ready"

cp vfio-pci-override-vga.sh /sbin/vfio-pci-override-vga.sh

chmod 755 /sbin/vfio-pci-override-vga.sh

echo "install vfio-pci /sbin/vfio-pci-override-vga.sh" > /etc/modprobe.d/local.conf

cp local.conf /etc/dracut.conf.d/local.conf


echo "Updating grub and generating initramfs"

grub2-mkconfig -o /etc/grub2-efi.cfg
dracut -f --kver `uname -r`
