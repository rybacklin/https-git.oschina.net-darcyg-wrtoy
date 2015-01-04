#!/bin/bash
source ./common/common.sh

mode=$1
proj=$2
[ -z "$3" ] && type="x86" || type="$3"



[ "$mode" == "" ] && mode=$(get_jcfg_item .build.mode)
[ "$proj" == "" ] && proj=$(get_jcfg_item .build.proj)

is_proxychains=$(netstat -tln | grep ":7070" | grep "tcp ")
[ -z "$is_proxychains" ] && is_proxychains="" || is_proxychains="pc"

if [ "$type" == "ramips" ]; then
  #echo "$tftproot" > .tftp
  echo "mt7620" > .chipname
  #echo "$usbdev" > .usbdev
  echo "mtall" > .boardname
  echo "MTALL" > .boardid
  echo "ramips" > .platform
  echo "7620a" > .tftplink
elif [ "$type" == "x86" ]; then
  echo "x86" > .chipname
  echo "generic" > .boardname
  echo "GENERIC" > .boardid
  echo "x86" > .platform
  echo "x86img" > .tftplink
elif [ "$type" == "x64" ]; then
  echo "x86_64" > .chipname
  echo "" > .boardname
  echo "GENERIC" > .boardid
  echo "x86_64" > .platform
  echo "x64img" > .tftplink
  type="x86"
elif [ "$type" == "rpi" ]; then
  echo "brcm2708" > .chipname
  echo "rpi" > .boardname
  echo "sdcard" > .boardid
  echo "rpi" > .platform
  echo "rpiimg" > .tftplink
  type="rpi"
fi

m="i"
echo $mode
[ -z "$proj" -o "$proj" == "empty" -o "$mode" == "e" ] && m="e"

[ -z "$mode" -o "$mode" == "c" ] && exit 0

set_jcfg_item .build.mode $mode
set_jcfg_item .build.proj $proj

[ "$mode" == "i" -o "$mode" == "e" ] && ./build.sh i
[ "$mode" == "r" ] && ./build.sh reset
[ "$mode" == "u" ] && m="u"

#./build.sh c2d
#./build.sh nf #clean and update all feeds
#./build.sh fc #commonpack
if [ "$m" == "i" ]; then
  ./build.sh hw
  ./build.sh f $is_proxychains
  #./build.sh m
  ./build.sh Pw $proj $type
  ./build.sh def
  ./build.sh c2ba
  ./build.sh pw $proj $type
  ./build.sh clear_tmp
  ./build.sh f
  #./build.sh m
  ./build.sh def
  ./build.sh pw $proj $type
  ./build.sh def
  ./build.sh c2bb
elif [ "$m" == "e" ]; then
  ./build.sh hw
  ./build.sh f $is_proxychains
elif [ "$m" == "u" ]; then
  ./build.sh hw
  ./build.sh nf $is_proxychains
  ./build.sh pw $proj $type
  ./build.sh f
  #./build.sh m
  ./build.sh def
fi