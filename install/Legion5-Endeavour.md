# Content

- [Content](#content)
- [Endeavour Install](#endeavour-install)
  - [Installation](#installation)
  - [Post Installation](#post-installation)
    - [ideapad\_laptop module to manage battery conservation](#ideapad_laptop-module-to-manage-battery-conservation)
    - [Swapfile](#swapfile)
      - [Tuning \& Performance Considerations](#tuning--performance-considerations)
    - [Hibernation](#hibernation)
    - [Install packages](#install-packages)
    - [Create base directory tree](#create-base-directory-tree)
    - [Change Shell](#change-shell)
    - [Setup config files](#setup-config-files)
    - [Tmux](#tmux)
    - [Gnome](#gnome)
      - [Extensions](#extensions)
      - [Shortcuts](#shortcuts)
      - [Startup programs](#startup-programs)
    - [Firewall](#firewall)
      - [GSConnect](#gsconnect)
    - [Nix](#nix)
      - [Flox](#flox)

# Endeavour Install

## Installation

|||
|:--- | :--- |
| Installer | **Calamares** |
| Desktop Environment | **Gnome** |
| Packages | **All packages except linux-kernel-lts, intel-ucode** |

----

Partitions

| MountPoint | Size | Type | Comment |
| :--- | :---: | :---: | ---: |
| /efi | 4 GiB | EFI System | using systemd-boot |
| / | 100 GiB | Linux filesystem | |
| /home | 750 GiB | Linux filesystem | |
|  | 50 GiB | Linux filesystem | Debian installation as backup |
|  | ~50 GiB | Empty | used to overprovisioning for the ssd |

## Post Installation

### ideapad_laptop module to manage battery conservation

This is a pre-require for Gnome extension IdeaPad

> Ref: [Github project](https://github.com/laurento/gnome-shell-extension-ideapad#additional-required-settings), [Gnome Extension](https://extensions.gnome.org/extension/2992/ideapad/)

```bash
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode" | sudo tee /etc/sudoers.d/20-ideapad
echo "ideapad_laptop" | sudo tee /etc/modules-load.d/ideapad_laptop.conf
```

### Swapfile

> [!NOTE]
> 24GB for swap and hibernation 8+16GB

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=24576 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile none swap defaults 0 0" | sudo tee --append /etc/fstab
```

#### Tuning & Performance Considerations

> Ref: [Tuning & Performance Considerations](https://wiki.manjaro.org/index.php/Swap#Tuning_.26_Performance_Considerations)

```bash
echo "vm.swappiness = 15" | sudo tee /etc/sysctl.d/99-swappiness.conf
```

### Hibernation

> Ref: [Hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation)

```bash
echo -e "#\t Path\t Mode\t UID\t GID\t Age\t Argument\t \nw\t /sys/power/image_size\t -\t -\t -\t -\t 17179869184" | sudo tee /etc/tmpfiles.d/hibernation_image_size.conf
echo "add_dracutmodules+=\" resume \"" | sudo tee /etc/dracut.conf.d/resume.conf
```

Add kernel parameters in `/etc/kernel/cmdline`

> Ref: [Manually specify hibernate location](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Manually_specify_hibernate_location) and [Acquire swap file offset](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset)
>
> kernel parameters `resume=UUID=fc6510e1-be20-4dad-a09d-640d18554eab resume_offset=458752`,
>
> where the UUID I got using `sudo blkid | grep '"EndeavourOS"'`, it's the UUID of the root partition because the swapfile is there.
>
> While for the offset parameter I used `sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'`

Finally update systemd-boot and reboot

```bash
sudo reinstall-kernels
sudo reboot now
```

Open some programs and test Hibernation

```bash
systemctl hibernate
```

Once it loads everything correctly I can proceed with an hibernate extension for gnome

```bash
cat <<EOF | sudo tee /etc/systemd/system/user-suspend@.service
[Unit]
Description=User suspend actions
Before=sleep.target

[Service]
User=%I
Type=forking
Environment=DISPLAY=:0
ExecStartPre= -/usr/bin/pkill -u %u unison ; /usr/local/bin/music.sh stop
ExecStart=/usr/bin/sflock
ExecStartPost=/usr/bin/sleep 1

[Install]
WantedBy=sleep.target
EOF
```

### Install packages

Update Signs

```bash
sudo pacman -Sy archlinux-keyring
```

Packages

```bash
sudo pacman -Sy linux-tools syncthing git neovim vim hddtemp zsh \
zsh-completions htop btop tree p7zip nmap mdcat podman podman-compose \
bat tmux alacritty steam obs-studio nvtop nvidia-container-toolkit \
lsd acpi fzf fd ttf-fira-code i2c-tools nix seahorse mpv vlc foliate \
discord gimp inkscape zettlr baobab gnome-browser-connector nethogs \
fastfetch libreoffice-still yt-dlp
```

Android and PostmarketOS set

```bash
android-tools scrcpy pmbootstrap python-argcomplete ncurses dtc
```

Aur packages

> [!NOTE]
> `epson-inkjet-printer-201207w` includes the epson driver for L555, [REF](https://www.openprinting.org/printer/Epson/Epson-L555_Series)

```bash
yay -Sy visual-studio-code-bin 1password 1password-cli ttf-mononoki \
ttf-ms-fonts dive cheat brave-bin anydesk-bin calibre-bin \
epson-inkjet-printer-201207w
```

Update and upgrade system

```bash
sudo pacman -Syu
```

Enable services

```bash
sudo systemctl enable bluetooth.service
sudo systemctl enable plocate-updatedb.timer
systemctl --user enable syncthing.service
```

### Create base directory tree

```bash
mkdir -p ~/repositories/{personal,others,work,use} ~/.config
```

### Change Shell

```bash
chsh -s /usr/bin/zsh
```

```bash
export ZSH=$HOME/repositories/use/oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
export PATH=$HOME/bin:/usr/local/bin:$PATH
```

### Setup config files

```bash
git clone https://github.com/RichardAlmanza/archlinux.git ~/repositories/personal/archlinux
pushd ~/repositories/personal/archlinux
git remote set-url origin github.com:RichardAlmanza/archlinux.git
./config-files/create-symbolic-links.sh
popd
```

### Tmux

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
```

Inside Tmux hit Prefix + I, It's a capital i

After config files -> Control + Space, Shift + i

### Gnome

Setup avatar and wallpaper for gnome desktop

#### Extensions

Install gnome extension

- [ideapad](https://extensions.gnome.org/extension/2992/ideapad/)
- [clipboard history](https://extensions.gnome.org/extension/4839/clipboard-history/)
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/)
- [Removable drive menu](https://extensions.gnome.org/extension/7/removable-drive-menu/)
- [Gtile](https://extensions.gnome.org/extension/28/gtile/)
- [Hibernate status button](https://extensions.gnome.org/extension/755/hibernate-status-button/)

#### Shortcuts

| Program | Command | Shortcut |
| :--- | :---: | ---: |
| Alacritty | `alacritty --option="window.startup_mode=\"maximized\""` | `Super + T` |
| Btop | `alacritty --option="window.startup_mode=\"maximized\"" --command="btop"` | `Ctrl + Alt + Del` |
| 1Password | `1password --quick-access` | `Ctlr + Shift + Space Bar` |

#### Startup programs

Add programs on Tweaks

- 1Password

### Firewall

Change Home connections to Zone: **Home**

#### GSConnect

1. Use **permanent** configuration
2. Select **Home** zone
3. Select **Services** tab
4. Enable **kdeconnect**

> REF: [EndeavourOS forum](https://forum.endeavouros.com/t/gsconnect-not-showing-any-devices/33308/2)
>
> REF: [GSConnect Help](https://github.com/GSConnect/gnome-shell-extension-gsconnect/wiki/Help#connecting-an-android-device)

### Nix

Move `/nix` to `/home/` partition which is larger than `/`

```bash
sudo mv /nix /home/nix
echo "/home/nix /nix none bind 0 0" | sudo tee --append /etc/fstab
```

Setup nix

```bash
sudo groupadd nix-users
sudo usermod -aG nix-users $USER
echo -e "\n# Unix group containing the users allowed to modify nix env without sudo\ntrusted-users = @nix-users" | sudo tee -a /etc/nix/nix.conf
sudo systemctl enable nix-daemon.service
```

Update nix-channel

```bash
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
sudo nix-channel --update
```

#### Flox

Setup flox repository

```bash
echo -e "\nextra-trusted-substituters = https://cache.flox.dev" | sudo tee -a /etc/nix/nix.conf
echo "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" | sudo tee -a /etc/nix/nix.conf
```

Restart nix service

```bash
sudo systemctl stop nix-daemon.service
sudo systemctl restart nix-daemon.socket
```

Install flox

```bash
nix profile install \
      --experimental-features "nix-command flakes" \
      --accept-flake-config \
      'github:flox/flox'
```

Check flox

```bash
flox --version
```

Disable flox's metrics

```bash
flox config --set disable_metrics true
```

Update flox

```bash
nix profile upgrade \
    --experimental-features "nix-command flakes" \
    --accept-flake-config \
    '.*flox'
```
