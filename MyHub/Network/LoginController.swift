//
//  LoginController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit

enum HUB_loginSource: String {
//    cloudtab、metab、upload、download、transfer
    case file = "a"
    case set = "b"
    case upload = "c"
    case transfer = "d"
}

class LoginController: UIViewController {

    var loginSuccessBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
