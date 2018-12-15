#!/bin/bash

#
# SmartPack-Kernel Build Script
# 
# Author: sunilpaulmathew <sunil.kde@gmail.com>
#

#
# This script is licensed under the terms of the GNU General Public 
# License version 2, as published # by the Free Software Foundation, 
# and may be copied, distributed, and modified under those terms.
#

#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR # PURPOSE. See the
# GNU General Public License for more details.
#

#
# ***** ***** ***** ..How to use this script… ***** ***** ***** #
#
# For those who want to build this kernel using this script…
#
# Please note: this script is by-default designed to build only 
# one variants at a time.
#

# 1. Properly locate toolchain (Line# 41)
# 2. Select the 'KERNEL_VARIANT' (Line# 47)
# 3. Open Terminal, ‘cd’ to the Kernel ‘root’ folder 
# 4. run ‘. build_SmartPack.sh’
# 5. The output file will be generated in the ‘release_SmartPack’ folder
# 6. Flash & enjoy your new Kernel

#
# ***** ***** *Variables to be configured manually* ***** ***** #

#TOOLCHAIN="/home/tc/arm-linux-gnueabi/bin/arm-linux-gnueabi-"

ARCHITECTURE="arm"

KERNEL_NAME="SmartPack-Kernel"

KERNEL_VARIANT="ja3g"	# only one variant at a time
			# Supported variants: ja3g, jalteskt & jaltelgt

KERNEL_VERSION="final-Linaro"   # leave as such, if no specific version tag

KERNEL_DEFCONFIG="lineageos_@$KERNEL_VARIANT@_defconfig"

KERNEL_DATE="$(date +"%Y%m%d")"

NUM_CPUS=""   # number of cpu cores used for build (leave empty for auto detection)

# ***** ***** ***** ***** ***THE END*** ***** ***** ***** ***** #

COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[1;32m"
COLOR_NEUTRAL="\033[0m"

export ARCH=$ARCHITECTURE
#export CROSS_COMPILE="${CCACHE} $TOOLCHAIN"

if [ -z "$NUM_CPUS" ]; then
	NUM_CPUS=`grep -c ^processor /proc/cpuinfo`
fi

if [ -z "$KERNEL_VARIANT" ]; then
	echo -e $COLOR_GREEN"\n Please select the variant to build... 'KERNEL_VARIANT' should not be empty...\n"$COLOR_NEUTRAL
else
	if [ -e arch/arm/configs/$KERNEL_DEFCONFIG ]; then
		echo -e $COLOR_GREEN"\n building $KERNEL_NAME v. $KERNEL_VERSION for $KERNEL_VARIANT\n"$COLOR_NEUTRAL
		# creating backups
		cp scripts/mkcompile_h release_SmartPack/
		# updating kernel name
		#sed "s/\`echo \$LINUX_COMPILE_BY | \$UTS_TRUNCATE\`/$KERNEL_NAME-$KERNEL_VARIANT-[sunilpaulmathew/g" -i scripts/mkcompile_h
		#sed "s/\`echo \$LINUX_COMPILE_HOST | \$UTS_TRUNCATE\`/xda-developers.com]/g" -i scripts/mkcompile_h
		if [ -e output_$KERNEL_VARIANT/.config ]; then
			rm -f output_$KERNEL_VARIANT/.config
			if [ -e output_$KERNEL_VARIANT/arch/arm/boot/zImage ]; then
				rm -f output_$KERNEL_VARIANT/arch/arm/boot/zImage
			fi
		else
			mkdir output_$KERNEL_VARIANT
		fi
		make -C $(pwd) O=output_$KERNEL_VARIANT $KERNEL_DEFCONFIG && make -j$NUM_CPUS -C $(pwd) O=output_$KERNEL_VARIANT
		if [ -e output_$KERNEL_VARIANT/arch/arm/boot/zImage ]; then
				stat output_$KERNEL_VARIANT/arch/arm/boot/zImage
#				mkdir recovery-zip_SmartPack/mkboot			
				cp output_$KERNEL_VARIANT/arch/arm/boot/zImage recovery-zip_SmartPack/mkboot/
				#echo -e $COLOR_GREEN"\n Generating kernel installer zip\n"$COLOR_NEUTRAL
				cp -R mkboot/ARM/. recovery-zip_SmartPack/mkboot/
				mkdir -p recovery-zip_SmartPack/mkboot/synapse/res/ && cp -r mkboot/LOS-ja3g/ramdisk/res/synapse "$_"
 				mkdir -p recovery-zip_SmartPack/mkboot/synapse/res/sbin/ && cp mkboot/LOS-ja3g/ramdisk/res/synapse/sbin/uci "$_"
				echo -e $COLOR_GREEN"\n Making recovery flashable zip\n"$COLOR_NEUTRAL
				cd recovery-zip_SmartPack/
				zip -r9 $KERNEL_NAME-$KERNEL_VARIANT-$KERNEL_VERSION-$KERNEL_DATE.zip *  
				mv $KERNEL_NAME* ../release_SmartPack/
				cd ../
				rm -R recovery-zip_SmartPack/mkboot
			
			echo -e $COLOR_GREEN"\n Restoring backups\n"$COLOR_NEUTRAL
			mv release_SmartPack/mkcompile_h scripts/
			echo -e $COLOR_GREEN"\n Everything done... please visit 'release_SmartPack'\n"$COLOR_NEUTRAL
		fi
	else
		echo -e $COLOR_GREEN"\n '$KERNEL_VARIANT' is not a supported variant... please check...\n"$COLOR_NEUTRAL
	fi
fi
