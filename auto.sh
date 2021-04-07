#!/bin/sh

echo "$1"
if [ -n "$1" ] ; then
    echo "已包含singleid"
else
    echo "必须包含singleid"
    exit 1
fi

echo "修改工程配置"
ruby ./Vigame/configuration.rb
echo "修改 Success"

echo "生成Podfile"
ruby ./Vigame/createPodfile.rb $1

echo "检测版本结束"

pod install

echo "修改VigameLibrary.plist"
ruby ./Vigame/connectSQL.rb $1

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

