#require "spaceship"
#
##class DevelopPortalHandle
##def initialize(appid)
##@appid = appid
##
##list = appid.split(".")
##appidLastName = list.last
##
##@appName = appidLastName
##@provisionName = appidLastName
##end
##
##def login()
#Spaceship::Portal.login("644202152@qq.com","Arges005")
#Spaceship::Portal.login("972995869@qq.com","Xyo356721894")
#Spaceship.client.team_id = "这里输入TeamId"
require 'spaceship'

Spaceship.login('644202152@qq.com','Arges005')
# 第一次运行的时候可能会提示需要双重认证，填写验证码。
#参数传入true表示要新增设备，例如：ruby fastlanetest.rb true
if ARGV[0] == "true"
    puts "你输入的是true"
    # file = File.open("Device_mushao_ios.txt")#文本文件里录入的udid和设备名，设备类型用tab分隔
    # file.each do |line|
    #     arr = line.strip.split("\t")
    #     # device = Spaceship.device.create!(name:arr[1], udid:arr[0],devicePlatform:arr[2])
    #     device = Spaceship.device.create!(name:arr[1], udid:arr[0], mac:false)
    #     puts "add device: #{device.name} #{device.udid}  #{device.model}"
    # end
    
    #获取所有的iPhone设备
    oldDevices = Spaceship.device.all_iphones
     puts "all old iphones count = #{oldDevices.count}"
     puts "all old iphones detail = #{oldDevices}"
     
    
    # 让设备可用
    # device = Spaceship.device.find_by_udid('a95b64a4b3c074b685d497675f88e69654dbe07d',include_disabled:true)
    # puts "当前要解除的设备  device=#{device}"
    # puts "当前要解除的设备  udid=#{device.udid} model=#{device.model}"
    # device.enable!
    
    #获取描述文件
#    profiles = Spaceship.provisioning_profile.development.all
#     puts "alldevelopents = #{profiles}"
#    profiles.each do |obj|
#        puts "name = #{obj.name}"
#        if obj.name == "ruby_0902"
#            #下载描述文件
#            File.write("/Users/chiyz/Desktop/测试项目/ruby脚本签名/0903.mobileprovision",obj.download)
#        end
#    end

    
    #获取证书列表
     certificate = Spaceship.certificate
     puts "certificate = #{certificate.all.count}"
    # devCer = certificate.find("39TAtsafdsa5")
     puts "devCer = #{certificate.all}"
    
    # #创建描述文件
    # profile = Spaceship.provisioning_profile
    # # puts "type = #{profile}"
    # # profile.type = "iOS Development"
    # profile.Development.create!(name:"ruby_0902",bundle_id:"com.yfagam.abc",certificate:devCer , devices:oldDevices,mac:false,)
    
    
    
    
    else
    puts "你输入的不是true"
end
# file = File.open("multi.txt")
# file.each do |line|
#     arr = lin.strip.split("\t")

