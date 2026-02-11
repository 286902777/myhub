//
//  TabbarTool.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit

class TabbarTool {
    static let instance = TabbarTool()
    
    func displayOrHidden(_ show: Bool) {
        NotificationCenter.default.post(name: Noti_TabbarShow, object: nil, userInfo: ["show": show])
    }
}
