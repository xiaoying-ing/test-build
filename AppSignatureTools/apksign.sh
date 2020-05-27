#! /bin/bash
#变量申明
keystore='gylr.jks'
alias='androiddebugkey'
storepass='android'
tsa='http://tsa.starfieldtech.com'
signtool='SignatureTools_20181114.jar'
keypass='android'
sigalg='SHA1withRSA'

#初步校验
sh_path=${0}
if [ $# -eq 2 ] && [ $1 = "-d" ] && [[ $2 =~ ".apk" ]]
then
	method=0
	apk_path=${2}
	sign='-d-signed-'
elif [ $# -eq 1 ] && [[ $1 =~ ".apk" ]]
then
	method=1	
	apk_path=${1}
	sign='-signed-'
else
	echo "参数：-d 删除第三方原始的签名信息"
	echo "用法1：./apksign.sh  xx.apk"
	echo "用法2：./apksign.sh  -d  xx.apk"
	exit 0
fi

#校验apk是否存在
apk=$(basename $apk_path)
apk_path1=${apk_path%/*}
apk_path2=$(find $apk_path1 -name $apk)
if [ "$apk_path2" = "" ]
then
	echo "此apk不存在"
	exit 0
fi

#获取当前日期
var=$(date "+%Y%m%d")

#文件命名
apk_name=${apk%\.apk}
backup=$apk_name"_backup.apk"
signed=$apk_name$sign$var".apk"

#相关文件路径
tool_path=${sh_path%/*}
keystore_path=$tool_path"/other/"$keystore
backup_path=$tool_path"/"$backup
signtool_path=$tool_path"/other/"$signtool
output_path=$tool_path"/signedapks/"$signed

#签名
if [ $method = 0 ]
then
	#备份apk
	cp -avx $apk_path $backup_path
	#删除备份apk的签名
	zip -d $backup_path META-INF/*
	parameters="
		-verbose
		-keystore $keystore_path
		-digestalg SHA1
		-sigalg $sigalg
		-storepass $storepass
		-tsa $tsa
		-sigfile TESTTEAM
		-signedjar $output_path $backup_path $alias
		"
	jarsigner $parameters
	#删除备份
	rm -rf $backup_path
elif [ $method = 1 ]
then
	parameters="
		-jar $signtool_path sign 
		--keytype jks 
		--apk $apk_path 
		--out $output_path 
		--keystore $keystore_path
		--alias $alias 
		--keypass $keypass
		--storepass $storepass
		--sigAlg $sigalg
		"
	java $parameters
else
	echo "error"
	exit 0
fi

#校验签名是否成功
output_path=$(find $tool_path"/signedapks/" -name $signed)
if [ "$output_path" = "" ]
then
	echo "签名失败"
	exit 0
else
	echo "签名成功,路径:"$output_path
fi

exit 0
