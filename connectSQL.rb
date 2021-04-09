#!/usr/bin/ruby

require 'Plist'
require 'net/https'
require 'uri'
require 'json'
require 'base64'
require 'xcodeproj'
def modify_xcodeproj(var,var1)
   
    #1工程路径
    #file_path = File.dirname(__FILE__)
    path = File.join(var, "#{$target_name}.xcodeproj")

    puts "获得当前文件的目录 = #{path} "
    #2、获取project
    project = Xcodeproj::Project.open(path)
    puts "当前project = #{project} "

    #3、获取target
    target = project.targets.first
    puts "当前target = #{target} "

    #6、添加其他设置
    target.build_configurations.each do |config|
        config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = var1
    end
    puts "其他设置成功 "
    project.save(path)
end
#修改wechat配置
def modify_wechat (var1, var2)
    puts "执行 modify_wechat"
    wechat_parameters = {"wechat_appid" => "wechat_appid", "wechat_appkey" => "wechat_appkey", "wechat_universalLink" => "wechat_universalLink"}
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
    analysis_parameters = {"umeng_appkey" => "umeng_appkey", "headline_appkey" => "headline_appkey", "trackingio_appkey" => "trackingIO_appkey", "appsflyer_appkey" => "appsflyer_appkey", "facebook_appkey" => "facebook_appkey", "adjust_key" => "adjust_appkey", "tenjin_appkey" => "tenjin_appkey", "google_appkey" => "google_appkey", "google_new_label" => "google_new_label", "google_retained_label" => "google_retained_label"}
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

#修改common
def modify_common (var1, var2)
    puts "执行 modify_common"
    commons = Hash.new("common");
    commons = {"pjId" => "company_prjid", "appkey" => "company_appkey", "com_appid" =>"company_appid", "bugly_appid" => "bugly_appid", "protocol_id" => "protocol_id", "apple_appid" => "apple_appid", "company_singleid" => "company_singleid", "moduleVersion" => "KTMSDK_Version"}
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


$path = File.join(file_path, "/Pods/KTMSDK/Common/KTMCommonKit.bundle/VigameLibrary.plist")

puts $path

#get_sdk_version

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
 
 modify_common "company_singleid", singleid
 modify_common 'pjId', data["pjId"]
 modify_common "appkey", data["appkey"]
 if ARGV[1] == '1'
     modify_xcodeproj file_path, data["packageName"]
     modify_common 'com_appid', data['appid']
 else
    modify_xcodeproj file_path, "com.wb.gc.gzsj2hd"
    modify_common 'com_appid','17265'
 end
 
 modify_common 'protocol_id',"1"
 modify_common 'moduleVersion', data["moduleVersion"]
 moduleData = data['moduleData'].split('#')
  moduleData.each do |i|
      array_module = i.split(';')
      if array_module[0] == "TJ"
          modify_analysis array_module[2],array_module[3]
      elsif  array_module[0]== "Social"
          if  array_module[1]== "Wechat"
              modify_wechat  array_module[2], array_module[3]
          end
          if  array_module[2].include?('appid')
          end
      elsif  array_module[0] == "Extension" &&  array_module[1] == "Bugly"
          modify_common 'bugly_appid',  array_module[3]
      elsif array_module[0] == "Core"
          modify_common 'apple_appid',  array_module[3]
      else
          puts "其他"
      end
  end

end
