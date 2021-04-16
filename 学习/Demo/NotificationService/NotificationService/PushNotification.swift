//
//  PushNotification.swift
//  NotificationService
//
//  Created by imou on 2019/5/28.
//  Copyright © 2019 imou. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotification: NSObject {
    
    /// 注册推送
    ///
    /// - Parameters:
    ///   - alerTtime:   距当前时间多少秒后触发
    ///   - identitfier: 唯一标示
    class func registerNotification(alerTtime: NSInteger, identitfier : String) -> Void {
        // 获取通知中心
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        // 创建可变通知内容
        let content : UNMutableNotificationContent = UNMutableNotificationContent.init()
        // 通知内容配置
        content.title = NSString.localizedUserNotificationString(forKey: "勿谓言之不预！美方不要低估中方反制能力", arguments: nil)
        content.body  = NSString.localizedUserNotificationString(forKey: "  “不愿打，不怕打，不得不打”！面对美国挑起对华经贸摩擦，中国政府始终坚持原则立场。美方一次又一次宣布加征关税，中国一次又一次不得不采取反制措施。\n  全世界都看到，美方手段一步步加码，不仅上调关税，而且试图用尽蛮力扭曲全球供应链，“剥夺”牵系中国企业生存的技术产品供应，其霸道行径令全球哗然。美国决策圈的一些人眼中只有自己——自己的利益，自以为全能的本领，狂傲得不可一世。为了一己之私，他们在全球供应链上呼风唤雨，臆想着“伟大而优先”的他们可以左右一切。然而，只要是学过牛顿定律的人都懂得，作用力与反作用力总是相伴相生，而且大小相等。\n  随着美国一些政客不停发出极限施压的叫嚣，人们愈加关心中国会拿出哪些“王牌”作为回应。国外不少媒体的目光投向稀土，有分析认为“中国对稀土市场的主导地位，已赋予北京还击之道”。\n    中国是世界第一稀土生产大国，也是世界最大的稀土材料供应国，而很多发达国家是稀土需求大国。加强稀土资源的开发利用，对中国和整个世界经济发展都具有积极意义。中国一直秉持开放、协同、共享的方针推动稀土产业发展。中国坚持稀土资源优先服务国内需要的原则，愿意满足世界各国对于稀土资源的正当需求，乐见本国稀土资源及稀土产品被用于制造各类先进产品，更好满足世界各国人民对美好生活的需要。\n    稀土是否会成为中国反制美方无端打压的反制武器？答案并不玄奥。这是产业分工高度全球化的时代，没有协同合作就没有发展进步。稀土元素被誉为现代工业的“维生素”，在冶金、石化、光学、激光、储氢、显示面板、磁性材料等现代工业领域均有广泛应用。随着世界科技革命和产业变革不断进步，稀土元素的战略价值和重要意义日益凸显。全球市场上，稀土新材料的消费量迅速增长，无论军事还是民用，大量产业的发展都离不开稀土资源，其中美国企业对稀土氧化物产品的需求尤其旺盛。当前，美方一些人的确在幻想“资源自立”，但美国对全球供应链的深度依赖是不争的现实。来自稀土产业的美国企业界人士最近颇为不安地对媒体表示：“我们落后很多，我们什么进展也没有。”国际市场研究机构的数据显示，美国是中国稀土的主要买家。事实上，美国生产的消费性电子产品、军事装备和其他许多产品，都高度依赖中国稀土资源。\n   毫无疑问，美方想利用中国出口的稀土所制造的产品，反用于遏制打压中国的发展，中国人民决不会答应。当前美方完全高估了自己操纵全球供应链的能力，在自我沉醉的空欢喜中无力自知，但其清醒后注定要自打嘴巴。中国有关部门已经多次发表严正声明，中美两国产业链高度融合，互补性极强，正所谓合则两利、斗则俱伤，贸易战没有赢家。奉劝美方不要低估中方维护自身发展权益的能力，勿谓言之不预！\n    知者不惑，仁者不忧，勇者不惧。在同世界各国扩大共同利益基础上携手发展，才可能拥抱持久繁荣，共赢的未来才值得拥有。\(identitfier)", arguments: nil)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "category";
        content.launchImageName    = "AppIconiPhoneNotification"
        content.badge              = 2
        let path = Bundle.main.path(forResource: "AppIconiPhoneNotification", ofType: "jpeg")
        let url = URL.init(fileURLWithPath: path!)
        do {
            let attachment = try! UNNotificationAttachment(identifier: "attachment", url: url, options: nil)
            content.attachments = [attachment]
        }
        
        addNotifactionAction()
        // 触发时间配置
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(alerTtime), repeats: false)
        // 生成通知请求
        let request = UNNotificationRequest.init(identifier: identitfier, content: content, trigger: trigger)
        // 添加通知请求
        center.add(request) { (error) in
            let alert : UIAlertController = UIAlertController.init(title: "本地通知", message: "成功添加推送", preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            // 显示alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /// 添加action
    class func addNotifactionAction() {
        let joinAction   = quickCreatAction(identifier: "join", title: "接受", option: .authenticationRequired)
        let lookAction   = quickCreatAction(identifier: "look", title: "查看", option: .foreground)
        let cancelAction = quickCreatAction(identifier: "cancel", title: "取消", option: .destructive)
        
        let notificationCategory = UNNotificationCategory.init(identifier: "category", actions: [joinAction,lookAction,cancelAction], intentIdentifiers: [], options: .customDismissAction)
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        let set : Set = [notificationCategory]
        center.setNotificationCategories(set)
    }
    
    
    /// 快速创建UNNotificationAction
    ///
    /// - Parameters:
    ///   - identifier: 唯一标示
    ///   - title:      标题
    ///   - option:     UNNotificationActionOptions类型
    /// - Returns:      UNNotificationActionOptions对象
    class func quickCreatAction(identifier: String, title: String, option:UNNotificationActionOptions) -> UNNotificationAction {
        let acticon = UNNotificationAction.init(identifier: identifier, title: title, options: option)
        return acticon
    }
    
}
