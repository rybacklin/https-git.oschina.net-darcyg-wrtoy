#!/bin/bash

source common/common.sh common

addOption --demo-mtall \
  flagTrue dest=demo_mtall \
  help="set board mtall(demo) ramips platform"

addOption --mt7620-mtall \
  flagTrue dest=mt7620_mtall \
  help="set board mtall ramips platform"

addOption --x86-mtall \
  flagTrue dest=x86_mtall \
  help="set board mtall x86 platform"

addOption -ap --add-profile \
  flagTrue dest=add_profile \
  help="add and set project's hardware profile"

addOption -sp --set-profile \
  flagTrue dest=set_profile \
  help="set project's hardware profile"

addOption -cp --change-project \
  flagTrue dest=change_project \
  help="openwrt change to project"

doAction=false
op_root=$(get_wrtoy_path)
op_wrtoy_dir=$(get_wrtoy_path ..)
op_hp_dir=$(get_wrtoy_path profiles)
op_tl_dir=$(get_wrtoy_path ../tftproot)
op_dir=$(get_wrtoy_path ../openwrt)

#======================================================

parseOptions "$@"

if [ $demo_mtall == true ]; then
  echo "use board mtall(demo) ramips platform"
  [ $add_profile == true ] && ./hardware_manage -a demo
  ./hardware_manage -u demo
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn mtall -bt MTALL -pf ramips -cn mt7620 -tr /works/openwrt/tftpboot -tl 7620a -bf "" -ud /dev/sdb
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af packages -fs https://github.com/openwrt/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af luci -fs https://github.com/openwrt/luci.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af routing -fs https://github.com/openwrt-routing/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af telephony -fs https://github.com/openwrt/telephony.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af management -fs https://github.com/openwrt-management/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af oldpackages -fs http://git.openwrt.org/packages.git
fi

if [ $mt7620_mtall == true ]; then
  echo "use board mtall ramips platform"
  [ $add_profile == true ] && ./hardware_manage -a mtall_ramips
  ./hardware_manage -u mtall_ramips
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn mtall -bt MTALL -pf ramips -cn mt7620 -tr /works/openwrt/tftpboot -tl 7620a -bf "" -ud /dev/sdb
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af packages -fs https://github.com/openwrt/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af luci -fs https://github.com/openwrt/luci.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af routing -fs https://github.com/openwrt-routing/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af telephony -fs https://github.com/openwrt/telephony.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af management -fs https://github.com/openwrt-management/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af oldpackages -fs http://git.openwrt.org/packages.git
fi

if [ $x86_mtall == true ]; then
  echo "use board mtall x86 platform"
  [ $add_profile == true ] && ./hardware_manage -a mtall_x86
  ./hardware_manage -u mtall_x86
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn generic -bt X86 -pf x86 -cn x86 -tr /works/openwrt/tftpboot -tl x86img -bf "" -ud /dev/sdb
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af packages -fs https://github.com/openwrt/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af luci -fs https://github.com/openwrt/luci.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af routing -fs https://github.com/openwrt-routing/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af telephony -fs https://github.com/openwrt/telephony.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af management -fs https://github.com/openwrt-management/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af oldpackages -fs http://git.openwrt.org/packages.git
fi

project_name=mtall

if [ $change_project == true ]; then
  # 安装最新版项目
  ./build -I
  # 使.config生效/存在
  ./build -def
  # 配置主板相关补丁，主板配置从.hardware中自动读取
  ./build -pp "$project_name"
  # 安装feeds
  ./build -f
  # 根据当前.config配置重新梳理项目依赖关系
  ./build -def
  # 项目应用补丁
  ./build -po "$project_name"
  # 升级feeds
  ./build -f
  # 根据当前.config配置重新梳理项目依赖关系
  ./build -def
  # 删除tmp临时目录，以便menuconfig能正确显示项目
  ./build -ct
fi