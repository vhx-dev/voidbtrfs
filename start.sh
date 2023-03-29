#!/usr/bin/env bash
# Find the name of the folder the scripts are in
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
clear
echo -ne "
-------------------------------------------------------------------------

                    ██╗   ██╗ ██████╗ ██╗██████╗ 
                    ██║   ██║██╔═══██╗██║██╔══██╗
                    ██║   ██║██║   ██║██║██║  ██║
                    ╚██╗ ██╔╝██║   ██║██║██║  ██║
                     ╚████╔╝ ╚██████╔╝██║██████╔╝
                      ╚═══╝   ╚═════╝ ╚═╝╚═════╝ 
                             
-------------------------------------------------------------------------
        Automated Void Linux Installer With Btrfs Snapshot
-------------------------------------------------------------------------

"
    chmod +x ./1setup.sh
    chmod +x ./2partition.sh
    chmod +x ./3strap.sh
    chmod +x ./4chroot.sh
    chmod +x ./5final.sh
    cp -R ${SCRIPT_DIR} /
    source /voidbtrfst/config.sh
    ( bash /voidbtrfs/1setup.sh )|& tee /voidbtrfs/setup.log
    ( bash /voidbtrfs/2partition.sh )|& tee /voidbtrfs/partition.log
    ( bash /voidbtrfs/3strap.sh )|& tee /voidbtrfs/strap.log
    ( arch-chroot /mnt /root/voidbtrfs/4chroot.sh )|& tee /mnt/root/voidbtrfs/chroot.log
    ( arch-chroot /mnt /root/voidbtrfs/5final.sh )|& tee /mnt/root/voidbtrfs/final.log
   
echo -ne "
-------------------------------------------------------------------------

                    ██╗   ██╗ ██████╗ ██╗██████╗ 
                    ██║   ██║██╔═══██╗██║██╔══██╗
                    ██║   ██║██║   ██║██║██║  ██║
                    ╚██╗ ██╔╝██║   ██║██║██║  ██║
                     ╚████╔╝ ╚██████╔╝██║██████╔╝
                      ╚═══╝   ╚═════╝ ╚═╝╚═════╝ 
                             
-------------------------------------------------------------------------
        Automated Void Linux Installer With Btrfs Snapshot
-------------------------------------------------------------------------

            Done - Please Eject Install Media and Reboot
      Also note that this script copied itself in /root/voidbtrfs/
             with the config you choosed and the logs

"
