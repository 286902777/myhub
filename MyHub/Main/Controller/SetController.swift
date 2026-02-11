//
//  SetController.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit

class SetController: SuperController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabbarTool.instance.displayOrHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabbarTool.instance.displayOrHidden(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
