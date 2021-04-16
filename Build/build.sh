#!/bin/sh

#打印执行的命令，只支持单参 
function echoCommand()
{
    echo "[******************* Start excuting command:$1]"
    $1
    echo "[******************* End excuting command...] \r\n"
}

#打印xcode、编译环境信息
function printXcodeInfo()
{
    xcode-select --version
    xcode-select --print-path
    security find-identity -v -p codesigning

    echo "Python version:"
    python --version

    # echo "Pod version:"
    # pod --version

    # echo "Remove Cache"
    # rm -rf ~/Library/Developer/Xcode/DerivedData/

	# echo "Set PBXNumberOfParallelBuildSubtasks 8"
	# defaults write com.apple.Xcode PBXNumberOfParallelBuildSubtasks 8
	# defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
}

#打印授权文件hash及名称
function printProvisionFiles()
{
    for file in `ls ~/Library/MobileDevice/Provisioning\ Profiles/`; do
    	echo "$(/usr/bin/security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/$file)" > "temp_plist.plist"
        echo "$file, ExpirationDate: `/usr/libexec/PlistBuddy -c "Print ExpirationDate" temp_plist.plist`, Name: `/usr/libexec/PlistBuddy -c "Print Name" temp_plist.plist`"
        #datetime=`/usr/libexec/PlistBuddy -c "Print ExpirationDate" temp_plist.plist`
        rm -rf temp_plist.plist
    done
}

