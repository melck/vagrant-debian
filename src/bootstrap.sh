#!/bin/bash

# No password for sudo
echo "%sudo ALL = NOPASSWD: ALL" >> /etc/sudoers

# Public SSH key for vagrant user
mkdir /home/vagrant/.ssh
wget --no-check-certificate -q "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub" -O /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Verify key
echo "#########################"
cat /home/vagrant/.ssh/authorized_keys
echo "#########################"

# Change mesgn to avoid stdin is not a tty
sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

# Install guest additions on next boot
cp /etc/rc.{local,local.bak} && cp /root/poststrap.sh /etc/rc.local

# Wait for disk
sync
