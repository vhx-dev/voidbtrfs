#!/usr/bin/env bash
    
#Where am I ?
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# This script will ask users about their prefrences
# like timezone, keyboard layout,
# user name, password, etc.


    

# set up a config file
CONFIG_FILE=$SCRIPT_DIR/config.sh
source $SCRIPT_DIR/config.sh



localeselect () {
echo -ne "
Please select your locale from this list"
# These are default key maps as presented in official arch repo archinstall
options=(en_CA.UTF-8 en_HK.UTF-8 en_US.UTF-8 fr_CA.UTF-8 fr_FR.UTF-8 zh_CN.UTF-8 zh_TW.UTF-8 hu.UTF-8 it_IT.UTF-8 ja_JP.UTF-8 ru_RU.UTF-8 es_ES.UTF-8 de_DE.UTF-8 ar_SA.UTF-8 af_ZA.UTF-8)

select_option $? 4 "${options[@]}"
langlocale=${options[$?]}

echo -ne "Your locale: ${langlocale} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
    set_option LANGLOCAL $langlocale;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    localeselect;;
    *) echo "Wrong option. Try again";localeselect;;
esac

}


keymap () {
echo -ne "
Please select keyboard layout from this list"
options=(by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru sg ua uk us)

select_option $? 4 "${options[@]}"
keymap=${options[$?]}

echo -ne "Your keyboards layout: ${keymap} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"
case ${options[$?]} in
    y|Y|yes|Yes|YES)
set_option KEYMAP $keymap
loadkeys $keymap;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    keymap;;
    *) echo "Wrong option. Try again";keymap;;
esac

}

lib32repo () {
echo -ne "
Do you want the Multilib repo ?"
options=(no yes)

select_option $? 4 "${options[@]}"
libchoice=${options[$?]}

echo -ne "Your choice : ${libchoice} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
set_option LIBCHOICE $libchoice;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    lib32repo;;
    *) echo "Wrong option. Try again";blackarch;;
esac

}

nonfree () {
echo -ne "
Do you want the nonfree repo ?"
options=(no yes)

select_option $? 4 "${options[@]}"
nonfree=${options[$?]}

echo -ne "Your choice : ${nonfree} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
    set_option NONFREE $nonfree;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    nonfree;;
    *) echo "Wrong option. Try again";blackarch;;
esac

}

nonfree32 () {
echo -ne "
Do you want the non free multilib repo ?"
options=(no yes)

select_option $? 4 "${options[@]}"
nonfreelib=${options[$?]}

echo -ne "Your choice : ${nonfreelib} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
set_option NONFREELIB $nonfreelib;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    nonfree32;;
    *) echo "Wrong option. Try again";blackarch;;
esac

}

userinfo () {
read -p "Please enter your username: " username
set_option USERNAME ${username,,} 
while true; do
  echo -ne "Please enter your password: \n"
  read -s password # read password without echo

  echo -ne "Please repeat your password: \n"
  read -s password2 # read password without echo

  if [ "$password" = "$password2" ]; then
    set_option PASSWORD $password
    break
  else
    echo -e "\nPasswords do not match. Please try again. \n"
  fi
done
while true; do
  echo -ne "Please enter your root password: \n"
  read -s rootpassword # read password without echo

  echo -ne "Please repeat your root password: \n"
  read -s rootpassword2 # read password without echo

  if [ "$rootpassword" = "$rootpassword2" ]; then
    set_option ROOTPASSWORD $rootpassword
    break
  else
    echo -e "\nPasswords do not match. Please try again. \n"
  fi
done
}

myhostname () {

read -rep "Please enter your hostname: " nameofmachine
clear
logo
echo -ne "Your Hostname : ${nameofmachine} \n"
echo -ne "Is this correct?
"
options=("Yes" "No")
select_option $? 1 "${options[@]}"

case ${options[$?]} in
    y|Y|yes|Yes|YES)
set_option NAME_OF_MACHINE $nameofmachine;;
    n|N|no|NO|No)
    clear
    echo "Please choose again"
    myhostname;;
    *) echo "Wrong option. Try again";myhostname;;
esac

}

