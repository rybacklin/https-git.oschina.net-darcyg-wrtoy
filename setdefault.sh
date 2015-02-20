#!/bin/sh

./doconfig -bn mtall -bt MTALL -pf ramips -cn mt7620 -tl "7620a"
./doconfig -af packages -fs https://github.com/openwrt/packages.git
./doconfig -af luci -fs https://github.com/openwrt/luci.git
./doconfig -af routing -fs https://github.com/openwrt-routing/packages.git
./doconfig -af telephony -fs https://github.com/openwrt/telephony.git
./doconfig -af management -fs https://github.com/openwrt-management/packages.git
./doconfig -af oldpackages -fs http://git.openwrt.org/packages.git
