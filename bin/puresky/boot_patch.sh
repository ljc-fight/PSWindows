#!/bin/bash
#
# magisk32,magisk64,magiskinit,util_functions.sh(,stub.apk) are required
#
#######################################################################################
# Magisk Boot Image Patcher
#######################################################################################
#
# Usage: boot_patch.sh <bootimage>
#
# The following flags can be set in environment variables:
# KEEPVERITY, KEEPFORCEENCRYPT, PATCHVBMETAFLAG, RECOVERYMODE, SYSTEM_ROOT
#
# This script should be placed in a directory with the following files:
#
# File name          Type      Description
#
# boot_patch.sh      script    A script to patch boot image for Magisk.
#                  (this file) The script will use files in its same
#                              directory to complete the patching process.
# util_functions.sh  script    A script which hosts all functions required
#                              for this script to work properly.
# magiskinit         binary    The binary to replace /init.
# magisk(32/64)      binary    The magisk binaries.
# magiskboot         binary    A tool to manipulate boot images.
# stub.apk           binary    The stub Magisk app to embed into ramdisk.
# chromeos           folder    This folder includes the utility and keys to sign
#                  (optional)  chromeos boot images. Only used for Pixel C.
#
#######################################################################################

############
# Functions
############

ui_print() {
	echo \[$(date +%T)\] $@ |sed "s/\[0/\[ /"
}

abort() {
	echo \[$(date +%T)\] !Abort! $@ |sed "s/\[0/\[ /"
}

usage() {
	echo -e "\nUsage:\n\t$0 <BOOTIMG> [PREINITDEVICE]\n"
	exit 1
}

if [ $# -lt 1 ];then
	usage
fi

#################
# Initialization
#################

#Check Files
[ ! -f magisk32 ] && abort "magisk32 not found"
[ ! -f magisk64 ] && abort "magisk64 not found"
[ ! -f magiskinit ] && abort "magiskinit not found"
[ ! -f util_functions.sh ] && abort "util_functions.sh not found"

[ $# -lt 1 ] && usage

magiskboot=$(find bin/ -type f -name magiskboot* |grep "$(uname)/$(uname -m)")
BOOTIMAGE="$1"
PREINITDEVICE="$2"

MAGISKVERSION=$(grep 'MAGISK_VER_CODE' util_functions.sh 2>/dev/null |cut -d '=' -f 2)
[ "$MAGISKVERSION" == "" ] && MAGISKVERSION=0
ui_print "Magisk version: $MAGISKVERSION"

if [ $MAGISKVERSION -lt 26000 ] ;then
	unset PREINITDEVICE
	ui_print "PREINITDEVICE variable was unset"
fi


# Flags
[ -z $KEEPVERITY ] && KEEPVERITY=false
[ -z $KEEPFORCEENCRYPT ] && KEEPFORCEENCRYPT=false
[ -z $PATCHVBMETAFLAG ] && PATCHVBMETAFLAG=false
[ -z $RECOVERYMODE ] && RECOVERYMODE=false
[ -z $SYSTEM_ROOT ] && SYSTEM_ROOT=false
export KEEPVERITY
export KEEPFORCEENCRYPT
export PATCHVBMETAFLAG

chmod -R 755 .

#########
# Unpack
#########

CHROMEOS=false

ui_print "Unpacking boot image"
$magiskboot unpack "$BOOTIMAGE" >/dev/null 2>&1

case $? in
  0 ) ;;
  1 )
    abort "Unsupported/Unknown image format"
    ;;
  2 )
    ui_print "ChromeOS boot image detected"
    CHROMEOS=true
    ;;
  * )
    abort "Unable to unpack boot image"
    ;;
esac

###################
# Ramdisk Restores
###################

# Test patch status and do restore
ui_print "Checking ramdisk status"
if [ -e ramdisk.cpio ]; then
  $magiskboot cpio ramdisk.cpio test >/dev/null 2>&1
  STATUS=$?
else
  # Stock A only legacy SAR, or some Android 13 GKIs
  STATUS=0
fi
case $((STATUS & 3)) in
  0 )  # Stock boot
    ui_print "Stock boot image detected"
    SHA1=$($magiskboot sha1 "$BOOTIMAGE" 2>/dev/null)
    cat $BOOTIMAGE > stock_boot.img
    cp -af ramdisk.cpio ramdisk.cpio.orig 2>/dev/null
    ;;
  1 )  # Magisk patched
    ui_print "Magisk patched boot image detected"
    # Find SHA1 of stock boot image
    [ -z $SHA1 ] && SHA1=$($magiskboot cpio ramdisk.cpio sha1 2>/dev/null)
    $magiskboot cpio ramdisk.cpio restore
    cp -af ramdisk.cpio ramdisk.cpio.orig
    rm -f stock_boot.img
    ;;
  2 )  # Unsupported
    abort "Boot image patched by unsupported programs"
    abort "Please restore back to stock boot image"
    ;;
