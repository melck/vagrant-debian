#!/bin/bash

dd if=/dev/zero of=/swapfile1 bs=1024 count=1024000
mkswap /swapfile1
swapon /swapfile1
echo "/swapfile1  none  swap  sw  0  0" >> /etc/fstab

# Install VirtualBox  additions
apt-get install -y linux-headers-$(uname -r)
mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run

mv /etc/rc.local.bak /etc/rc.local

# display grub timeout and login promt after boot
sed -i \
  -e "s/quiet splash//" \
  -e "s/GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=0/" \
  /etc/default/grub
update-grub

# clean up
apt-get clean

shutdown -h now
