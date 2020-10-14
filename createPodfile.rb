#!/usr/bin/ruby

require 'Plist'
require 'net/https'
require 'uri'
require 'json'
require 'base64'

#获取icon
def create_icon(var, var1)
    puts "执行 create_icon"
    bidFile=File.new("#{var}/icon.png",'w')
    img_base64 = var1
    bidFile.binmode
    bidFile.write(Base64.decode64(img_base64))
    bidFile.close
end
#获取版本号
def get_sdk_version()
    puts "执行 KTMSDK_Version"
    
    #读取服务器配置
    url = "http://gui.vigame.cn/plugin/files/Versions_iOS.json"
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)

    resbody = JSON.parse(res.body)
    if resbody.nil?
        puts "服务器请求异常"
    else
        ktm_version = resbody["KTMSDK_Version"]["version"]
        if ktm_version == "1.0.0"
            ktm_version = "1.0.3"
        end
    end
    
    ktm_version
end

#设置FacebookAppID
def modify_analysis_fb(var, var1)
    puts "执行 modify_analysis_fb"
    info_path = File.join(var1, "/Info.plist")

    result = Plist.parse_xml($info_path)
    
    if var.nil?
         puts "FacebookAppID为空，请检查参数"
    else
        result["FacebookAppID"] = var
         puts "FacebookAppID 设置为：#{var}"
    end
    Plist::Emit.save_plist(result, $info_path)
   
end

#修改info.plist中wechat、facebook参数
def modify_info (var1,var2,var3)
    puts "执行 modify_info"
    puts var1,var2,var3
    info_path = File.join(var1, "/Info.plist")

    result = Plist.parse_xml($info_path)
    
    shcemes = result["LSApplicationQueriesSchemes"]
    urltypes = result["CFBundleURLTypes"]
    if var2 == "Wechat"
        if shcemes.nil?
            result["LSApplicationQueriesSchemes"] = ["weixin","weixinULAPI"]
        else
            result["LSApplicationQueriesSchemes"] = (["weixin","weixinULAPI"] + shcemes).uniq
        end
        if urltypes.nil?
            result["CFBundleURLTypes"] = ["CFBundleTypeRole" =>"Editor","CFBundleURLSchemes" => [var3]]
        else
            result["CFBundleURLTypes"] = (["CFBundleTypeRole" =>"Editor","CFBundleURLSchemes" => [var3]] +urltypes).uniq
        end
    elsif var2 == "FaceBook"
        result["FacebookAppID"] = var3
        fbid = "fb"+var3
        if shcemes.nil?
             result["LSApplicationQueriesSchemes"] = ["fbshareextension","fb","fbauth2","fb-messenger-share-api","fbapi"]
        else
             result["LSApplicationQueriesSchemes"] = (["fbshareextension","fb","fbauth2","fb-messenger-share-api","fbapi"] + shcemes).uniq
        end
        if urltypes.nil?
            result["CFBundleURLTypes"] = ["CFBundleTypeRole" =>"Editor","CFBundleURLSchemes" => [fbid]]
        else
            result["CFBundleURLTypes"] = (["CFBundleTypeRole" =>"Editor","CFBundleURLSchemes" => [fbid]] + urltypes).uniq
        end
    else
    end
    Plist::Emit.save_plist(result, $info_path)
    puts " #{var2} 配置设置成功"
end

#修改displayname
def modify_displayname (var1, var2)
    puts "执行 modify_displayname"
    puts $info_path
    result = Plist.parse_xml($info_path)
    result["UILaunchStoryboardName"] = "LaunchScreen"
    
    
    if result.include?("CFBundleDisplayName")
        result["CFBundleDisplayName"] = var2
    else
        result["CFBundleName"] = var2
    end
    Plist::Emit.save_plist(result, $info_path)
    puts "displayname修改成: #{var2}"
    
end

#修改version
def modify_version (var1, var2)
    puts "执行 modify_version"
    result = Plist.parse_xml($info_path)
    
    result["GADIsAdManagerApp"] = true
    
    result["NSAppTransportSecurity"] = {"NSAllowsArbitraryLoads" => true}
    
    result["CFBundleShortVersionString"] = var2
    Plist::Emit.save_plist(result, $info_path)
    puts "版本号修改成  #{var2} "
end

#生成Podfile
def create_podfile (var, var2)
    
    puts "执行 create_podfile"
    var2.concat(["end"])
    puts var2
    aFile=File.new("#{var}/Podfile",'w')
    var2.each do |i|
        aFile.write(i)
    end
    puts 'podfile生成成功'
    aFile.close
end

def get_info_path(var)
    puts "执行 get_info_path"
    flag = File.exist?(File.join(var, "/Info.plist"))
    flag1 = File.exist?(File.join(var, "/#{$target_name}/Info.plist"))
    if flag
        $info_path = File.join(var, "/Info.plist")
    end
    if flag1
        $info_path = File.join(var, "/#{$target_name}/Info.plist")
    end
    
end

