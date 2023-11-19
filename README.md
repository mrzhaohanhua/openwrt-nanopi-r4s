# openwrt for nanopi r4s

基于OpenWrt官方代码

参考和使用了coolsnowwolf的代码，https://github.com/coolsnowwolf/lede

参考和使用了QiuSimons的代码，https://github.com/QiuSimons/YAOF

除了OpenWrt官方代码外，增加了passwall、kms激活助手等功能。

QiuSimons对R4S进行了超频，这里没有采用，以降低对电源的要求，可以使用低功率的USB电源供电。

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
