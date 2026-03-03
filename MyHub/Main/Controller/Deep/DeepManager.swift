//
//  DeepManager.swift
//  MyHub
//
//  Created by Ever on 2026/3/2.
//

import UIKit

class DeepManager {
    static let share = DeepManager()
    
    func openBoxDeep(_ linkId: String, _ rootVC: UIViewController) {
        let vc = BoxDeepController(linkId: linkId)
        let nav = UINavigationController(rootViewController: vc)
        vc.modalPresentationStyle = .overFullScreen
        rootVC.present(nav, animated: false)
    }
}
