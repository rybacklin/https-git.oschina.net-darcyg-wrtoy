#!/bin/bash
source ./common/common.sh

script_dir=`pwd`

is_feeds=""
is_menu=""
is_down=""
is_make=""
is_debug=""
is_clear_dir=""
is_copy=""
is_set=""
showdebug=""
boardname=""
boardid=""
platform="ramips"
chipname="rt305x"
targetbin="5350"
rootfs=""
usbdev=""
tftproot="../tftpboot"
is_cfgbak=""
is_cfgdef=""
is_extra=""
is_install=""
has_cmd=false
cmd_flag=""
proj_mode=""
proj_name=""
proj_type="ramips"
is_proxychains=""
package_name=""
is_makepackage=""
do_action=""
vertag=""


for i in $@
do
    if [ $has_cmd == true ]; then
      #echo "has_cmd $cmd_flag"
      if [ "$cmd_flag" == "p" -o "$cmd_flag" == "pw" -o "$cmd_flag" == "pf" \
        -o "$cmd_flag" == "P" -o "$cmd_flag" == "Pw" -o "$cmd_flag" == "Pf" ]; then
        proj_name=$i
        has_cmd=false
        #echo $proj_name
      fi
      if [ "$cmd_flag" == "mp" -o "$cmd_flag" == "mpc" -o "$cmd_flag" == "mpi" ]; then
        package_name=$i
        has_cmd=false
        #echo $proj_name
      fi
      continue
    fi

    if [ "$i" == "f" -o "$i" == "feeds" ]; then
        is_feeds="1"
    elif [ "$i" == "pc" -o "$i" == "proxychains" ]; then
        is_proxychains="proxychains"
    elif [ "$i" == "i" -o "$i" == "install" ]; then
        is_install="1"
    elif [ "$i" == "fc" ]; then
        is_feeds="commonpack"
    elif [ "$i" == "u" -o "$i" == "update" ]; then
        is_install="2"
    elif [ "$i" == "r" -o "$i" == "reset" ]; then
        is_install="3"
    elif [ "$i" == "nf" -o "$i" == "newfeeds" ]; then
        is_feeds="2"
    elif [ "$i" == "m" -o "$i" == "menu" ]; then
        is_menu="1"
    elif [ "$i" == "km" -o "$i" == "kernelmenu" ]; then
        is_menu="2"
    elif [ "$i" == "b" -o "$i" == "build" -o "$i" == "make" ]; then
        is_make="1"
    elif [ "$i" == "def" -o "$i" == "defconfig" -o "$i" == "defcfg" ]; then
        is_make="2"
    elif [ "$i" == "d" -o "$i" == "debug" ]; then
        showdebug="V=s"
    elif [ "$i" == "down" -o "$i" == "download" ]; then
        is_down="1"
    elif [ "$i" == "down+" -o "$i" == "download+" ]; then
        is_down="2"
        is_proxychains="proxychains"
    elif [ "$i" == "j" ]; then
        is_debug="-j -l8"
    elif [ "$i" == "j2" ]; then
        is_debug="-j 2 -l8"
    elif [ "$i" == "j4" ]; then
        is_debug="-j 4 -l8"
    elif [ "$i" == "j8" ]; then
        is_debug="-j 8 -l8"
    elif [ "$i" == "clear_tmp" ]; then
        is_clear_dir="tmp"
    elif [ "$i" == "clean" ]; then
        is_clear="clean"
    elif [ "$i" == "c" ]; then
        is_copy="1"
    elif [ "$i" == "set" ]; then
        is_set="1"
    elif [ "$i" == "setup" ]; then
        is_set="2"
    elif [ "$i" == "usb" ]; then
        is_extra="usb"
    elif [ "$i" == "usbcp" ]; then
        is_extra="usbcp"
    elif [ "$i" == "cfg2bak" -o "$i" == "c2b" ]; then
        is_cfgbak="1"
    elif [ "$i" == "bak2cfg" -o "$i" == "b2c" ]; then
        is_cfgbak="2"
    elif [ "$i" == "cfg2baka" -o "$i" == "c2ba" ]; then
        is_cfgbak="3"
    elif [ "$i" == "baka2cfg" -o "$i" == "ba2c" ]; then
        is_cfgbak="4"
    elif [ "$i" == "cfg2bakb" -o "$i" == "c2bb" ]; then
        is_cfgbak="5"
    elif [ "$i" == "bakb2cfg" -o "$i" == "bb2c" ]; then
        is_cfgbak="6"
    elif [ "$i" == "cfg2bakc" -o "$i" == "c2bc" ]; then
        is_cfgbak="7"
    elif [ "$i" == "bakc2cfg" -o "$i" == "bc2c" ]; then
        is_cfgbak="8"
    elif [ "$i" == "cfg2bakd" -o "$i" == "c2bd" ]; then
        is_cfgbak="9"
    elif [ "$i" == "bakd2cfg" -o "$i" == "bd2c" ]; then
        is_cfgbak="10"
    elif [ "$i" == "cfg2bake" -o "$i" == "c2be" ]; then
        is_cfgbak="11"
    elif [ "$i" == "bake2cfg" -o "$i" == "be2c" ]; then
        is_cfgbak="12"
    elif [ "$i" == "cfg2def" -o "$i" == "c2d" ]; then
        is_cfgdef="1"
    elif [ "$i" == "def2cfg" -o "$i" == "d2c" ]; then
        is_cfgdef="2"
    elif [ "$i" == "bak2def" -o "$i" == "b2d" ]; then
        is_cfgdef="3"
    elif [ "$i" == "def2bak" -o "$i" == "d2b" ]; then
        is_cfgdef="4"
    elif [ "$i" == "tftp" ]; then
        do_action="reset_tftp"
    elif [ "$i" == "x86" ]; then
        proj_type="x86"
    elif [ "$i" == "ramips" ]; then
        proj_type="ramips"
    elif [ "$i" == "rpi" -o "$i" == "brcm2708" -o "$i" == "brcm2835" ]; then
        proj_type="rpi"
    elif [ "$i" == "p" -o "$i" == "pf" -o "$i" == "pw" \
      -o "$i" == "P" -o "$i" == "Pf" -o "$i" == "Pw" ]; then
        has_cmd=true
        cmd_flag="$i"
    elif [ "$i" == "hw" -o "$i" == "hf" -o "$i" == "h" ]; then
        cmd_flag="$i"
    elif [ "$i" == "mp" -o "$i" == "mpc" -o "$i" == "mpi" ]; then
        is_makepackage="$i"
        has_cmd=true
        cmd_flag="$i"
    fi
