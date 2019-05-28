#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)" 1>&2
    exit 1
fi

mod="mk_arcade_joystick_rpi"
ver=0.1.5

apt-get -y install raspberrypi-kernel-headers raspberrypi-kernel 
apt-get -y install dkms joystick

if [[ -e /usr/src/$mod-$ver || -e /var/lib/dkms/$mod/$ver ]]; then
    dkms remove --force -m $mod -v $ver --all
    rm -rf /usr/src/$mod-$ver
fi

mkdir /usr/src/$mod-$ver/
cp -a ./* /usr/src/$mod-$ver/

sudo dkms build -m $mod -v $ver
sudo dkms install -m $mod -v $ver 

grep -q "mk_arcade_joystick_rpi" /etc/modules || \
    echo "mk_arcade_joystick_rpi" >> /etc/modules  

if [[ -f "/etc/modprobe.d/joystick.conf" ]]; then
    echo “rm /etc/modprobe.d/joystick.conf”
    rm -rf /etc/modprobe.d/joystick.conf
fi

if [ x$1 != 'x2' ];then
    echo "options mk_arcade_joystick_rpi map=5 gpio=22,23,24,25,4,17,27,5,6,12,16,26" >> /etc/modprobe.d/joystick.conf
    echo "joystick 1"
else 
    echo "options mk_arcade_joystick_rpi map=1,2" >> /etc/modprobe.d/joystick.conf
    echo "joystick 2"
fi

echo "" >> /boot/config.txt
grep -q "max_usb_current=1" /boot/config.txt || \
    echo "max_usb_current=1" >> /boot/config.txt

grep -q "hdmi_force_hotplug=1" /boot/config.txt || \
    echo "hdmi_force_hotplug=1" >> /boot/config.txt

grep -q "config_hdmi_boost=10" /boot/config.txt || \
    echo "config_hdmi_boost=10" >> /boot/config.txt

grep -q "hdmi_group=2" /boot/config.txt || \
    echo "hdmi_group=2" >> /boot/config.txt

grep -q "hdmi_mode=87" /boot/config.txt || \
    echo "hdmi_mode=87" >> /boot/config.txt

grep -q "hdmi_cvt 1024 600 60 6 0 0 0" /boot/config.txt || \
    echo "hdmi_cvt 1024 600 60 6 0 0 0" >> /boot/config.txt

grep -q "avoid_warnings=1" /boot/config.txt || \
    echo "avoid_warnings=1" >> /boot/config.txt

grep -q "disable_splash=1" /boot/config.txt || \
    echo "disable_splash=1" >> /boot/config.txt

#sudo reboot
