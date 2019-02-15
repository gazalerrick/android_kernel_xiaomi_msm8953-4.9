#!/bin/bash
# kkkll!/usr/bin/env bash
# Copyright (C) 2018 Abubakar Yagob (blacksuan19)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# SPDX-License-Identifier: GPL-3.0-or-later


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
export KBUILD_BUILD_HOST="Ubuntu18.04-Trial"

mkdir out

make O=out $CONFIG $THREAD &>/dev/null
make O=out $THREAD & pid=$!
