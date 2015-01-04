#!/bin/bash
source ./common/common.sh

echo "===INIT==UBUNTU=OPENWRT=HOSTLIB==="
sudo echo "SUDO ROOT"

read -p "是否安装全编译工具支持(y/N)" READMODE

show t "安装pyyaml工具"
  install_pip_pack "pyyaml"

show t "安装argtools工具"
  install_pip_pack "argtools"

show t "安装openwrt编译支持基本库"
  install_apt_pack "force|g++ libncurses5-dev zlib1g-dev bison flex unzip autoconf gawk make"
  install_apt_pack "force|gettext gcc binutils patch bzip2 libz-dev asciidoc subversion"
  install_apt_pack "force|libtool screen cvs libxml-parser-perl e2fslibs-dev"

show t "安装putty cu minicom ckermit等超级终端工具"
  install_apt_pack "force|putty cu minicom ckermit"
  install_apt_pack "force|gtkterm terminator "
  #install_apt_pack "force|yakuake"
  tmp_file=~/.kermrc
  echo "set line /dev/ttyUSB0" > $tmp_file
  echo "set speed 57600" >> $tmp_file
  echo "set carrier-watch off" >> $tmp_file
  echo "set handshake none" >> $tmp_file
  echo "set flow-control none" >> $tmp_file
  echo "robust" >> $tmp_file
  echo "set parity none" >> $tmp_file
  echo "set stop-bits 1" >> $tmp_file
  echo "set file type bin" >> $tmp_file
  echo "set file name lit" >> $tmp_file
  echo "set rec pack 1000" >> $tmp_file
  echo "set send pack 8096" >> $tmp_file
  echo "set window 5" >> $tmp_file
  echo "set protocol xmodem" >> $tmp_file
  echo "set protocol zmodem" >> $tmp_file
  
show t "安装tftpd tftp工具"
  install_apt_pack "force|tftpd-hpa tftp-hpa"
  tmp_file=/etc/default/tftpd-hpa
  sudo chown $USER:$USER $tmp_file
  echo "# /etc/default/tftpd-hpa" > $tmp_file
  echo "RUN_DAEMON=\"yes\"" >> $tmp_file
  echo "TFTP_USERNAME=\"tftp\"" >> $tmp_file
  echo "TFTP_DIRECTORY=\"/works/openwrt/tftpboot\"" >> $tmp_file
  echo "TFTP_ADDRESS=\"[::]:69\"" >> $tmp_file
  echo "TFTP_OPTIONS=\"--secure\"" >> $tmp_file
  sudo chown root:root $tmp_file
  if [ ! -d /works/openwrt/tftpboot ]; then
    chk_mkdir /works/openwrt/tftpboot sudo
  fi
  sudo chmod 777 /works/openwrt/tftpboot
  sudo service tftpd-hpa restart

show t "安装nfs工具"
  install_apt_pack "force|nfs-kernel-server"
  tmp_file=/etc/exports
  sudo chown $USER:$USER $tmp_file
  echo "/works/openwrt/nfs *(rw,sync,rw,sync,no_subtree_check,root_squash)" > $tmp_file
  sudo chown root:root $tmp_file
  chk_mkdir /works/openwrt/nfs
  sudo exportfs -rav


if [ "y" == "$READMODE" ]; then
  show t "安装openwrt编译支持扩展库"
  install_apt_pack "force|sphinxsearch sphinx-common bzr default-jdk sdcc"
fi

show t "git安装libiconv-1.14"
tmpdir=/works/openwrt/thirdparty_libs
if [ ! -d $tmpdir ]; then
  chk_mkdir $tmpdir
fi
cd $tmpdir

iconvlibdir=$tmpdir/iconv-1.14-ubuntu12
iconvliburl=http://git.oschina.net/darcyg/iconv-1.14-ubuntu12.git
chk_gitcloneurl "libiconv" "$iconvlibdir" "$iconvliburl"
iconvheader=/usr/include/iconv.h
iconvlibstatic=/usr/lib/libiconv.a
iconvlibshared=/usr/lib/libiconv.so.2
if [ -d $iconvlibdir -a ! -f $iconvlibstatic ]; then
  cd $iconvlibdir
  ./configure --prefix=/usr --enable-static=yes
  make
  sudo make install
  if [ ! -f $iconvlibshared ]; then
    sudo ln -s /usr/local/lib/libiconv.so  /usr/lib/libiconv.so
    sudo ln -s /usr/local/lib/libiconv.so.2  /usr/lib/libiconv.so.2
    sudo ln -s /usr/local/lib/libiconv.so.2.5.1  /usr/lib/libiconv.so.2.5.1
  fi
fi

