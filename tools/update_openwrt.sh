#!/bin/bash
source ./common/common.sh

echo "===INIT==UBUNTU=OPENWRT==="
sudo echo "SUDO ROOT"

args_mode=$1

if [ ! -f /usr/lib/libiconv.so ]; then
  ./install_openwrt_hostlib.sh
fi

show t "更新openwrt源"
rootdir=/works/openwrt

cd $rootdir/openwrt.git
git_prefix=`git log -1 --format="works/%ad_%h" --date=short`
git_targz=`git log -1 --format="openwrt_%ad_%h.tar.gz" --date=short`

if [ ! -f ../$git_targz -a ! -f ../backup/$git_targz ]; then
  show -i "导出最新版openwrt"
  git archive --format=tar --prefix=$git_prefix/ HEAD | gzip > ../$git_targz
  echo "$git_prefix" > ../lastgit
fi
cd $rootdir
if [ ! -d $git_prefix -a -f $git_targz ]; then
  show -i "解压最新版openwrt"
  #cd works
  tar zxvf $git_targz
  if [ ! -d $git_prefix.orig ]; then
    mv $git_prefix $git_prefix.orig
    tar zxvf $git_targz
  fi
  mv $git_targz backup/$git_targz
  #cd ..
fi

if [ -L openwrt ]; then
  rm -rf openwrt
fi

if [ ! -f openwrt -a -d $git_prefix ]; then
  ln -s $git_prefix openwrt
fi

if [ -d $git_prefix ]; then
  if [ -d dl -a ! -L $git_prefix/dl ]; then
    show -i "链接dl目录"
    ln -s ../../dl $git_prefix/dl
  fi
  if [ -d staging_dir -a ! -L $git_prefix/staging_dir ]; then
    show -i "链接staging_dir目录"
    ln -s ../../staging_dir $git_prefix/staging_dir
  fi
  if [ -d build_dir -a ! -L $git_prefix/build_dir ]; then
    show -i "链接build_dir目录"
    ln -s ../../build_dir $git_prefix/build_dir
  fi
  cd $git_prefix
  if [ ! -f feeds.conf ]; then
    show -i "复制feeds.conf文件"
    cp feeds.conf.default feeds.conf
  fi
  #awk '{if ($0 == "HOST_CONFIGURE_ARGS += --with-internal-glib") printf \
  #"HOST_CONFIGURE_ARGS += --with-internal-glib --enable-iconv=no --with-libiconv=gnu\n"; else printf $0"\n"}' \
  #tools/pkg-config/Makefile 1<>tools/pkg-config/Makefile
  #find_replace_line "tools/pkg-config/Makefile" "HOST_CONFIGURE_ARGS += --with-internal-glib" "HOST_CONFIGURE_ARGS += --with-internal-glib --enable-iconv=no --with-libiconv=gnu"
  if [ -z "$args_mode" ]; then
    show -i "更新并安装feeds"
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make defconfig
  fi
  
  #make defconfig
  find_replace_line .config "CONFIG_DOWNLOAD_FOLDER=\\\"\\\"" "CONFIG_DOWNLOAD_FOLDER=\\\"$rootdir/dl/\\\""
  echo "$git_prefix" > ../../usegit
  echo "==========================="
  echo "  现在可以编译openwrt 最新版了"
  echo "  cd $rootdir/$git_prefix"
  echo "  [option] ./scripts/feeds update -a"
  echo "  [option] ./scripts/feeds install -a"
  echo "  make defconfig"
  echo "  make menuconfig"
  echo "  [option] make download"
  echo "  [screen] make V=99"
  echo "  [screen] make -j 4 V=99"
  echo "==========================="
fi

