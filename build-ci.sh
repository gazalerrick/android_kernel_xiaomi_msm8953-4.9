# Nito CI Script
# Copyright (C) 2019 urK -kernelaesthesia- (Z5X67280@163.com)
# Copyright (C) 2019 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2019 Rama Bondan Prakoso (rama982) 
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Test clang
#

export ARCH=arm64
export SUBARCH=arm64
export CC=$PWD/../ToolDragon9/Clang/bin/clang
export CLANG_TREPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$PWD/../ToolDragon9/Toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="alanndz"
export KBUILD_BUILD_HOST="DragonTC-9.0"
export BUILD_END=$(date +"%s")
export DIFF=$(($BUILD_END - $BUILD_START))

export IMG=$PWD/out/arch/arm64/boot/Image.gz
export DTB=$PWD/out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb

if [ ! -d "$CROSS_COMPILE" ]; then
  mkdir $TOOL_DIR
  git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 ../ToolDragon9/Toolchain --depth=1
fi
if [ ! -d "$CC" ]; then
  mkdir $TOOL_DIR
  git clone https://github.com/nibaji/DragonTC-9.0 --depth=1 ../ToolDragon9/Clang
fi
#git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 Toolchain --depth=1
#git clone https://github.com/nibaji/DragonTC-9.0 --depth=1 Clang

make O=out vince-perf_defconfig
# -j$(grep -c '^processor' /proc/cpuinfo)
make O=out -j$(grep -c '^processor' /proc/cpuinfo)

if ! [ -a out/arch/arm64/boot/Image.gz ]; then
	echo -e "Kernel compilation failed, See buildlog to fix errors"
	finerr
	exit 1
fi

mkdir outImage/kernel
mkdir outImage/kernel/treble
cp $IMG outImage/kernel/
cp $DTB outImage/kernel/treble
cd outImage
zip "aLN-Test.zip" *

cd ../

fin
echo "Build done!"
