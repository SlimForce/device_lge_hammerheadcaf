#!/sbin/busybox sh

BB=/sbin/busybox

# protect init from oom
echo "-1000" > /proc/1/oom_score_adj;

PIDOFINIT=$(pgrep -f "/sbin/ext/post-init.sh");
for i in $PIDOFINIT; do
	echo "-600" > /proc/"$i"/oom_score_adj;
done;

# Mount root as RW to apply tweaks and settings
mount -o remount,rw /;
mount -o remount,rw /system

$BB --install -s /sbin/

# Cleanup conflicts
if [ -e /system/etc/sysctl.conf ]; then
	mv /system/etc/sysctl.conf /system/etc/sysctl.conf-bak;
fi;
rm -f /system/etc/init.d/N4UKM;
rm -f /system/etc/init.d/UKM;
rm -f /system/etc/init.d/UKM_WAKE;
rm -f /system/xbin/uci;
rm -rf /data/UKM;

# allow untrusted apps to read from debugfs
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_hardware file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms"

# Make tmp folder
mkdir /tmp;

# Give permissions to execute
chown -R root:system /tmp/;
chmod -R 777 /tmp/;
chmod -R 777 /res/;
chmod 6755 /sbin/*;
chmod 6755 /system/xbin/*;

# Tune LMK with values we love
echo "1536,2048,4096,16384,28672,32768" > /sys/module/lowmemorykiller/parameters/minfree
echo 32 > /sys/module/lowmemorykiller/parameters/cost

if [ -d "/res/synapse" ]; then
	chmod 6755 /res/synapse/actions/*;
    ln -s /res/synapse/uci /sbin/uci
	chmod 777 /sbin/uci > /tmp/uci.boot 2>&1 ;
fi

sh /sbin/ext/busybox.sh > /tmp/busybox.log 2>&1 ;
sh /sbin/ext/install.sh > /tmp/install.log 2>&1 ;

echo "Boot initiated on $(date)" > /tmp/bootcheck;
