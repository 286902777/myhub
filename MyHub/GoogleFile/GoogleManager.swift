//
//  GoogleManager.swift
//  MyHub
//
//  Created by hub on 3/6/26.
//

import Foundation
import AppLovinSDK
import GoogleMobileAds
import HandyJSON

class GoogleManager: NSObject {
    static let share = GoogleManager()
    var playTime: TimeInterval = 0
    
    var playMiddleTime: Int = 600
    var spaceTime: Int = 60
    var startTime: Int = 7
    var playingIndex: Int = 5
    var playingTime: Int = 10
    var playMethod: Int = 0
    var playNativeTime: Int = 7
    var playNativeClickRate: Int = 60
    var nativeTime: Int = 7
    var nativeClickRate: Int = 60
    var s_nativeTime: Int = 7
    var s_nativeClickRate: Int = 60
    
    var nativeView: MANativeAdView?
    var maxNaLoad: MANativeAdLoader?
    
    var admobLoader: AdLoader?
    
    var showMode: AdsShowMode = .play
    var isPlayingAds: Bool = false
    var admobNativeView: NativeAdView?
    
    var successComplete: (() -> Void)?
    
    var cacheArray: [String: GoogleAdsCacheData] = [:]
    var listData: [GoogleAdsListData] = []
    var installed: Bool = false
    var nativeList: [String] = []
    private let accessQueue = DispatchQueue(label: "com.safelist.queue")
    
    var addNativeDate: TimeInterval?
    var startData: GoogleAdsFireData = GoogleAdsFireData() {
        didSet {
            self.listData.removeAll()
            self.startTime = self.startData.startTime
            self.spaceTime = self.startData.spaceTime
            self.playMiddleTime = self.startData.playMiddleTime
            self.nativeTime = self.startData.nativeTime
            self.nativeClickRate = self.startData.nativeClickRate
            self.playingIndex = self.startData.playingIndex
            self.playingTime = self.startData.playingTime
            self.playMethod = self.startData.playMethod
            self.playNativeTime = self.startData.playNativeTime
            self.playNativeClickRate = self.startData.playNativeClickRate
            self.s_nativeTime = self.startData.s_NativeTime
            self.s_nativeClickRate = self.startData.s_NativeClickRate
            self.listData.append(self.mapAdsData(self.startData.play, .play))
            self.listData.append(self.mapAdsData(self.startData.playing, .playing))
        }
    }
    
    func mapAdsData(_ arr: [GoogleAdsData], _ mode: AdsShowMode) -> GoogleAdsListData {
        let mod = GoogleAdsListData()
        mod.lists = arr.sorted(by: {$0.index > $1.index})
        mod.playMode = mode
        return mod
    }
    
    func readAdsFile() {
        let path = Bundle.main.path(forResource: "GoogleAds", ofType: "json")
        if let p = path {
            guard let dj = try? Data(contentsOf: URL(fileURLWithPath: p)) else { return }
            if let json = try? JSONSerialization.jsonObject(with: dj) as? [String: Any], let mod = GoogleAdsFireData.deserialize(from: json) {
                self.startData = mod
            }
        }
    }
    
    func postDismiss() {
        HubTool.share.showAdomb = false
        NotificationCenter.default.post(name: Noti_DismissAds, object: nil, userInfo: nil)
    }
}

extension GoogleManager {
    
    // MARK: - 写入操作 (Dispatch Barrier 确保独占访问)
    func safeAppend(_ element: String) {
        self.nativeList.append(element)
    }
    
    func safeRemove(_ adsId: String) {
        // 在 barrier block 内部，可以安全地检查索引有效性
        self.nativeList = self.nativeList.filter({$0 != adsId})
        print("App -  广告加载 showList:", self.nativeList)
    }
    
    func safeRemoveAll() {
        self.nativeList.removeAll()
    }
    
    func insertCacheModel(_ adsId: String, _ item: GoogleAdsCacheData) {
        print("--------------------addinsertCache---\(adsId)----\(item.mode.rawValue)")
        guard self.cacheArray.keys.contains(adsId) else {
            self.cacheArray.updateValue(item, forKey: adsId)
            return
        }
    }
    
    func deleteCache(_ adsId: String) {
        print("--------------------adddeleteCache\(adsId)")
        self.cacheArray.removeValue(forKey: adsId)
    }
    
    func reSetAdsData() {
        self.playTime = Date().timeIntervalSince1970
    }
    
