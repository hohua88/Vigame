#!/usr/bin/ruby
require 'xcodeproj'

#获取target名字
$target_name
file_path=Dir::pwd
aDir=Dir::entries(file_path)
aDir.each do |dir_file|
    if dir_file.include?('xcodeproj')
        $target_name= dir_file.split('.')[0]
    end
end

#1工程路径
#file_path = File.dirname(__FILE__)
$path = File.join(file_path, "#{$target_name}.xcodeproj")

puts "获得当前文件的目录 = #{$path} "
#2、获取project
$project = Xcodeproj::Project.open($path)
puts "当前project = #{$project} "

#3、获取target
$target = $project.targets.first
puts "当前target = #{$target} "

#4、添加其他设置
$target.build_configurations.each do |config|

   config.build_settings['ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME'] = ''
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
   config.build_settings['ENABLE_BITCODE'] = 'NO'
   config.build_settings['GCC_C_LANGUAGE_STANDARD'] = 'gnu11'
   config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'gnu++14'
   config.build_settings['GCC_ENABLE_CPP_RTTI'] = 'YES'
   config.build_settings['GCC_ENABLE_OBJC_EXCEPTIONS'] = 'YES'
   config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
   config.build_settings['DEVELOPMENT_TEAM'] = 'F8JZ43KSCR'
   config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.wb.gc.gzsj2hd'
   if config.name == "Release"
       config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'guozhihd_hoc'
       config.build_settings['CODE_SIGN_IDENTITY'] = 'iPhone Distribution'
       config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'iPhone Distribution'
   else
       config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'guozhihd_dev'
       config.build_settings['CODE_SIGN_IDENTITY'] = 'iPhone Developer'
       config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'iPhone Developer'
   end
end
puts "其他设置成功 "

#5、添加group
$group = $project.main_group.find_subpath(File.join('Vigame'), true)
$group.clear
puts "当前group = #{$group} "
$group.set_source_tree('SOURCE_ROOT')

#6、向group中添加文件
$file_path8 = File.join(file_path, "/Vigame/LaunchScreen.storyboard")

if $group.find_file_by_path($file_path8)
    puts "LaunchScreen.storyboard"
else
    $target.resources_build_phase.add_file_reference($group.new_reference($file_path8))
end
$file_path9 = File.join(file_path, "/Vigame/launch_image.png")

if $group.find_file_by_path($file_path9)
    puts "launch_image.png"
else
    $target.resources_build_phase.add_file_reference($group.new_reference($file_path9))
end

#7、保存
$project.save($path)
