//
//  BoxPingController.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit

class BoxPingController: SuperController {

    let headView: BoxPingHeadView = BoxPingHeadView.view()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        self.navbar.nameL.isHidden = true
    }
}
