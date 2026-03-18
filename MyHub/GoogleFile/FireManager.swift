//
//  FireManager.swift
//  MyHub
//
//  Created by hub on 3/5/26.
//

import Foundation
import HandyJSON
import FirebaseRemoteConfig

class FireManager {
    static let share = FireManager()
    var deConfig = RemoteConfig.remoteConfig()
    var total: Int = 0
    
    func setConfig() {
        var data = ""
        let path = Bundle.main.path(forResource: "GoogleAds", ofType: "json")
        if let p = path {
            guard let dj = try? Data(contentsOf: URL(fileURLWithPath: p)) else { return }
            data = dj.base64EncodedString()
        }
        
        deConfig.configSettings = RemoteConfigSettings()
//        deConfig.setDefaults(["premuim_config": "" as NSObject])
        deConfig.configSettings.minimumFetchInterval = 5000
        deConfig.setDefaults(["MyHub_Ads": data as NSObject])
        self.initData()
    }
    
    private func initData() {
        deConfig.fetch(withExpirationDuration: 0) { [weak self] info, err in
            guard let self = self else { return }
            guard let _ = err else {
                self.deConfig.activate { suc, error in
                    guard let _ = error else {
                        DispatchQueue.main.async {
                            self.total = 1
                            let json: String = self.deConfig["MyHub_Ads"].stringValue
                            if json.count > 0 {
                                if let mod = GoogleAdsFireData.deserialize(from: json) {
                                    GoogleManager.share.startData = mod
                                }
                            }
                            let plusJson: String = self.deConfig["MyHub_Two_Ads"].stringValue
                            if plusJson.count > 0 {
                                if let mod = GoogleAdsFireData.deserialize(from: plusJson) {
                                    GoogleManager.share.listData.append(GoogleManager.share.mapAdsData(mod.plus, .plus))
                                }
                            }
                            let threeJson: String = self.deConfig["MyHub_Three_Ads"].stringValue
                            if threeJson.count > 0 {
                                if let mod = GoogleAdsFireData.deserialize(from: threeJson) {
                                    GoogleManager.share.listData.append(GoogleManager.share.mapAdsData(mod.three, .three))
                                }
                            }
                            //                        let deepInfo: String = self.deConfig["deep_Permission"].stringValue
                            //                        if deepInfo.count > 0 {
                            //                            if let mod = TR_ConfigModel.deserialize(from: deepInfo) {
                            //                                SystemManager.share.configModel = mod
                            //                            }
                            //                        }
                            //                        let premuimInfo: String = self.deConfig["premuim_config"].stringValue
                            //                        if premuimInfo.count > 0 {
                            //                            UserDefaults.standard.set(premuimInfo, forKey: premuimInfoKey)
                            //                            if let mod = TR_PayListData.deserialize(from: premuimInfo) {
                            //                                TR_PayManager.share.productDatas = mod.subscription_items.sorted(by: {$0.order < $1.order})
                            //                                TR_PayManager.share.defaultProduct = TR_PayManager.share.productDatas.first(where: {$0.isSelect == true})?.product_id ?? ""
                            //                                guard let _ = TR_PayManager.share.productDatas.first(where: {$0.isSelect == true}) else {
                            //                                    TR_PayManager.share.productDatas.first?.isSelect = true
                            //                                    TR_PayManager.share.defaultProduct = TR_PayManager.share.productDatas.first(where: {$0.isSelect == true})?.product_id ?? ""
                            //                                    TR_PayManager.share.getAppPayReceipt(type: .refresh)
                            //                                    return
                            //                                }
                            //                                TR_PayManager.share.getAppPayReceipt(type: .refresh)
                            //                            }
                            //                        }
                            //
                            //                        let gameInfo: String = self.deConfig["game_config"].stringValue
                            //                        if gameInfo.count > 0 {
                            //                            if let mod = TR_GameModel.deserialize(from: gameInfo) {
                            //                                SystemManager.share.gameCount = mod.num
                            //                                SystemManager.share.isShowGame = mod.show != 0
                            //                            }
                            //                        }
                        }
                        return
                    }
                }
                return
            }
            if self.total == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.initData()
                }
            }
        }
    }
}
