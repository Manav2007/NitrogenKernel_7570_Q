  #!/bin/bash
#
# NitrogenKernel script
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Main Dir
CR_DIR=$(pwd)
# Define toolchan path
#CR_TC=/home/sarr/TC/bin/aarch64-linux-android-
CR_TC=/home/android/too/aarch64-linux-android-4.9-kernel/bin/aarch64-linux-android-
#CR_TC=/media/sarr/SARR-DRIVER/toolchain/bin/aarch64-linux-android-
#CR_TC=$CR_DIR/tc/bin/aarch64-linux-gnu-
# Define proper arch and dir for dts files
CR_DTS=arch/arm64/boot/dts
# Define boot.img out dir
CR_OUT=$CR_DIR/Nitrogen/Out
CR_PRODUCT=$CR_DIR/Nitrogen/Product
# Presistant A.I.K Location
CR_AIK=$CR_DIR/Nitrogen/A.I.K
# Main Ramdisk Location
CR_RAMDISK=$CR_DIR/Nitrogen/universal7570
# Compiled image name and location (Image/zImage)
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
# Compiled dtb by dtbtool
CR_DTB=$CR_DIR/arch/arm64/boot/boot.img-dtb
# Kernel Name and Version
CR_VERSION=V5.1
CR_NAME=NitrogenKernel
# Thread count
CR_JOBS=`grep processor /proc/cpuinfo|wc -l`
# Target android version and platform (7/n/8/o/9/p)
CR_ANDROID=q
CR_PLATFORM=10.0.0
# Target ARCH
CR_ARCH=arm64
# Init build
export CROSS_COMPILE=$CR_TC
# General init
export ANDROID_MAJOR_VERSION=$CR_ANDROID
export PLATFORM_VERSION=$CR_PLATFORM
export $CR_ARCH

# DTB SPECIFIC
CR_A=null
OUTDIR=$CR_DIR/arch/$ARCH/boot
DTSDIR=$CR_DIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$CR_DIR/scripts/dtc/dtc
INCDIR=$CR_DIR/include
PAGE_SIZE=2048
DTB_PADDING=0


##########################################
# Device specific Variables [SM-G570X]
CR_DTSFILES_G570X="exynos7570-on5xelte_swa_open_00.dtb exynos7570-on5xelte_swa_open_01.dtb exynos7570-on5xelte_swa_open_02.dtb exynos7570-on5xelte_swa_open_03.dtb exynos7570-on5xelte_swa_open_04.dtb exynos7570-on5xreflte_swa_open_00.dtb"
CR_CONFG_G570X=exynos7570-on5xelte_defconfig
CR_CONFG_G570Xt=exynos7570-on5xeltet_defconfig
CR_VARIANT_G570X=G570X
# Device specific Variables [SM-J330X]
CR_DTSFILES_J330X="exynos7570-j3y17lte_eur_open_00.dtb exynos7570-j3y17lte_eur_open_01.dtb exynos7570-j3y17lte_eur_open_02.dtb exynos7570-j3y17lte_eur_open_04.dtb exynos7570-j3y17lte_kor_open_02.dtb"
CR_CONFG_J330X=exynos7570-j3y17lte_defconfig
CR_CONFG_J330Xt=exynos7570-j3y17ltet_defconfig
CR_VARIANT_J330X=J330X
# Device specific Variables [SM-J400X]
CR_DTSFILES_J400X="exynos7570-j4lte_mea_open_00.dtb exynos7570-j4lte_mea_open_01.dtb exynos7570-j4lte_mea_open_02.dtb"
CR_CONFG_J400X=exynos7570-j4lte_defconfig
CR_CONFG_J400Xt=exynos7570-j4ltet_defconfig
CR_VARIANT_J400X=J400X
# Device specific Variables [SM-J260X]
CR_DTSFILES_J260X="exynos7570-j4lte_mea_open_00.dtb exynos7570-j4lte_mea_open_01.dtb exynos7570-j4lte_mea_open_02.dtb"
CR_CONFG_J260X=exynos7570-j2corelte_defconfig
CR_CONFG_J260Xt=exynos7570-j2coreltet_defconfig
CR_VARIANT_J260X=J260X
CR_DEFCON=NULL
# Prefixes
CR_ROOT="0"
CR_PERMISSIVE="0"
CR_HALLIC="0"
# Flashable Variables
FL_MODEL=NULL
FL_VARIANT=NULL
FL_DIR=$CR_DIR/Nitrogen/Flashable
FL_EXPORT=$CR_DIR/Nitrogen/Flashable_OUT
FL_SCRIPT=$FL_EXPORT/META-INF/com/google/android/updater-script
#####################################################

