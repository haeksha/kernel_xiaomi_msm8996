#!/bin/bash

# Syntax: 
# ./builder.sh yourdevicecodename
# Example:
# ./builder.sh capricorn

if [ $1 ]
then
 
echo "Building for $1"
KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel3
OUTKERNEL_DIR=$KERNEL_DIR/../out
DATE=$(date +"%d%m%Y")
TIME=$(date +"%H%M")
KERNEL_NAME="Havoc"
DEVICE="$1"
FINAL_ZIP="$KERNEL_NAME-$DEVICE-$DATE-$TIME.zip"

if [ -e CRSC.sh ]; then . CRSC.sh; fi
CCACHE=`which ccache`;
mkdir -p $OUTKERNEL_DIR;
make O=$OUTKERNEL_DIR clean mrproper;
rm -rf $ANYKERNEL_DIR/Image.gz*;

make O=$OUTKERNEL_DIR $1_defconfig;
/bin/bash -c "(make -j4 -C $KERNEL_DIR O=$OUTKERNEL_DIR CFLAGS_MODULE=\"-fno-pic\" ARCH=arm64 CROSS_COMPILE=\"$CCACHE $CROSS_COMPILE\" CROSS_COMPILE_ARM32=\"$CROSS_COMPILE_ARM32\" Image.gz-dtb)"

{
cp $OUTKERNEL_DIR/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
} || {
  if [ $? != 0 ]; then
    echo Noooope
    exit
  fi
}

cd $ANYKERNEL_DIR/
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
mkdir -p $KERNEL_DIR/../builds
mv $FINAL_ZIP $KERNEL_DIR/../builds/$FINAL_ZIP
echo "Your kernel is located in ../builds/$FINAL_ZIP"

else
echo "You should specify codename of the your device"
fi
