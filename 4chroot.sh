#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/config.sh

clear
logo

echo LANG=$LANGLOCAL > /etc/locale.conf
sed -i "s/^#${LANGLOCAL}/${LANGLOCAL}/" /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

xbps-install --yes -Su
xbps-install --yes snapper

if [ "$LIBCHOICE" = "yes" ]; then 

#Enable multilib repo
xbps-install --yes void-repo-multilib

fi

if [ "$NONFREE" = "yes" ]; then 

#Enable non-free repo
xbps-install --yes void-repo-nonfree

fi

if [ "$NONFREELIB" = "yes" ]; then

#Enable multilib non-free repo
xbps-install --yes void-repo-multilib-nonfree 

fi

 

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers



clear
logo
echo -ne "
-------------------------------------------------------------------------
                    Adding User
-------------------------------------------------------------------------
"

groupadd libvirt


useradd -m -G wheel,libvirt $USERNAME

# use chpasswd to enter $USERNAME:$password
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$ROOTPASSWORD" | chpasswd



umount /.snapshots
rm -r /.snapshots
snapper --no-dbus -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 750 /.snapshots

clear
logo
echo -ne "
-------------------------------------------------------------------------
                  Grub Install
-------------------------------------------------------------------------
"

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch-Btrfs --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt btrfs"

sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub


sed -i 's/rootflags=subvol=${rootsubvol}//' /etc/grub.d/10_linux
sed -i 's/rootflags=subvol=${rootsubvol}//' /etc/grub.d/20_linux_xen
sed -i 's|,subvolid=258,subvol=/@/.snapshots/1/snapshot| |' /etc/fstab


cp /proc/mounts /etc/fstab
sed -i '/devtmpfs/,$d' inputfilename

xbps-reconfigure -fa
