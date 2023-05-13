@echo off
if exist bin\platform-tools-windows\fastboot.exe PATH=bin\platform-tools-windows;%PATH%
setlocal enabledelayedexpansion
title PureSky线刷脚本 [请勿选中窗口，否则卡住活该，卡住按右键或回车或放大缩小窗口恢复]
echo.
echo.刷机注意事项：
echo.①首次刷入PureSky官改需要清除数据
echo.②解密Data和不解密Data的包互刷需要清除数据
echo.
if exist images\super.img.zst (
	echo.正在转换...
	zstd --rm -d images/super.img.zst -o images/super.img
	if "!errorlevel!" NEQ "0" (
		echo.Super.img转换可能出错，请不要刷入！
		echo.如果提示"No space left on device"则是你电脑空间不足，请释放后重新解压再刷入
		echo.如果是其他提示，请联系QQ 3556423385
		pause
		exit
	)
)
echo.
set /p wipeData="是否需要清除数据（y/n）"
echo.
echo.刷机过程中请不要乱动乱点，请注意看标题
echo.刷机过程中请不要乱动乱点，请注意看标题
echo.刷机过程中请不要乱动乱点，请注意看标题
echo.
for /f "tokens=*" %%i in ('curl -sS --connect-timeout 5 https://jk.511i.cn 2^>nul ^|findstr fs-22 ^|findstr lh-22 ^|awk NR^=^=2 ^|cut -d ">" -f 2 ^|cut -d "<" -f 1') do (set QQGROUP=%%i)
if "!QQGROUP!" neq "" (
	echo.如果卡在 ^<waiting for any device^> 请前往群（!QQGROUP!）文件搜索”安卓驱动“
	echo.如果卡在 ^<waiting for any device^> 请前往群（!QQGROUP!）文件搜索”安卓驱动“
	echo.如果卡在 ^<waiting for any device^> 请前往群（!QQGROUP!）文件搜索”安卓驱动“
) else (
	echo.如果卡在 ^<waiting for any device^> 请前往群（607192055）文件搜索”安卓驱动“
	echo.如果卡在 ^<waiting for any device^> 请前往群（607192055）文件搜索”安卓驱动“
	echo.如果卡在 ^<waiting for any device^> 请前往群（607192055）文件搜索”安卓驱动“

)

if exist images\boot_twrp.img (
	echo.
	set /p twrpOrNot="是否需要TWRP？（y/n）"
)
if exist images\recovery_twrp.img (
	echo.
	set /p twrpOrNot="是否需要TWRP？（y/n）"
)
if exist images\init_boot_official.img (
	if exist images\init_boot_magisk.img (
		echo.
		set /p rootOrNot="是否需要ROOT？（y/n）"
		if /i "!rootOrNot!" == "y" (
			fastboot flash init_boot_a images/init_boot_magisk.img
			fastboot flash init_boot_b images/init_boot_magisk.img
		) else (
			fastboot flash init_boot_a images/init_boot_official.img
			fastboot flash init_boot_b images/init_boot_official.img
		)
	) else (
		fastboot flash init_boot_a images/init_boot_official.img
		fastboot flash init_boot_b images/init_boot_official.img
	)
	fastboot flash boot_a images/boot_official.img
	fastboot flash boot_b images/boot_official.img
) else (
	if exist images\boot_magisk.img (
		echo.
		set /p rootOrNot="是否需要ROOT？（y/n）"
		if /i "!rootOrNot!" == "y" (
			fastboot flash boot_a images/boot_magisk.img
			fastboot flash boot_b images/boot_magisk.img
		) else (
			fastboot flash boot_a images/boot_official.img
			fastboot flash boot_b images/boot_official.img
		)
	) else (
		fastboot flash boot_a images/boot_official.img
		fastboot flash boot_b images/boot_official.img
	)
)

if exist images\boot_twrp.img (
	if /i "!twrpOrNot!" == "y" (
		fastboot flash boot_a images/boot_twrp.img
		fastboot flash boot_b images/boot_twrp.img
	)
)

if exist images\recovery_twrp.img (
	if /i "!twrpOrNot!" == "y" (
		fastboot flash recovery_a images/recovery_twrp.img
		fastboot flash recovery_b images/recovery_twrp.img
	)
)


rem


if exist images\preloader_raw.img (
	fastboot flash preloader_a images/preloader_raw.img 1>nul 2>nul
	fastboot flash preloader_b images/preloader_raw.img 1>nul 2>nul
	fastboot flash preloader1 images/preloader_raw.img 1>nul 2>nul
	fastboot flash preloader2 images/preloader_raw.img 1>nul 2>nul
)

if exist images\cust.img fastboot flash cust images/cust.img
echo.
echo.
echo.如果显示 invalid sparse file format at header magic 为正常情况，不是报错
echo.如果显示 invalid sparse file format at header magic 为正常情况，不是报错
echo.
echo.请耐心等待，卡在这里多久取决于电脑性能，也可以看下标题
echo.请耐心等待，卡在这里多久取决于电脑性能，也可以看下标题
echo.
echo.
if exist images\super.img fastboot flash super images/super.img
echo.
echo.
echo.刷完super可能会卡一段时间，请耐心等待，请勿自行重启，否则可能不开机需要重刷
echo.刷完super可能会卡一段时间，请耐心等待，请勿自行重启，否则可能不开机需要重刷
echo.
echo.如果长时间没有反应，请尝试手动开机或者重刷一遍
echo.如果长时间没有反应，请尝试手动开机或者重刷一遍
echo.
echo.

if /i "!wipeData!" == "y" (
	fastboot erase userdata
	fastboot erase metadata
)
fastboot set_active a
fastboot reboot

pause