done

[ -f ".boardname" ] && boardname=$(cat .boardname)
[ -f ".boardid" ] && boardid=$(cat .boardid)
[ -f ".platform" ] && platform=$(cat .platform)
[ -f ".chipname" ] && chipname=$(cat .chipname)
[ -f ".usbdev" ] && usbdev=$(cat .usbdev)
[ -f ".tftp" ] && tftproot=$(cat .tftp)
[ -f ".tftplink" ] && targetbin=$(cat .tftplink)
[ -f ".vertag" ] && vertag=$(cat .vertag)

if [ ! -z "$is_set" ]; then
  echo "configure board info."
  if [ "$is_set" == "2" ]; then
    read -p "tftproot($tftproot):" tftp_root
    if [ ! -z "$tftp_root" ]; then
      tftproot=$tftp_root
      echo "$tftproot" > .tftp
    fi
    read -p "usbdev($usbdev):" usb_dev
    if [ ! -z "$usb_dev" ]; then
      usbdev=$usb_dev
      echo "$usbdev" > .usbdev
    fi
  fi
  read -p "boardname($boardname):" board_name
  if [ ! -z "$board_name" ]; then
    boardname=$board_name
    echo "$boardname" > .boardname
  fi
  read -p "boardtagid($boardid):" board_id
  if [ ! -z "$board_id" ]; then
    boardid=$board_id
    echo "$boardid" > .boardid
  fi
  read -p "platform($platform):" plat_name
  if [ ! -z "$plat_name" ]; then
    platform=$plat_name
    echo "$platform" > .platform
  fi
  read -p "chipname($chipname):" chip_name
  if [ ! -z "$chip_name" ]; then
    chipname=$chip_name
    echo "$chipname" > .chipname
  fi
  read -p "tftplink($targetbin):" target_name
  if [ ! -z "$target_name" ]; then
    targetbin=$target_name
    echo "$targetbin" > .tftplink
  fi
fi

binfile=openwrt-$vertag$platform-$chipname-$boardname-squashfs-sysupgrade.bin
rootfs=openwrt-$platform-$chipname-$boardid-rootfs.tar.gz