esac

# Workaround custom legacy Sony /init -> /(s)bin/init_sony : /init.real setup
INIT=init
if [ $((STATUS & 4)) -ne 0 ]; then
  INIT=init.real
fi

##################
# Ramdisk Patches
##################

ui_print "Patching ramdisk"

# Compress to save precious ramdisk space
SKIP32="#"
SKIP64="#"
if [ -f magisk64 ]; then
  #$BOOTMODE && [ -z "$PREINITDEVICE" ] && PREINITDEVICE=$(./magisk64 --preinit-device)
  $magiskboot compress=xz magisk64 magisk64.xz
  unset SKIP64
fi
if [ -f magisk32 ]; then
  #$BOOTMODE && [ -z "$PREINITDEVICE" ] && PREINITDEVICE=$(./magisk32 --preinit-device)
  $magiskboot compress=xz magisk32 magisk32.xz
  unset SKIP32
fi

if [ -f stub.apk ];then
	$magiskboot compress=xz stub.apk stub.xz
fi

echo "KEEPVERITY=$KEEPVERITY" > config
echo "KEEPFORCEENCRYPT=$KEEPFORCEENCRYPT" >> config
echo "PATCHVBMETAFLAG=$PATCHVBMETAFLAG" >> config
echo "RECOVERYMODE=$RECOVERYMODE" >> config

if [ -n "$PREINITDEVICE" ]; then
  ui_print "Pre-init storage partition device ID: $PREINITDEVICE"
  echo "PREINITDEVICE=$PREINITDEVICE" >> config
fi

[ -n "$SHA1" ] && echo "SHA1=$SHA1" >> config

if [ -f ramdisk.cpio ];then
	RANDOMSEED=$(sha256sum ramdisk.cpio |head -c 16)
	echo "RANDOMSEED=0x$RANDOMSEED" >> config

	$magiskboot cpio ramdisk.cpio \
	"add 0750 $INIT magiskinit" \
	"mkdir 0750 overlay.d" \
	"mkdir 0750 overlay.d/sbin" \
	"$SKIP32 add 0644 overlay.d/sbin/magisk32.xz magisk32.xz" \
	"$SKIP64 add 0644 overlay.d/sbin/magisk64.xz magisk64.xz" \
	"patch" \
	"backup ramdisk.cpio.orig" \
	"mkdir 000 .backup" \
	"add 000 .backup/.magisk config" >/dev/null 2>&1

	if [ -f stub.xz ];then
		ui_print "Add stub.apk embed into ramdisk"
		$magiskboot cpio ramdisk.cpio "add 0644 overlay.d/sbin/stub.xz stub.xz" >/dev/null 2>&1
	fi
fi

rm -f ramdisk.cpio.orig config magisk*.xz stub.xz

#################
# Binary Patches
#################


for dt in dtb kernel_dtb extra; do
  if [ -f $dt ]; then
    if ! $magiskboot dtb $dt test; then
      ui_print "Boot image $dt was patched by old (unsupported) Magisk"
      ui_print "Please try again with *unpatched* boot image"
    fi
    if $magiskboot dtb $dt patch; then
      ui_print "Patch fstab in boot image $dt"
    fi
  fi
done

if [ -f kernel ]; then
  PATCHEDKERNEL=false
  # Remove Samsung RKP
  $magiskboot hexpatch kernel \
  49010054011440B93FA00F71E9000054010840B93FA00F7189000054001840B91FA00F7188010054 \
  A1020054011440B93FA00F7140020054010840B93FA00F71E0010054001840B91FA00F7181010054 \
  && PATCHEDKERNEL=true

  # Remove Samsung defex
  # Before: [mov w2, #-221]   (-__NR_execve)
  # After:  [mov w2, #-32768]
  $magiskboot hexpatch kernel 821B8012 E2FF8F12 && PATCHEDKERNEL=true

  # Force kernel to load rootfs for legacy SAR devices
  # skip_initramfs -> want_initramfs
  $magiskboot hexpatch kernel \
  736B69705F696E697472616D667300 \
  77616E745F696E697472616D667300 \
  && PATCHEDKERNEL=true

  # If the kernel doesn't need to be patched at all,
  # keep raw kernel to avoid bootloops on some weird devices
  $PATCHEDKERNEL || rm -f kernel
fi

#################
# Repack & Flash
#################

ui_print "Repacking boot image"
$magiskboot repack "$BOOTIMAGE" >/dev/null 2>&1 || ui_print "Unable to repack boot image"

rm -rf stock_boot.img *kernel* *dtb* ramdisk.cpio*

#rm -rf magisk64 magisk32 magiskinit stub.*

# Reset any error code
true
