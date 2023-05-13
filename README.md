# PSWindows

## PureSky官改官方网站：[https://jk.511i.cn](https://jk.511i.cn)

## 简介
- PureSky官改Windows端制作工具

## 目录结构说明
- [d] bin - 存放必要环境以及所有用到的文件、开源工具等
    - [d] apks - 一些apk文件
    - [d] apktool - apk反编译工具
    - [d] file_config - 打包上下文附加文件
    - [d] flash - 线刷刷机脚本
    - [d] images - cust等空镜像
    - [d] Magisk - 存放Magisk安装包
    - [d] platform-tools - 存放三大平台adb工具
    - [d] puresky - 存放一些配置文件以及修改脚本
    - [d] ramdisk - 存放V-A/B机型的 twrp-ramdisk.cpio
    - [d] recovery - 存放twrp recovery
    - [d] Windows_NT - 存放必要的改包可执行文件
      - [f] checkfile.list - 必要文件检查列表
      - [f] configure.txt 配置文件表
      - [f] 更新日志.txt
      - [f] 文件系统类型一览表（必读）.txt

- [d] input - 本地刷机包存放位置

- [f] main.bat - 制作刷机包脚本文件
## 适用机型说明
- 仅适用于ext4文件系统的小米红米安卓10以及之后的机型，例如
    - 小米10系列
    - 红米K40系列
    - 红米K30系列
    - 小米平板5系列
    - 等等在19年-22年之间发布的ext4文件系统机型
- 特殊说明：
  - 小米11系列仅支持安卓12及以下的ROM包制作
  - 小米10系列、红米K30系列不支持MIUI14制作
  - 红米K40G、红米Note10Pro、红米Note11Pro等联发科机型不支持
  - 不建议非动态分区的机型制作，即小米10以下、红米Note9以下

## 运行：
- 双击main.bat
- 如果要显示全部提示信息，可在控制台中输入
````
main.bat --debug
````
## 免责说明
- 此项目基于PureSky定制V20230511版本修改发布，没有任何恶意代码，使用者下载使用造成的一切后果均由其本人承担

## 一些使用及借鉴的开源项目
- [ErfanGSIs](https://github.com/erfanoabdi/ErfanGSIs)
- [img2sdat](https://github.com/xpirt/img2sdat)
- [make_ext4fs](https://github.com/rendiix/make_ext4fs)
- [erofs-utils](https://github.com/sekaiacg/erofs-utils)
- [vbmeta-disable-verification](https://github.com/libxzr/vbmeta-disable-verification)
- [payload-dumper-go](https://github.com/ssut/payload-dumper-go)
