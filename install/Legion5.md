# Content

- [Content](#content)
- [Manjaro Install](#manjaro-install)
  - [Post Installation](#post-installation)
    - [Load modules](#load-modules)
      - [ideapad\_laptop module to manage battery conservation](#ideapad_laptop-module-to-manage-battery-conservation)
    - [Change Shell](#change-shell)
    - [Swapfile](#swapfile)
      - [Tuning \& Performance Considerations](#tuning--performance-considerations)
    - [Hibernation](#hibernation)
    - [Install packages](#install-packages)
    - [Create base directory tree](#create-base-directory-tree)
    - [Syncthing](#syncthing)
    - [Docker](#docker)
    - [Nix](#nix)
      - [Flox](#flox)

# Manjaro Install

## Post Installation

### Load modules

#### ideapad_laptop module to manage battery conservation

This is a pre-require for Gnome extension IdeaPad

> Ref: [Github project](https://github.com/laurento/gnome-shell-extension-ideapad#additional-required-settings), [Gnome Extension](https://extensions.gnome.org/extension/2992/ideapad/)

```bash
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/bus/platform/drivers/ideapad_acpi/VPC????\:??/conservation_mode" | sudo tee/etc/sudoers.d/20-ideapad
echo "ideapad_laptop" | sudo tee /etc/modules-load.d/ideapad_laptop.conf
```

### Change Shell

```bash
chsh -s /usr/bin/zsh
```

### Swapfile

> [!NOTE]
> 24GB for swap and hibernation 8+16GB

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=24576 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo bash -c "echo /swapfile none swap defaults 0 0 >> /etc/fstab"
```

#### Tuning & Performance Considerations

> Ref: [Tuning & Performance Considerations](https://wiki.manjaro.org/index.php/Swap#Tuning_.26_Performance_Considerations)

```bash
echo "vm.swappiness = 20" | sudo tee /etc/sysctl.d/99-swappiness.conf
```

### Hibernation

> Ref: [Hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation)

```bash
echo -e "#\t Path\t Mode\t UID\t GID\t Age\t Argument\t \nw\t /sys/power/image_size\t -\t -\t -\t -\t 17179869184" | sudo tee /etc/tmpfiles.d/hibernation_image_size.conf
```

Add the *resume* module to `/etc/mkinitcpio.conf` in the line for hooks, after *systemfiles*.

> HOOKS=(base udev autodetect microcode kms modconf block keyboard keymap consolefont plymouth filesystems *resume* fsck)

```bash
sudo mkinitcpio -P
```

Add the kernel parameters for the resume hook in the grub config file `/etc/default/grub` in the line of `GRUB_CMDLINE_LINUX_DEFAULT=`

> Ref: [Manually specify hibernate location](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Manually_specify_hibernate_location) and [Acquire swap file offset](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset)
>
> kernel parameters `resume=UUID=fc6510e1-be20-4dad-a09d-640d18554eab resume_offset=458752`, where the UUID I got using `sudo blkid | grep '"Manjaro"'`, it's the UUID of the root partition because the swapfile is there.
> While for the offset parameter I used `sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'`

Finally update grub and reboot

```bash
sudo update-grub
sudo reboot now
```

Open some programs and use

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

```bash
sudo pacman -Sy archlinux-keyring
```

```bash
sudo pacman -Sy base-devel neovim vim btop tree neofetch mdcat \
docker docker-buildx docker-compose bat tmux plocate lsd \
fzf fd ttf-fira-code nix vlc bookworm discord gimp inkscape \
alacritty steam syncthing yay obs-studio nvtop podman \
nvidia-container-toolkit
```

```bash
yay -Sy visual-studio-code-bin 1password 1password-cli ttf-mononoki \
dive slack-desktop cheat brave
```

```bash
sudo pacman -Syu
```

```bash
sudo systemctl enable plocate-updatedb.timer
```

### Create base directory tree

```bash
mkdir -p ~/repositories/personal ~/repositories/others ~/repositories/work ~/repositories/use ~/.config
```

### Syncthing

```bash
systemctl --user enable syncthing.service
```

### Docker

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

### Nix

```bash
sudo systemctl enable nix-daemon.service
sudo usermod -aG nix-users $USER
```

```bash
zsh -l
su $USER
```

```bash
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
sudo nix-channel --update
```

#### Flox

```bash
echo -e "\nextra-trusted-substituters = https://cache.flox.dev" | sudo tee -a /etc/nix/nix.conf
echo "extra-trusted-public-keys = flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" | sudo tee -a /etc/nix/nix.conf
```

```bash
sudo systemctl stop nix-daemon.service
sudo systemctl restart nix-daemon.socket
```

```bash
nix profile install \
      --experimental-features "nix-command flakes" \
      --accept-flake-config \
      'github:flox/flox'
```

```bash
flox --version
```

```bash
flox config --set-bool disable_metrics true
```

```bash
nix profile upgrade \
    --experimental-features "nix-command flakes" \
    --accept-flake-config \
    '.*flox'
```
