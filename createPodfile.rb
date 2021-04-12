#!/usr/bin/ruby

require 'Plist'
require 'net/https'
require 'uri'
require 'json'
require 'base64'
require 'xcodeproj'

#获取icon
def create_icon(var, var1)
    puts "执行 create_icon"
    if var1.nil?
        puts "未设置icon"
    else
        bidFile=File.new("#{var}/icon.png",'w')
        img_base64 = var1
        bidFile.binmode
        bidFile.write(Base64.decode64(img_base64))
        bidFile.close
    end
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
#    result["UILaunchStoryboardName"] = "LaunchScreen"
#    result["UIMainStoryboardFile"] = "LaunchScreen"
    if result.include?("CFBundleDisplayName")
        result["CFBundleDisplayName"] = var2
    else
        result["CFBundleName"] = var2
    end
    Plist::Emit.save_plist(result, $info_path)
    puts "displayname修改成: #{var2}"
    
end

#修改version
def modify_version (var2)
    puts "执行 modify_version"
    result = Plist.parse_xml($info_path)
    
    result["GADIsAdManagerApp"] = true
    
    result["NSAppTransportSecurity"] = {"NSAllowsArbitraryLoads" => true}
    
    result["CFBundleShortVersionString"] = var2
    
    #
    result["SKAdNetworkItems"] = [{"SKAdNetworkIdentifier"=>"58922NB4GD.skadnetwork"},{"SKAdNetworkIdentifier"=>"SU67R6K2V3.skadnetwork"},{"SKAdNetworkIdentifier"=>"cstr6suwn9.skadnetwork"},{"SKAdNetworkIdentifier"=>"ludvb6z3bs.skadnetwork"},{"SKAdNetworkIdentifier"=>"22mmun2rn5.skadnetwork"},{"SKAdNetworkIdentifier"=>"238da6jt44.skadnetwork"},{"SKAdNetworkIdentifier"=>"4DZT52R2T5.skadnetwork"},{"SKAdNetworkIdentifier"=>"KBD757YWX3.skadnetwork"}]
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
    flag2 = File.exist?(File.join(var, "/ios/Info.plist"))
    if flag
        $info_path = File.join(var, "/Info.plist")
    end
    if flag1
        $info_path = File.join(var, "/#{$target_name}/Info.plist")
    end
    if flag2
        $info_path = File.join(var, "/ios/Info.plist")
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

#1工程路径
$path = File.join(file_path, "#{$target_name}.xcodeproj")

puts "获得当前文件的目录 = #{$path} "
#2、获取project
$project = Xcodeproj::Project.open($path)
puts "当前project = #{$project} "

#3、获取target
$target_first = $project.targets.first
$targetname = $target_first.name

unityframework_target = $project.targets[$project.targets.length - 1]

if unityframework_target.name.eql?("UnityFramework")
    $targetname_framework = unityframework_target.name
end
puts "targetname = #{$targetname_framework} "
get_info_path file_path

$arr=Array.new

