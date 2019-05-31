//
//  ViewController.swift
//  NotificationService
//
//  Created by imou on 2019/5/23.
//  Copyright © 2019 imou. All rights reserved.
//

import UIKit

let NotificationCountString = "NotificationCountString"

class ViewController: UIViewController {
    
    let label : UILabel = UILabel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let button = UIButton.init(frame: CGRect(x: 100, y: 100, width: 100, height: 40))
        self.view.addSubview(button)
        button.layer.cornerRadius  = 5.0
        button.layer.masksToBounds = true
        button.backgroundColor     = UIColor.orange
        button.setTitle("触发通知", for: .normal)
        button.addTarget(self, action: #selector(registerNotification), for: .touchUpInside)
        
        self.view.addSubview(label)
        label.frame     = CGRect(x: 100, y: 200, width: 200, height: 20)
        label.textColor = UIColor.orange
        
        let identifier : NSInteger = UserDefaults.standard.value(forKey: NotificationCountString) as? NSInteger ?? 0
        label.text      = String(identifier)
    }

    @objc func registerNotification(sender: UIButton) -> Void {
        var identifier : NSInteger = UserDefaults.standard.value(forKey: NotificationCountString) as? NSInteger ?? 0
        identifier += 1
        UserDefaults.standard.set(identifier, forKey: NotificationCountString)
        let identifierString = String(identifier)
        label.text           = identifierString
        PushNotification.registerNotification(alerTtime: 5, identitfier: identifierString)
    }
}

