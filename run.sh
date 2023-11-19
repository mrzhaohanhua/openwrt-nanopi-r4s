#!/bin/bash

# 定义函数
checkout_code(){
    repo_url=$1
    source_dir=$2
    dest_dir=$3      
    branch_or_tag=$4

    if [ -z "$branch_or_tag" ]; then
        branch_path="trunk"
    elif [ "$branch_or_tag" = "tag" ]; then
        branch_path="tags/$5"
    elif [ "$branch_or_tag" = "branch" ]; then
        branch_path="branches/$5"
    else
        echo "branch or tag name error."
        exit 1
    fi
    svn export $repo_url/$branch_path/$source_dir $dest_dir
    if [ $? -ne 0 ]; then
        echo "svn export $repo_url/$branch_path/$source_dir $dest_dir"
        echo "执行错误"
        exit 1
    fi
}


openwrt_version_code="v23.05.0"
lede_version_code="20230609"
openwrt_repo="https://github.com/openwrt/openwrt"
lede_repo="https://github.com/coolsnowwolf/lede"

my_package_repo="https://github.com/mrzhaohanhua/openwrt-package"

extra_package_path="./package/extra"

### 清理 ###
echo "清理 ./openwrt/"
rm -rf openwrt

git clone --depth 1 -b $openwrt_version_code $openwrt_repo openwrt

cd openwrt

./scripts/feeds update -a
./scripts/feeds install -a

# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in

# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/ucl tools/ucl
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/upx tools/upx
checkout_code ${my_package_repo} tools/ucl tools/ucl
checkout_code ${my_package_repo} tools/upx tools/upx

### 获取额外的 LuCI 应用、主题和依赖 ###

# 更换smartdns
rm -rf feeds/packages/net/smartdns
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/openwrt-smartdns/ feeds/packages/net/smartdns
checkout_code ${my_package_repo} openwrt-smartdns feeds/packages/net/smartdns

# 替换luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-smartdns/ feeds/luci/applications/luci-app-smartdns
checkout_code ${my_package_repo} luci-app-smartdns feeds/luci/applications/luci-app-smartdns

# Argon主题
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-theme-argon/ ${extra_package_path}/luci-theme-argon
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-argon-config/ ${extra_package_path}/luci-app-argon-config
checkout_code ${my_package_repo} luci-theme-argon ${extra_package_path}/luci-theme-argon
checkout_code ${my_package_repo} luci-app-argon-config ${extra_package_path}/luci-app-argon-config

# ChinaDNS
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/chinadns-ng/ ${extra_package_path}/chinadns-ng
checkout_code ${my_package_repo} chinadns-ng ${extra_package_path}/chinadns-ng

# OLED 驱动程序
git clone -b master --depth 1 https://github.com/NateLol/luci-app-oled.git ${extra_package_path}/luci-app-oled

# Passwall2
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall2 &{extra_package_path}/luci-app-passwall2

# Passwall
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall ${extra_package_path}/luci-app-passwall
checkout_code ${my_package_repo} luci-app-passwall ${extra_package_path}/luci-app-passwall

# 修改luci-app-passwall中的Makefile以支持最新的iptables
sed -i 's,iptables-legacy,iptables-nft,g' ${extra_package_path}/luci-app-passwall/Makefile

# Passwall的依赖包
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ipt2socks ${extra_package_path}/ipt2socks
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/microsocks ${extra_package_path}/microsocks
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2socks ${extra_package_path}/dns2socks
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2tcp ${extra_package_path}/dns2tcp
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/naiveproxy ${extra_package_path}/naiveproxy
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/gn ${extra_package_path}/gn
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/pdnsd-alt ${extra_package_path}/pdnsd-alt
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocks-rust ${extra_package_path}/shadowsocks-rust
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocksr-libev ${extra_package_path}/shadowsocksr-libev
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/simple-obfs ${extra_package_path}/simple-obfs
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tcping ${extra_package_path}/tcping
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-go ${extra_package_path}/trojan-go
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/brook ${extra_package_path}/brook
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-plus ${extra_package_path}/trojan-plus
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ssocks ${extra_package_path}/ssocks
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-core ${extra_package_path}/xray-core
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-plugin ${extra_package_path}/v2ray-plugin
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-plugin ${extra_package_path}/xray-plugin
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/hysteria ${extra_package_path}/hysteria
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-core ${extra_package_path}/v2ray-core
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-geodata ${extra_package_path}/v2ray-geodata
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tuic-client ${extra_package_path}/tuic-client
checkout_code ${my_package_repo}  ipt2socks ${extra_package_path}/ipt2socks
checkout_code ${my_package_repo}  microsocks ${extra_package_path}/microsocks
checkout_code ${my_package_repo}  dns2socks ${extra_package_path}/dns2socks
checkout_code ${my_package_repo}  dns2tcp ${extra_package_path}/dns2tcp
checkout_code ${my_package_repo}  naiveproxy ${extra_package_path}/naiveproxy
checkout_code ${my_package_repo}  gn ${extra_package_path}/gn
checkout_code ${my_package_repo}  pdnsd-alt ${extra_package_path}/pdnsd-alt
checkout_code ${my_package_repo}  shadowsocks-rust ${extra_package_path}/shadowsocks-rust
checkout_code ${my_package_repo}  shadowsocksr-libev ${extra_package_path}/shadowsocksr-libev
checkout_code ${my_package_repo}  simple-obfs ${extra_package_path}/simple-obfs
checkout_code ${my_package_repo}  tcping ${extra_package_path}/tcping
checkout_code ${my_package_repo}  trojan-go ${extra_package_path}/trojan-go
checkout_code ${my_package_repo}  brook ${extra_package_path}/brook
checkout_code ${my_package_repo}  trojan-plus ${extra_package_path}/trojan-plus
checkout_code ${my_package_repo}  ssocks ${extra_package_path}/ssocks
checkout_code ${my_package_repo}  xray-core ${extra_package_path}/xray-core
checkout_code ${my_package_repo}  v2ray-plugin ${extra_package_path}/v2ray-plugin
checkout_code ${my_package_repo}  xray-plugin ${extra_package_path}/xray-plugin
checkout_code ${my_package_repo}  hysteria ${extra_package_path}/hysteria
checkout_code ${my_package_repo}  v2ray-core ${extra_package_path}/v2ray-core
checkout_code ${my_package_repo}  v2ray-geodata ${extra_package_path}/v2ray-geodata
checkout_code ${my_package_repo}  tuic-client ${extra_package_path}/tuic-client

# luci-app-xray
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-xray ${extra_package_path}/luci-app-xray

# KMS 激活助手
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-vlmcsd ${extra_package_path}/luci-app-vlmcsd
# svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/vlmcsd ${extra_package_path}/vlmcsd
checkout_code ${my_package_repo}  luci-app-vlmcsd ${extra_package_path}/luci-app-vlmcsd
checkout_code ${my_package_repo}  vlmcsd ${extra_package_path}/vlmcsd

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
mkdir -p package/base-files/files/bin/
cp ../files/bin/pppoe_daemon.sh package/base-files/files/bin/
sed -i "`wc -l < package/base-files/files/etc/rc.local`i\\sh /bin/pppoe_daemon.sh &\\" package/base-files/files/etc/rc.local

# Copy config file
cp ../r4s_config .config
make defconfig
echo "ready to make!!!"
