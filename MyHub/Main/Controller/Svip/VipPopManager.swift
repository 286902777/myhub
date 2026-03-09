//
//  VipPopManager.swift
//  MyHub
//
//  Created by hub on 3/8/26.
//

import Foundation
import UIKit

class VipPopManager {
    static let instance = VipPopManager()
    
    func openPopPage(_ controller: UIViewController) {
//        let scount = UserDefaults.standard.integer(forKey: PreStartPopVip)
//        UserDefaults.standard.set(scount + 1, forKey: PreStartPopVip)
//        UserDefaults.standard.synchronize()
//        self.showPop(controller)
    }
    
    private func showPop(_ controller: UIViewController) {
        if VipTool.instance.isUser == false {
            let count = UserDefaults.standard.integer(forKey: PreAutoVipPayCount)
            if count > 2 {
                return
            }
            
            let popdate = UserDefaults.standard.object(forKey: PrePupopDate) as? Date
            let date = UserDefaults.standard.object(forKey: PreAutoVipPayDate) as? Date
            if let d = popdate, d.isDayHour(Date()) == true {
                return
            }
            
            let adsDisPlay = UserDefaults.standard.integer(forKey: PreStartPopVip)
            if (adsDisPlay <= 1) {
                return
            }
            
            let popd = popdate ?? Date()
            if let d = date {
                if d.isHour(popd) {
                    return
                }
            }
            UserDefaults.standard.set(Date(), forKey: PrePupopDate)
            UserDefaults.standard.set(count + 1, forKey: PreAutoVipPayCount)
            UserDefaults.standard.set(0, forKey: PreStartPopVip)
            UserDefaults.standard.synchronize()
            self.presentPopAlertVC(controller)
        }
    }
    
    private func presentPopAlertVC(_ controller: UIViewController) {
        //            let vc = PremiumAlertController()
        //            vc.modalPresentationStyle = .overFullScreen
        //            controller.present(vc, animated: false)
    }
}