efiformat () {

        #choice for formmating the EFI


        echo -ne "Do you want to format the EFI partition ? ${partition2}
    Choose No if it's already used by another system or Yes if it's a New partition"
    options=("Yes" "No")
    select_option $? 1 "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        echo "EFI partition will be Formatted"
        mkfs.vfat -F32 ${partition2};;
        n|N|no|NO|No)
        echo "Please make sure it's a valid EFI partition otherwise the following may fail"
        read -p "Press any key to resume";;
        *) echo "Wrong option. Try again";efiformat;;
    esac
}

swappartition () {

        #choice for Having Swap or not


        echo -ne "Do you have a Swap partition ?"
    
    options=("Yes" "No")
    select_option $? 1 "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        lsblk
        read -p "Please enter your SWAP partition (EX: /dev/sda2): " partition4
        set_option SWAPPART $partition4
        set_option SWAPON yes
        mkswap $partition4
        uuid4=$(blkid -o value -s UUID $partition4)
        set_option SWAPUUID $uuid4;;
        n|N|no|NO|No)
        set_option SWAPON no
        echo "No Swap Partition are gonna be used"
        read -p "Press any key to resume";;
        *) echo "Wrong option. Try again";swappartition;;
    esac
}






homefinal () {
clear
logo
set_option HOMEPART "yes"
set_option HOMESNAP "no"
uuid5=$(blkid -o value -s UUID $partition5)
set_option HOMEUUID $uuid5
}


homeformat () {

        #choice for Home Filesystem

        echo -ne "Do you want Btrfs or Ext4 For Home ?"
    
    options=("Btrfs" "Ext4")
    select_option $? 1 "${options[@]}"

    case ${options[$?]} in
        btrfs|Btrfs|BTRFS|b|B)
        mkfs.btrfs -L HOME -m single -f ${partition5}
        homefinal;;
        ext4|Ext4|EXT4|e|E)
        mkfs.ext4 -L HOME ${partition5}
        homefinal;;
        *) echo "Wrong option. Try again";homeformat;;
    esac
}

homepartition2 () {
        

        #choice for Formatting Home or Not
        logo
        lsblk
        read -p "Please enter your Home partition (EX: /dev/sda4): " partition5
        echo -ne "Do you want to format Home ?"
    
    options=("Yes" "No")
    select_option $? 1 "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        homeformat;;
        n|N|no|NO|No)
        echo "Home Partition is gonna be used as is"
        read -p "Press any key to resume"
        homefinal;;
        *) echo "Wrong option. Try again";homepartition2;;
    esac
}

homesnapchoice () {
echo -ne "
Do you want /Home to be included inside snapshot ? 
Be aware that doing so might result in lost data when rolling the system back to a previous state"

options=(yes no)

select_option $? 4 "${options[@]}"
homesnap=${options[$?]}

set_option HOMESNAP $homesnap
}

homepartition () {

        #choice for Having Separate Home or Not


        echo -ne "Do you want a separate Home partition ? (Doing so prevent home from being included in snapshot)"
    
    options=("Yes" "No")
    select_option $? 1 "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        clear
        logo
        homepartition2;;


        n|N|no|NO|No)
        clear
        logo
        echo "No Home Partition are gonna be used"
        set_option HOMEPART "no"
        homesnapchoice;;

        
        *) echo "Wrong option. Try again";homepartition;;
    esac
}


    clear
    logo
    keymap
    clear
    logo
    userinfo
    clear
    logo
    myhostname
    clear
    logo
    lsblk
    read -p "Please enter your EFI partition (EX: /dev/sda1): " partition2
    set_option EFIPART $partition2
    clear
    logo
    efiformat
    uuid2=$(blkid -o value -s UUID $partition2)
    set_option EFIUUID $uuid2
    clear
    logo
    swappartition
    clear
    logo
    lsblk
    homepartition
    clear
    logo
    lsblk
    read -p "Please enter your Root partition : (EX: /dev/sda3 ) " partition3
    set_option ROOTPART $partition3
    clear
    mkfs.btrfs -L ROOT -m single -f $partition3
    uuid3=$(blkid -o value -s UUID $partition3)
    set_option ROOTUUID $uuid3