# Generate entitlements
# 通过Profile文件生成签名用的entitlements.plist文件
#参数1：Profile文件，保存至ENTITLEMENTS_PLIST中
#返回值：plist文件路径
function generateEntitlementPlistFile()
{
	if [[ -z $1 ]]; then
		echo "Error: No profiles input..."
	fi

	provisionvalue=`cat "${1}"`
	parseEntitlement=${provisionvalue#*<key>Entitlements</key>}
	entitlementFromMPP=${parseEntitlement%%</dict>*}
	entitlementHeader1='<?xml version="1.0" encoding="UTF-8"?>'
	entitlementHeader2='<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
	entitlementHeader3='<plist version="1.0">'
	fullEntitlement=$entitlementHeader1$entitlementHeader2$entitlementHeader3"${entitlementFromMPP}</dict></plist>"
	echo "${fullEntitlement}" > "$(pwd)/entitlements.plist"

	#echo "------------ Entitlements file used --------------"
	#echo "${fullEntitlement}"
	#echo "--------------------------------------------------"

	echo "$(pwd)/entitlements.plist"
}

#对可执行文件进行签名
#参数1：授权文件路径
#参数2：证书KeychainId
#参数3：可执行文件路径
function resignFile()
{
	echo "Resign File: $1, $2, $3"
	entitlementsPlist=`generateEntitlementPlistFile $1`

	#去除旧的签名
	echo "Remove _CodeSignature..."
	rm -rf "$3/_CodeSignature"

	#拷贝描述文件
	echo "Copy provisioning file to ... $3/embedded.mobileprovision"
	cp -rf "$1" "$3/embedded.mobileprovision"

	#目录下有Frameworks文件夹，则需要对所有动态库进行重签名
	if [ -d "$3/Frameworks" ];then
		`codesign -v -f -s $2 $3/Frameworks/*`
	fi

	#对可执行文件进行签名
	`codesign -v -f -s $2 --entitlements ${entitlementsPlist} $3`
}

#检查文件路径是否存在，如果不存在，直接结束
#参数1：文件路径
function checkFile() {
	if [[ -z $1 ]]; then
		echo "Check file with nothing..."
	fi

	if [[ ! -f $1 ]]; then
		echo "[******************** Checking file failed: $1, now ending... ********************] \r\n \r\n"
		exit
	fi
}

#从目录中查找ipa文件
#参数1：文件路径
function findIPAFileInFolder() {
	for file in `find $1 name "*.ipa"`
	do
    	echo "Find file: ${file}"
	done
}

# 打印Xcode、证书、授权文件相关信息
echoCommand "printXcodeInfo"
echoCommand "printProvisionFiles"

# 工程路径、打包文件名相关的配置
echo "[******************** Set Project Parameters ********************]"
#打包脚本所在路径
BUILD_SCRIPT_PATH=`pwd`
echo "BUILD_SCRIPT_PATH: $BUILD_SCRIPT_PATH"

#打包的workspace文件的路径
WORKSPACE_FILE_PATH=../Project/Easy4ip/LeChangeOverseas.xcworkspace
echo "WORKSPACE_FILE_PATH: ${WORKSPACE_FILE_PATH}"

#target名称
SCHEME_NAME=LeChangeOverseas
echo "SCHEME_NAME: ${SCHEME_NAME}"

#项目plist文件
PLIST_FILE_PATH=../Project/Easy4ip/Easy4ip/Other/Info.plist
echo "PLIST_FILE_PATH: ${PLIST_FILE_PATH}"

#SVN路径对应的文件夹名称，Jenkins打PROJECT_NAME包时需要对应，如iEasy4ip、iLeChange
PROJECT_NAME=iEasy4ip
echo "PROJECT_NAME: ${PROJECT_NAME}"

#IPA对应的程序名称
IPA_APP_NAME=ImouOversea-IOS-Phone-Device_MultiLang
echo "IPA_APP_NAME: ${IPA_APP_NAME}"

echo "[******************** Set Project Parameters End ********************] \r\n \r\n"


echo "[******************** Start Run OEM ********************] \r\n \r\n"

WorkspaceName='overseaEasy4ip'
bundleID='com.dahuaoversea.easy4ip'
OEM_Enable=0

PROJECT_FILE_PATH=../Project/Easy4ip/LeChangeOverseas.xcodeproj/project.pbxproj
DISTRIBUTION_CER_SHA1=''

# 识别是否为一键OEM,判断是否传入了一个参数
if [ -n "$1" ] && [ ${1} != 'ALL' ] && [ ${1} != 'all' ] ; then

    #移除证书文件夹
    echoCommand "rm -rf ./provisionfile"
    #延时2秒，确保删除操作在svn之前，保证svn拉取到文件
    sleep 2

    #移动.svn标记文件
    rm -rf ./certification/.svn
    sleep 2

    mv .svn ./certification
    sleep 2

    #拉取资源SVN
    echoCommand "svn co ${1} ./"
    #测试资源SVN地址:http://10.6.5.2/svn/MobileMonitor/MobileDirectMonitor/iEasy4ip/Branches/CustomBranches/C_2019.05.08_iEasy4ip_RQP0000000_MySlominsVideo_Base3.00.000_V3.20.000/Build/testOEM

    #移除资源分支的.svn
    rm -rf .svn
    sleep 2

    #还原代码分支的svn,避免上传脚本无法获取svn信息
    mv ./certification/.svn ./

    #移动工程分支的脚本来使用
    mv ../ReplaceResources/replace.sh ./
    mv ../ReplaceResources/replace_images.sh ./
    sleep 2

    #验证文件
    echoCommand "checkFile setConfig.sh"
    echoCommand "checkFile replace.sh"
    echoCommand "checkFile replace_images.sh"

    #执行OEM配置
    echo "[******************** Setting Config.Please Wait.. ********************] \r\n \r\n"
    echoCommand "./setConfig.sh $1"

    #执行换图
    echo "[******************** Replace Image.Please Wait.. ********************] \r\n \r\n"
    echoCommand "./replace.sh"

    resultValue=$?
    echo $revalue
    if [[ "${revalue}" == 400 ]] ; then
        echo "[******************** SetConfig Error ********************] \r\n \r\n"
        exit
    else
        ##定制人员注意，包名和大图推送的包名需要统一，证书名需要与项目名统一

        #修改全局的变量
        OEM_Enable=1
        WorkspaceName=`./readExcel "oem-config" "app config" "app name"`
        bundleID=`./readExcel "oem-config" "app config" "bundle id"`

        #替换pbxproj文件中的发布证书名字，替换团队ID
        TeamID=`./readExcel "oem-config" "app config" "team id"`
        DistributionCerName=`./readExcel "oem-config" "app config" "distribution certification name"`
        sed -i "" "s/iPhone Distribution: ZHEJIANG DAHUA TECHNOLOGY CO.,LTD. (9QZ8T7G56W)/${DistributionCerName}/g" $PROJECT_FILE_PATH
        sed -i "" "s/9QZ8T7G56W/${TeamID}/g" $PROJECT_FILE_PATH

        #打包后IPA对应的程序名称
        IPA_APP_NAME=${WorkspaceName}"-IOS-Phone-Device_MultiLang"
        echo "IPA_APP_NAME: ${IPA_APP_NAME}"

        #读取表格中证书的SHA-1值
        DISTRIBUTION_CER_SHA1=`./readExcel "oem-config" "app config" "distribution certification SHA-1"`
    fi
fi

# 打印参数
echo "parameter1: $1"
echo "parameter2: $2"
echo "OEM: $OEM_Enable"
echo "bundleID: $bundleID"
echo "WorkspaceName: $WorkspaceName"

echo "[******************** Run OEM End ********************] \r\n \r\n"


# 证书、BundleId、授权文件相关配置
echo "[******************** Set Certificate and Provision Parameters ********************]"
#AppStore证书名称，在导出AppStore版本需要
PRODUCT_BUNDLE_IDENTIFIER=${bundleID}
APP_STORE_PROFILE_NAME=overseaEasy4ip_appstore_181211
APP_STORE_PROFILE_FILE="`pwd`/provisionfile/appstore/overseaEasy4ip_appstore_181211.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    APP_STORE_PROFILE_NAME='golf_appstore_provisioning_profile'
    APP_STORE_PROFILE_FILE="`pwd`/provisionfile/appstore/golf_appstore_provisioning_profile.mobileprovision"
    sed -i "" "s/overseaEasy4ip_appstore_181211/golf_appstore_provisioning_profile/g" $PROJECT_FILE_PATH
fi
echoCommand "checkFile ${APP_STORE_PROFILE_FILE}"

#发布版证书签名及证书路径，导出AdHoc版本需要
DISTRIBUTION_KEYCHAI_ID="9D533974D4BFAE92FD10859286E9E631165DE6D7"
DISTRIBUTION_PROFILE_FILE="`pwd`/provisionfile/adhoc/overseaEasy4ipDis.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    DISTRIBUTION_KEYCHAI_ID=${DISTRIBUTION_CER_SHA1}
    DISTRIBUTION_PROFILE_FILE="`pwd`/provisionfile/adhoc/golf_adhoc_provisioning_profile.mobileprovision"
    echo "${DISTRIBUTION_KEYCHAI_ID}"
fi
echoCommand "checkFile ${DISTRIBUTION_PROFILE_FILE}"

#导出IPA选用的方法: 'app-store'、'enterprise'、'ad-hoc'
# EXPORT_METHOD='enterprise'
EXPORT_METHOD='app-store'
echo "EXPORT_METHOD: ${EXPORT_METHOD}"

#WATCH相关，如果不需要将此值置空：ad-hoc版本不需要设置
WATCH_BUNDLE_IDENTIFIER='com.dahuaoversea.easy4ip.watchkitapp'
APP_STORE_WATCH_PROFILE_NAME=Easy4ipWatchKitApp_appstore
APP_STORE_WATCH_PROFILE_FILE="`pwd`/provisionfile/appstore/Easy4ipWatchKitApp_appstore.mobileprovision"
if [ $OEM_Enable == 0 ] ; then
    echoCommand "checkFile ${APP_STORE_WATCH_PROFILE_FILE}"
elif [ $OEM_Enable == 1 ] ; then
    unset WATCH_BUNDLE_IDENTIFIER
fi


#WATCH相关，如果不需要将此值置空：ad-hoc版本不需要设置
WATCHEXTENSION_BUNDLE_IDENTIFIER='com.dahuaoversea.easy4ip.watchkitapp.watchkitextension'
APP_STORE_WATCHEXTENSION_PROFILE_NAME=Easy4ipWatchkitExtension_appstore
APP_STORE_WATCHEXTENSION_PROFILE_FILE="`pwd`/provisionfile/appstore/Easy4ipWatchkitExtension_appstore.mobileprovision"
if [ $OEM_Enable == 0 ] ; then
    echoCommand "checkFile ${APP_STORE_WATCHEXTENSION_PROFILE_FILE}"
fi


#NotificationService相关，如果不需要将此值置空
MEDIA_SERVICE_BUNDLE_IDENTIFIER=$bundleID".MediaNotificationService"
APP_STORE_MEDIA_SERVICE_PROFILE_NAME=MediaNotificationService_appstore
APP_STORE_MEDIA_SERVICE_PROFILE_FILE="`pwd`/provisionfile/appstore/MediaNotificationService_appstore.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    APP_STORE_MEDIA_SERVICE_PROFILE_NAME='golf_service_appstore_provisioning_profile'
    APP_STORE_MEDIA_SERVICE_PROFILE_FILE="`pwd`/provisionfile/appstore/golf_service_appstore_provisioning_profile.mobileprovision"
    sed -i "" "s/MediaNotificationService_appstore/golf_service_appstore_provisioning_profile/g" $PROJECT_FILE_PATH
fi
echoCommand "checkFile ${APP_STORE_MEDIA_SERVICE_PROFILE_FILE}"

AD_HOC_MEDIA_SERVICE_PROFILE_FILE="`pwd`/provisionfile/adhoc/Easy4ipNotificationServiceExtensionDis.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    AD_HOC_MEDIA_SERVICE_PROFILE_FILE="`pwd`/provisionfile/adhoc/golf_service_adhoc_provisioning_profile.mobileprovision"
fi
echoCommand "checkFile ${AD_HOC_MEDIA_SERVICE_PROFILE_FILE}"

#NotificationContent相关，如果不需要将此值置空
MEDIA_CONTENT_BUNDLE_IDENTIFIER=$bundleID".MediaNotificationContent"
APP_STORE_MEDIA_CONTENT_PROFILE_NAME=MediaNotificationContent_appstore
APP_STORE_MEDIA_CONTENT_PROFILE_FILE="`pwd`/provisionfile/appstore/MediaNotificationContent_appstore.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    APP_STORE_MEDIA_CONTENT_PROFILE_NAME='golf_content_appstore_provisioning_profile'
    APP_STORE_MEDIA_CONTENT_PROFILE_FILE="`pwd`/provisionfile/appstore/golf_content_appstore_provisioning_profile.mobileprovision"
    sed -i "" "s/MediaNotificationContent_appstore/golf_content_appstore_provisioning_profile/g" $PROJECT_FILE_PATH
fi
echoCommand "checkFile ${APP_STORE_MEDIA_CONTENT_PROFILE_FILE}"

AD_HOC_MEDIA_CONTENT_PROFILE_FILE="`pwd`/provisionfile/adhoc/Easy4ipNotificationContentExtensionDis.mobileprovision"
if [ $OEM_Enable == 1 ] ; then
    AD_HOC_MEDIA_CONTENT_PROFILE_FILE="`pwd`/provisionfile/adhoc/golf_content_adhoc_provisioning_profile.mobileprovision"
fi
echoCommand "checkFile ${AD_HOC_MEDIA_CONTENT_PROFILE_FILE}"


#企业版证书签名, 如果不需要将此值置空
ENTERPRISE_KEYCHAIN_ID='8D2091ED1AE8E4D89A2BA76D6194087A5F7F3292'
ENTERPRISE_BUNDEL_ID='com.dahuaoversea.easy4ip2'
ENTERPRISE_PROFILE_FILE="`pwd`/provisionfile/enterprise/dahuaoverseaEasy4ipINHOUSE.mobileprovision"
echoCommand "checkFile ${ENTERPRISE_PROFILE_FILE}"

#NotificationService相关，如果不需要将此值置空
ENTERPRISE_MEDIA_SERVICE_BUNDLE_IDENTIFIER='com.dahuaoversea.easy4ip2.Easy4ipNotificationService'
ENTERPRISE_MEDIA_SERVICE_PROFILE_FILE="`pwd`/provisionfile/enterprise/Easy4ipNotificationService.mobileprovision"
echoCommand "checkFile ${ENTERPRISE_MEDIA_SERVICE_PROFILE_FILE}"

#NotificationContent相关，如果不需要将此值置空
ENTERPRISE_MEDIA_CONTENT_BUNDLE_IDENTIFIER=' com.dahuaoversea.easy4ip2.Easy4ipNotificationContent'
ENTERPRISE_MEDIA_CONTENT_PROFILE_FILE="`pwd`/provisionfile/enterprise/Easy4ipNotificationContent.mobileprovision"
echoCommand "checkFile ${ENTERPRISE_MEDIA_CONTENT_PROFILE_FILE}"

#一键oem不打企业包
if [ $OEM_Enable == 1 ] ; then
    unset ENTERPRISE_KEYCHAIN_ID
fi

echo "[******************** Set Certificate and Provision Parameters End ********************] \r\n \r\n"


echo "[******************** Auto Parameters ********************]"

#获取BundleVersion: 结项时，版本号需要固定, IPA_BUNDLE_VERSION
BUNDLE_VERSION=$(python `pwd`/getVersion.py ${PLIST_FILE_PATH})
IPA_BUNDLE_VERSION=${BUNDLE_VERSION}
IPA_BUNDLE_VERSION='3.601.0000001.0' #$BUNDLE_VERSION
echo "BUNDLE_VERSION: $BUNDLE_VERSION"

#编译日期
BUILD_DATE=`date "+%Y%m%d"`
echo "BUILD_DATE: $BUILD_DATE"

#计算带日期的版本号
BUNDLE_VERSION_WITH_DATE=${BUNDLE_VERSION}.$(date +%m%d)
echo "BUNDLE_VERSION_WITH_DATE:"${BUNDLE_VERSION_WITH_DATE}

#获取工程所在路径
SRCROOT=${WORKSPACE_FILE_PATH%/*}
echo "SRCROOT:"${SRCROOT}

WORKSPACE_FILE_NANE=${WORKSPACE_FILE_PATH##*/}
echo "WORKSPACE_FILE_NANE:"${WORKSPACE_FILE_NANE}

WORKSPACE_NAME=${WORKSPACE_FILE_NANE%.*}
echo "WORKSPACE_NAME:"${WORKSPACE_NAME}

echo "Enter Project Dir"
cd ${SRCROOT}

#记录绝对路径：工程路径
PROJECT_DIR=$(pwd)
echo "PROJECT_DIR:"${PROJECT_DIR}

echo "[********************  Auto Parameters End ********************] \r\n \r\n"


echo "[******************** Step1. Start Packaging $(date +%Y-%m-%d\ %H:%M:%S) ********************]"
ARCHIVE_NAME=archivePath
echo "ARCHIVE_NAME:"${ARCHIVE_NAME}
ARCHIVE_PATH=${PROJECT_DIR}/${ARCHIVE_NAME}.xcarchive
echo "ARCHIVE_PATH:"${ARCHIVE_PATH}
xcodebuild archive -workspace ${WORKSPACE_FILE_NANE} -configuration clean -scheme ${SCHEME_NAME} -archivePath ${ARCHIVE_PATH}
echo "[******************** End Packaging $(date +%Y-%m-%d\ %H:%M:%S) ********************] \r\n \r\n"


echo "[******************** Start Checking Archive ********************]"
echo "Checking archive at path:${ARCHIVE_PATH}"
#判断导出的archive是否存在，不存在直接结束
if [ ! -d "${ARCHIVE_PATH}" ];then
echo "[******************** Building failed, now ending... ********************] \r\n \r\n"
exit
fi
echo "[******************** End Checking Archive ********************] \r\n \r\n"


#=============使用AppStore的授权文件导出IPA包=================
echo "[******************** Step2. Export ipa ... ********************]"
ENTITLEMENTS_PLIST=`generateEntitlementPlistFile "${APP_STORE_PROFILE_FILE}"`
DEVELOPMENT_TEAM=$(/usr/libexec/PlistBuddy -c "print :com.apple.developer.team-identifier" "$ENTITLEMENTS_PLIST")
echo "DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM"

applestore_plist_store=$'<?xml version="1.0" encoding="UTF-8"?>\n'
applestore_plist_store=${applestore_plist_store}$'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
applestore_plist_store=${applestore_plist_store}$'<plist version="1.0">\n'
applestore_plist_store=${applestore_plist_store}$'<dict>\n'
applestore_plist_store=${applestore_plist_store}$'	<key>uploadSymbols</key>\n'
applestore_plist_store=${applestore_plist_store}$'	<true/>\n'
applestore_plist_store=${applestore_plist_store}$'	<key>method</key>\n'
applestore_plist_store=${applestore_plist_store}$'	<string>'${EXPORT_METHOD}'</string>\n'
applestore_plist_store=${applestore_plist_store}$'	<key>teamID</key>\n'
applestore_plist_store=${applestore_plist_store}$'	<string>'${DEVELOPMENT_TEAM}$'</string>\n'
applestore_plist_store=${applestore_plist_store}$'	<key>provisioningProfiles</key>\n'
applestore_plist_store=${applestore_plist_store}$'	<dict>\n'
applestore_plist_store=${applestore_plist_store}$'		<key>'${PRODUCT_BUNDLE_IDENTIFIER}$'</key>\n'
applestore_plist_store=${applestore_plist_store}$'		<string>'${APP_STORE_PROFILE_NAME}$'</string>\n'

#设置Watch相关
if [[ ! -z ${WATCH_BUNDLE_IDENTIFIER} ]]; then
	applestore_plist_store=${applestore_plist_store}$'		<key>'${WATCH_BUNDLE_IDENTIFIER}$'</key>\n'
	applestore_plist_store=${applestore_plist_store}$'		<string>'${APP_STORE_WATCH_PROFILE_NAME}$'</string>\n'
	applestore_plist_store=${applestore_plist_store}$'		<key>'${WATCHEXTENSION_BUNDLE_IDENTIFIER}$'</key>\n'
	applestore_plist_store=${applestore_plist_store}$'		<string>'${APP_STORE_WATCHEXTENSION_PROFILE_NAME}$'</string>\n'
fi

#设置NotificationService
if [[ ! -z ${MEDIA_SERVICE_BUNDLE_IDENTIFIER} ]]; then
	applestore_plist_store=${applestore_plist_store}$'		<key>'${MEDIA_SERVICE_BUNDLE_IDENTIFIER}$'</key>\n'
	applestore_plist_store=${applestore_plist_store}$'		<string>'${APP_STORE_MEDIA_SERVICE_PROFILE_NAME}$'</string>\n'
fi
#

#设置NotificationContent
if [[ ! -z ${MEDIA_CONTENT_BUNDLE_IDENTIFIER} ]]; then
	applestore_plist_store=${applestore_plist_store}$'		<key>'${MEDIA_CONTENT_BUNDLE_IDENTIFIER}$'</key>\n'
	applestore_plist_store=${applestore_plist_store}$'		<string>'${APP_STORE_MEDIA_CONTENT_PROFILE_NAME}$'</string>\n'
fi
#

applestore_plist_store=${applestore_plist_store}$'	</dict>\n'
applestore_plist_store=${applestore_plist_store}$'</dict>\n'
applestore_plist_store=${applestore_plist_store}$'</plist>'

APP_STORE_PLIST_FILE=applestore_temp.plist
echo "${applestore_plist_store}" > "${APP_STORE_PLIST_FILE}"
echo "Export ipa with entitlements: ${APP_STORE_PLIST_FILE}"

xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -exportOptionsPlist ${APP_STORE_PLIST_FILE} -exportPath ipa-build

EXPORT_DIR=${PROJECT_DIR}/ipa-build
echo "EXPORT_DIR:"${EXPORT_DIR}
mkdir ${EXPORT_DIR}

#找到导出后的ipa文件路径，有些设置不正确时，导致的IPA并不是SCHEME_NAME.ipa，直接从archivePath.xcarchive读取ipa名称
IPANAME=$(/usr/libexec/PlistBuddy -c "print :Name" "${ARCHIVE_PATH}/Info.plist")
echo "Find ipa name: $IPANAME"
EXPORT_IPA_FILE_PATH=${EXPORT_DIR}/${IPANAME}.ipa

echo "EXPORT_IPA_FILE_PATH:"${EXPORT_IPA_FILE_PATH}


#检验IPA是否导出成功
checkFile ${EXPORT_IPA_FILE_PATH}

echo "[******************** End Export ipa... ********************] \r\n \r\n"


#=============IPA包解压缩到tmp文件夹中=================
echo "[******************** Step3. Unzip ipa ... ********************]"

TEMP="${PROJECT_DIR}/temp"

if [ ! -d $TEMP ]
then
   mkdir -p $TEMP
fi
echo "TEMP:"$TEMP

echo "start unzip ipa file, path: $EXPORT_IPA_FILE_PATH"
unzip "$EXPORT_IPA_FILE_PATH" -d $TEMP

#导出后  删除原来的ipa
rm -rf $EXPORT_IPA_FILE_PATH

APP_NAME=$(ls $TEMP/Payload)
echo "AppName: $APP_NAME"

TEMP_UNZIP_INFOPLIST_FILE_PATH="${TEMP}/Payload/${APP_NAME}/Info.plist"
echo "TEMP_UNZIP_INFOPLIST_FILE_PATH: ${TEMP_UNZIP_INFOPLIST_FILE_PATH}"
echo "[******************** End Unzip ipa... ********************] \r\n \r\n"




echo "[******************** Step4-1. Resign ipa for app-store... ********************]"
#写入不带日期的版本号
`/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BUNDLE_VERSION" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#带appstore版本不开启沙盒共享
`/usr/libexec/PlistBuddy -c "Set :UIFileSharingEnabled 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#非企业版
`/usr/libexec/PlistBuddy -c "Set :LCEnterpriseVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#是否为发布版本
`/usr/libexec/PlistBuddy -c "Set :LCDistributionVersion 1" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#对App进行签名设置
REGISN_PROFILE_FILE=$APP_STORE_PROFILE_FILE
REGISN_KEYCHAI_ID=$DISTRIBUTION_KEYCHAI_ID
REGISN_OUT_IPA=$EXPORT_DIR/General_${IPA_APP_NAME}_AppStore-Basic_IS_V${IPA_BUNDLE_VERSION}.R.${BUILD_DATE}.ipa

#一键OEM移除全部的watch功能
if [ $OEM_Enable == 1 ] ; then
    rm -rf $TEMP/Payload/$APP_NAME/Watch
fi

resignFile "$REGISN_PROFILE_FILE" "$REGISN_KEYCHAI_ID" "${TEMP}/Payload/${APP_NAME}"

#生成ipa文件
echo "zip file generate new ipa file"
cd $TEMP

#上传appstore的文件需要对应的SwiftSupport 和 Symbols
echo `zip -qr resign.ipa BCSymbolMaps Symbols SwiftSupport Payload WatchKitSupport2`

mv resign.ipa ${REGISN_OUT_IPA}

echo "[******************** End Resign ipa for app-store... ********************] \r\n \r\n"



# echo "[******************** Step4-2. Resign ipa for ad-hoc... ********************]"
# #写入不带日期的版本号
# `/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BUNDLE_VERSION" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

# #带appstore版本不开启沙盒共享
# `/usr/libexec/PlistBuddy -c "Set :UIFileSharingEnabled 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

# #非企业版
# `/usr/libexec/PlistBuddy -c "Set :LCEnterpriseVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

# #是否为发布版本
# `/usr/libexec/PlistBuddy -c "Set :LCDistributionVersion 1" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

# #对App进行签名设置
# REGISN_PROFILE_FILE=$DISTRIBUTION_PROFILE_FILE
# REGISN_KEYCHAI_ID=$DISTRIBUTION_KEYCHAI_ID
# REGISN_OUT_IPA=$EXPORT_DIR/General_${IPA_APP_NAME}_AdHoc-Basic_IS_V${IPA_BUNDLE_VERSION}.R.${BUILD_DATE}.ipa

# # Watch签名
# if [[ -d ${TEMP}/Payload/${APP_NAME}/Watch ]]; then
# 	REGISN_PROFILE_WATCH=${BUILD_SCRIPT_PATH}/provisionfile/adhoc/Easy4ip_appWatchKitDis.mobileprovision
# 	REGISN_PROFILE_WATCH_EXTENSION=${BUILD_SCRIPT_PATH}/provisionfile/adhoc/Easy4ip_appWatchExtensionDis.mobileprovision

# 	resignFile "${REGISN_PROFILE_WATCH_EXTENSION}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/Watch/Watch.app/PlugIns/Watch Extension.appex"
# 	resignFile "${REGISN_PROFILE_WATCH}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/Watch/Watch.app"
# fi

# # NotificationService签名 
# if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex ]]; then
# 	REGISN_PROFILE_NOTIFICATION_SERVICE=${AD_HOC_MEDIA_SERVICE_PROFILE_FILE}
# 	resignFile "${REGISN_PROFILE_NOTIFICATION_SERVICE}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex"
# fi

# # NotificationContent签名 
# if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex ]]; then
# 	REGISN_PROFILE_NOTIFICATION_CONTENT=${AD_HOC_MEDIA_CONTENT_PROFILE_FILE}
# 	resignFile "${REGISN_PROFILE_NOTIFICATION_CONTENT}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex"
# fi

# resignFile "$REGISN_PROFILE_FILE" "$REGISN_KEYCHAI_ID" "${TEMP}/Payload/${APP_NAME}"

# #生成ipa文件
# echo "zip file generate new ipa file"
# cd $TEMP

# echo `zip -qr resign.ipa Payload`
# mv resign.ipa ${REGISN_OUT_IPA}

# echo "[******************** End Resign ipa for ad-hoc... ********************] \r\n \r\n"


 
echo "[******************** Step4-3. Resign ipa for ad-hoc with ip... ********************]"
#写入带日期的版本号
`/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BUNDLE_VERSION_WITH_DATE" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#开启沙盒文件共享
`/usr/libexec/PlistBuddy -c "Set :UIFileSharingEnabled 1" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#非企业版
`/usr/libexec/PlistBuddy -c "Set :LCEnterpriseVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

#是否为发布版本
`/usr/libexec/PlistBuddy -c "Set :LCDistributionVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`


# 对App进行签名设置
REGISN_PROFILE_FILE=$DISTRIBUTION_PROFILE_FILE
REGISN_KEYCHAI_ID=$DISTRIBUTION_KEYCHAI_ID
REGISN_OUT_IPA=$EXPORT_DIR/General_${IPA_APP_NAME}_AdHocIP-Basic_IS_V${IPA_BUNDLE_VERSION}.R.${BUILD_DATE}.ipa

#AdHocIP版本去除watch相关
rm -rf $TEMP/Payload/$APP_NAME/Watch

# NotificationService签名 
if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex ]]; then
	REGISN_PROFILE_NOTIFICATION_SERVICE=${AD_HOC_MEDIA_SERVICE_PROFILE_FILE}
	resignFile "${REGISN_PROFILE_NOTIFICATION_SERVICE}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex"
