# Generated by pykickstart v3.48
#version=DEVEL
# Use text mode install
text
firstboot --disable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Network information
network  --bootproto=dhcp --hostname=FEDORA
# Reboot after installation
reboot --eject
repo --name="rpmfusion-free" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-free-updates" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree-updates" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch
repo --name="fedora-cisco-openh264" --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-cisco-openh264-$releasever&arch=$basearch --install
# System services
services --enabled="NetworkManager,sshd,bluetooth"
# Do not configure the X Window System
skipx
timesource --ntp-server=time.cloudflare.com --nts
timesource --ntp-server=time.cloudflare.com --nts
timesource --ntp-server=virginia.time.system76.com --nts
timesource --ntp-server=ohio.time.system76.com --nts
timesource --ntp-server=oregon.time.system76.com --nts
# System timezone
timezone Asia/Taipei --utc
# Use network installation
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch"
# System bootloader configuration
bootloader --location=mbr --sdboot
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel --disklabel=gpt
# Disk partitioning information
part /boot/efi --fstype="efi" --size=1024 --label=ESP
part btrfs.main --fstype="btrfs" --grow --fsoptions="compress=lzo"
btrfs none --label=FEDORA btrfs.main
btrfs / --subvol --name=root FEDORA
btrfs /home --subvol --name=home FEDORA

%pre
#!/bin/bash
set -x

cat<<'EOF'>>/etc/dnf/dnf.conf
install_weak_deps=False
deltarpm=False
ip_resolve=4
EOF
%end

%pre --interpreter=/bin/bash
#!/bin/bash
set -x
echo "manage the btrfs subvolumes"
mkdir /mnt/btrfsvol
mount /dev/disk/by-label/FEDORA /mnt/btrfsvol
btrfs subvol list /mnt/btrfsvol
OPTIONS="compress=lzo"
mkdir -vp /mnt/btrfsvol/home/"$USER"/.var/app/com.brave.Browser
SUBVOLUMES=(
  	"opt"
  	"nix"
  	"var/cache"
  	"var/crash"
  	"var/tmp"
  	"var/log"
  	"var/spool"
  	"var/www"
  	"var/lib/AccountsService"
  	"var/lib/libvirt/images"
  	"var/lib/gdm"
  	"home/$USER/.var/app/com.brave.Browser"
)

for dir in "''${SUBVOLUMES[@]}"; do
  	if [[ -d "/mnt/btrfsvol/''${dir}" ]]; then
  		mv -v "/mnt/btrfsvol/''${dir}" "/mnt/btrfsvol/''${dir}-old"
  		btrfs subvolume create "/mnt/btrfsvol/''${dir}"
  		cp -ar "/mnt/btrfsvol/''${dir}-old/." "/mnt/btrfsvol/''${dir}/"
  	else
  		btrfs subvolume create "/mnt/btrfsvol/''${dir}"
  	fi
  	restorecon -RF "/mnt/btrfsvol/''${dir}"
  	printf "%-41s %-35s %-5s %-s %-s\n" \
  		"UUID=''${ROOT_UUID}" \
  		"/''${dir}" \
  		"btrfs" \
  		"subvol=''${dir},''${OPTIONS}" \
  		"0 0" |
  		tee -a /mnt/btrfsvol/etc/fstab
done

chmod 1777 /mnt/btrfsvol/var/tmp
chmod 1770 /mnt/btrfsvol/var/lib/gdm
chown -R "$USER": /mnt/btrfsvol/home/"$USER"/.var/app/com.brave.Browser

for dir in "''${SUBVOLUMES[@]}"; do
  if [[ -d "/mnt/btrfsvol/''${dir}-old" ]]; then
  	rm -rf "/mnt/btrfsvol/''${dir}-old"
  fi
done

btrfs subvol list /mnt/btrfsvol
umount /mnt/btrfsvol
rmdir /mnt/btrfsvol
%end

%post --interpreter=/bin/bash
#!/bin/bash
set -x

cat<<'EOF'>>/etc/dnf/dnf.conf
install_weak_deps=False
max_parallel_downloads=10
deltarpm=False
ip_resolve=4
excludepkgs=xorg-x11-*
EOF
# Set the plymouth theme
plymouth-set-default-theme charge -R

# Change Systemd boot target
systemctl set-default graphical.target

systemctl enable gdm

grub2-editenv - unset menu_auto_hide

# Configure Flatpak
systemctl disable flatpak-add-fedora-repos
flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sed -i "s/#Experimental = false/Experimental = true/" /etc/bluetooth/main.conf

curl https://raw.githubusercontent.com/percygt/fedora-kickstart/main/nix_install -o /home/percygt/nix-install
curl https://raw.githubusercontent.com/percygt/fedora-kickstart/main/home_install -o /home/percygt/home-install
chmod +x /home/percygt/nix-install
chmod +x /home/percygt/home-install
git clone --recurse-submodule git@gitlab.com:percygt/nix-dots.git "/home/percygt/nix-dots"
%end

%packages
@fonts
@guest-desktop-agents
@hardware-support
@multimedia
@networkmanager-submodules
aria2
bash-color-prompt
bash-completion
curl
dnf-plugins-core
fedora-workstation-repositories
ffmpeg
ffmpeg-libs
flatpak
git
gnome-disk-utility
gnome-shell
gnome-terminal
gnome-user-share
gstreamer1-libav
gstreamer1-plugin-openh264
gstreamer1-plugins-bad-*
gstreamer1-plugins-base
gstreamer1-plugins-good-*
gvfs*
intel-gpu-firmware
intel-media-driver
libappstream-glib
libva
libva-utils
mozilla-openh264
openh264
ostree
plymouth-system-theme
policycoreutils-python-utils
pykickstart
rsync
wget
xdg-desktop-portal-gnome
xdg-user-dirs
xdg-user-dirs-gtk
xdg-utils
-@input-methods
-PackageKit-gstreamer-plugin
-ffmpeg-free
-gstreamer-ffmpeg
-gstreamer1-plugins-bad-free-devel

%end