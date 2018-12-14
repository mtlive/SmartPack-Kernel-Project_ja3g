#!/sbin/sh
cd /tmp/
./wrapper boot.img bootfolder
cp zImage bootfolder/zImage
./wrapper bootfolder newboot.img -origramdisk