module_hash = {
    "1cd9ef18da30e4c8" => "pod 'KTMSDK/Ads/Admob',sdkVersion\n",
    "48e736bbf8e18094" => "pod 'KTMSDK/Ads/Bytedance',sdkVersion\n",
    "c4981e0c3e8b53dd" => "pod 'KTMSDK/Ads/Facebook',sdkVersion\n",
    "376fc3eb2c4be30d" => "pod 'KTMSDK/Ads/GDT',sdkVersion\n",
    "b89fe097b01290e1" => "pod 'KTMSDK/Ads/Applovin',sdkVersion\n",
    "4092ca002b6e3b11" => "pod 'KTMSDK/Ads/Vungle',sdkVersion\n",
    "bd9a2f3fb25755f2" => "pod 'KTMSDK/Ads/Mintegral',sdkVersion\n",
    "93bc045e56b7a903" => "pod 'KTMSDK/Ads/Ironsource',sdkVersion\n",
    "3e82819188397b3c" => "pod 'KTMSDK/Ads/Kuaishou',sdkVersion\n",
    "343018db7f91804f" => "pod 'KTMSDK/Ads/Ironsource',sdkVersion\npod 'IronSourceAdMobAdapter','4.3.17.1'\npod 'IronSourceFacebookAdapter','4.3.21.0'\npod 'IronSourceUnityAdsAdapter','4.3.6.0'\npod 'IronSourcePangleAdapter','4.1.10.0'\npod 'IronSourceAppLovinAdapter','4.3.20.0'\n",
    "346d3b77bcce9699" => "pod 'KTMSDK/Ads/KTMAd',sdkVersion\n",
    "8f42b12421198153" => "pod 'KTMSDK/Ads/Unity',sdkVersion\n",
    "800c9f2b44906a40" => "pod 'KTMSDK/Ads/Sigmob',sdkVersion\n",
    "bbe689a628acbe99" => "pod 'KTMSDK/Ads/Mjuhe',sdkVersion\n",
    "61a0b8addc4e2ada" => "pod 'KTMSDK/Analysis/Appsflyer',sdkVersion\n",
    "dc20f2d856ad0ad1" => "pod 'KTMSDK/Analysis/ByteDance',sdkVersion\n",
    "27eb7172e79f04af" => "pod 'KTMSDK/Analysis/TrackingIO',sdkVersion\n",
    "9bc4b30ad093983b" => "pod 'KTMSDK/Analysis/Umeng',sdkVersion\n",
    "6736790a5e4f9829" => "pod 'KTMSDK/Analysis/Facebook',sdkVersion\n",
    "811b3ce36e6d7fd8" => "pod 'KTMSDK/Analysis/Adjust',sdkVersion\n",
    "affcc433cf07f469" => "pod 'KTMSDK/Analysis/DataEye',sdkVersion\n",
    "65a42a48b5c9de51" => "pod 'KTMSDK/Analysis/Google',sdkVersion\n",
    "7f86e6683a2a3a9d" => "pod 'KTMSDK/Analysis/Tenjin',sdkVersion\n",
    "2e5316d6958e7ed0" => "pod 'KTMSDK/Extension/Bugly',sdkVersion\n",
    "edb9f86c8f8aaa6e" => "pod 'KTMSDK/IAP',sdkVersion\n",
    "3a03da5b9486e430" => "pod 'KTMSDK/Social/Facebook',sdkVersion\n",
    "60bea3764e1efb60" => "pod 'KTMSDK/Social/Wechat',sdkVersion\n",
    "a152da8dd2db3f85" => "pod 'KTMSDK/Social/Apple',sdkVersion\n"
    }

 #读取服务器配置
    url = "https://edc.vimedia.cn:6115/selectWbguiFormconfig?singleid=#{singleid}"
    puts "请求地址：#{url}"
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)

    resbody = JSON.parse(res.body)
    if resbody.nil?
        puts "服务器请求异常"
    else
         data = resbody["data"]
         modify_version data["moduleVersion"]
         version = "1.0.0"
         if ARGV[1].nil?
             version = data["moduleVersion"]
         else
            version = ARGV[1]
            puts "版本号 = #{version}"
            
         end
         ad_arr = data['ad'].split(';') # ad
#         "pod 'KTMSDK/KTMSDK',sdkVersion\n","pod 'KTMSDK/Common',sdkVersion\n"
        if $targetname_framework.nil?
            df_array=["source 'http://wy@dnsdk.vimedia.cn:8080/r/IOSMavenSpec.git'\n" ,   "source 'https://cdn.cocoapods.org/'\n", "platform :ios, 9.0\n" , "use_frameworks!\n", "target ‘#{$targetname}’ do\n",  "sdkVersion='#{version}'\n","pod 'KTMSDK/KTMSDK',sdkVersion\n", "pod 'KTMSDK/Common',sdkVersion\n"]
         else
            df_array=["source 'http://wy@dnsdk.vimedia.cn:8080/r/IOSMavenSpec.git'\n" ,   "source 'https://cdn.cocoapods.org/'\n", "platform :ios, 9.0\n" , "use_frameworks!\n", "target ‘#{$targetname_framework}’ do\n ", "sdkVersion='#{version}'\n","pod 'KTMSDK/KTMSDK',sdkVersion\n", "pod 'KTMSDK/Common',sdkVersion\n", "end\n", "target ‘#{$targetname}’ do\n ","sdkVersion='#{version}'\n"]
         end
         $arr.concat(df_array)
          moduleData = data['moduleData'].split('#')
          puts moduleData
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