# Script functions

read -p "Clean source (y/n) > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "Clean Build"
     CR_CLEAN="1"
else
     echo "Dirty Build"
     CR_CLEAN="0"
fi

#Particular dtb build 

read -p "Build DTB With kernel (y/n) if N only DTB will be built > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "DTB will be compiled with Zimage"
     CR_KRI="1"
else
     echo "DTB Will be particulary built"
     CR_KRI="0"
fi
# TREBLE / OneUI
read -p "Variant? (1 (oneUI) | 2 (TREBLE) > " aud
if [ "$aud" = "TREBLE" -o "$aud" = "2" ]; then
     echo "Build TREBLE Variant"
     CR_MODE="2"
     CR_HALLIC="1"
     CR_PERMISSIVE="0"
	 CR_TT=AOSP
else
     echo "Build OneUI Variant"
     CR_MODE="1"
     CR_HALLIC="1"
     CR_PERMISSIVE="0"
	 CR_TT=OneUI
fi

BUILD_CLEAN()
{
if [ $CR_CLEAN = 1 ]; then
     echo " "
     echo " Cleaning build dir"
     make clean && make mrproper
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7570.dtsi
     rm -rf $CR_OUT/*.img
     rm -rf $CR_OUT/*.zip
fi
if [ $CR_CLEAN = 0 ]; then
     echo " "
     echo " Skip Full cleaning"
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7570.dtsi
fi
}

BUILD_IMAGE_NAME()
{
	CR_IMAGE_NAME=$CR_NAME-$CR_VERSION-$CR_VARIANT

  # Flashable_script
  if [ $CR_VARIANT = $CR_VARIANT_G570X-TREBLE ]; then
    FL_VARIANT="G570X-AOSP"
    FL_MODEL=on5xelte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_G570X-ONEUI ]; then
    FL_VARIANT="G570X-OneUI"
    FL_MODEL=on5xelte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J330X-TREBLE ]; then
    FL_VARIANT="J330X-AOSP"
    FL_MODEL=j3y17lte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J330X-ONEUI ]; then
    FL_VARIANT="J330X-OneUI"
    FL_MODEL=j3y17lte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J400X-TREBLE ]; then
    FL_VARIANT="J400X-AOSP"
    FL_MODEL=j4lte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J400X-ONEUI ]; then
    FL_VARIANT="J400X-OneUI"
    FL_MODEL=j4lte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J260X-TREBLE ]; then
    FL_VARIANT="J260X-AOSP"
    FL_MODEL=j2corelte
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J260X-ONEUI ]; then
    FL_VARIANT="J260X-OneUI"
    FL_MODEL=j2corelte
  fi

}

BUILD_GENERATE_CONFIG()
{
 CR_DEFCON=$CR_DEF
}

BUILD_OUT()
{
    echo " "
    echo "----------------------------------------------"
    echo "$CR_VARIANT kernel build finished."
    echo "Compiled DTB Size = $sizdT Kb"
    echo "Kernel Image Size = $sizT Kb"
    echo "Boot Image   Size = $sizkT Kb"
    echo "Image Generated at $CR_PRODUCT/$CR_IMAGE_NAME.img"
    echo "Zip Generated at $CR_PRODUCT/$CR_NAME-$CR_VERSION-$FL_VARIANT.zip"
    echo "Press Any key to end the script"
    echo "----------------------------------------------"
}

BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building zImage for $CR_VARIANT"
	export LOCALVERSION=-$CR_IMAGE_NAME
	echo "Make $CR_DEF"
	make $CR_DEFCON
	make -j$CR_JOBS
	if [ ! -e $CR_KERNEL ]; then
	exit 0;
	echo "Image Failed to Compile"
	echo " Abort "
	fi
    du -k "$CR_KERNEL" | cut -f1 >sizT
    sizT=$(head -n 1 sizT)
    rm -rf sizT
	echo " "
	echo "----------------------------------------------"
}

RUN_BUILD_DTB()
{
	# This source compiles particulary and it is recommended
	[ -f "$DTCTOOL" ] || {
		echo "You need to run ./build.sh first!"
		exit 1
	}
	case $CR_A in
	G570)
		echo "Building Device blob tree for $CR_A"
		DTSFILES="exynos7570-on5xelte_swa_open_00 exynos7570-on5xelte_swa_open_01
				exynos7570-on5xelte_swa_open_02 exynos7570-on5xelte_swa_open_03 exynos7570-on5xreflte_swa_open_00"
		;;
	J330)
		DTSFILES="exynos7570-j3y17lte_eur_open_00 exynos7570-j3y17lte_eur_open_01 
		exynos7570-j3y17lte_kor_open_02 exynos7570-j3y17lte_eur_open_02 exynos7570-j3y17lte_eur_open_04"
		;;
	J400)
		DTSFILES="exynos7570-j4lte_mea_open_00 exynos7570-j4lte_mea_open_01 exynos7570-j4lte_mea_open_02"
		;;
	J260)
		DTSFILES="exynos7570-j4lte_mea_open_00 exynos7570-j4lte_mea_open_01 exynos7570-j4lte_mea_open_02"
		;;
	
	*)
		echo "Unknown device: $CR_A"
		exit 1
		;;
	esac
	mkdir -p $OUTDIR $DTBDIR
	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}
	rm -f ./*
	echo "Processing dts files."
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done
	echo "Generating dtb.img."
	$CR_DIR/scripts/dtbTool/dtbtool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
	echo "Done."
	mv $CR_DIR/arch/$ARCH/boot/dtb.img $CR_DIR/arch/$ARCH/boot/boot.img-dtb
}

BUILD_DTB()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building DTB for $CR_VARIANT"
	# This source compiles dtbs while doing Image
	./scripts/dtbtool_exynos/dtbTool -o $CR_DTB -d $CR_DTS/ -s 2048
	if [ ! -e $CR_DTB ]; then
    exit 0;
    echo "DTB Failed to Compile"
    echo " Abort "
	fi
	rm -rf $CR_DTS/.*.tmp
	rm -rf $CR_DTS/.*.cmd
	rm -rf $CR_DTS/*.dtb
  rm -rf $CR_DTS/exynos7570.dtsi
    du -k "$CR_DTB" | cut -f1 >sizdT
    sizdT=$(head -n 1 sizdT)
    rm -rf sizdT
	echo " "
	echo "----------------------------------------------"
}
PACK_BOOT_IMG()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Boot.img for $CR_VARIANT"
	# Copy Ramdisk
	cp -rf $CR_RAMDISK/* $CR_AIK
	# Move Compiled kernel and dtb to A.I.K Folder
	mv $CR_KERNEL $CR_AIK/split_img/boot.img-zImage
	mv $CR_DTB $CR_AIK/split_img/boot.img-dtb
	# Create boot.img
	$CR_AIK/repackimg.sh
	# Remove red warning at boot
	echo -n "SEANDROIDENFORCE" » $CR_AIK/image-new.img
  # Copy boot.img to Production folder
	cp $CR_AIK/image-new.img $CR_PRODUCT/$CR_IMAGE_NAME.img
	# Move boot.img to out dir
	mv $CR_AIK/image-new.img $CR_OUT/$CR_IMAGE_NAME.img
	du -k "$CR_OUT/$CR_IMAGE_NAME.img" | cut -f1 >sizkT
	sizkT=$(head -n 1 sizkT)
	rm -rf sizkT
	echo " "
	$CR_AIK/cleanup.sh
}

PACK_FLASHABLE()
{

  echo "----------------------------------------------"
  echo "$CR_NAME $CR_VERSION Flashable Generator"
  echo "----------------------------------------------"
	echo " "
	echo " Target device : $CR_VARIANT "
  echo " Target image $CR_OUT/$CR_IMAGE_NAME.img "
  echo " Prepare Temporary Dirs"
  FL_DEVICE=$FL_EXPORT/Nitrogen/device/$FL_MODEL/boot.img
  echo " Copy $FL_DIR to $FL_EXPORT"
  rm -rf $FL_EXPORT
  mkdir $FL_EXPORT
  cp -rf $FL_DIR/* $FL_EXPORT
  echo " Generate updater for $FL_VARIANT"
  sed -i 's/FL_NAME/ui_print("* '$CR_NAME'");/g' $FL_SCRIPT
  sed -i 's/FL_VERSION/ui_print("* '$CR_VERSION'");/g' $FL_SCRIPT
  sed -i 's/FL_VARIANT/ui_print("* For '$FL_VARIANT' ");/g' $FL_SCRIPT
  echo " Copy Image to $FL_DEVICE"
  cp $CR_OUT/$CR_IMAGE_NAME.img $FL_DEVICE
  echo " Packing zip"
  # TODO: FInd a better way to zip
  # TODO: support multi-compile
  # TODO: Conditional
  cd $FL_EXPORT
  zip -r $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT.zip .
  cd $CR_DIR
  rm -rf $FL_EXPORT
  # Copy zip to production
  cp $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT.zip $CR_PRODUCT
  # Move out dir to BUILD_OUT
  # Respect CLEAN build rules
  BUILD_CLEAN
}

# Main Menu
clear
echo "*************************************************"
echo "*         Nitrogen Kernel build script          *"
echo "*           For Exynos 7570 Devices             *"
echo "*             Developper: Asarre                *"
echo "*                                               *"
echo "* Version:$CR_VERSION                           *"
echo "* Architecture: ARM64                           *"
echo "* Build Type:$CR_TT                             *"
echo "* Kernel Version: 3.18.140                      *"
echo "* Android Version: 10 (Q)                       *"
echo "*                                               *"
echo "*                                               *"
echo "*************************************************"
echo " "
echo " "
PS3='Please select your Device (1-4): '
menuvar=("SM-G570X" "SM-J330X" "SM-J400X" "SM-J260X" "Build_All" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "SM-G570X")
            clear
			echo " "
            echo " "
            echo "Starting $CR_VARIANT_G570X kernel build..."
			CR_A=G570
            CR_DTSFILES=$CR_DTSFILES_G570X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
              CR_VARIANT=$CR_VARIANT_G570X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_DEF=$CR_CONFG_G570Xt
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_G570X
              CR_VARIANT=$CR_VARIANT_G570X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
	    #ASARRE
            #BUILD_DTB
	    #RUN_BUILD_DTB
            #PACK_BOOT_IMG
            #PACK_FLASHABLE
            #BUILD_OUT
            #RUN_BUILD_DTB
            read -n1 -r key
            break
            ;;
        "SM-J330X")
            clear
            echo "Starting $CR_VARIANT_J330X kernel build..."
			CR_A=J330			
            CR_DTSFILES=$CR_DTSFILES_J330X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_J330Xt
              CR_VARIANT=$CR_VARIANT_J330X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_J330X
              CR_VARIANT=$CR_VARIANT_J330X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
			#ASARRE3
            #BUILD_DTB
            #PACK_BOOT_IMG
            #PACK_FLASHABLE
            #BUILD_OUT
            read -n1 -r key
            break
            ;;
        "SM-J400X")
            clear
            echo "Starting $CR_VARIANT_J400X kernel build..."
			CR_A=J400
            CR_DTSFILES=$CR_DTSFILES_J400X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_J400Xt
              CR_VARIANT=$CR_VARIANT_J400X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_J400X
              CR_VARIANT=$CR_VARIANT_J400X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
			#ASARRE4
            #BUILD_DTB
            #PACK_BOOT_IMG
            #PACK_FLASHABLE
            #BUILD_OUT
            read -n1 -r key
            break
            ;;
        "SM-J260X")
            clear
            echo "Starting $CR_VARIANT_J260X kernel build..."
	     CR_A=J260
            CR_DTSFILES=$CR_DTSFILES_J260X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_J260Xt
              CR_VARIANT=$CR_VARIANT_J260X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_J260X
              CR_VARIANT=$CR_VARIANT_J260X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            #BUILD_DTB
            #PACK_BOOT_IMG
            #PACK_FLASHABLE
            #BUILD_OUT
            read -n1 -r key
            break
            ;;
            "Build_All")
            echo "Starting $CR_VARIANT_G570X kernel build..."	
			CR_A=G570
            CR_DTSFILES=$CR_DTSFILES_G570X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_G570Xt
              CR_VARIANT=$CR_VARIANT_G570X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_G570X
              CR_VARIANT=$CR_VARIANT_G570X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo "Starting $CR_VARIANT_J330X kernel build..."
			CR_A=J330
            CR_DTSFILES=$CR_DTSFILES_J330X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_J330Xt
              CR_VARIANT=$CR_VARIANT_J330X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF= $CR_CONFG_J330X
              CR_VARIANT=$CR_VARIANT_J330X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo "Starting $CR_VARIANT_J400X kernel build..."
			CR_A=J400
            CR_DTSFILES=$CR_DTSFILES_J400X
            if [ $CR_MODE = "2" ]; then
              echo " Building TREBLE variant "
	      CR_DEF=$CR_CONFG_J400Xt
              CR_VARIANT=$CR_VARIANT_J400X-TREBLE
              CR_RAMDISK=$CR_RAMDISK
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
	      CR_DEF=$CR_CONFG_J400X
              CR_VARIANT=$CR_VARIANT_J400X-ONEUI
              CR_DTB_MOUNT=$CR_DTS_TREBLE
              CR_RAMDISK=$CR_RAMDISK
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo " "
            echo " "
            echo " compilation finished "
            echo " Targets at $CR_OUT"
            echo " "
            echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
