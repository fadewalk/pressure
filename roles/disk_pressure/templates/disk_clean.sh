#!/bin/sh

if [ -z $1 ]; then
    printf "Usage: %s <Wipe Level>\n" $0
    printf "Wipe Level: meta, dd or shred\n"
    exit
elif [ "$1" == "meta" ]; then
    wipeLevel="meta"
elif [ "$1" == "dd" ]; then
    wipeLevel="dd"
elif [ "$1" == "shred" ]; then
    wipeLevel="shred"
else
    printf "Usage: %s <Wipe Level>\n" $0
    printf "Wipe Level: meta, dd or shred\n"
    exit
fi
    
for i in $(lsblk | grep -v loop | grep disk | awk '{print $1}' | sort)
do
{
    # If not root disk, then continue next loop.
    # Check if MBR is at this disk. 
    ifMBRStart=$(dd if="/dev/""$i" bs=1 count=512 2>/dev/null | hexdump | sed -n '1p' | awk '{print $2}')
    BRID=$(dd if="/dev/""$i" bs=1 count=512 2>/dev/null | hexdump | grep 1f0 | awk '{print $NF}')
    if [ "$ifMBRStart" == "63eb" ] && [ "$BRID" == "aa55" ]; then
        printf "%s is root disk, skip it.\n" "/dev/""$i"
        continue
    fi

    # Or check if device is specific name like:
    # if [ "$i" == "sda" ]; then continue; fi

    printf "clean %s\n" "/dev/""$i"
    # Erase devices metadata
    if [ $wipeLevel == "meta" ]; then
        wipefs --force --all "/dev/""$i"  
        sgdisk -Z "/dev/""$i"  
    # Erase block devices
    elif [ $wipeLevel == "dd" ]; then
        diskSizebyte=$(lsblk -Pbdi -oNAME,SIZE | grep $i | awk '{print $2}' | sed 's/SIZE="//' | sed 's/"//')
        let "diskSizemb=$diskSizebyte/4096"
        dd if=/dev/zero of="/dev/""$i" bs=4k count=$diskSizemb 
		sync
    elif [ $wipeLevel == "shred" ]; then
        shred --force --zero --verbose --iterations 0 "/dev/""$i" 
    fi
} &
done

sleep 0.5
printf "Cleaning...\n"
