#!/bin/sh

echo "$1"
if [ -n "$1" ] ; then
    echo "已包含singleid"
else
    echo "必须包含singleid"
    exit 1
fi
sudo gem install fir-cli
sudo gem install xcodeproj
sudo gem install plist

echo "修改配置"
ruby ./Vigame/configuration.rb
echo "修改 Success"

echo "读取服务器信息"
ruby ./Vigame/createPodfile.rb $1

echo "检测版本结束"

pod update

echo "读取服务器信息"
ruby ./Vigame/connectSQL.rb $1



#添加证书和描述文件
echo "添加证书和描述文件"
security import "./Vigame/证书-密码123456/dis.p12" -k ~/Library/Keychains/login.keychain-db -P "123456" -A
security import "./Vigame/证书-密码123456/dev.p12" -k ~/Library/Keychains/login.keychain-db -P "123456" -A
open ./Vigame/证书-密码123456/guozhihd_hoc.mobileprovision
open ./Vigame/证书-密码123456/guozhihd_dev.mobileprovision

echo "打开完成"


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
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/
  xcodebuild clean -workspace "$appname.xcworkspace" -scheme "$appname" -configuration enterprise
  xcodebuild archive -workspace "$appname.xcworkspace" -scheme "$appname" -archivePath "$appname.xcarchive" -quiet
  xcodebuild -exportArchive -archivePath "$appname.xcarchive" -exportPath ipa -exportOptionsPlist "Vigame/ExportOptions.plist"

echo "上传fir.im"

for element in `ls "$path/ipa" | tr " " "\?"`
do
    element=`tr "\?" " " <<<$element`
    dir_or_file="$path/ipa"/"$element"
    if [ -d "$dir_or_file" ];then
        var=$( find "$dir_or_file" -name '*.ipa' )
        var1=${var##*/}
        if [ -n "$var1" ];then
            echo "上传fir.im"
            fir publish "$path/ipa/$var1" -T f093c9fb7d416121ce83634e37c6acb8 -Q
            open ./ipa
        fi
    fi
done
