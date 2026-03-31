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
        var dataInfo = ""
        let path = Bundle.main.path(forResource: "GoogleAds", ofType: "json")
        if let p = path {
            guard let d = try? Data(contentsOf: URL(fileURLWithPath: p)) else { return }
            dataInfo = d.base64EncodedString()
        }
        deConfig.configSettings = RemoteConfigSettings()
        deConfig.setDefaults(["MyHub_Vip": "" as NSObject])
        deConfig.configSettings.minimumFetchInterval = 5000
        deConfig.setDefaults(["MyHub_Ads": dataInfo as NSObject])
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
                            let cloakInfo: String = self.deConfig["MyHub_Cloak"].stringValue
                            if cloakInfo.count > 0 {
                                if let data = SimModel.deserialize(from: cloakInfo) {
                                    HubTool.share.simData = data
                                }
                            }
                            let premuimInfo: String = self.deConfig["MyHub_Vip"].stringValue
                            if premuimInfo.count > 0 {
                                UserDefaults.standard.set(premuimInfo, forKey: VipInfoKey)
                                if let mod = PayListData.deserialize(from: premuimInfo) {
                                    PayManager.instance.productDatas = mod.infoList.sorted(by: {$0.index > $1.index})
                                    let selectPro = PayManager.instance.productDatas.first(where: {$0.isSelect == true})?.product_id ?? ""
                                    PayManager.instance.defaultProduct = PayID(rawValue: selectPro) ?? .life
                                    guard let _ = PayManager.instance.productDatas.first(where: {$0.isSelect == true}) else {
                                        PayManager.instance.productDatas.first?.isSelect = true
                                        let selectPro = PayManager.instance.productDatas.first(where: {$0.isSelect == true})?.product_id ?? ""
                                        PayManager.instance.defaultProduct = PayID(rawValue: selectPro) ?? .life
                                        PayManager.instance.requestProductInfo(type: .refresh)
                                        return
                                    }
                                    PayManager.instance.requestProductInfo(type: .refresh)
                                }
                            }
                        }
                        return
                    }
                }
                return
            }
            if self.total == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                    self.initData()
                }
            }
        }
    }
}
