#!/sbin/busybox sh

BB=/sbin/busybox

ROOTFS_MOUNT=$(mount | grep rootfs | cut -c26-27 | grep rw | wc -l)
SYSTEM_MOUNT=$(mount | grep system | cut -c69-70 | grep rw | wc -l)
if [ "$ROOTFS_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$SYSTEM_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /system;
fi;

cd /;

STWEAKS_CHECK=$($BB find /data/app/ -name com.af.synapse* | wc -l);

if [ "$STWEAKS_CHECK" -eq "1" ]; then
	$BB rm -rf /data/app/com.af.synapse* > /dev/null 2>&1;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ -e /system/priv-app/com.af.synapse* ]; then
	$BB rm -rf /system/priv-app/com.af.synapse*;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ -e /system/app/com.af.synapse* ]; then
	$BB rm -rf /system/app/com.af.synapse*;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ -e /system/app/Synapse* ]; then
	$BB rm -rf /system/app/Synapse* > /dev/null 2>&1;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;
