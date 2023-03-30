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


# Populate Fstab Properly
          #Alternative method but use path relative to /dev/
              #cp /proc/mounts /etc/fstab
              #sed -i '/devtmpfs/,$d' inputfilename
              
              
sed -i '/tmpfs/d' /etc/fstab
cat << EOF >> /etc/fstab

# ESP
UUID=${EFIUUID}      	/boot/efi 	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro	0 2

# /
UUID=${ROOTUUID}	/         	btrfs     	rw,relatime,compress=zstd:3,ssd,space_cache=v2 	0 0

# Snapshot
UUID=${ROOTUUID}	/.snapshots	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/.snapshots	0 0

# grub
UUID=${ROOTUUID}	/boot/grub	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/boot/grub	0 0

# /root
UUID=${ROOTUUID}	/root     	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/root	0 0

# /tmp
UUID=${ROOTUUID}	/tmp      	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/tmp	0 0

# cache
UUID=${ROOTUUID}	/var/cache	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/var/cache	0 0

# logs
UUID=${ROOTUUID}	/var/log  	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/var/log	0 0

# spool
UUID=${ROOTUUID}	/var/spool	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/var/spool	0 0

# /var/tmp
UUID=${ROOTUUID}	/var/tmp  	btrfs     	rw,noatime,compress=zstd:3,ssd,space_cache=v2,subvol=/@/var/tmp	0 0


EOF


HOMEFSTAB=no

 if [ "$HOMEPART" = "no" ] && [ "$HOMESNAP" = "no" ]; then
   
    HOMEFSTAB="UUID=${ROOTUUID} /home btrfs     	noatime,compress=zstd,ssd,commit=120,subvol=@/home "

   fi 
   
    
   if [ "$HOMEPART" = "yes" ] && [ "$HOMESNAP" = "no" ]; then
   
    HOMEFSTAB="UUID=${HOMEUUID} /home btrfs     	rw,relatime,ssd,space_cache=v2,subvolid=5,subvol=/	0 0"

   fi 
	
 if [ "$HOMEFSTAB" != "no" ] ; then
 
 echo "$HOMEFSTAB" >> /etc/fstab
 
 fi 

if [ "$SWAPON" = "yes" ] ; then
 
 SWAPFSTAB="UUID=${SWAPUUID} 	none      	swap      	defaults  	0 0"
 echo "$SWAPFSTAB" >> /etc/fstab
 
 fi 


xbps-reconfigure -fa