    func refreshCache() {
        let t = Date().timeIntervalSince1970
        var adsList: [String] = []
        for (key, value) in self.cacheArray {
            if (t - value.time < 3500) {
                adsList.append(key)
            }
        }
        adsList.forEach { key in
            self.cacheArray.removeValue(forKey: key)
        }
    }
    
    func getCacheData(_ adsId: String) -> GoogleAdsCacheData? {
        return self.cacheArray[adsId]
    }
    
    func loadNativeAd(mode: AdsShowMode, index: Int, adsId: String) {
        if let d = addNativeDate {
            let date = Date().timeIntervalSince1970
            if date - d > 30 {
                self.safeRemoveAll()
            } else {
                self.addNativeDate = Date().timeIntervalSince1970
                if self.nativeList.contains(adsId) {
                    return
                }
                self.safeAppend(adsId)
                if self.nativeList.count == 1 {
                    self.requestNative(adsId)
                }
                print("App -  广告加载 ++++++++++")
                return
            }
        }
        if self.nativeList.contains(adsId) {
            return
        }
        self.safeAppend(adsId)
        self.addNativeDate = Date().timeIntervalSince1970
        self.requestNative(adsId)
    }
    
    func requestNative(_ adsId: String) {
        print("App -  广告加载", adsId)
        let option = NativeAdViewAdOptions()
        option.preferredAdChoicesPosition = .topRightCorner
        self.admobLoader = AdLoader(adUnitID: adsId, rootViewController: HubTool.share.keyVC(), adTypes: [.native], options: [option])
        self.admobLoader?.delegate = self
        self.admobLoader?.load(Request())
    }
}

extension GoogleManager {
    func uploadAdsValue(_ para: [String: Any]) {
        TbaManager.instance.addEvent(type: .ad, event: .max, paramter: para)
    }
    
