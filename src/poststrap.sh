#!/bin/bash

# Install VirtualBox  additions
apt-get install -y linux-headers-$(uname -r)
mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run
mv /etc/rc.local.bak /etc/rc.local

# Fix mount issues for virtualbox guest additions v4.3.10
if [[ -d "/opt/VBoxGuestAdditions-4.3.10" ]]; then
	ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi

# Install last puppet
#wget --quiet --tries=5 --timeout=10 -O /tmp/puppet.deb "http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb"
#dpkg -i /tmp/puppet.deb
#apt-get update
#apt-get -y install puppet
#rm -rf /tmp/puppet.deb

# display grub timeout and login promt after boot
sed -i \
  -e "s/quiet splash//" \
  -e "s/GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=0/" \
  /etc/default/grub
update-grub

# Clean up aptitude
aptitude -y purge ri
aptitude -y purge installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide
aptitude -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30
aptitude -y purge python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl libffi5
apt-get purge -y linux-image-3.0.0-12-generic-pae

# Remove APT cache
apt-get clean -y
apt-get autoclean -y

# Zero free space to aid VM compression
echo "Cleanup"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Remove bash history
echo "Cleanup history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Cleanup log files
echo "Cleanup logs"
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Whiteout root
echo "Cleanup root"
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot
echo "Cleanup boot"
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;

shutdown -h now
