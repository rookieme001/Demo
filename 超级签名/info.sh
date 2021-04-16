#!/bin/sh

require "spaceship"

class DevelopPortalHandle
def initialize(appid)
@appid = appid

list = appid.split(".")
appidLastName = list.last

@appName = appidLastName
@provisionName = appidLastName
end

def login()
Spaceship::Portal.login("644202152@qq.com","Arges005")
Spaceship.client.team_id = "这里输入TeamId"
end

def createApp()
puts "createApp #{@appid} appName = #{@appName}"
app = Spaceship::Portal.app.find(@appid)
puts "app =  #{app}  class = #{app.class}"
if !app then
#生成appid,创建新的app
app = Spaceship::Portal.app.create!(bundle_id: @appid, name: @appName)
puts "createApp #{app}"
end
end

#appstore or inHouse
def createDistributionProvision(provisioningClass)
cert = Spaceship::Portal.certificate.production.all.last
provisionNameDis = @provisionName + '_dis'
profile = provisioningClass.create!(bundle_id: @appid,certificate:cert,name:@provisionName)
return profile
end

#appstore or inHouse
def downloadDistributionProvision(provisioningClass)
#查找有没有provision文件
filtered_profiles = provisioningClass.find_by_bundle_id(bundle_id: @appid)
profile = nil
if  0 < filtered_profiles.length then
profile = filtered_profiles[0]
elsif 0 == filtered_profiles.length then
profile = createProvision(provisioningClass)
end

#没有找到就创建，找到就下载
provisionNameDis = @provisionName + '_dis'
provisionFileName = provisionNameDis + '.mobileprovision'
File.write(provisionFileName, profile.download)
return provisionFileName
end


def createDevelopProvision()
dev_certs = Spaceship::Portal.certificate.development.all
all_devices = Spaceship::Portal.device.all
provisionNameDev = @provisionName + '_dev'
profile = Spaceship::Portal.provisioning_profile.development.create!(bundle_id: @appid,certificate: dev_certs,name: provisionNameDev,devices:all_devices)
return profile
end

def downloadDevelopProvision()
#查找有没有provision文件
filtered_profiles = Spaceship::Portal.provisioning_profile.development.find_by_bundle_id(bundle_id: @appid)
profile = nil
if  0 < filtered_profiles.length then
profile = filtered_profiles[0]
elsif 0 == filtered_profiles.length then
profile = createDevelopProvision()
end

#没有找到就创建，找到就下载
provisionNameDev = @provisionName + '_dev'
provisionFileName = provisionNameDev + '.mobileprovision'
File.write(provisionFileName, profile.download)
return provisionFileName
end

def addServices(appServiceObj)
app = Spaceship::Portal.app.find(@appid)
app.update_service(appServiceObj)
end
end


#创建、下载develop的provision文件

appid = ARGV[0]
handle = DevelopPortalHandle.new(appid)
handle.login()
handle.createApp()
handle.addServices(Spaceship::Portal.app_service.push_notification.on)
handle.addServices(Spaceship::Portal.app_service.vpn_configuration.on)
provisionPath = handle.downloadDevelopProvision()
