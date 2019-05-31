//
//  NotificationViewController.swift
//  MediaNotificationContent
//
//  Created by imou on 2019/5/23.
//  Copyright © 2019 imou. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content    = notification.request.content
        let attachment = content.attachments.first
        
        self.label?.text = content.title
        

        // 1.初始化富文本
        let nameStr : NSMutableAttributedString = NSMutableAttributedString(string:content.body as String)
        // 2.添加样式 (行间距和对其方式)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 10
        paragraphStyle.paragraphSpacingBefore = 5
        paragraphStyle.alignment = .left
        // 3.行间距和字间距
        nameStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, NSString(string: content.body).length))
        nameStr.addAttribute(NSAttributedString.Key.kern, value: 2, range:  NSMakeRange(0, NSString(string: content.body).length))
        // 设置富文本内容
        self.subTitle.attributedText = nameStr
        
        if ((attachment?.url.startAccessingSecurityScopedResource())!) {
            self.iconImageView.image = UIImage(contentsOfFile: (attachment?.url.path)!)
        }
    }

}
