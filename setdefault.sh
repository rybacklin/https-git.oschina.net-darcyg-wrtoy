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
# 设置项目常用目录
op_root=$(get_wrtoy_path)
op_wrtoy_dir=$(get_wrtoy_path ..)
op_hp_dir=$(get_wrtoy_path profiles)
op_tl_dir=$(get_wrtoy_path ../tftproot)
op_dir=$(get_wrtoy_path ../openwrt)

#======================================================

parseOptions "$@"

# 执行./setdefault.sh --demo-mtall <命令>
if [ $demo_mtall == true ]; then
  echo "use board mtall(demo) ramips platform"
  # --add-profile 模式增加一个叫demo的配置，配置在profiles目录里
  [ $add_profile == true ] && ./hardware_manage -a demo
  # 使用名为demo的配置 即将 profiles/demo.json 链接(link）到 ./.hardware
  # ./hardware是当前使用的硬件配置项
  ./hardware_manage -u demo
  # 使用--set-profile 和 --add-profile模式时 对 当前的.hardware做配置，定义板子的名字bn，板子的标签bt，平台pf,芯片名mt7620
  # tftp的目录tr，tftp的link名字tl，usb驱动的名称ud,和binfile，固件二进制文件的bf
  # 上述这些参数，都是用来生成wrtoy的配置信息的
  # 有这些参数，wrtoy能自动生成二进制文件名（--bin-file/-bf参数可以手工指定），并在需要的时候拷贝到tftp目录，并做好短链接
  # 让开发操作得以简化
  # ./build -bj 8 -c 是编译固件，并将固件拷贝到tftp的目录中，形成tl的短链
  # 本例中，-c参数会自动检测openwrt的bin/ramips目录中，是否有固件
  # 并将其拷贝到/works/openwrt/tftpboot目录中，然后建立7620a的短链
  # uboot从tftp刷固件的时候，只需要在tftp文件名处输入7620a即可
  # ./build -cu 将img文件用cp写到/dev/sdb驱动挂载的分区，拷贝固件到U盘（文件名会自动加入拷贝时间）
  # ./build -iu 将img文件用dd写到/dev/sdb(制作x86或rpi的启动盘)
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn mtall -bt MTALL -pf ramips -cn mt7620 -tr /works/openwrt/tftpboot -tl 7620a -bf "" -ud /dev/sdb
  # 本系统调整了openwrt的feeds模式。不在openwrt的feeds目录下直接git项目仓库的feeds
  # 而是在wrtoy/feeds.git目录中建立项目的git仓库，然后针对某一版本git，导出到wrtoy/feeds目录中，openwrt的feeds，都是通过软链访问
  # 这样设计，避免在feeds中调整代码后，相关feeds不能pull的问题
  # 以下是openwrt默认的几个feeds
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af packages -fs https://github.com/openwrt/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af luci -fs https://github.com/openwrt/luci.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af routing -fs https://github.com/openwrt-routing/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af telephony -fs https://github.com/openwrt/telephony.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af management -fs https://github.com/openwrt-management/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af oldpackages -fs http://git.openwrt.org/packages.git
fi

# 执行./setdefault.sh --ramips-mtall <命令>
if [ $mt7620_mtall == true ]; then
  echo "use board mtall ramips platform"
  # --add-profile 模式增加一个叫mtall_ramips的配置，配置在profiles目录里
  [ $add_profile == true ] && ./hardware_manage -a mtall_ramips
  # 使用名为demo的配置 即将 profiles/demo.json 链接(link）到 ./.hardware
  # ./hardware是当前使用的硬件配置项
  ./hardware_manage -u mtall_ramips
  # 使用--set-profile 和 --add-profile模式时 对 当前的.hardware做配置，定义板子的名字bn，板子的标签bt，平台pf,芯片名mt7620
  # tftp的目录tr，tftp的link名字tl，usb驱动的名称ud,和binfile，固件二进制文件的bf
  # 上述这些参数，都是用来生成wrtoy的配置信息的
  # 有这些参数，wrtoy能自动生成二进制文件名（--bin-file/-bf参数可以手工指定），并在需要的时候拷贝到tftp目录，并做好短链接
  # 让开发操作得以简化
  # ./build -bj 8 -c 是编译固件，并将固件拷贝到tftp的目录中，形成tl的短链
  # 本例中，-c参数会自动检测openwrt的bin/ramips目录中，是否有固件
  # 并将其拷贝到/works/openwrt/tftpboot目录中，然后建立7620a的短链
  # uboot从tftp刷固件的时候，只需要在tftp文件名处输入7620a即可
  # ./build -cu 将img文件用cp写到/dev/sdb驱动挂载的分区，拷贝固件到U盘（文件名会自动加入拷贝时间）
  # ./build -iu 将img文件用dd写到/dev/sdb(制作x86或rpi的启动盘)
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn mtall -bt MTALL -pf ramips -cn mt7620 -tr /works/openwrt/tftpboot -tl 7620a -bf "" -ud /dev/sdb
  # 本系统调整了openwrt的feeds模式。不在openwrt的feeds目录下直接git项目仓库的feeds
  # 而是在wrtoy/feeds.git目录中建立项目的git仓库，然后针对某一版本git，导出到wrtoy/feeds目录中，openwrt的feeds，都是通过软链访问
  # 这样设计，避免在feeds中调整代码后，相关feeds不能pull的问题
  # 以下是openwrt默认的几个feeds
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af packages -fs https://github.com/openwrt/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af luci -fs https://github.com/openwrt/luci.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af routing -fs https://github.com/openwrt-routing/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af telephony -fs https://github.com/openwrt/telephony.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af management -fs https://github.com/openwrt-management/packages.git
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -af oldpackages -fs http://git.openwrt.org/packages.git
fi

