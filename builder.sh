#!/bin/bash

# Syntax: 
# ./builder.sh yourdevicecodename
# Example:
# ./builder.sh capricorn

color_failed=$'\E'"[0;31m"
color_success=$'\E'"[0;32m"
color_reset=$'\E'"[00m"

function tmr()
{
	if [ -z $task ]; then task=task; fi
	local start_time=$(date +"%s")
	"$@"
	local ret=$?
	local end_time=$(date +"%s")
	local tdiff=$(($end_time-$start_time))
	local hours=$(($tdiff / 3600 ))
	local mins=$((($tdiff % 3600) / 60))
	local secs=$(($tdiff % 60))
	echo
	if [ $ret -eq 0 ] ; then
		echo -n "${color_success}#### $task completed successfully "
	else
		echo -n "${color_failed}#### $task failed to build some targets "
	fi
	if [ $hours -gt 0 ] ; then
		printf "(%02g:%02g:%02g (hh:mm:ss))" $hours $mins $secs
	elif [ $mins -gt 0 ] ; then
		printf "(%02g:%02g (mm:ss))" $mins $secs
	elif [ $secs -gt 0 ] ; then
		printf "(%s seconds)" $secs
	fi
	echo " ####${color_reset}"
	echo
	return $ret
};

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
tmr make O=$OUTKERNEL_DIR clean mrproper;
rm -f $ANYKERNEL_DIR/Image.gz-dtb;

make O=$OUTKERNEL_DIR $1_defconfig;
tmr /bin/bash -c "(make -j4 -C $KERNEL_DIR O=$OUTKERNEL_DIR CFLAGS_MODULE=\"-fno-pic\" ARCH=arm64 CROSS_COMPILE=\"$CCACHE $CROSS_COMPILE\" CROSS_COMPILE_ARM32=\"$CROSS_COMPILE_ARM32\" Image.gz-dtb)"

{
cp $OUTKERNEL_DIR/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/
} || {
  if [ $? != 0 ]; then
    echo Noooope
    exit
  fi
}

cd $ANYKERNEL_DIR/
tmr zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
mkdir -p $KERNEL_DIR/../builds
mv $FINAL_ZIP $KERNEL_DIR/../builds/$FINAL_ZIP
echo "Your kernel is located in ../builds/$FINAL_ZIP"

else
echo "You should specify codename of the your device"
fi
