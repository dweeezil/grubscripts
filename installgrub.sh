#!/bin/sh

VERBOSE="--verbose"
GRUBPREFIX="/usr"
PREFIX="grub"
DEV="$1"
[ "$2" ] && IMAGEPREFIX="--prefix $2"


MODULES_DISKIO="biosdisk ahci"
MODULES_LABEL="part_bsd part_gpt part_msdos part_sun"
MODULES_FS="ext2 zfs fat exfat"
MODULES_TERMINAL="terminal serial"
MODULES_MISC="zfsinfo search_fs_uuid search_label"


# ARCH="x86_64"
# TARGET="efi"
ARCH="i386"
TARGET="pc"

GRUBTARGET="$ARCH-$TARGET"

mkdir -p "$PREFIX"/"$GRUBTARGET"
cp "$GRUBPREFIX"/lib/grub/"$GRUBTARGET"/boot.img "$PREFIX"/"$GRUBTARGET"

grub-mkimage \
	$VERBOSE \
	$IMAGEPREFIX \
	--format "$GRUBTARGET" \
	--directory "$GRUBPREFIX"/lib/grub/"$GRUBTARGET" \
	--output "$PREFIX/$GRUBTARGET/core.img" \
	--compression auto \
	--config load.cfg \
	$MODULES_DISKIO \
	$MODULES_LABEL \
	$MODULES_FS \
	$MODULES_TERMINAL \
	$MODULES_MISC

if [ $? -ne 0 ]; then
	echo grub-mkimage failed
	echo removing: "$PREFIX/$GRUBTARGET/core.img" 
	rm -f "$PREFIX/$GRUBTARGET/core.img" 
	exit 1
fi

grub-bios-setup \
	$VERBOSE \
	--skip-fs-probe \
	--directory="$PREFIX/$GRUBTARGET" \
	--device-map="$PREFIX"/device.map \
	--boot-image="boot.img" \
	--core-image="core.img" \
	"$DEV"
