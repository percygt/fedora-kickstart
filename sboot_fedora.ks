#version=F39
# Use text mode install
text
# License agreement
eula --agreed
# Shutdown after installation
shutdown

%pre
#!/bin/bash
set -x

cat<<'EOF'>>/etc/dnf/dnf.conf
group_package_types=mandatory
install_weak_deps=False
deltarpm=False
ip_resolve=4
excludepkgs=xorg-x11-*
EOF
%end

%post --interpreter=/bin/bash
#!/bin/bash
set -x

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-39-x86_64
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-39
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-nonfree-fedora-39

cat<<'EOF'>>/etc/dnf/dnf.conf
group_package_types=mandatory
install_weak_deps=False
deltarpm=False
ip_resolve=4
excludepkgs=xorg-x11-*
EOF

%end

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US

# Firewall configuration
firewall --enabled --service=ssh --remove-service=cockpit
# Network information
network  --bootproto=dhcp --device=link --hostname=freshinstall --activate

repo --name="updates"  --metalink=ttps://mirrors.fedoraproject.org/metalink?repo=updates-released-f$releasever&arch=$basearch&country=us
repo --name="updates-testing"  --metalink=https://mirrors.fedoraproject.org/metalink?repo=updates-testing-f$releasever&arch=$basearch&country=us
repo --name="fedora-cisco-openh264"  --metalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-cisco-openh264-$releasever&arch=$basearch
repo --name="rpmfusion-free"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=free-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-free-updates"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=free-fedora-updates-released-$releasever&arch=$basearch
repo --name="rpmfusion-free-updates-testing"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=free-fedora-updates-testing-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree-updates"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch
repo --name="rpmfusion-nonfree-updates-testing"  --metalink=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-updates-testing-$releasever&arch=$basearch

# Use network installation
url --metalink="https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch&country=us"

%packages --inst-langs=en_US --exclude-weakdeps
@core
   #mandatory
  -yum
   #default
   systemd-resolved
   #optional
   #conditional
#@standard
   #mandatory
   #conditional
#@hardware-support
   #default
   #optional
   #conditional
#@server-product
   #mandatory
   #default
#@headless-management
   #mandatory
   #default
   #optional
#@networkmanager-submodules
   #default
#@container-management
#@domain-client
   #mandatory
   #default
#@guest-agents
   #mandatory
#@server-hardware-support
   #default
   #optional
#NetworkManager
-dracut-config-rescue
generic-logos
google-noto-sans-mono-vf-fonts
intel-gpu-firmware
intel-media-driver
#intel-mediasdk
#microcode_ctl - handled by host?
openssh-server
#plymouth-theme-spinner
#policycoreutils-dbus
polkit
spice-vdagent
#sqlite
systemd-networkd
%end

# System authorization information
authselect sssd
# SELinux configuration
selinux --enforcing

# System services
services --disabled="mdns,dnf-makecache.timer" --enabled="systemd-networkd"
# Do not configure the X Window System
skipx

bootloader --sdboot
# uefi vm partitioning
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel --disklabel=gpt
# Disk partitioning information
part /boot/efi --fstype="efi" --size=1024
part / --fstype="xfs" --size=4096 --label="ROOT"

timesource --ntp-server=time.cloudflare.com --nts
timesource --ntp-server=virginia.time.system76.com --nts
timesource --ntp-server=ohio.time.system76.com --nts
timesource --ntp-server=oregon.time.system76.com --nts
# System timezone
timezone Etc/UTC --utc

#Root password
rootpw --lock
# regular user
user --name=regular --iscrypted --password "INSERT_ENCRYPTED_PASSWORD_HERE"
# ansible user
