if [ -d tmp/product/pangu ];then
	echo>system_file_contexts_pangu
	echo>system_fs_config_pangu
	#生成fs_config file_contexts
	for file in $(ls tmp/product/pangu/system/);do
		find tmp/product/pangu/system/$file |sed "1d" |sed "s/tmp\/product\/pangu/\/system/g" |sed "s/\./\\\\./g" |sed "s/$/& u:object_r:system_file:s0/g" >>system_file_contexts_pangu
		find tmp/product/pangu/system/$file -type d |sed "1d" |sed "s/tmp\/product\/pangu/system/g" |sed "s/$/& 0 0 0755/g" >>system_fs_config_pangu
		find tmp/product/pangu/system/$file -type f |sed "s/tmp\/product\/pangu/system/g" |sed "s/$/& 0 0 0644/g" >>system_fs_config_pangu
	done

	# 去重已存在的文件夹
	for var in $(find tmp/product/pangu/system -type d |sed "1d" |sed "s/tmp\/product\/pangu\/system\///g");do
		if [ -d tmp/system/system/$var ];then
			tmpvar=$(echo "system/system/$var" |sed "s/\//\\\\\//g")
			#Yellow Directory \"$tmpvar\" already exists
			#WriteLog Directory \"$tmpvar\" already exists
			sed -i "/$tmpvar u:object_r:system_file:s0/d" system_file_contexts_pangu
			sed -i "/$tmpvar 0 0 0755/d" system_fs_config_pangu
			unset tmpvar
		fi
	done

	# 去重已存在的文件
	for var in $(find tmp/product/pangu/system -type f |sed "s/tmp\/product\/pangu\/system\///g");do
		if [ -f tmp/system/system/$var ];then
			tmpvar=$(echo "system/system/$var" |sed "s/\//\\\\\//g" |sed "s/\./\\\\./g")
			#Yellow File \"$tmpvar\" already exists
			#WriteLog File \"$tmpvar\" already exists
			sed -i "/$tmpvar u:object_r:system_file:s0/d" system_file_contexts_pangu
			sed -i "/$tmpvar 0 0 0644/d" system_fs_config_pangu
			unset tmpvar
		fi
	done
	cat system_file_contexts_pangu>>tmp/config/system_file_contexts
	cat system_fs_config_pangu>>tmp/config/system_fs_config
fi