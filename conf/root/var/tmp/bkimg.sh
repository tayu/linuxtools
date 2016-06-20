#! /bin/sh


# check user
if [ "root" != "`whoami`" ]; then
    echo "Must be root"
    exit 1
fi


# do backup at share directory
umount /home
cp /home.img /media/sf_share/home.img
mount -a

echo "donw"

