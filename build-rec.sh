#!/usr/bin/env bash
# Copyright (C) 2018 Abubakar Yagob (blacksuan19)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# SPDX-License-Identifier: GPL-3.0-or-later
# @alanndz

# Color
# green='\033[0;32m'
# echo -e "$green"

# Main Environment
KERNEL_DIR=$PWD
TOOL_DIR=$KERNEL_DIR/../toolchains
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/../AnyKernel2
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs
CONFIG=vince-perf_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE+="ccache "
CROSS_COMPILE+="$PWD/../toolchains/bin/aarch64-linux-android-"

# Setup
if [ ! -d "$TOOL_DIR" ]; then
  mkdir $TOOL_DIR
  git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --depth=1 ../toolchains
fi   
if [ ! -d "$ZIP_DIR" ]; then
  mkdir $ZIP_DIR
  git clone  https://github.com/alanndz/AnyKernel2 -b vince-aosp ../AnyKernel2
fi  

# Export
export ARCH=arm64
export SUBARCH=arm64
export PATH=/usr/lib/ccache:$PATH
export CROSS_COMPILE
export KBUILD_BUILD_USER="alanndz"
export KBUILD_BUILD_HOST="Ubuntu-18.04.2-x86_x64"

# Main Setup
TELE=~/telegram/telegram
TELE_TOKEN=799058967:AAHdBKLP8cjxLXUCxeBiWmEOoY8kZHvbiQo
TELE_ID=671339354

# Main Telegram
#function sendInfo() {
# $TELE -t $TELE_TOKEN -c $TELE_ID "${1}"
#}

function sendInfo() {
	"${TELEGRAM}" -t ${TELE_TOKEN} -c ${TELE_ID} -H \
		"$(
			for POST in "${@}"; do
				echo "${POST}"
			done
		)"
}

function sendFile() {
	$TELE -t $TELE_TOKEN -c $TELE_ID -f $ZIP_DIR/aLN*.zip
}

# Generate defconfig
make O=out  $CONFIG savedefconfig &>/dev/null
cp out/defconfig arch/arm64/configs/$CONFIG &>/dev/null

# Push to Bot Telegram
sendInfo "$(echo -e "--aLN Kernel New Build--\nStarted at $DATE\nStarted on $(hostname)\nCommit : $(git log --pretty=format:'"%h : %s"' -1)\nBuild using GCC 4.9\nBuild Started ...")"

# Start Building
make  O=out $CONFIG $THREAD &>/dev/null
make  O=out $THREAD & pid=$!   
	
BUILD_START=$(date +"%s")
DATE=`date`

echo -e "\n#######################################################################"

echo -e "(i) Build started at $DATE using $CORES thread"


spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"
echo -ne "\n[Please wait...] ${spin[0]}"
while kill -0 $pid &>/dev/null
do
	for i in "${spin[@]}"
	do
		echo -ne "\b$i"
		sleep 0.1
	done
done
	
if ! [ -a $KERN_IMG ]; then
	echo -e "\n(!) Kernel compilation failed, See buildlog to fix errors"
	sendInfo "$(echo -e "Kernel compilation failed!!!")"
	echo -e "#######################################################################"
	exit 1
fi
	
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

echo -e "\n(i) Image-dtb compiled successfully."

echo -e "#######################################################################"

echo -e "(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

# Building Zip File
echo -e "#######################################################################"
cd $ZIP_DIR
make clean &>/dev/null
cp $KERN_IMG $ZIP_DIR/zImage
make normal &>/dev/null
cd ..

echo -e "(i) Flashable zip generated under $ZIP_DIR."

echo -e "#######################################################################"

# Send to Telegram
sendFile
sendInfo "$(echo -e "(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
