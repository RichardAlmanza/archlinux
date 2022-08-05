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

fdisk -l
cgdisk /dev/sda

# ---- Results
# Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
# Disk model: Samsung SSD 860 
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: gpt
# Disk identifier: 5818E344-8418-4965-8D5D-18031E94D55C

# Device        Start       End   Sectors  Size Type
# /dev/sda1      4096   1052671   1048576  512M EFI System
# /dev/sda2   1052672  17829887  16777216    8G Linux swap
# /dev/sda3  17829888 722472959 704643072  336G Linux filesystem

mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
