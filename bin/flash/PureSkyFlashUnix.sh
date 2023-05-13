

[ "$(uname)" = "Linux" ] && bin="bin/platform-tools-linux"
[ "$(uname)" = "Darwin" ] && bin="bin/platform-tools-darwin"
chmod -R 0755 bin/

if [ -f images/super.img.zst ];then
	zstd --rm -d images/super.img.zst -o images/super.img || echo -e "zstd 不可用 Linux 请尝试 sudo apt install zstd -y \nMacOS 请尝试 brew install zstd\n" && exit 1
fi


if [ -f images/init_boot_official.img ];then

	if [ -f images/init_boot_official.img ];then
		$bin/fastboot flash init_boot_a images/init_boot_official.img
		$bin/fastboot flash init_boot_b images/init_boot_official.img
	fi

	if [ -f images/init_boot_magisk.img ];then
		read -p "是否需要ROOT（y/n）" rootOrNot
		[ "$rootOrNot" = "y" -o "$rootOrNot" = "Y" ] && $bin/fastboot flash init_boot_a images/init_boot_magisk.img
		[ "$rootOrNot" = "y" -o "$rootOrNot" = "Y" ] && $bin/fastboot flash init_boot_b images/init_boot_magisk.img
	fi
	
	$bin/fastboot flash boot_a images/boot_official.img
	$bin/fastboot flash boot_b images/boot_official.img
	
else

	if [ -f images/boot_official.img ];then
		$bin/fastboot flash boot_a images/boot_official.img
		$bin/fastboot flash boot_b images/boot_official.img
	fi

	if [ -f images/boot_magisk.img ];then
		read -p "是否需要ROOT（y/n）" rootOrNot
		[ "$rootOrNot" = "y" -o "$rootOrNot" = "Y" ] && $bin/fastboot flash boot_a images/boot_magisk.img
		[ "$rootOrNot" = "y" -o "$rootOrNot" = "Y" ] && $bin/fastboot flash boot_b images/boot_magisk.img
	fi

fi



if [ -f images/boot_twrp.img ];then
	read -p "是否需要TWRP（y/n）" twrpOrNot
	[ "$twrpOrNot" = "y" -o "$twrpOrNot" = "Y" ] && $bin/fastboot flash boot_a images/boot_magisk.img
	[ "$twrpOrNot" = "y" -o "$twrpOrNot" = "Y" ] && $bin/fastboot flash boot_b images/boot_magisk.img
fi

if [ -f images/recovery_twrp.img ] ;then
	read -p "是否需要TWRP（y/n）" twrpOrNot
	[ "$twrpOrNot" = "y" -o "$twrpOrNot" = "Y" ] && $bin/fastboot flash recovery_a images/recovery_twrp.img
	[ "$twrpOrNot" = "y" -o "$twrpOrNot" = "Y" ] && $bin/fastboot flash recovery_b images/recovery_twrp.img
fi

if [ -f images/preloader_raw.img ];then
	$bin/fastboot flash preloader1 images/preloader_raw.img
	$bin/fastboot flash preloader2 images/preloader_raw.img
	$bin/fastboot flash preloader_a images/preloader_raw.img
	$bin/fastboot flash preloader_b images/preloader_raw.img
fi


#HereToInsert


[ -f images/cust.img ] && $bin/fastboot flash cust images/cust.img
echo " "
echo "如果显示 invalid sparse file format at header magic 为正常情况，不是报错"
echo "如果显示 invalid sparse file format at header magic 为正常情况，不是报错"
echo "如果显示 invalid sparse file format at header magic 为正常情况，不是报错"
echo " "
[ -f images/super.img ] && $bin/fastboot flash super images/super.img

echo " "
echo "如果长时间没有反应，请尝试手动开机或者重刷一遍"
echo "如果长时间没有反应，请尝试手动开机或者重刷一遍"
echo "如果长时间没有反应，请尝试手动开机或者重刷一遍"
echo " "

read -p "是否要清除数据？（y/n）" wipeOrNot

if [ "$wipeOrNot" = "y" -o "$wipeOrNot" = "Y" ] ;then
	$bin/fastboot erase userdata
	$bin/fastboot erase metadata
fi

$bin/fastboot set_active a
$bin/fastboot reboot