#!/bin/bash
clear

### 清理 ###
echo "清理 ./openwrt/"
rm -rf openwrt

openwrt_version_code="v22.03.2"
lede_tag_code="20221001"

extra_package_path="./package/extra/"

### 获取openwrt ###
git clone --depth 1 -b $openwrt_version_code https://github.com/openwrt/openwrt openwrt

#切换到openwrt目录
cd openwrt

# 更新 Feeds
./scripts/feeds update -a

# 安装Feeds
./scripts/feeds install -a

### 更换关键文件 ###
# 删除原target文件
rm -rf ./target/linux/rockchip
# 下载lede的target文件
svn export https://github.com/coolsnowwolf/lede/tags/$lede_tag_code/target/linux/rockchip target/linux/rockchip
# 删除lede里的Makefile
rm -rf ./target/linux/rockchip/Makefile
# 使用原openwrt中的Makefile
wget -P target/linux/rockchip/ https://github.com/openwrt/openwrt/raw/$openwrt_version_code/target/linux/rockchip/Makefile
# openwrt使用5.10内核, 删除没有用到的PATCH
rm -rf ./target/linux/rockchip/patches-5.4
rm -rf ./target/linux/rockchip/patches-5.15
rm -rf ./target/linux/rockchip/patches-5.19
rm -rf ./target/linux/rockchip/files-5.19
rm -rf ./target/linux/rockchip/files-5.15
rm ./target/linux/rockchip/modules.mk
# patches-5.10中002和003patch会编译失败, 在此删除
rm -rf ./target/linux/rockchip/patches-5.10/002-net-usb-r8152-add-LED-configuration-from-OF.patch 
rm -rf ./target/linux/rockchip/patches-5.10/003-dt-bindings-net-add-RTL8152-binding-documentation.patch
# 使用QiuSimons的YAOF中的dts文件
cp -rf ../PATCH/dts/* ./target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/

# 删除原uboot
rm -rf ./package/boot/uboot-rockchip
# 使用lede的uboot
svn export https://github.com/coolsnowwolf/lede/tags/$lede_tag_code/package/boot/uboot-rockchip package/boot/uboot-rockchip
sed -i '/r2c-rk3328:arm-trusted/d' package/boot/uboot-rockchip/Makefile

svn export https://github.com/coolsnowwolf/lede/tags/$lede_tag_code/package/boot/arm-trusted-firmware-rockchip-vendor package/boot/arm-trusted-firmware-rockchip-vendor

rm -rf ./package/kernel/linux/modules/video.mk
wget -P package/kernel/linux/modules/ https://github.com/immortalwrt/immortalwrt/raw/master/package/kernel/linux/modules/video.mk

# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/ucl tools/ucl
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/upx tools/upx

### 获取额外的 LuCI 应用、主题和依赖 ###

# 更换smartdns
rm -rf feeds/packages/net/smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/smartdns/ feeds/packages/net/smartdns

# 替换luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-smartdns/ feeds/luci/applications/luci-app-smartdns

# Argon主题
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-theme-argon/ ${extra_package_path}/luci-theme-argon
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-argon-config/ ${extra_package_path}/luci-app-argon-config

# ChinaDNS
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/chinadns-ng/ ${extra_package_path}/chinadns-ng

# OLED 驱动程序
git clone -b master --depth 1 https://github.com/NateLol/luci-app-oled.git ${extra_package_path}/luci-app-oled

# Passwall
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall ${extra_package_path}/luci-app-passwall
# 修改luci-app-passwall中的Makefile以支持最新的iptables
sed -i 's,iptables-legacy,iptables-nft,g' ${extra_package_path}/luci-app-passwall/Makefile

# Passwall的依赖包
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ipt2socks ${extra_package_path}/ipt2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/microsocks ${extra_package_path}/microsocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2socks ${extra_package_path}/dns2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2tcp ${extra_package_path}/dns2tcp
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/naiveproxy ${extra_package_path}/naiveproxy
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/pdnsd-alt ${extra_package_path}/pdnsd-alt
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocks-rust ${extra_package_path}/shadowsocks-rust
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocksr-libev ${extra_package_path}/shadowsocksr-libev
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/simple-obfs ${extra_package_path}/simple-obfs
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tcping ${extra_package_path}/tcping
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-go ${extra_package_path}/trojan-go
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/brook ${extra_package_path}/brook
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-plus ${extra_package_path}/trojan-plus
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ssocks ${extra_package_path}/ssocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-core ${extra_package_path}/xray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-plugin ${extra_package_path}/v2ray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-plugin ${extra_package_path}/xray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/hysteria ${extra_package_path}/hysteria
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-core ${extra_package_path}/v2ray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-geodata ${extra_package_path}/v2ray-geodata

# KMS 激活助手
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-vlmcsd ${extra_package_path}/luci-app-vlmcsd
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/vlmcsd ${extra_package_path}/vlmcsd

### 后续修改 ###

# 最大连接数（来自QiuSimons/YAOF）
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#convert_translation（来自QiuSimons/YAOF）
po_file="$({ find | grep -E "[a-z0-9]+\.zh\-cn.+po"; } 2>"/dev/null")"
for a in ${po_file}; do
  [ -n "$(grep "Language: zh_CN" "$a")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$a"
  po_new_file="$(echo -e "$a" | sed "s/zh-cn/zh_Hans/g")"
  mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find | grep "/zh-cn/" | grep "\.po"; } 2>"/dev/null")"
for b in ${po_file2}; do
  [ -n "$(grep "Language: zh_CN" "$b")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$b"
  po_new_file2="$(echo -e "$b" | sed "s/zh-cn/zh_Hans/g")"
  mv "$b" "${po_new_file2}" 2>"/dev/null"
done

lmo_file="$({ find | grep -E "[a-z0-9]+\.zh_Hans.+lmo"; } 2>"/dev/null")"
for c in ${lmo_file}; do
  lmo_new_file="$(echo -e "$c" | sed "s/zh_Hans/zh-cn/g")"
  mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find | grep "/zh_Hans/" | grep "\.lmo"; } 2>"/dev/null")"
for d in ${lmo_file2}; do
  lmo_new_file2="$(echo -e "$d" | sed "s/zh_Hans/zh-cn/g")"
  mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find | grep "/zh-cn" | sed "/\.po/d" | sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}; do
  po_new_dir="$(echo -e "$e" | sed "s/zh-cn/zh_Hans/g")"
  mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}; do
  [ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh-cn/zh_Hans/g" "$f"
  [ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh_Hans.lmo/zh-cn.lmo/g" "$f"
done

makefile_file="$({ find package | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for g in ${makefile_file}; do
  [ -n "$(grep "golang-package.mk" "$g")" ] && sed -i "s,\../..,\$(TOPDIR)/feeds/packages,g" "$g"
  [ -n "$(grep "luci.mk" "$g")" ] && sed -i "s,\../..,\$(TOPDIR)/feeds/luci,g" "$g"
done

# Remove upx commands

makefile_file="$({ find package|grep Makefile |sed "/Makefile./d"; } 2>"/dev/null")"
for a in ${makefile_file}
do
	[ -n "$(grep "upx" "$a")" ] && sed -i "/upx/d" "$a"
done

# Script for creating ACL file for each LuCI APP
bash ../create_acl_for_luci.sh -a

# Install scripts
mkdir -p openwrt/package/base-files/files/bin/
cp files/bin/pppoe_daemon.sh openwrt/package/base-files/files/bin/
sed -i "`wc -l < openwrt/package/base-files/files/etc/rc.local`i\\sh /bin/pppoe_daemon.sh &\\" openwrt/package/base-files/files/etc/rc.local

# Copy config file
cp ../r4s_config .config
make defconfig
echo "ready to make!!!"
