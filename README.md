# openwrt for nanopi r4s

基于OpenWrt官方代码

增加了passwall、kms激活助手等功能。

```BASH
git clone https://github.com/mrzhaohanhua/openwrt-nanopi-r4s
cd openwrt-nanopi-r4s
sh run.sh
cd openwrt
make menuconfig     #根据自己的需求进行配置
make download -j10 V=s
make -jxx V=s       #根据自己的配置选择-jxx，建议第一次运行使用-j1，方便发现失败原因
```
Enjoy!
