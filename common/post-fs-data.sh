#!/system/bin/sh
# Auto re-patch /system/etc/sysconfig/* across ROM/GApps updates

# Environment
export PATH=/dev/magisk/bin:$PATH
MODPATH=${0%/*}
syscfg=/dev/magisk/mirror/system/etc/sysconfig
syscfgTMP=/data/_syscfg
syscfgP=$MODPATH/system/etc/sysconfig
syscfgBKP=$MODPATH/.syscfgBKP
mga_dir=/data/media/MagicGApps
. $mga_dir/config.txt


if $sysconfig_patch; then
	if [ "$(cat $MODPATH/.SystemSizeK)" -ne "$(du -s /dev/magisk/mirror/system | cut -f1)" ]; then
		exec &>$mga_dir/sysconfig_auto_repatch.log
		date
		[ -d "$syscfgBKP" ] || cp -rf $syscfgP $syscfgBKP
		[ -d "$syscfgTMP" ] && rm -rf $syscfgTMP
		mkdir $syscfgTMP
		rm -rf $syscfgP/*
		
		for file in $syscfg/* $syscfgBKP/*; do
			if [ -f "$file" ]; then
				grep -Eq '<allow-in-power-save|<allow-in-data-usage-save' "$file" \
					&& cp "$file" $syscfgTMP || cp "$file" $syscfgP
			fi
		done
		
		for file in $syscfgTMP/*; do
			[ -f "$file" ] && sed -i '/allow/s/<a/<!-- a/' "$file"
		done
		
		sed -i '/.volta/s/<!-- a/<a/' $syscfgTMP/google.xml
		cp $syscfgTMP/* $syscfgP
		rm -rf $syscfgTMP
		chmod -R 644 $syscfgP
		
		echo "$(du -s /dev/magisk/mirror/system | cut -f1)" > $MODPATH/.SystemSizeK
		date
	fi
fi
exit 0