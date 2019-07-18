#!/bin/bash

#dnf update

echo "Installing required packages"

dnf install qemu qemu-img nano -y

dnf groupinstall "Virtualization" -y

echo "Egit grub: intel_iommu=on or amd_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1"

nano /etc/sysconfig/grub

echo "Updating grub"

grub2-mkconfig -o /etc/grub2-efi.cfg

echo "Getting GPU passthrough scripts ready"

cp vfio-pci-override-vga.sh /sbin/vfio-pci-override-vga.sh

chmod 755 /sbin/vfio-pci-override-vga.sh

echo "install vfio-pci /sbin/vfio-pci-override-vga.sh" > /etc/modprobe.d/local.conf

cp local.conf /etc/dracut.conf.d/local.conf

echo "Generating initramfs"

dracut -f --kver `uname -r`
