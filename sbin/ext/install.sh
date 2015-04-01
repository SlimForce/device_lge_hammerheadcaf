#!/sbin/busybox sh

BB=/sbin/busybox

ROOTFS_MOUNT=$(mount | grep rootfs | cut -c26-27 | grep rw)
SYSTEM_MOUNT=$(mount | grep system | cut -c69-70 | grep rw)
if [ "$ROOTFS_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$SYSTEM_MOUNT" -eq "0" ]; then
	$BB mount -o remount,rw /system;
fi;

cd /;

STWEAKS_CHECK=$($BB find /data/app/ -name com.af.synapse* | wc -l);

if [ "$STWEAKS_CHECK" -eq "1" ]; then
	echo "/data/app";
	$BB rm -rf /data/app/com.af.synapse* > /dev/null 2>&1;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ -f /system/priv-app/com.af.synapse* ]; then
	echo "/system/priv-app";
	$BB rm -rf /system/priv-app/com.af.synapse*;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ -f /system/app/com.af.synapse* ]; then
	echo "/system/app";
	$BB rm -rf /system/app/com.af.synapse*;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
fi;

if [ ! -d /system/app/Synapse ]; then
	$BB mkdir /system/app/Synapse;
fi;

if [ -f /system/app/Synapse/Synapse.apk ]; then
	stmd5sum=$($BB md5sum /system/app/Synapse/Synapse.apk | $BB awk '{print $1}');
	stmd5sum_kernel=$($BB cat /res/payload/Synapse.md5);
	if [ "$stmd5sum" != "$stmd5sum_kernel" ]; then
		echo "reinstall, stmd5sum = $stmd5sum , stmd5sum_kernel = $stmd5sum_kernel"
		$BB rm -rf /system/app/Synapse/* > /dev/null 2>&1;
		$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
		$BB cp /res/payload/Synapse.apk /system/app/Synapse/;
		$BB chown -R root.root /system/app/Synapse/Synapse.apk;
		$BB chmod 755 /system/app/Synapse;
		$BB chmod 644 /system/app/Synapse/Synapse.apk;
	fi;
else
	echo "install"
	$BB rm -rf /system/app/Synapse/* > /dev/null 2>&1;
	$BB rm -rf /data/data/com.af.synapse* > /dev/null 2>&1;
	$BB cp /res/payload/Synapse.apk /system/app/Synapse/;
	$BB chown root.root /system/app/STweaks.apk;
	$BB chmod 755 /system/app/Synapse;
	$BB chmod 644 /system/app/Synapse/Synapse.apk;
fi;