fi

# NotificationContent签名 
if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex ]]; then
	REGISN_PROFILE_NOTIFICATION_CONTENT=${AD_HOC_MEDIA_CONTENT_PROFILE_FILE}
	resignFile "${REGISN_PROFILE_NOTIFICATION_CONTENT}" "${REGISN_KEYCHAI_ID}" "$TEMP/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex"
fi

resignFile "$REGISN_PROFILE_FILE" "$REGISN_KEYCHAI_ID" "${TEMP}/Payload/${APP_NAME}"

#生成ipa文件
echo "zip file generate new ipa file"
cd $TEMP

echo `zip -qr resign.ipa Payload`
mv resign.ipa ${REGISN_OUT_IPA}

echo "[******************** End Resign ipa for ad-hoc with ip ... ********************] \r\n \r\n"


echo "[******************** Step4-4. Resign ipa for enterprise with ip... ********************]"
echo "EnterpriseKeyChainId: 此值为空，则不打企业版本！！！ ${ENTERPRISE_KEYCHAIN_ID}"

if [[ -z ${ENTERPRISE_KEYCHAIN_ID}  ]]; then
	echo "Warning!!! Enterprise keychina id is null, now ignore..."
else 
	echo "Start exporting enterprise...."

	#写入带日期的版本号
	`/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BUNDLE_VERSION_WITH_DATE" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#开启沙盒文件共享
	`/usr/libexec/PlistBuddy -c "Set :UIFileSharingEnabled 1" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#非企业版
	`/usr/libexec/PlistBuddy -c "Set :LCEnterpriseVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#是否为发布版本
	`/usr/libexec/PlistBuddy -c "Set :LCDistributionVersion 0" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#换bundleID
	`/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ENTERPRISE_BUNDEL_ID}" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#更换显示的名称，后面加-E
	BUNDLE_DISPLAY_NAME=$(/usr/libexec/PlistBuddy -c "print :CFBundleDisplayName" "$TEMP_UNZIP_INFOPLIST_FILE_PATH")
	`/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${BUNDLE_DISPLAY_NAME}-E" "$TEMP_UNZIP_INFOPLIST_FILE_PATH"`

	#企业版本去除watch相关
	rm -rf ${TEMP}/Payload/$APP_NAME/Watch

	#对App进行签名设置
	REGISN_PROFILE_FILE=$ENTERPRISE_PROFILE_FILE
	REGISN_KEYCHAI_ID=$ENTERPRISE_KEYCHAIN_ID
	REGISN_OUT_IPA=$EXPORT_DIR/General_${IPA_APP_NAME}_Inhouse-Basic_IS_V${IPA_BUNDLE_VERSION}.R.${BUILD_DATE}.ipa

	# NotificationService签名 
	if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex ]]; then
		#企业版本需要修改bundle identifier
		`/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ENTERPRISE_MEDIA_SERVICE_BUNDLE_IDENTIFIER}" "${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex/Info.plist"`
		REGISN_PROFILE_NOTIFICATION_SERVICE=${ENTERPRISE_MEDIA_SERVICE_PROFILE_FILE}
		resignFile "${REGISN_PROFILE_NOTIFICATION_SERVICE}" "${REGISN_KEYCHAI_ID}" "${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationService.appex"
	fi

	# NotificationContent签名 
	if [[ -d ${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex ]]; then
		#企业版本需要修改bundle identifier
		`/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ENTERPRISE_MEDIA_CONTENT_BUNDLE_IDENTIFIER}" "${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex/Info.plist"`
		REGISN_PROFILE_NOTIFICATION_CONTENT=${ENTERPRISE_MEDIA_CONTENT_PROFILE_FILE}
		resignFile "${REGISN_PROFILE_NOTIFICATION_CONTENT}" "${REGISN_KEYCHAI_ID}" "${TEMP}/Payload/${APP_NAME}/PlugIns/MediaNotificationContent.appex"
	fi

	resignFile "$REGISN_PROFILE_FILE" "$REGISN_KEYCHAI_ID" "${TEMP}/Payload/${APP_NAME}"

	#生成ipa文件
	echo "zip file generate new ipa file"
	cd $TEMP

	echo `zip -qr resign.ipa Payload`
	mv resign.ipa ${REGISN_OUT_IPA}
fi

echo "[******************** End Resign ipa for enterprise with ip ... ********************] \r\n \r\n"

#=============打包=================
echo "[******************** Step5. Zip dSYM... ********************]"

cd $EXPORT_DIR
mkdir -p Release-iphoneos
cp -rf $ARCHIVE_PATH/dSYMs/${SCHEME_NAME}.app.dSYM $EXPORT_DIR/Release-iphoneos/${SCHEME_NAME}.app.dSYM
tar czf ${PROJECT_NAME}.tar.gz Release-iphoneos *.ipa
mv ${PROJECT_NAME}.tar.gz ${BUILD_SCRIPT_PATH}/${PROJECT_NAME}.tar.gz

echo "[******************** Zip Successful... ********************] \r\n \r\n"



echo "[******************** Over. Clean resources... ********************]"

cd ${PROJECT_DIR}
echoCommand "rm -rf ${EXPORT_DIR}"
echoCommand "rm -rf ${TEMP}"
echoCommand "rm -rf ${ENTITLEMENTS_PLIST}"
echoCommand "rm -rf ${APP_STORE_PLIST_FILE}"
echoCommand "rm -rf entitlements.plist"
echoCommand "rm -rf applestore_temp.plist"
#echoCommand "rm -rf ${ARCHIVE_PATH}"

cd ${BUILD_SCRIPT_PATH}
echo "[******************** Clean Successful... ********************]"
