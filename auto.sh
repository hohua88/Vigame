#!/bin/sh

echo "$1"
if [ -n "$1" ] ; then
    echo "已包含singleid"
else
    echo "必须包含singleid"
    exit 1
fi
function IconContents(){
cat <<EOF >./AppIcon.appiconset/Contents.json

    {
          "images" : [
            {
              "filename" : "icon-20@2x.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-20@3x.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-29.png",
              "idiom" : "iphone",
              "scale" : "1x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-29@2x.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-29@3x.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-40@2x.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-40@3x.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-60@2x.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "60x60"
            },
            {
              "filename" : "icon-60@3x.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "60x60"
            },
            {
              "filename" : "icon-20-ipad.png",
              "idiom" : "ipad",
              "scale" : "1x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-20@2x-ipad.png",
              "idiom" : "ipad",
              "scale" : "2x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-29-ipad.png",
              "idiom" : "ipad",
              "scale" : "1x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-29@2x-ipad.png",
              "idiom" : "ipad",
              "scale" : "2x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-40-ipad.png",
              "idiom" : "ipad",
              "scale" : "1x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-40@2x-ipad.png",
              "idiom" : "ipad",
              "scale" : "2x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-76-ipad.png",
              "idiom" : "ipad",
              "scale" : "1x",
              "size" : "76x76"
            },
            {
              "filename" : "icon-76@2x-ipad.png",
              "idiom" : "ipad",
              "scale" : "2x",
              "size" : "76x76"
            },
            {
              "filename" : "icon-83.5@2x-ipad.png",
              "idiom" : "ipad",
              "scale" : "2x",
              "size" : "83.5x83.5"
            },
            {
              "filename" : "icon-1024.png",
              "idiom" : "ios-marketing",
              "scale" : "1x",
              "size" : "1024x1024"
            }
          ],
        "info" : {
            "author" : "xcode",
            "version" : 1
        }
    }
EOF
}
function setIconImage(){
    echo "20pt图标生成······"
    sips -z 20 20 "$1" --out ./AppIcon.appiconset/icon-20-ipad.png
    sips -z 40 40 "$1" --out ./AppIcon.appiconset/icon-20@2x-ipad.png
    sips -z 40 40 "$1" --out ./AppIcon.appiconset/icon-20@2x.png
    sips -z 60 60 "$1" --out ./AppIcon.appiconset/icon-20@3x.png
    echo "29pt图标生成······"
    sips -z 29 29 "$1" --out ./AppIcon.appiconset/icon-29-ipad.png
    sips -z 29 29 "$1" --out ./AppIcon.appiconset/icon-29.png
    sips -z 58 58 "$1" --out ./AppIcon.appiconset/icon-29@2x-ipad.png
    sips -z 58 58 "$1" --out ./AppIcon.appiconset/icon-29@2x.png
    sips -z 87 87 "$1" --out ./AppIcon.appiconset/icon-29@3x.png
    echo "40pt图标生成······"
    sips -z 40 40 "$1" --out ./AppIcon.appiconset/icon-40-ipad.png
    sips -z 80 80 "$1" --out ./AppIcon.appiconset/icon-40@2x.png
    sips -z 80 80 "$1" --out ./AppIcon.appiconset/icon-40@2x-ipad.png
    sips -z 120 120 "$1" --out ./AppIcon.appiconset/icon-40@3x.png
    echo "60pt图标生成······"
    sips -z 120 120 "$1" --out ./AppIcon.appiconset/icon-60@2x.png
    sips -z 180 180 "$1" --out ./AppIcon.appiconset/icon-60@3x.png
    echo "76pt图标生成······"
    sips -z 76 76 "$1" --out ./AppIcon.appiconset/icon-76-ipad.png
    sips -z 152 152 "$1" --out ./AppIcon.appiconset/icon-76@2x-ipad.png

    echo "83.5pt图标生成······"
    sips -z 167 167 "$1" --out ./AppIcon.appiconset/icon-83.5@2x-ipad.png

    echo "1024pt图标生成······"
    sips -z 1024 1024 "$1" --out ./AppIcon.appiconset/icon-1024.png
}

function createIcon(){
       if [ -n "$1" ] ; then
       iconfileName="$1"
    else
        echo "使用默认icon"
        iconfileName="$2"/icon.png
    fi
    mkdir AppIcon.appiconset
    IconContents
    setIconImage "$iconfileName"

    keyfile=Images.xcassets
    key_file=Assets.xcassets
    x=$(find "$2" -name $keyfile)
    if [ -n "$x" ]; then
         echo "生成icon的图片地址 == ${x} "
    else
         x=$(find "$2" -name $key_file)
         echo "生成icon的图片地址 == ${x} "
    fi
    rm -rf "$x/AppIcon.appiconset"
    rm -rf icon.png
    mv -f "$2/AppIcon.appiconset"  "$x"
}
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
if [ $3 -eq 1];then
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
path=$PWD
echo "修改VigameLibrary.plist"
ruby ./Vigame/connectSQL.rb $1 $2
#createIcon "" $path
echo "开始打包"

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
  rm -rf ./ipa
  xcodebuild clean -workspace "$appname.xcworkspace" -scheme "$appname" -configuration enterprise
  xcodebuild archive -workspace "$appname.xcworkspace" -scheme "$appname" -archivePath "$appname.xcarchive" -quiet
  xcodebuild -exportArchive -archivePath "$appname.xcarchive" -exportPath ipa -exportOptionsPlist "Vigame/ExportOptions.plist"
  fir publish "./ipa/Unity-iPhone.ipa" -T f093c9fb7d416121ce83634e37c6acb8
