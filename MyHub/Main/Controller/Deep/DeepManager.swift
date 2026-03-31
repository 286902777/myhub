//
//  DeepManager.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit

class DeepManager {
    static let share = DeepManager()
    
    func openBoxDeep(linkId: String, rootVC: UIViewController) {
        let vc = BoxDeepController(linkId: linkId)
        TabbarTool.instance.displayOrHidden(false)
        HubTool.share.deepUrl = ""
        vc.clickCloseToPayBlock = {
            DispatchQueue.main.async {
                HubTool.share.preSource = .vip_home
                HubTool.share.preMethod = .vip_auto
                TabbarTool.instance.displayOrHidden(false)
                PlayTool.instance.adsPushPremium(HubTool.share.adsPlayState, .vip_Ad, rootVC)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        rootVC.present(nav, animated: false)
    }
    
    func openOtherDeep(linkId: String, uId: String, platform: HUB_PlatformType, rootVC: UIViewController) {
        if linkId.count > 0 {
            let vc = OtherDeepController(linkId: linkId)
            TabbarTool.instance.displayOrHidden(false)
            HubTool.share.deepUrl = ""
            vc.clickCloseToPayBlock = {
                DispatchQueue.main.async {
                    HubTool.share.preSource = .vip_home
                    HubTool.share.preMethod = .vip_auto
                    TabbarTool.instance.displayOrHidden(false)
                    PlayTool.instance.adsPushPremium(HubTool.share.adsPlayState, .vip_Ad, rootVC)
                }
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            rootVC.present(nav, animated: false)
        } else {
            HubTool.share.channelSource = .homeChannel
            HubTool.share.platform = platform
            let vc = PingController(uId: uId, platform: platform)
            TabbarTool.instance.displayOrHidden(false)
            HubTool.share.deepUrl = ""
            rootVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