# 执行./setdefault.sh --x86-mtall <命令>
if [ $x86_mtall == true ]; then
  echo "use board mtall x86 platform"
  # --add-profile 模式增加一个叫mtall_x86的配置，配置在profiles目录里
  [ $add_profile == true ] && ./hardware_manage -a mtall_x86
  # 使用名为demo的配置 即将 profiles/demo.json 链接(link）到 ./.hardware
  # ./hardware是当前使用的硬件配置项
  ./hardware_manage -u mtall_x86
  # 使用--set-profile 和 --add-profile模式时 对 当前的.hardware做配置，定义板子的名字bn，板子的标签bt，平台pf,芯片名mt7620
  # tftp的目录tr，tftp的link名字tl，usb驱动的名称ud,和binfile，固件二进制文件的bf
  # 上述这些参数，都是用来生成wrtoy的配置信息的
  # 有这些参数，wrtoy能自动生成二进制文件名（--bin-file/-bf参数可以手工指定），并在需要的时候拷贝到tftp目录，并做好短链接
  # 让开发操作得以简化
  # ./build -bj 8 -c 是编译固件，并将固件拷贝到tftp的目录中，形成tl的短链
  # 本例中，-c参数会自动检测openwrt的bin/ramips目录中，是否有固件
  # 并将其拷贝到/works/openwrt/tftpboot目录中，然后建立7620a的短链
  # uboot从tftp刷固件的时候，只需要在tftp文件名处输入7620a即可
  # ./build -cu 将img文件用cp写到/dev/sdb驱动挂载的分区，拷贝固件到U盘（文件名会自动加入拷贝时间）
  # ./build -iu 将img文件用dd写到/dev/sdb(制作x86或rpi的启动盘)
  [ $set_profile == true -o $add_profile == true ] && ./hardware_manage -bn generic -bt X86 -pf x86 -cn x86 -tr /works/openwrt/tftpboot -tl x86img -bf "" -ud /dev/sdb
  # 本系统调整了openwrt的feeds模式。不在openwrt的feeds目录下直接git项目仓库的feeds
  # 而是在wrtoy/feeds.git目录中建立项目的git仓库，然后针对某一版本git，导出到wrtoy/feeds目录中，openwrt的feeds，都是通过软链访问
  # 这样设计，避免在feeds中调整代码后，相关feeds不能pull的问题
  # 以下是openwrt默认的几个feeds
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
  # 备份当前配置为openwrt目录下的./config.orig
  ./build -bc orig
  # 配置主板相关补丁，主板配置从.hardware中自动读取
  ./build -pp "$project_name"
  # 安装feeds
  ./build -f
  # 根据当前.config配置重新梳理项目依赖关系
  ./build -def
  # 备份当前配置为openwrt目录下的./config.pp
  ./build -bc pp
  # 项目应用补丁
  ./build -po "$project_name"
  # 升级feeds
  ./build -f
  # 根据当前.config配置重新梳理项目依赖关系
  ./build -def
  # 备份当前配置为openwrt目录下的./config.po
  ./build -bc po
  # 删除tmp临时目录，以便menuconfig能正确显示项目
  ./build -ct
fi