cd ..
root=`pwd`
cd openwrt
openwrt_dir=`pwd`
uImage_path=build_dir/$(cd build_dir/target*;basename `pwd`)/linux-"$platform"_"$chipname"/vmlinux-"$boardname".uImage
uImage_file=$(basename $uImage_path)
#openwrt-ramips-mt7620a-DGWRTDEVBOARDIIUSB-rootfs
echo $rootfs

echo "=============================================="
echo " BoardName : $boardname"
echo " BoardTag  : $boardid"
echo " Platform  : $platform"
echo " ChipName  : $chipname"
echo " TftpLink  : $targetbin"
echo " TargetBin : $binfile"
echo " uImageBin : $uImage_file"
echo " RootfsBin : $rootfs"
echo " USB Dev   : $usbdev"
echo " TFTP Root : $tftproot"
echo "=============================================="
echo "进入openwrt项目目录"

if [ ! -z "$is_install" ]; then
  cd $script_dir
  if [ "$is_install" == "1" ]; then
    $is_proxychains ./install_openwrt.sh nofeeds
  fi
  if [ "$is_install" == "2" ]; then
    $is_proxychains ./update_openwrt.sh nofeeds
  fi
  if [ "$is_install" == "3" ]; then
    $is_proxychains ./reset_openwrt.sh nofeeds
  fi
  cd $openwrt_dir
fi

