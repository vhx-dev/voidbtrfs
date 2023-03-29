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

XBPS_ARCH=x86_64 xbps-install -S -r /mnt -R "https://repo-default.voidlinux.org/current" base-system intel-ucode void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree  btrfs-progs grub-x86_64-efi grub-btrfs grub-btrfs-runit NetworkManager bash-completion nano wget gcc


clear



cp -R ${SCRIPT_DIR} /mnt/root/voidbtrfs
    chmod +x /mnt/root/archscript/4chroot.sh
    chmod +x /mnt/root/archscript/5final.sh



