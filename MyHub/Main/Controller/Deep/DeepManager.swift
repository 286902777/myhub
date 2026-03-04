//
//  DeepManager.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit

class DeepManager {
    static let share = DeepManager()
    
    func openBoxDeep(_ linkId: String, _ rootVC: UIViewController) {
        let vc = BoxDeepController(linkId: linkId)
        TabbarTool.instance.displayOrHidden(false)
        HubTool.share.deepUrl = ""
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        rootVC.present(nav, animated: false)
    }
}
