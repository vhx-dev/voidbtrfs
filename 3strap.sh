#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/config.sh


mkdir /mnt &>/dev/null # Hiding error message if any
clear


logo


echo -ne "
-------------------------------------------------------------------------
                    Straping Setup 
-------------------------------------------------------------------------
"


mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

XBPS_ARCH=x86_64 xbps-install -S -r /mnt --yes -R "https://repo-default.voidlinux.org/current" base-system btrfs-progs grub-x86_64-efi grub-btrfs grub-btrfs-runit NetworkManager bash-completion nano wget gcc

rm /mnt/etc/default/libc-locales
cp /etc/default/libc-locales /mnt/etc/default/libc-locales
sed -i "s/^en_US.UTF-8}/#en_US.UTF-8/" /etc/default/libc-locales
clear



cp -R ${SCRIPT_DIR} /mnt/root/voidbtrfs
    chmod +x /mnt/root/voidbtrfs/4chroot.sh
    chmod +x /mnt/root/voidbtrfs/5final.sh



