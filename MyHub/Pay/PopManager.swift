//
//  PopManager.swift
//  MyHub
//
//  Created by myhub-ios on 3/25/26.
//
import UIKit

class PopManager {
    static let instance = PopManager()
    
    func openPopPage(_ controller: UIViewController) {
        let scount = UserDefaults.standard.integer(forKey: PreStartPopVip)
        UserDefaults.standard.set(scount + 1, forKey: PreStartPopVip)
        UserDefaults.standard.synchronize()
        self.showPop(controller)
    }
    
    private func showPop(_ controller: UIViewController) {
        if PayManager.instance.isVip == false {
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
            let vc = PayAlertController()
            vc.modalPresentationStyle = .overFullScreen
            controller.present(vc, animated: false)
        }
    }
}

