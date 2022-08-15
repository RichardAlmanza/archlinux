# Content
- [Content](#content)
- [Installation](#installation)
  - [Laptop Thinkpad X230](#laptop-thinkpad-x230)
    - [First step](#first-step)
    - [Update system clock and select time zone](#update-system-clock-and-select-time-zone)
    - [Prepare for a remote connection](#prepare-for-a-remote-connection)
  - [From remote computer](#from-remote-computer)
    - [Use SSH remote connection](#use-ssh-remote-connection)
    - [Check battery](#check-battery)
      - [Check battery percetage](#check-battery-percetage)
      - [Check the detailed state of the battery](#check-the-detailed-state-of-the-battery)
    - [Prepare disk](#prepare-disk)
      - [List disks](#list-disks)
      - [Edit partitions](#edit-partitions)
      - [Format partitions](#format-partitions)
      - [Mount partitions](#mount-partitions)
      - [Use swap partition](#use-swap-partition)
    - [Prepare mirrorlist](#prepare-mirrorlist)
      - [Backup mirrorlist](#backup-mirrorlist)
      - [Create a new mirrorlist](#create-a-new-mirrorlist)
    - [Install Arch Linux](#install-arch-linux)
      - [Update signatures](#update-signatures)
      - [Install Arch linux and other packages](#install-arch-linux-and-other-packages)
      - [Generate an fstab file](#generate-an-fstab-file)
      - [Change root into the new system](#change-root-into-the-new-system)
      - [Change default shell to zsh](#change-default-shell-to-zsh)
      - [Set time and time zone](#set-time-and-time-zone)
      - [Uncomment the locales needed](#uncomment-the-locales-needed)
      - [Create locale file and select language](#create-locale-file-and-select-language)
      - [Make the input layout persistent](#make-the-input-layout-persistent)
      - [Set hostname](#set-hostname)
      - [Set Root password](#set-root-password)
    - [Install Boot Loader](#install-boot-loader)
      - [Edit boot loader config file](#edit-boot-loader-config-file)
      - [Install intel microcode](#install-intel-microcode)
      - [Add config file for Arch entry](#add-config-file-for-arch-entry)
    - [Enable services](#enable-services)
    - [Add users](#add-users)
    - [Final steps](#final-steps)
      - [Exit from **chroot**](#exit-from-chroot)
      - [Unmount partitions recursively](#unmount-partitions-recursively)
      - [Reboot or Shutdown laptop](#reboot-or-shutdown-laptop)
- [Post-installation](#post-installation)
  - [Update system](#update-system)
  - [Install Paru, a Pacman wrapper](#install-paru-a-pacman-wrapper)

# Installation
## Laptop Thinkpad X230
### First step
Select the input layout for this laptop keyboard

Show EFI variables, check this to be sure the system is booted in UEFI mode
```bash
loadkeys es
ls /sys/firmware/efi/efivars
```
Show network interfaces, ensure there is at least one up and enabled

Ping to verify internet connection
```bash
ip link
ping archlinux.org -c 3
```
### Update system clock and select time zone
```bash
timedatectl set-ntp true
timedatectl set-timezone America/Bogota 
timedatectl status
```
### Prepare for a remote connection
Set password to use a SSH connection
```bash
passwd
```
Show the network interface IP address 
```bash
ip addr show enp0s25
```
## From remote computer
### Use SSH remote connection
```bash
ssh root@192.168.1.9
```
### Check battery
#### Check battery percetage
```bash
cat /sys/class/power_supply/BAT0/capacity
```
#### Check the detailed state of the battery
```bash
pacman -Sy upower
upower -i /org/freedesktop/UPower/devices/battery_BAT0
alias checkbattery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
```
### Prepare disk
#### List disks
```bash
fdisk -l
lsblk
```
#### Edit partitions
```bash
cgdisk /dev/sda
```
Results
>```st
>Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
>Disk model: Samsung SSD 860 
>Units: sectors of 1 * 512 = 512 bytes
>Sector size (logical/physical): 512 bytes / 512 bytes
>I/O size (minimum/optimal): 512 bytes / 512 bytes
>Disklabel type: gpt
>Disk identifier: 5818E344-8418-4965-8D5D-18031E94D55C
>
>Device        Start       End   Sectors  Size Type
>/dev/sda1      4096   1052671   1048576  512M EFI System
>/dev/sda2   1052672  17829887  16777216    8G Linux swap
>/dev/sda3  17829888 722472959 704643072  336G Linux filesystem
>```
#### Format partitions
```bash
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
```
#### Mount partitions
```bash
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
```
#### Use swap partition
```bash
swapon /dev/sda2
```
### Prepare mirrorlist 
#### Backup mirrorlist 
```bash
cp /etc/pacman.d/mirrorlist .
```
#### Create a new mirrorlist
```bash
reflector --latest 20 --protocol https --country 'United States,Colombia,' --save /etc/pacman.d/mirrorlist --ipv4 --ipv6 --sort rate --verbose
```
### Install Arch Linux
#### Update signatures
Update signatures to prevent error when installing arch from an old live boot
```bash
pacman -Sy archlinux-keyring
```
#### Install Arch linux and other packages
```bash
pacstrap /mnt base base-devel linux linux-firmware \
gnome gnome-extra kubernetes-tools kubectl-plugins linux-tools \
neovim vim seahorse lm_sensors sensors-applet smartmontools hddtemp \
zsh zsh-completions networkmanager nm-connection-editor network-manager-applet \
networkmanager-openvpn networkmanager-pptp htop tree nano neofetch \
kitty p7zip firefox nmap mdcat docker docker-compose
```
#### Generate an fstab file
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
#### Change root into the new system
```bash
arch-chroot /mnt
```
#### Change default shell to zsh
```bash
chsh -s /bin/zsh
```
#### Set time and time zone
```bash
ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
timedatectl set-ntp true
```
#### Uncomment the locales needed
* **en_US.UTF-8**
* **es_CO.UTF-8**
```bash
nvim /etc/locale.gen
```
#### Create locale file and select language
```bash
locale-gen
echo -e "# Custom settings\nLANG=en_US.UTF-8" > /etc/locale.conf
```
#### Make the input layout persistent
```bash
echo "KEYMAP=es" > /etc/vconsole.conf
```
#### Set hostname
```bash
echo "arch-wolf" > /etc/hostname
```
#### Set Root password
```bash
passwd
```
### Install Boot Loader
Install systemd-boot
```bash
bootctl install
systemctl enable systemd-boot-update.service
mkinitcpio -P
```
#### Edit boot loader config file
```bash
nvim /boot/loader/loader.conf
```
Example loader.conf https://man.archlinux.org/man/loader.conf.5#OPTIONS
>```ls
>#timeout 3
>#console-mode keep
>default arch-*
># Should be enable by default
>#auto-entries
>#auto-firmware
>```
#### Install intel microcode
```bash
pacman -Sy intel-ucode
```
#### Add config file for Arch entry
```bash
nvim /boot/loader/entries/arch.conf
```
example arch.conf entry  config file
>```
>title   Arch Linux
>linux   /vmlinuz-linux
>initrd  /intel-ucode.img
>initrd  /initramfs-linux.img
>options root=PARTUUID=a38fedd8-6fdd-4638-885f-a2411aefc1f1 rw
>```
### Enable services
* Network manager service
* Gnome display manager
* Docker 
* Weekly trim for the SSD
```bash
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service
systemctl enable fstrim.timer
```
### Add users
Add users using zsh as default Shell, and with sudo permissions
```bash
useradd -m -s /bin/zsh anaeru
passwd anaeru
chfn -f "Richard Almanza" anaeru
echo "anaeru ALL=(ALL:ALL) ALL" > /etc/sudoers.d/sudo-users.conf
```
### Final steps
#### Exit from **chroot**
```bash
exit
```
#### Unmount partitions recursively
```bash
umount -R /mnt
```
#### Reboot or Shutdown laptop
```bash
reboot now
```
```bash
shutdown now
```
# Post-installation
## Update system
```bash
sudo pacman -Syu
```
## Install Paru, a Pacman wrapper

<!-- oh my zsh, fzf, dive, cheat -->