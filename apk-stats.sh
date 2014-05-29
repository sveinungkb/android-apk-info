#!/bin/sh

DEXDUMP=$ANDROID_HOME/build-tools/19.1.0/dexdump
DEX_FILE="classes.dex"
FORMAT_TERMINAL="%s\t%s\t%s\t%s\t%s\n"
TEAMCITY=0

die()
{
	echo "Processing failed: ${1}"
	exit 1
}

#apk classes methods dex-bytes apk-bytes
print_result_terminal()
{
	printf ${FORMAT_TERMINAL} $2 $3 $4 $5 $1
}

print_result_teamcity()
{
	printf "##teamcity[buildStatisticValue key='%s-%s' value='%s']\n" "classes" $1 $2
	printf "##teamcity[buildStatisticValue key='%s-%s' value='%s']\n" "methods" $1 $3
	printf "##teamcity[buildStatisticValue key='%s-%s' value='%s']\n" "dex-size" $1 $4
	printf "##teamcity[buildStatisticValue key='%s-%s' value='%s']\n" "apk-size" $1 $5
}

process_apk()
{
	rm -f $DEX_FILE
	unzip -q -j $1 $DEX_FILE -d . || die "Could not unzip ${1}, does file exists?"
	CLASS_COUNT=$($DEXDUMP $DEX_FILE | grep 'Class descriptor' | wc -l)
	METHOD_COUNT=$(cat $DEX_FILE | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d"')
	DEX_SIZE=$(stat -f%z $DEX_FILE)
	APK_SIZE=$(stat -f%z $1)
	print_result_terminal $1 $CLASS_COUNT $METHOD_COUNT $DEX_SIZE $APK_SIZE
	if [ $TEAMCITY == 1 ]; then
		print_result_teamcity $1 $CLASS_COUNT $METHOD_COUNT $DEX_SIZE $APK_SIZE
	fi
	rm -f $DEX_FILE
}

process_all_apks()
{
	for f in *.apk
	do
		process_apk $f
	done
}

if [[ ! -d $1 && $1 == "teamcity" ]]; then
	echo "Team City system messages enabled!"
	TEAMCITY=1
fi

echo "classes\tmethods\\tdex-bytes\tapk-bytes\tapk"
process_all_apks