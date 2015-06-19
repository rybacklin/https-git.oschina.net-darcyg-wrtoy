#!/bin/sh

# OpenWRT USB Boot Disk Util, Powered by Manfeel
# Version : 2.00 2014-07-06

# display my banner ;-)

cat <<"_EOB"
[32;1m╔─────────────────────────────────────────────────╗
[32;1m│     [33;1m OpenWRT USB Disk Boot for                  [32;1m│ 
[32;1m│ [34;1m   _    _ ____ _____ _   _           _          [32;1m│         
[32;1m│ [34;1m  | |  | |  _ \_   _| \ | | ___   __| | ___     [32;1m│         
[32;1m│ [34;1m  | |  | | |_) || | |  \| |/ _ \ / _` |/ _ \    [32;1m│         
[32;1m│ [34;1m  | |/\| |  _ < | | | |\  | (_) | (_| |  __/    [32;1m│         
[32;1m│ [34;1m  |__/\__|_| \_\|_| |_| \_|\___/ \__,_|\___|    [32;1m│         
[32;1m│ [34;1m                                                [32;1m│         
[32;1m│                        [36;1mby manfeel@foxmail.com   [32;1m│ 
[32;1m╚─────────────────────────────────────────────────╝
[0m
_EOB

boardname=""
boardid=""
platform="ramips"
chipname="rt305x"
usbdev=""
tftproot="../tftpboot"

if [ -f ".boardname" ]; then
  boardname=`cat .boardname`
fi

if [ -f ".boardid" ]; then
  boardid=`cat .boardid`
fi

if [ -f ".platform" ]; then
  platform=`cat .platform`
fi

if [ -f ".chipname" ]; then
  chipname=`cat .chipname`
fi

if [ -f ".usbdev" ]; then
  usbdev=`cat .usbdev`
fi

if [ -f ".tftp" ]; then
  tftproot=`cat .tftp`
fi

uImage=$tftproot/vmlinux-$boardname.uImage
rootfs=$tftproot/openwrt-$platform-$chipname-$boardid-rootfs.tar.gz

if [ ! -f $uImage ]; then
	echo "没有找到$uImage文件"
	exit 1
fi

if [ ! -f $rootfs ]; then
	echo "没有找到$rootfs文件"
	exit 1
fi

echo "uImage: $uImage"
echo "rootfs: $rootfs"

if [ ! -z "$usbdev" ]; then
  if [ -e "$usbdev" ]; then
    DRIVE=$usbdev
  else
    echo "未检测到U盘"
  fi
fi

echo "DRIVE: $DRIVE | $usbdev #"

if [ -z "$DRIVE" ]; then
    if [ $1 ] ; then
        DRIVE=$1
    else
        echo -n "请输入U盘的设备名(如/dev/sdc)："
        read DRIVE
    fi
fi

# get USB disk size
SIZE=`sudo fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
if [ ! $SIZE ] ; then
	echo "没有找到指定的USB设备？请确认您输入了正确的设备名。"
	exit 1
else
	size_in_mb=`echo $SIZE/1024/1024 | bc`
	echo "U盘($DRIVE)的容量是 : ${size_in_mb}MB"
	echo -n "[31;1m正确么？ 请输入 'yes' 继续。(yes/no)[0m"
	read ans
	if [ $ans != "yes" -a $ans != "YES" ] ; then 
		echo "你必须输入yes才能继续进行安装！"
		exit 2
	fi
fi

# umount first
#while read line
#do
#    #[[ "$line" =~ "$DRIVE" ]] && echo "$DRIVE is Mounted"
#	dev=`echo $line | grep $DRIVE | awk '{print $1}'`
#	if [ $dev ] ; then
#		echo "umount $dev ..."
#		umount $dev
#	fi
#done < /proc/mounts

sudo umount ${DRIVE}1 2>/dev/null
sudo umount ${DRIVE}2 2>/dev/null
sudo umount ${DRIVE}3 2>/dev/null
sudo umount ${DRIVE}4 2>/dev/null
sudo umount ${DRIVE}5 2>/dev/null
sudo umount ${DRIVE}6 2>/dev/null

CYLINDERS=`echo $SIZE/255/63/512 | bc`
 
echo "[32;1m正在创建U盘分区...[0m"
# create 2 partitions
{
cat << _EOF
,32,c,*
,,,-
_EOF
} | sudo sfdisk --force -D -H 255 -S 63 -C $CYLINDERS $DRIVE > /dev/null
 
echo "[32;1m正在格式化分区...[0m" 

sudo mkfs.vfat -F 32 -n "boot" ${DRIVE}1 > /dev/null
sudo mkfs.ext4 -j -L "rootfs" ${DRIVE}2 > /dev/null

mkdir /tmp/boot
mkdir /tmp/rootfs

sudo mount ${DRIVE}1 /tmp/boot
sudo mount ${DRIVE}2 /tmp/rootfs

#copy uImage to boot
echo "[32;1m文件拷贝中，请稍侯...[0m"
sudo cp $uImage /tmp/boot/uImage
#tar root files to rootfs

sudo tar -xzf $rootfs -C /tmp/rootfs

# generate mac address & build eeprom file
EEPROM=lib/firmware/soc_wmac.eeprom
echo "[32;1m正在生成 $EEPROM ...[0m"

RAND_BYTES=`dd if=/dev/urandom count=3 bs=1 | hexdump -C`

echo $RAND_BYTES

A=`echo -n $RAND_BYTES | awk '{print $2}'` #awk '{printf("%02x",$3)}'`
B=`echo -n $RAND_BYTES | awk '{print $3}'`
C=`echo -n $RAND_BYTES | awk '{print $4}'`

MAC_ADDR_HEAD="00 4e 69 76 20"
# EEPROM xxd formatted content
{
cat <<EOE
000: 20 76 05 01 $MAC_ADDR_HEAD $A ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
020: ff ff ff ff ff ff ff ff $MAC_ADDR_HEAD $B $MAC_ADDR_HEAD $C 22 0c 00 00 ff ff 82 01 55 77 a8 aa
040: 8c 88 ff ff 0a 00 00 00 00 00 00 00 00 00 ff ff ff ff 04 04 04 03 03 03 03 03 03 04 04 04 04 04
060: 09 09 09 0a 0a 0a 0a 0b 0b 0b 0b 0c 0c 0c 80 ff ff ff 80 ff ff ff 00 00 ff ff ff ff ff ff ff ff
080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 20 ff ff ff ff ff ff ff ff ff ff ff ff ff 09 09
0e0: 08 08 06 00 07 07 06 00 08 08 06 00 07 07 06 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
1e0: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
EOE
} | xxd -r -c32 > /tmp/eeprom

sudo cp -f /tmp/eeprom /tmp/rootfs/$EEPROM

rm -f /tmp/eeprom

sudo umount ${DRIVE}1
sudo umount ${DRIVE}2

sudo rm -rf /tmp/boot 2>/dev/null
sudo rm -rf /tmp/rootfs 2>/dev/null

sudo eject ${DRIVE}

echo "\n[33;1m注意：必须刷入压缩包中的uboot.bin才能U盘启动。"
echo "[33;1mU盘创建完毕！请尽情享受U盘启动OpenWRT的快乐吧^_^"
echo "[33;1m如果你有任何问题或建议\n请访问我的博客 [36;1mhttp://blog.csdn.net/manfeel[0m"
