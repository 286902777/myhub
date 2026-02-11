//
//  PlayTool.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit

class PlayTool {
    static let instance = PlayTool()
    
    var auto: Bool = false
    var list: [VideoData] = []
    
    func pushPage(_ controller: UIViewController, _ mod: VideoData, _ list: [VideoData], _ history: Bool = false) {
        PlayTool.instance.list = list.filter({$0.file_type == .video})
        let vc = PlayVideoController(model: mod, history: history)
        vc.hidesBottomBarWhenPushed = true
        vc.premiumBlock = { [weak self] in
            guard let self = self else { return }
//            if PremiumTool.instance.isMember {
//                return
//            }
//            ESBaseTool.instance.preSource = .vip_playPage
//            ESBaseTool.instance.preMethod = .vip_auto
//            DispatchQueue.main.async {
//                self.adsPushPremium(.playBack, .vip_Ad, controller)
//            }
        }
        controller.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func adsPushPremium(_ state: ES_AdsPlayState, _ source: ES_PremiumSource, _ controller: UIViewController) {
//        if PremiumTool.instance.isMember == false {
//            let count = UserDefaults.standard.integer(forKey: PreAutoVipPayCount)
//            if count > 2 {
//                return
//            }
//            
//            let popdate = UserDefaults.standard.object(forKey: PrePupopDate) as? Date
//            let date = UserDefaults.standard.object(forKey: PreAutoVipPayDate) as? Date
//            if let d = date, d.isDayHour(Date()) == true {
//                return
//            }
//            
//            let d = date ?? Date()
//            if let popd = popdate {
//                if d.isHour(popd) {
//                    return
//                }
//            }
//            
//            UserDefaults.standard.set(Date(), forKey: PreAutoVipPayDate)
//            UserDefaults.standard.set(count + 1, forKey: PreAutoVipPayCount)
//            UserDefaults.standard.synchronize()
//            ESBaseTool.instance.adsPlayState = state
//            ESBaseTool.instance.preMethod = .vip_auto
//            ESBaseTool.instance.preSource = source
//            let vc = PremiumController()
//            vc.modalPresentationStyle = .fullScreen
//            controller.present(vc, animated: true)
//        }
//    }
}