    func disPlay(_ mode: AdsShowMode, complete: @escaping(Bool, FullScreenPresentingAd?, Bool) -> Void) {
        complete(false, nil, false)
        return
        let date = Date().timeIntervalSince1970
        if mode != .playing {
            self.isPlayingAds = false
            if Int(ceil(date - self.playTime)) < self.spaceTime {
                complete(false, nil, false)
                return
            }
        } else {
            self.isPlayingAds = true
        }
        
        TbaManager.instance.addEvent(type: .custom, event: .adsneedShow, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        
        self.showMode = mode
        var found: Bool = false
        var data: GoogleAdsCacheData?
        var twoData: GoogleAdsCacheData?
        if let item = self.listData.first(where: {$0.playMode == self.showMode}) {
            for m in item.lists {
                if let d = self.getCacheData(m.id) {
                    found = true
                    data = d
                }
                if let td  = self.getCacheData(m.s_id) {
                    found = true
                    twoData = td
                }
                if found {
                    break
                }
            }
            if found == false {
                TbaManager.instance.addEvent(type: .custom, event: .adsshowFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1", EventParaName.code.rawValue: EventParaValue.noPading.rawValue])
                self.admobMaxLoad(self.showMode)
                complete(false, nil, !(self.showMode == .plus || self.showMode == .three))
                return
            }
        }
        if data == nil, twoData != nil {
            data = twoData
            twoData = nil
        }
        guard let item = data else {
            self.admobMaxLoad(self.showMode)
            complete(false, nil, false)
            return
        }
        
        switch item.source {
        case .admob:
            if let ad = item.ad as? AppOpenAd {
                ad.fullScreenContentDelegate = self
                complete(true, ad, true)
            } else if let ad = item.ad as? InterstitialAd {
                ad.fullScreenContentDelegate = self
                complete(true, ad, true)
            } else if let ad = item.ad as? RewardedAd {
                ad.fullScreenContentDelegate = self
                complete(true, ad, true)
            } else if let ad = item.ad as? RewardedInterstitialAd {
                ad.fullScreenContentDelegate = self
                complete(true, ad, true)
            } else if let ad = item.ad as? NativeAd {
                DispatchQueue.main.async {
                    if let vc = HubTool.share.keyVC(), vc.isKind(of: GoogleNativeController.self) || HubTool.share.showAdomb == true {
                        complete(false, nil, true)
                        return
                    }
                    let vc = GoogleNativeController()
                    vc.adContent = ad
                    if let twoItem = twoData, let t_ad = twoItem.ad as? NativeAd {
                        vc.s_adContent = t_ad
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    HubTool.share.keyVC()?.present(vc, animated: false)
                    complete(true, nil, true)
                }
            }
        case .max:
            if (item.ad as? MAInterstitialAd)?.isReady == true {
                (item.ad as? MAInterstitialAd)?.show()
                complete(true, nil, true)
            } else if (item.ad as? MAAppOpenAd)?.isReady == true {
                (item.ad as? MAAppOpenAd)?.show()
                complete(true, nil, true)
            } else if (item.ad as? MARewardedAd)?.isReady == true {
                (item.ad as? MARewardedAd)?.show()
                complete(true, nil, true)
            }
        }
    }
    
    func admobMaxLoad(_ mode: AdsShowMode, _ idx: Int = 0) {
        if PayManager.instance.isVip {
            return
        }
        guard HubTool.share.toPay == false else {
            return
        }
        
        if let item = self.listData.first(where: {$0.playMode == mode}), idx < item.lists.count {
            let model = item.lists[idx]
            print("--------------------add__\(mode.rawValue)__\(model.id)")
            if let _ = self.getCacheData(model.id) {
                return
            } else {
                switch model.type {
                case .open:
                    self.OpenAds(mode, idx, model)
                case .interstitial:
                    self.InterstitialAds(mode, idx, model)
                case .rewarded:
                    self.RewardedAds(mode, idx, model)
                case .native:
                    self.loadNativeAd(mode: mode, index: idx, adsId: model.id)
                    if model.s_id.count > 0 {
                        self.loadNativeAd(mode: mode, index: idx, adsId: model.s_id)
                    }
                }
            }
        }
    }
    
    func InterstitialAds(_ mode: AdsShowMode, _ idx: Int, _ model: GoogleAdsData) {
        switch model.source {
        case .admob:
            let quest = Request()
            InterstitialAd.load(with: model.id, request: quest) { [weak self] info, error in
                guard let self = self else { return }
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                if let e = error {
                    TbaManager.instance.addEvent(type: .custom, event: .adsreqFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1", EventParaName.code.rawValue: "\(e.localizedDescription)"])
                    TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: "\(e.localizedDescription)"])

                    print(error.debugDescription, error?.localizedDescription ?? "")
                    print("App -  广告加载失败 type: \(mode.rawValue) 优先级: \(idx + 1), id: \(model.id)")
                    self.admobMaxLoad(mode, idx + 1)
                    return
                }
                print("App -  广告加载成功 placementid: \(model.id)")
                TbaManager.instance.addEvent(type: .custom, event: .adsreqSuc, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: EventParaValue.success.rawValue])

                if let adData = info {
                    let cacheM = GoogleAdsCacheData()
                    cacheM.id = model.id
                    cacheM.index = model.index
                    cacheM.source = model.source
                    cacheM.mode = mode
                    cacheM.ad = adData
                    cacheM.adsType = model.type
                    self.insertCacheModel(model.id, cacheM)
                    if mode == .play {
                        self.successComplete?()
                    }
                    adData.paidEventHandler = { value in
                        let nvalue = value.value.doubleValue * 1000000
                        let currencyCode = value.currencyCode
                        let p: String = mode.rawValue
                        
                        let para = TbaManager.instance.adsValueInfos(value: nvalue, currency: currencyCode, source: adData.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", platform: "admob", unitid: adData.adUnitID, placement: "", format: p)
                        self.uploadAdsValue(para)
                        self.adsEvent(nvalue)
                    }
                } else {
                    self.admobMaxLoad(mode, idx + 1)
                }
            }
        case .max:
            if let mod = self.listData.first(where: {$0.playMode == mode}) {
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                mod.ad = MAInterstitialAd(adUnitIdentifier: model.id)
                (mod.ad as? MAInterstitialAd)?.revenueDelegate = self
                (mod.ad as? MAInterstitialAd)?.delegate = self
                (mod.ad as? MAInterstitialAd)?.load()
            }
        }
    }
    
    func OpenAds(_ mode: AdsShowMode, _ idx: Int, _ model: GoogleAdsData) {
        switch model.source {
        case .admob:
            let quest = Request()
            AppOpenAd.load(with: model.id, request: quest) { [weak self] info, error in
                guard let self = self else { return }
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                if let e = error {
                    TbaManager.instance.addEvent(type: .custom, event: .adsreqFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1", EventParaName.code.rawValue: "\(e.localizedDescription)"])
                    TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: "\(e.localizedDescription)"])
                    print("App -  广告加载失败 type: \(mode.rawValue) 优先级: \(idx + 1), id: \(model.id)")
                    self.admobMaxLoad(mode, idx + 1)
                    return
                }
                TbaManager.instance.addEvent(type: .custom, event: .adsreqSuc, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: EventParaValue.success.rawValue])
                if let adData = info {
                    let cacheM = GoogleAdsCacheData()
                    cacheM.id = model.id
                    cacheM.index = model.index
                    cacheM.source = model.source
                    cacheM.mode = mode
                    cacheM.ad = adData
                    cacheM.adsType = model.type
                    self.insertCacheModel(model.id, cacheM)
                    if mode == .play {
                        self.successComplete?()
                    }
                    adData.paidEventHandler = { value in
                        let nvalue = value.value.doubleValue * 1000000
                        let currencyCode = value.currencyCode
                        let p: String = mode.rawValue
                        let para = TbaManager.instance.adsValueInfos(value: nvalue, currency: currencyCode, source: adData.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", platform: "admob", unitid: adData.adUnitID, placement: "", format: p)
                        self.uploadAdsValue(para)
                        self.adsEvent(nvalue)
                    }
                } else {
                    self.admobMaxLoad(mode, idx + 1)
                }
            }
            break
        case .max:
            if let mod = self.listData.first(where: {$0.playMode == mode}) {
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                mod.ad = MAAppOpenAd(adUnitIdentifier: model.id)
                (mod.ad as? MAAppOpenAd)?.revenueDelegate = self
                (mod.ad as? MAAppOpenAd)?.delegate = self
                (mod.ad as? MAAppOpenAd)?.load()
            }
        }
    }
    
    func RewardedAds(_ mode: AdsShowMode, _ idx: Int, _ model: GoogleAdsData) {
        switch model.source {
        case .admob:
            let quest = Request()
            RewardedAd.load(with: model.id, request: quest) { [weak self] info, error in
                guard let self = self else { return }
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                if let e = error {
                    TbaManager.instance.addEvent(type: .custom, event: .adsreqFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1", EventParaName.code.rawValue: "\(e.localizedDescription)"])
                    TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: "\(e.localizedDescription)"])
                    print("App -  广告加载失败 type: \(mode.rawValue) 优先级: \(idx + 1), id: \(model.id)")
                    self.admobMaxLoad(mode, idx + 1)
                    return
                }
                TbaManager.instance.addEvent(type: .custom, event: .adsreqSuc, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: model.id, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: EventParaValue.success.rawValue])
                if let adData = info {
                    let cacheM = GoogleAdsCacheData()
                    cacheM.id = model.id
                    cacheM.index = model.index
                    cacheM.source = model.source
                    cacheM.mode = mode
                    cacheM.ad = adData
                    cacheM.adsType = model.type
                    self.insertCacheModel(model.id, cacheM)
                    if mode == .play {
                        self.successComplete?()
                    }
                    adData.paidEventHandler = { value in
                        let nvalue = value.value.doubleValue * 1000000
                        let currencyCode = value.currencyCode
                        let p: String = mode.rawValue
                        
                        let para = TbaManager.instance.adsValueInfos(value: nvalue, currency: currencyCode, source: adData.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", platform: "admob", unitid: adData.adUnitID, placement: "", format: p)
                        self.uploadAdsValue(para)
                        self.adsEvent(nvalue)
                    }
                } else {
                    self.admobMaxLoad(mode, idx + 1)
                }
            }
            break
        case .max:
            if let mod = self.listData.first(where: {$0.playMode == mode}) {
                TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: mode == .plus ? "2" : "1"])
                
                mod.ad =  MARewardedAd.shared(withAdUnitIdentifier: model.id)
                (mod.ad as? MARewardedAd)?.revenueDelegate = self
                (mod.ad as? MARewardedAd)?.delegate = self
                (mod.ad as? MARewardedAd)?.load()
            }
        }
    }
}

