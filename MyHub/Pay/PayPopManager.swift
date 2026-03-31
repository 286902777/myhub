//
//  PayPopManager.swift
//  MyHub
//
//  Created by hub on 3/8/26.
//

import Foundation
import UIKit

class PayPopManager {
    static let instance = PayPopManager()
    
    func openPopPage(_ controller: UIViewController, _ isPlay: Bool = false) {
        let scount = UserDefaults.standard.integer(forKey: PreStartPopVip)
        UserDefaults.standard.set(scount + 1, forKey: PreStartPopVip)
        UserDefaults.standard.synchronize()
        self.showPop(controller, isPlay)
    }
    
    private func showPop(_ controller: UIViewController, _ isPlay: Bool) {
        self.presentPopAlertVC(controller, isPlay)
//        if PayManager.instance.isVip == false {
//            let count = UserDefaults.standard.integer(forKey: PreAutoVipPayCount)
//            if count > 2 {
//                return
//            }
//            
//            let popdate = UserDefaults.standard.object(forKey: PrePupopDate) as? Date
//            let date = UserDefaults.standard.object(forKey: PreAutoVipPayDate) as? Date
//            if let d = popdate, d.isDayHour(Date()) == true {
//                return
//            }
//            
//            let adsDisPlay = UserDefaults.standard.integer(forKey: PreStartPopVip)
//            if (adsDisPlay <= 1) {
//                return
//            }
//            
//            let popd = popdate ?? Date()
//            if let d = date {
//                if d.isHour(popd) {
//                    return
//                }
//            }
//            UserDefaults.standard.set(Date(), forKey: PrePupopDate)
//            UserDefaults.standard.set(count + 1, forKey: PreAutoVipPayCount)
//            UserDefaults.standard.set(0, forKey: PreStartPopVip)
//            UserDefaults.standard.synchronize()
//            self.presentPopAlertVC(controller, isPlay)
//        }
    }
    
    private func presentPopAlertVC(_ controller: UIViewController, _ isPlay: Bool) {
        let vc = PayAlertController(play: isPlay)
        vc.modalPresentationStyle = .overFullScreen
        controller.present(vc, animated: false)
    }
}

