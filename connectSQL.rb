#!/usr/bin/ruby

require 'Plist'
require 'net/https'
require 'uri'
require 'json'
require 'base64'

#获取版本号
def get_sdk_version()
    puts "执行 KTMSDK_Version"
    result = Plist.parse_xml($path)
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

    result["KTMSDK_Version"] = ktm_version
    Plist::Emit.save_plist(result, $path)
    
    ktm_version
end

#修改wechat配置
def modify_wechat (var1, var2)
    puts "执行 modify_wechat"
    wechat_parameters = {"wechat_appid" => "AppID", "wechat_appkey" => "AppSecret", "wechat_universalLink" => "UniversalLink"}
    result = Plist.parse_xml($path)

    if var2.length == 0
        puts '没有配置参数'
    else
        if wechat_parameters[var1]
               result['Used Social Agent']['wx-Social'][wechat_parameters[var1]] = var2
               Plist::Emit.save_plist(result, $path)

        end
    end
     puts " 微信参数 #{var1} 设置为： #{var2} "
end

#修改Analysis
def modify_analysis (var1, var2)
    puts "执行 modify_analysis"
    analysis_parameters = {"umeng_appkey" => "umeng_appkey", "dataeye_appkey" => "dataeye_trackingid", "headline_appkey" => "headline_appkey", "trackingio_appkey" => "trackingIO_appkey", "appsflyer_appkey" => "appsflyer_devkey", "facebook_appkey" => "facebook_appkey", "adjust_key" => "adjust_appToken", "tenjin_appkey" => "tenjin_appkey", "google_appkey" => "google_appkey", "google_new_label" => "google_new_label", "google_retained_label" => "google_retained_label"}
    result = Plist.parse_xml($path)

    if var2.nil?
        puts '没有配置参数'
    else
        if analysis_parameters[var1]
               result["statistical parameters"][analysis_parameters[var1]] = var2
               Plist::Emit.save_plist(result, $path)

        end
    end
    puts " #{var1} 修改为  #{var2} "
end

#修改appid
def modify_appid (var1, var2)
    puts "执行 modify_appid"
    parameter = Hash.new('parameter');
    parameter = {"appleID" => "apple_appid"}

    result = Plist.parse_xml($path)

    array = var2.split('#')

    array.each do |i|
        ar = i.split(';')
        if ar.length == 1
            puts '没有配置参数'
        else
            var = ar[0]
            result[parameter[var]] = ar[1]
            Plist::Emit.save_plist(result, $path)
        end
        puts "apple_appid修改为：#{ar[1]} "
    end
    
end

#修改common
def modify_common (var1, var2)
    puts "执行 modify_common"
    commons = Hash.new("common");
    commons = {"pjId" => "company_prjid", "appkey" => "company_appkey", "com_appid" =>"company_appid", "bugly_appid" => "bugly_appid", "protocol_id" => "protocol_id"}
    result = Plist.parse_xml($path)
    key = commons[var1]
    result[key] = var2
    Plist::Emit.save_plist(result, $path)
    puts " #{key} 修改为: #{var2} "
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

$path = File.join(file_path, "/Pods/KTMSDK/KTMSDK/KTMSDK.bundle/VigameLibrary.plist")

puts $path

#$ktm_version = get_sdk_version

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
         modify_common 'pjId', "333359"
         modify_appid 'appid', data['parameter']
         modify_common "appkey", data["appkey"]
         modify_common 'com_appid', data['appid']
         
          moduleData = data['moduleData'].split('#')
          moduleData.each do |i|
              array_module = i.split(';')
              if array_module[0] == "TJ"
                  if array_module[1] == "FaceBook"
                     
                  else
                      modify_analysis array_module[2],array_module[3]
                  end
              elsif  array_module[0]== "Social"
                  if  array_module[1]== "Wechat"
                      modify_wechat  array_module[2], array_module[3]
                  end
                  if  array_module[2].include?('appid')

                  end
              elsif  array_module[0] == "Extension" &&  array_module[1] == "Bugly"
                  modify_common 'bugly_appid',  array_module[3]
              elsif  array_module[0] == "Extension" &&  array_module[1] == "Activity"
                  modify_common array_module[2], array_module[3]
              else
                  puts "其他"
              end
          end

    end