// MARK: - admob native
extension GoogleManager: NativeAdLoaderDelegate, NativeAdDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        print("App -  广告加载成功 placementid: \(adLoader.adUnitID)")
        self.safeRemove(adLoader.adUnitID)
        print("App -  广告加载 unShowList:", self.nativeList)
        if let adsId = self.nativeList.first {
            self.requestNative(adsId)
        }
        TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        TbaManager.instance.addEvent(type: .custom, event: .adsreqSuc, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: adLoader.adUnitID, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue:  EventParaValue.success.rawValue])
        let cacheModel = GoogleAdsCacheData()
        cacheModel.id = adLoader.adUnitID
        cacheModel.ad = nativeAd
        cacheModel.adsType = .native
        self.insertCacheModel(adLoader.adUnitID, cacheModel)
        nativeAd.paidEventHandler = { value in
            let nvalue = value.value.doubleValue * 1000000
            let currencyCode = value.currencyCode
            let p: String = self.showMode.rawValue
            let para = TbaManager.instance.adsValueInfos(value: nvalue, currency: currencyCode, source: nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", platform: "admob", unitid: adLoader.adUnitID, placement: "", format: p)
            self.uploadAdsValue(para)
            self.adsEvent(nvalue)
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        print("App -  广告加载失败 placementid: \(adLoader.adUnitID)")
        self.safeRemove(adLoader.adUnitID)
        print("App -  广告加载 showList:", self.nativeList)
        if let adsId = self.nativeList.first {
            self.requestNative(adsId)
        }
        TbaManager.instance.addEvent(type: .custom, event: .adsreqPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: adLoader.adUnitID, EventParaName.adSource.rawValue: EventParaValue.admob.rawValue, EventParaName.result.rawValue: "\(error.localizedDescription)"])
        TbaManager.instance.addEvent(type: .custom, event: .adsreqFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1", EventParaName.code.rawValue: "\(error.localizedDescription)"])
        self.listData.forEach({ item in
            for (idx, m) in item.lists.enumerated() {
                if m.id == adLoader.adUnitID || m.s_id == adLoader.adUnitID {
                    self.admobMaxLoad(item.playMode, idx + 1)
                    return
                }
            }
        })
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("xxxx")
        NotificationCenter.default.post(name: Noti_ClickNativeAds, object: nil, userInfo: nil)
        TbaManager.instance.addEvent(type: .custom, event: .adsclick, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        
    }
}

extension GoogleManager: MAAdViewAdDelegate, MARewardedAdDelegate, MAAdRevenueDelegate, FullScreenContentDelegate {
    // admob
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("App -  Ad did fail to present full screen content.")
        TbaManager.instance.addEvent(type: .custom, event: .adsshowFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1", EventParaName.code.rawValue: "\(error.localizedDescription)"])
        self.closeAdSuccess()
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("success")
        NotificationCenter.default.post(name: Noti_ShowAds, object: nil, userInfo: nil)
        HubTool.share.showAdomb = true
        TbaManager.instance.addEvent(type: .custom, event: .adsshowPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        TbaManager.instance.addEvent(type: .custom, event: .adsclick, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("close --- admob")
        self.closeAdSuccess()
    }
    
    func didExpand(_ ad: MAAd) {
        print("App -  didExpand")
    }
    
    func didCollapse(_ ad: MAAd) {
        print("App -  didCollapse")
    }
    
    func didLoad(_ ad: MAAd) {
        print("App -  didLoad")
        if self.showMode == .play {
            self.successComplete?()
        }
        
        print("App -  广告加载成功 placementid: \(ad.adUnitIdentifier)")
        TbaManager.instance.addEvent(type: .custom, event: .adsreqSuc, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: self.showMode == .plus ? "2" : "1"])
        TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: ad.adUnitIdentifier, EventParaName.adSource.rawValue: EventParaValue.max.rawValue, EventParaName.result.rawValue: EventParaValue.success.rawValue])
        for item in self.listData {
            item.lists.forEach { m in
                if m.id == ad.adUnitIdentifier {
                    let cModel = GoogleAdsCacheData()
                    cModel.id = ad.adUnitIdentifier
                    cModel.source = .max
                    cModel.ad = item.ad
                    cModel.adsType = (cModel.ad as? MARewardedAd) == nil ? .open : .rewarded
                    self.insertCacheModel(ad.adUnitIdentifier, cModel)
                    return
                }
            }
        }
    }
    
    func didClick(_ ad: MAAd) {
        print("App -  didClick")
        TbaManager.instance.addEvent(type: .custom, event: .adsclick, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: self.showMode == .plus ? "2" : "1"])
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("App -  didFailToLoadAd: adUnitIdentifier: \(adUnitIdentifier), error: \(error.mediatedNetworkErrorCode) \(error.message)")
        self.listData.forEach({ mod in
            if let item = mod.lists.first(where: {$0.id == adUnitIdentifier}) {
                TbaManager.instance.addEvent(type: .custom, event: .adsreqFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: self.showMode == .plus ? "2" : "1", EventParaName.code.rawValue: "\(error.message)"])
                TbaManager.instance.addEvent(type: .custom, event: .adResult, paramter: [EventParaName.adId.rawValue: adUnitIdentifier, EventParaName.adSource.rawValue: EventParaValue.max.rawValue, EventParaName.result.rawValue: "\(error.message)"])
                print("App -  广告加载失败 type: \(mod.playMode.rawValue) 优先级: \(item.index + 1), placementid: \(adUnitIdentifier)")
                self.admobMaxLoad(mod.playMode, item.index + 1)
                return
            }
        })
    }
    
    func didDisplay(_ ad: MAAd) {
        print("App -  didDisplay")
        HubTool.share.showAdomb = true
        NotificationCenter.default.post(name: Noti_ShowAds, object: nil, userInfo: nil)
        TbaManager.instance.addEvent(type: .custom, event: .adsshowPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: self.showMode == .plus ? "2" : "1"])
    }
    
    func didHide(_ ad: MAAd) {
        print("App -  didHide")
        print("close --- MAX")
        self.closeAdSuccess()
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("App -  didFailtoDisplay, error: \(error)")
        TbaManager.instance.addEvent(type: .custom, event: .adsshowFail, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: self.showMode == .plus ? "2" : "1", EventParaName.code.rawValue: "\(error.message)"])
        self.closeAdSuccess()
    }
    
    func didPayRevenue(for ad: MAAd) {
        print("App -  didPayRevenue")
        let revenue = ad.revenue * 1000000 // In USD
        let adUnitId = ad.adUnitIdentifier // The MAX Ad Unit ID
        let networkName = ad.networkName // Display name of the network that showed the ad (e.g. "AdColony")
        let p: String = self.showMode.rawValue
        
        let para = TbaManager.instance.adsValueInfos(value: revenue, currency: "USD", source: networkName, platform: "max", unitid: adUnitId, placement: "", format: p)
        self.uploadAdsValue(para)
        self.adsEvent(revenue)
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        
    }
    
    func adsEvent(_ value: Double) {
        var result: Bool = false
        guard let linkId = UserDefaults.standard.string(forKey: EventSaveLinkId), linkId.count > 0 else { return }
        if let platform = UserDefaults.standard.string(forKey: EventSavePlatform), platform == HubTool.share.platform.rawValue {
            result = true
        }
        if result {
            let m = VideoData()
            if let userId = UserDefaults.standard.string(forKey: EventSaveUserId) {
                m.userId = userId
            }
            
            if self.showMode == .play {
                if HubTool.share.isChannelAds == false {
                    m.linkId = HubTool.share.playLinkId
                }
                m.userId = HubTool.share.playUserId
            }
            
            HttpManager.share.uploadEventApi(event: .adv_profit, currency: "USD", val: value, model: m) {[weak self] success in
                guard let self = self else { return }
                if success == false {
                    self.adsEvent(value)
                }
            }
        }
    }
    
    func closeAdSuccess() {
        HubTool.share.showAdomb = false
        var adsId: String = ""
        var adsType: AdsType = .open
        if let item = self.listData.first(where: {$0.playMode == self.showMode}) {
            for m in item.lists {
                if let d = self.getCacheData(m.id) {
                    adsId = m.id
                    adsType = d.adsType
                    break
                }
                if let td = self.getCacheData(m.s_id) {
                    adsId = m.s_id
                    adsType = td.adsType
                    break
                }
            }
        }
        guard adsId.count > 0 else { return }
        self.deleteCache(adsId)
        self.admobMaxLoad(self.showMode)
        if (self.isPlayingAds) {
            self.postDismiss()
            return
        }
        if (self.showMode == .plus || self.showMode == .three) {
            self.reSetAdsData()
            self.postDismiss()
        } else {
            playPlusAds(adsType) { [weak self] s in
                guard let self = self else { return }
                if s == false {
                    self.reSetAdsData()
                    self.postDismiss()
                }
            }
        }
    }
    
    func playPlusAds(_ adsType: AdsType, complete: @escaping(Bool) -> Void) {
        if adsType == .rewarded {
            self.showMode = .three
        } else {
            self.showMode = .plus
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            HubTool.share.show(self.showMode) { success in
                complete(success)
            }
        }
    }
}