if [ ! -z "$proj_name" ]; then
  cd $script_dir
  [ "$cmd_flag" == "P" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name -P
  [ "$cmd_flag" == "Pf" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name -f -P
  [ "$cmd_flag" == "Pw" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name -w -P
  [ "$cmd_flag" == "p" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name
  [ "$cmd_flag" == "pf" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name -f
  [ "$cmd_flag" == "pw" ] && $is_proxychains ./patch_openwrt.py proj -t $proj_type $proj_name -w
  set_jcfg_item .build.proj $proj_name
  cd $openwrt_dir
else
  cd $script_dir
  [ "$cmd_flag" == "h" ] && $is_proxychains ./patch_openwrt.py proj -H empty
  [ "$cmd_flag" == "hf" ] && $is_proxychains ./patch_openwrt.py proj -H -f empty
  [ "$cmd_flag" == "hw" ] && $is_proxychains ./patch_openwrt.py proj -H -w empty
  cd $openwrt_dir
fi

if [ ! -z "$is_feeds" ]; then
  if [ "$is_feeds" == "2" ]; then
    rm -Rf ./feeds/*
  fi
  #echo $is_proxychains
  if [ "$is_feeds" == "1" -o "$is_feeds" == "2" ]; then
    echo "update all feeds."
    $is_proxychains ./scripts/feeds update -a
    $is_proxychains ./scripts/feeds update luci2
    $is_proxychains ./scripts/feeds update oldpackages
    $is_proxychains ./scripts/feeds update commonpack
    $is_proxychains ./scripts/feeds install -a
  else
    echo "update $is_feeds feed!"
    $is_proxychains ./scripts/feeds update $is_feeds
    $is_proxychains ./scripts/feeds install -a
  fi
fi

if [ ! -z "$is_clear_dir" -a -d "$is_clear_dir" ]; then
  echo "clear tmp folder."
  rm -Rf $is_clear_dir
fi

if [ ! -z "$is_clear" ]; then
  make $is_clear
fi

if [ ! -z "$is_menu" ]; then
  if [ "$is_menu" == "1" ]; then
    echo "run menuconfig"
    make menuconfig
  elif [ "$is_menu" == "2"  ]; then
    echo "run kernel_menuconfig"
    make kernel_menuconfig
  fi
fi

if [ ! -z "$is_down" ]; then
  if [ "$is_down" == "1" ]; then
    echo "download packages source code."
    $is_proxychains make download $showdebug
  else
    echo "download packages source code from proxy."
    $is_proxychains make download $showdebug
  fi
fi

if [ ! -z "$is_makepackage" -a ! -z "$package_name" ]; then
  echo "make package : $package_name $is_debug"
  [ "$is_makepackage" == "mp" -o "$is_makepackage" == "mpc" ] && \
    $is_proxychains make package/$package_name/compile $is_debug $showdebug
  [ "$is_makepackage" == "mpi" ] && \
    $is_proxychains make package/$package_name/install $is_debug $showdebug
fi

if [ ! -z "$is_make" ]; then
  echo "build board firmware."
  $is_proxychains make defconfig
  [ "$is_make" == "1" ] && $is_proxychains make $is_debug $showdebug
fi

if [ ! -z "$is_copy" ]; then
  if [ $platform == "ramips" ]; then
    echo "copy *.bin to tftpboot folder..."
    cp -f bin/$platform/*.bin ../../tftpboot/
    if [ -f bin/$platform/$rootfs ]; then
      echo "copy openwrt*-rootfs.* to tftpboot folder..."
      cp -f bin/$platform/openwrt*-rootfs.* ../../tftpboot/
    fi
    if [ -f $uImage_path ]; then
      echo "copy uImage to tftpboot folder..."
      cp -f $uImage_path ../../tftpboot/$uImage_file
    fi
    if [ ! -z "$boardname" -a ! -z "$platform" -a ! -z "$chipname" -a ! -z "$targetbin" ]; then
      if [ -f "../../tftpboot/$targetbin" ]; then
        fsize=$(ls -l ../../tftpboot/$targetbin | awk '{print $5}')
        fsizeh=$(ls -lh ../../tftpboot/$targetbin | awk '{print $5}')
        echo "$targetbin filesize: $fsize byte ($fsizeh)"
        echo "link $targetbin exists! rm $targetbin link!"
        rm ../../tftpboot/$targetbin
      fi
      if [ ! -f "../../tftpboot/$targetbin" -a -f "../../tftpboot/$binfile" ]; then
        echo "link $binfile to $targetbin"
        ln -s $binfile ../../tftpboot/$targetbin
        fsize=$(ls -l ../../tftpboot/$binfile | awk '{print $5}')
        fsizeh=$(ls -lh ../../tftpboot/$binfile | awk '{print $5}')
        echo "$targetbin filesize: $fsize byte ($fsizeh)"
      fi
    fi
  elif [ $platform == "x86" -o $platform == "x86_64" -o $platform == "x64" ]; then
    echo "copy *.img.gz to tftpboot folder..."
    cp -f bin/$platform/*.img.gz ../../tftpboot/
    # openwrt-x86-generic-combined-ext4
    # openwrt-x86-generic-combined-squashfs.img.gz
    if [ ! -z "$platform" ]; then
      #imggzfile="openwrt-$platform-$boardname-combined-squashfs.img.gz"
      #imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      [ -z "$boardname" ] && imggzfile="openwrt-$platform-combined-squashfs.img.gz" \
        || imggzfile="openwrt-$platform-$boardname-combined-squashfs.img.gz"
      [ -z "$boardname" ] && imgfile="openwrt-$platform-combined-squashfs.img" \
        || imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      #echo $imggzfile
      if [ -f "../../tftpboot/$imgfile" ]; then
        fsize=$(ls -l ../../tftpboot/$imgfile | awk '{print $5}')
        fsizeh=$(ls -lh ../../tftpboot/$imgfile | awk '{print $5}')
        echo "$imgfile filesize: $fsize byte ($fsizeh)"
        echo "link $imgfile exists! rm $imgfile file!"
        rm ../../tftpboot/$imgfile
      fi
      if [ ! -f "../../tftpboot/$imgfile" -a -f "../../tftpboot/$imggzfile" ]; then
        echo "gunzip $imggzfile to $imgfile"
        gunzip -k ../../tftpboot/$imggzfile
        if [ -f "../../tftpboot/$imgfile" ]; then
          fsize=$(ls -l ../../tftpboot/$imgfile | awk '{print $5}')
          fsizeh=$(ls -lh ../../tftpboot/$imgfile | awk '{print $5}')
          echo "$imgfile filesize: $fsize byte ($fsizeh)"
        else
          echo "Don't gunzip! $imgfile NOT Exists!"
        fi
      fi
    fi
  elif [ $platform == "rpi" -o $platform == "brcm2708" -o $platform == "brcm2835" ]; then
    # openwrt-x86-generic-combined-ext4
    # openwrt-x86-generic-combined-squashfs.img.gz
    if [ ! -z "$platform" ]; then
      #imggzfile="openwrt-$platform-$boardname-combined-squashfs.img.gz"
      #imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      imgfile="openwrt-brcm2708-sdcard-vfat-ext4.img"
      #echo $imggzfile
      if [ -f "../../tftpboot/$imgfile" ]; then
        fsize=$(ls -l ../../tftpboot/$imgfile | awk '{print $5}')
        fsizeh=$(ls -lh ../../tftpboot/$imgfile | awk '{print $5}')
        echo "$imgfile filesize: $fsize byte ($fsizeh)"
        echo "link $imgfile exists! rm $imgfile file!"
        rm ../../tftpboot/$imgfile
      fi
      if [ ! -f "../../tftpboot/$imgfile" ]; then
        cp -f bin/brcm2708/openwrt-brcm2708-sdcard-vfat-ext4.img ../../tftpboot/
      fi
    fi
  fi
fi

if [ ! -z "$is_cfgbak" ]; then
  cfgdst=".config.$targetbin"
  cfgdef=".config.$targetbin.def"
  if [ "$is_cfgbak" == "1" ]; then
    echo " copy .config to $cfgdst"
    cp .config $cfgdst
  elif [ "$is_cfgbak" == "2" ]; then
    echo " copy $cfgdst to .config"
    cp $cfgdst .config
  elif [ "$is_cfgbak" == "3" ]; then
    echo " copy .config to $cfgdst.a"
    cp .config $cfgdst.a
  elif [ "$is_cfgbak" == "4" ]; then
    echo " copy $cfgdst.a to .config"
    cp $cfgdst.a .config
  elif [ "$is_cfgbak" == "5" ]; then
    echo " copy .config to $cfgdst.b"
    cp .config $cfgdst.b
  elif [ "$is_cfgbak" == "6" ]; then
    echo " copy $cfgdst.b to .config"
    cp $cfgdst.b .config
  elif [ "$is_cfgbak" == "7" ]; then
    echo " copy .config to $cfgdst.c"
    cp .config $cfgdst.c
  elif [ "$is_cfgbak" == "8" ]; then
    echo " copy $cfgdst.c to .config"
    cp $cfgdst.c .config
  elif [ "$is_cfgbak" == "9" ]; then
    echo " copy .config to $cfgdst.d"
    cp .config $cfgdst.d
  elif [ "$is_cfgbak" == "10" ]; then
    echo " copy $cfgdst.d to .config"
    cp $cfgdst.d .config
  elif [ "$is_cfgbak" == "11" ]; then
    echo " copy .config to $cfgdst.e"
    cp .config $cfgdst.e
  elif [ "$is_cfgbak" == "12" ]; then
    echo " copy $cfgdst.e to .config"
    cp $cfgdst.e .config
  fi
fi

if [ ! -z "$is_cfgdef" ]; then
  cfgdst=".config.$targetbin"
  cfgdef=".config.$targetbin.def"
  if [ "$is_cfgdef" == "1" ]; then
    echo " copy .config to $cfgdef"
    cp .config $cfgdef
  elif [ "$is_cfgdef" == "2" ]; then
    echo " copy $cfgdef to .config"
    cp $cfgdef .config
  elif [ "$is_cfgdef" == "3" ]; then
    echo " copy $cfgdst to $cfgdef"
    cp $cfgdst $cfgdef
  elif [ "$is_cfgdef" == "4" ]; then
    echo " copy $cfgdef to $cfgdst"
    cp $cfgdef $cfgdst
  fi
fi

if [ ! -z "$do_action" ]; then
  [ "$do_action" == "reset_tftp" ] && sudo service tftpd-hpa restart
fi

if [ ! -z "$is_extra" ]; then
  if [ $platform == "ramips" ]; then
    if [ "$is_extra" == "usb" ]; then
      echo " "
      ls -l /dev/sd* | awk '{print "  " $10 "\t" $3 "/" $4 "\t" $5$6 "\t" $1}'
      echo " "
      read -p "  Write Image To Disk $usbdev NOW (Y/n)?" iswritesel
      if [ ! -z "$iswritesel" ]; then
        if [ "$iswritesel" == "y" -o "$iswritesel" == "Y" -o "$iswritesel" == "yes" -o "$iswritesel" == "YES" ]; then
          cd $script_dir
          ./instusb.sh
        fi
      fi
    fi
  elif [ $platform == "x86" -o $platform == "x86_64" -o $platform == "x64" ]; then
    if [ "$is_extra" == "usb" ]; then
      #imgfile="openwrt-$platform-$boardname-combined-ext4.img"
      #imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      [ -z "$boardname" ] && imgfile="openwrt-$platform-combined-squashfs.img" \
        || imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      if [ -f "../../tftpboot/$imgfile" ]; then
        echo " "
        echo "DISK IMAGE File ../../tftpboot/$imgfile Exists!"
        ls -l /dev/sd* | awk '{print "  " $10 "\t" $3 "/" $4 "\t" $5$6 "\t" $1}'
        echo " "
        read -p "  Write Image To Disk $usbdev NOW (Y/n)?" iswritesel
        if [ ! -z "$iswritesel" ]; then
          if [ "$iswritesel" == "y" -o "$iswritesel" == "Y" -o "$iswritesel" == "yes" -o "$iswritesel" == "YES" ]; then
            sudo echo "SUPER USER"
            sudo dd if=../../tftpboot/$imgfile of=$usbdev conv=fsync
          fi
        fi
      fi
    fi
    if [ "$is_extra" == "usbcp" ]; then
      [ -z "$boardname" ] && imgfile="openwrt-$platform-combined-squashfs.img" \
        || imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      projname=$(get_jcfg_item ".build.proj" $script_dir/.jconfig)
      #[ -z $projname ] && projname="nodefprj"
      datestr=$(now)
      [ -z "$boardname" ] && oimgfile="$projname-$platform-combined-squashfs_$datestr.img" \
        || oimgfile="$projname-$platform-$boardname-combined-squashfs_$datestr.img"
      #echo "$oimgfile"
      if [ -f "../../tftpboot/$imgfile" ]; then
        echo " "
        echo "DISK IMAGE File ../../tftpboot/$imgfile Exists!"
        ls -l /dev/sd* | awk '{print "  " $10 "\t" $3 "/" $4 "\t" $5$6 "\t" $1}'
        echo " "
        read -p "  Write Image To Disk $usbdev NOW (Y/n)?" iswritesel
        mntpath=$(df -h | grep $usbdev | awk '{print $6}')
        if [ -d $mntpath ]; then
          echo "  $usbdev mount to $mntpath"
          echo "  write to $oimgfile"
          #cp ../../tftpboot/$imgfile $mntpath/$oimgfile
          dd if=../../tftpboot/$imgfile of=$mntpath/$oimgfile conv=fsync
        else
          echo "$usbdev no mount"
        fi
      fi
    fi
  elif [ $platform == "rpi" -o $platform == "brcm2708" -o $platform == "brcm2835" ]; then
    if [ "$is_extra" == "usb" ]; then
      #imgfile="openwrt-$platform-$boardname-combined-ext4.img"
      #imgfile="openwrt-$platform-$boardname-combined-squashfs.img"
      #openwrt-brcm2708-sdcard-vfat-ext4.img
      imgfile="openwrt-brcm2708-sdcard-vfat-ext4.img"
      if [ -f "../../tftpboot/$imgfile" ]; then
        echo " "
        echo "DISK IMAGE File ../../tftpboot/$imgfile Exists!"
        ls -l /dev/sd* | awk '{print "  " $10 "\t" $3 "/" $4 "\t" $5$6 "\t" $1}'
        echo " "
        read -p "  Write Image To Disk $usbdev NOW (Y/n)?" iswritesel
        if [ ! -z "$iswritesel" ]; then
          if [ "$iswritesel" == "y" -o "$iswritesel" == "Y" -o "$iswritesel" == "yes" -o "$iswritesel" == "YES" ]; then
            sudo echo "SUPER USER"
            sudo dd if=../../tftpboot/$imgfile of=$usbdev conv=fsync
          fi
        fi
      fi
    fi
    if [ "$is_extra" == "usbcp" ]; then
      #openwrt-brcm2708-sdcard-vfat-ext4.img
      imgfile="openwrt-brcm2708-sdcard-vfat-ext4.img"
      projname=$(get_jcfg_item ".build.proj" $script_dir/.jconfig)
      #[ -z $projname ] && projname="nodefprj"
      datestr=$(now)
      oimgfile="openwrt-brcm2708-sdcard-vfat-ext4_$datestr.img"
      #echo "$oimgfile"
      if [ -f "../../tftpboot/$imgfile" ]; then
        echo " "
        echo "DISK IMAGE File ../../tftpboot/$imgfile Exists!"
        ls -l /dev/sd* | awk '{print "  " $10 "\t" $3 "/" $4 "\t" $5$6 "\t" $1}'
        echo " "
        read -p "  Write Image To Disk $usbdev NOW (Y/n)?" iswritesel
        mntpath=$(df -h | grep $usbdev | awk '{print $6}')
        if [ -d $mntpath ]; then
          echo "  $usbdev mount to $mntpath"
          echo "  write to $oimgfile"
          #cp ../../tftpboot/$imgfile $mntpath/$oimgfile
          dd if=../../tftpboot/$imgfile of=$mntpath/$oimgfile conv=fsync
        else
          echo "$usbdev no mount"
        fi
      fi
    fi
  fi
fi
