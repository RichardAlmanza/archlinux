# ==== In the laptop ====
loadkeys es
ls /sys/firmware/efi/efivars
ip link
ping archlinux.org -c 3
timedatectl set-ntp true
timedatectl set-timezone America/Bogota 
timedatectl status
passwd
# set password to use a ssh connection

ip addr show enp0s25
# in this case the laptop ip is 192.168.1.9

# ==== Use SSH remote connection ====
ssh root@192.168.1.9
pacman -Sy upower
# to check the detailed battery state use the command below
upower -i /org/freedesktop/UPower/devices/battery_BAT0
alias checkbattery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'