singleid = ARGV.first
#获取target名字
$target_name
$info_path
file_path=Dir::pwd
aDir=Dir::entries(file_path)
aDir.each do |dir_file|
    if dir_file.include?('xcodeproj')
        $target_name= dir_file.split('.')[0]
    end
end

get_info_path file_path

$ktm_version = get_sdk_version

$arr=Array.new

module_hash = {
    "1cd9ef18da30e4c8" => "pod 'KTMSDK/Ads/Admob',sdkVersion\n",
    "48e736bbf8e18094" => "pod 'KTMSDK/Ads/ByteDance',sdkVersion\n",
    "c4981e0c3e8b53dd" => "pod 'KTMSDK/Ads/Facebook',sdkVersion\n",
    "376fc3eb2c4be30d" => "pod 'KTMSDK/Ads/GDT',sdkVersion\n",
    "b89fe097b01290e1" => "pod 'KTMSDK/Ads/Applovin',sdkVersion\n",
    "4092ca002b6e3b11" => "pod 'KTMSDK/Ads/Vungle',sdkVersion\n",
    "3e82819188397b3c" => "pod 'KTMSDK/Ads/Kuaishou',sdkVersion\n",
    "bd9a2f3fb25755f2" => "pod 'KTMSDK/Ads/Mintegral',sdkVersion\n",
    "93bc045e56b7a903" => "pod 'KTMSDK/Ads/Ironsource',sdkVersion\n",
    "343018db7f91804f" => "pod 'KTMSDK/Ads/Ironsource',sdkVersion\npod 'IronSourceAdMobAdapter','4.3.16.0'\npod 'IronSourceFacebookAdapter','4.3.18.5'\npod 'IronSourceUnityAdsAdapter','4.3.4.2'\npod 'IronSourcePangleAdapter','4.1.7.0'\npod 'IronSourceAppLovinAdapter','4.3.17.0'\n",
    "346d3b77bcce9699" => "pod 'KTMSDK/Ads/KTMAd',sdkVersion\n",
    "8f42b12421198153" => "pod 'KTMSDK/Ads/Unity',sdkVersion\n",
    "61a0b8addc4e2ada" => "pod 'KTMSDK/Analysis/Appsflyer',sdkVersion\n",
    "dc20f2d856ad0ad1" => "pod 'KTMSDK/Analysis/ByteDance',sdkVersion\n",
    "27eb7172e79f04af" => "pod 'KTMSDK/Analysis/TrackingIO',sdkVersion\n",
    "9bc4b30ad093983b" => "pod 'KTMSDK/Analysis/Umeng',sdkVersion\n",
    "6736790a5e4f9829" => "pod 'KTMSDK/Analysis/Facebook',sdkVersion\n",
    "811b3ce36e6d7fd8" => "pod 'KTMSDK/Analysis/Adjust',sdkVersion\n",
    "65a42a48b5c9de51" => "pod 'KTMSDK/Analysis/Google',sdkVersion\n",
    "7f86e6683a2a3a9d" => "pod 'KTMSDK/Analysis/Tenjin',sdkVersion\n",
    "2e5316d6958e7ed0" => "pod 'KTMSDK/Extension/Bugly',sdkVersion\n",
    
    "edb9f86c8f8aaa6e" => "pod 'KTMSDK/IAP',sdkVersion\n",
    "3a03da5b9486e430" => "pod 'KTMSDK/Social/Facebook',sdkVersion\n",
    "60bea3764e1efb60" => "pod 'KTMSDK/Social/Wechat',sdkVersion\n",
    "a152da8dd2db3f85" => "pod 'KTMSDK/Social/Apple',sdkVersion\n"
    }

df_array=["source 'http://wy@dnsdk.vimedia.cn:8080/r/IOSMavenSpec.git'\n" ,   "source 'https://cdn.cocoapods.org/'\n", "platform :ios, 9.0\n"  "use_frameworks!\n" , "target ‘#{$target_name}’ do\n", "sdkVersion='#{$ktm_version}'\n", "pod 'KTMSDK/KTMSDK',sdkVersion\n", "pod 'KTMSDK/Common',sdkVersion\n"]
$arr.concat(df_array)

 #读取服务器配置
    url = "https://api.vzhifu.net/selectWbguiFormconfig?singleid=#{singleid}"
    puts "请求地址：#{url}"
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)

    resbody = JSON.parse(res.body)
    if resbody.nil?
        puts "服务器请求异常"
    else
         data = resbody["data"]
         ad_arr = data['ad'].split(';') # ad
         
          moduleData = data['moduleData'].split('#')
          moduleData.each do |i|
              array_module = i.split(';')
              if array_module[0] == "TJ"
                  if array_module[1] == "FaceBook"
                      modify_analysis_fb array_module[3], file_path
                  end
              elsif  array_module[0]== "Social"
                  if  array_module[2].include?('appid')
                      modify_info file_path, array_module[1], array_module[3]
                  end
              
              else
                  puts "其他"
              end
          end

          ad_arr.each do |ad|
              $arr.concat([module_hash[ad]])
          end
         create_icon file_path, data["icon"]
         modify_displayname file_path, data["gameName"]
         create_podfile file_path, $arr
    end
