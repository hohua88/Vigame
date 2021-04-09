#!/bin/sh

echo "$1"
if [ -n "$1" ] ; then
    echo "已包含singleid"
else
    echo "必须包含singleid"
    exit 1
fi
function modify_Exportplist(){
   
    security cms -D -i "$1" > new_provision.plist
    TeamIdentifier=$(/usr/libexec/PlistBuddy  -c 'Print :"TeamIdentifier:0"' new_provision.plist)
    mobileProName=$(/usr/libexec/PlistBuddy  -c 'Print :"Name"' new_provision.plist)
    applicationidentifier=$(/usr/libexec/PlistBuddy  -c 'Print :"Entitlements:application-identifier"' new_provision.plist)
    len=${#TeamIdentifier}
    identifier=${applicationidentifier:len+1}
    device=$(/usr/libexec/PlistBuddy  -c 'Print :"ProvisionedDevices:"' new_provision.plist)
    deviceNum=${#device}
    /usr/libexec/PlistBuddy -c 'Set :teamID '$TeamIdentifier'' "./Vigame/ExportOptions.plist"
    if [ $deviceNum  -eq 0 ];then
        /usr/libexec/PlistBuddy -c 'Set :method "app-store"' "./Vigame/ExportOptions.plist"
    else
        /usr/libexec/PlistBuddy -c 'Set :method "ad-hoc"' "./Vigame/ExportOptions.plist"
    fi
   
    /usr/libexec/PlistBuddy -c 'Add :provisioningProfiles:'$identifier' string '$mobileProName'' "./Vigame/ExportOptions.plist"
    
    echo "${TeamIdentifier}"
}
echo "修改工程配置"
if [ $3 -eq 1 ];then
    modify_Exportplist "./mobileprovision.mobileprovision"
    mpName=$(/usr/libexec/PlistBuddy -c "Print Name" /dev/stdin <<< $(/usr/bin/security cms -D -i ./mobileprovision.mobileprovision ))
    teamId=$(/usr/libexec/PlistBuddy -c "Print TeamIdentifier:0" /dev/stdin <<< $(/usr/bin/security cms -D -i ./mobileprovision.mobileprovision ))
    echo "证书信息  ${mpName} ${teamId} "
    ruby ./Vigame/configuration.rb "$mpName" "$teamId"
else
    ruby ./Vigame/configuration.rb 'guozhi_hoc' 'VDBUYJQ29S'
fi


echo "修改 Success"

echo "生成Podfile"
ruby ./Vigame/createPodfile.rb $1 $3

echo "检测版本结束"

pod install

echo "修改VigameLibrary.plist"
ruby ./Vigame/connectSQL.rb $1 $2

echo "开始打包"

path=$PWD
echo $path
for element in `ls "$path" | tr " " "\?"`
  do
      element=`tr "\?" " " <<<$element`
      dir_or_file="$path"/"$element"
      if [ -d "$dir_or_file" ];then
          var=$( find "$dir_or_file" -name '*.xcodeproj' )
          var1=${var##*/}
          if [ -n "$var1" ];then
              podStr="Pods"
             if [[ $var1 == *$podStr* ]];then
              echo "Pods.xcodeproj"
             else
              appname=${var1%.*}
             fi
          fi

      fi
  done
 echo "Targetname==== $appname "
  rm -rf "$appname.xcarchive"
  xcodebuild clean -workspace "$appname.xcworkspace" -scheme "$appname" -configuration enterprise
  xcodebuild archive -workspace "$appname.xcworkspace" -scheme "$appname" -archivePath "$appname.xcarchive" -quiet
  xcodebuild -exportArchive -archivePath "$appname.xcarchive" -exportPath ipa -exportOptionsPlist "Vigame/ExportOptions.plist"
  fir publish "./ipa/Unity-iPhone.ipa" -T f093c9fb7d416121ce83634e37c6acb8
