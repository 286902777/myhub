//
//  TbaManager.swift
//  MyHub
//
//  Created by hub on 3/6/26.
//

import Foundation
import AdSupport
import CoreTelephony
import UIKit
import FirebaseAnalytics

enum EventName: String {
    case homeExpose = "dUSxTIvT"
    case homeChannelExpose = "itmI"
    case homeHistoryExpose = "MFhoBwBelt"
    case cloudpageExpose = "KEGML"
    case landpageExpose = "ZIzYHWJRVQ"
    case landpageFail = "QFvpL"
    case landpageUploadedExpose = "rNUruNqRsH"
    case playStartAll = "bEUwNcWVIU"
    case playSource = "TWPsMDM"
    case playSuc = "vzJUSX"
    case playFail = "TmOBv"
    case adsreqPlacement = "XFtVvaQEjX"
    case adsreqSuc = "AIPdKo"
    case adsreqFail = "jLysg"
    case adsneedShow = "yVq"
    case adsshowPlacement = "PlNLcI"
    case adsshowFail = "SmqSOyHnqx"
    case adsclick = "cCB"
    case adResult = "pVTT1"
    case historyExpose = "dvVHfmkw"
    case deeplinkOpen = "ezEJGdb"
    case channellistExpose = "XoGcml"
    case channellistClick = "YXIzY"
    case channelpageExpose = "FSRpVuO"
    
//    case shareClick = "aQNzEEw"
//    case downloadpageExpose = "fnYuXergDg"
//    case downloadSuc = "bVnIAIij"
//    case downloadFail = "cHUSG"
//    case downloadClick = "nghUQP"
//    case uploadpageExpose = "oEqUeltWuf"
//    case uploadSuc = "SNZD"
//    case uploadFail = "vsrAWzFWiW"
//    case uploadClick = "HZEGUb"

    case loginPageExpose = "BQKOQgKMK"
    case loginClick = "EUq"
    case loginSuc = "YRmStAzG"
    case loginFail = "wTAr"
    case logout = "RPw"
    
    case premiumVipExpose = "Mzzrw"
    case premiumVipClick = "IOMnMsATQM"
    case premiumVipSuc = "DolmVr"
    case premiumVipFail = "tYauMz"
    
    case install = "install"
    case max = "ads"
    case session = "session"
}

enum EventParaName: String {
    case value = "GpUzBiopN"
    case type = "kfJGYbCjU"
    case method = "lksmyXiJ"
    case source = "HGxkSZ"
    case code = "IDyfH"
    case history = "evEQBeK"
    case iplayerUid = "zbYbWfdfx"
    case iplayerEmail = "XYbPkM"
    case iplayerLinkid = "PIjy"
    case iplayerResource = "xCu"
    case iplayerRecentEmail = "mGSwDq"
    case iplayerRecentUid = "UWQSHrYwRZ"
    case channelPlatform = "tTZgucgYed"
    case iplayerUser = "ZRyz"
    case linkSource = "UDeFxxrD"
    case isFirstLink = "CPKshp"
    case adCount = "dyHV"
    case isNewUser = "ZPNwwFXaoi"
    case adType = "TNA"
    case entrance = "AUqtLKQ"
    case landpageLinkId = "tvqHlD"
    case cloudTotal = "pIIsYJHbsY"
    case cloudUse = "RinoHtQe"
    case reason = "xhZuGDBQjH"
    case commonLin = "vTVUA"
    case vip_popup = "SrTJmUyh"
    case vip_auto = "QECJvibezr"
    case adId = "tltxwcami1"
    case adSource = "OYKuLp1"
    case result = "Djyn1"
}

enum EventParaValue: String {
    case noPading = "no_pading"
    case history = "gmJgWUMeT"
    case home = "iJSg"
    case list = "cPzBn"
    case recommend = "LCL"
    case lifeTime = "lrXtJZVNc"
    case year = "PwLPe"
    case weak = "sKcTXNH"
    case vip_page = "ZKiHRPq"
    case vip_click = "vyrnBPrwz"
    case vip_playPage = "qvYWiS"
    case vip_channelPage = "KwkM"
    case vip_landPage = "Eiq"
    case vip_Ad = "GdpJUF"
    case vip_Accelerate = "NzlseKW"
    case delayLink = "ayO"
    case link = "cfo"
    case box = "EHT"
    case cash = "LzgfRaO"
    case quick = "rySvz"
    case success = "zalhRImt1"
    case max = "jSt1"
    case admob = "HCFtPA1"
    case topon = "asntFYAXBQ1"
}

enum EventType {
    case install, session, ad, custom // install, session, ad, cus
}

class TbaManager {
    static let instance = TbaManager()
    
//    let hostUrl = "https://test-hilum.myhubweb.com/hoboken/litigant" // test

    let hostUrl = "https://hilum.myhubweb.com/yoke/magic"

    var uploadList: [[String: Any]] = UserDefaults.standard.value(forKey: EventUploadArray) == nil ? [] : UserDefaults.standard.value(forKey: EventUploadArray) as! [[String: Any]] {
        didSet {
            UserDefaults.standard.set(uploadList, forKey: EventUploadArray)
        }
    }

    func configInit() {
        self.uploadList.forEach { data in
            if let da = data["gig"] as? String, let i = Double(da) {
                let d = Date(timeIntervalSince1970: i / 1000)
                if d.isThreeDay(Date()) == false {
                    self.startEventUpload(data)
                }
            }
        }
        self.uploadList.removeAll()
    }
    
    func installEvent(link: Bool) {
        if link {
            if !UserDefaults.standard.bool(forKey: EventLinkInstall) {
                self.addEvent(type: .install, event: .install, paramter: nil)
                UserDefaults.standard.set(true, forKey: EventLinkInstall)
            }
        } else {
            if !UserDefaults.standard.bool(forKey: EventInstall) {
                self.addEvent(type: .install, event: .install, paramter: nil)
                UserDefaults.standard.set(true, forKey: EventInstall)
            }
        }
    }
    
    func startEventUpload(_ para: [String: Any]) {
        var request: URLRequest = URLRequest(url: URL(string: hostUrl + "?basis=" + "\(self.idfv())")!)
        request.timeoutInterval = 12
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(Int(Date().timeIntervalSince1970 * 1000))", forHTTPHeaderField: "gig") // client_ts
        request.setValue("\(UIDevice.current.systemVersion)", forHTTPHeaderField: "ritchie") // os_version

        if (JSONSerialization.isValidJSONObject(para)) {
            let body = try? JSONSerialization.data(withJSONObject: para, options: [])
            request.httpBody = body
        } else {
            return
        }
        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: request, completionHandler: {[weak self] data, response, error in
            guard error == nil, let self = self else {
                self?.uploadList.append(para)
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                debugPrint("[eventUpload] success!")
                if para["screechy"] as? String == EventName.landpageExpose.rawValue {
                    let firstLink: Bool = UserDefaults.standard.bool(forKey: FirstOpenLink)
                    if firstLink == false {
                        UserDefaults.standard.set(true, forKey: FirstOpenLink)
                        UserDefaults.standard.synchronize()
                    }
                }
            } else {
                self.uploadList.append(para)
            }
        })
        dataTask.resume()
    }
    
    func addEvent(type: EventType, event: EventName, paramter: [String: Any]?) {
        Analytics.logEvent(event.rawValue, parameters: paramter)
        self.startEventUpload(self.addEventConfig(type: type, event: event, paramter: paramter))
    }
    
    func addEventConfig(type: EventType, event: EventName, paramter: [String: Any]?) -> [String: Any] {
        var lparas: [String: Any] = [:]
        lparas["drudge"] = HUB_BuildId
        lparas["bitt"] = self.distinctId() // 用户排重字段，统计涉及到的排重用户数就是依据该字段，对接时需要和产品确认
        lparas["brutal"] = self.iPhoneSysInfo() // 手机型号
        lparas["bursitis"] = self.idfa()
        lparas["basis"] = self.idfv()
        lparas["ritchie"] = UIDevice.current.systemVersion
        
        var marjory: [String: Any] = [:]
        marjory["cortez"] = "dubhe" // 映射关系: {“saigon”: “android”, “dubhe”: “ios”, “con”: “web”, “fitful”: “macos”, “train”: “windows”}
        marjory["usage"] = "\(Locale.current.languageCode ?? "en")_\(Locale.current.regionCode ?? "EN")"
        
        var epsilon: [String: Any] = [:]
        epsilon["gaul"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        epsilon["ermine"] = UUID().uuidString // 日志唯一id，用于排重日志
        epsilon["gig"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
        epsilon["trojan"] = "mcc"

        var wilfred: [String: Any] = [:]
        wilfred["threat"] = "Apple"

        let email = UserDefaults.standard.string(forKey: EventSaveEmail)
        let userId = UserDefaults.standard.string(forKey: EventSaveUserId)
        let linkId = UserDefaults.standard.string(forKey: EventSaveLinkId)
        let platform = UserDefaults.standard.string(forKey: EventSavePlatform) ?? ""

        let channel_platform: String = HUB_PlatformType(rawValue: platform) == .cash ? EventParaValue.cash.rawValue : EventParaValue.quick.rawValue

        // MARK: - 全局参数
        let cpa: [String: Any] = [
            "\(EventParaName.iplayerUid.rawValue)": userId ?? "", // iplayer_uid
            "\(EventParaName.iplayerEmail.rawValue)": email ?? "", // iplayer_email
            "\(EventParaName.iplayerLinkid.rawValue)": linkId ?? "", // iplayer_linkid
            "\(EventParaName.iplayerResource.rawValue)": HubTool.share.fileId, // iplayer_resource
            "\(EventParaName.iplayerRecentEmail.rawValue)": email ?? "", // iplayer_recent_email
            "\(EventParaName.channelPlatform.rawValue)": channel_platform,// channel_platform = quick/cash/PONslcD
            "ROflKzbQG": HubTool.share.isSim, // sim
            "THmFN": HubTool.share.isEmulator, // simulator
            "wayCOYDI": HubTool.share.isVpn, //vpn
            "PVufZ": HubTool.share.isPod, //pad
        ]
        
        
        var paras: [String: Any] = [:]
        paras["cpa"] = cpa
        paras["l"] = lparas
        paras["marjory"] = marjory
        paras["epsilon"] = epsilon
        paras["wilfred"] = wilfred

        switch type {
        case .install:
            paras["screechy"] = "economy"
            paras["arrear"] = "build/\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "1.0.0")" // 系统构建版本，Build.ID， 以 build/ 开头
            paras["tamp"] = ""// webview中的user_agent, 注意为webview的，android中的useragent有;wv关键字
            paras["nauseum"] = HubTool.share.isTrackUser ? "talky" : "loathe"// 用户是否启用了限制跟踪，0：没有限制，1：限制了；枚举值，映射关系: {“talky”: 0, “loathe”: 1}
            paras["heavy"] = 0
            paras["club"] = 0
            paras["armco"] = 0
            paras["urology"] = 0
            paras["tachyon"] = 0
            paras["despotic"] = 0
        case .session:
            paras["screechy"] = "asbestos"
        case .ad:
            paras["screechy"] = "cushion"
            if let paramter = paramter {
                for item in paramter.keys {
                    paras[item] = paramter[item]
                }
            }
        case .custom:
            paras["screechy"] = event.rawValue
            paras["shepard"] = paramter
        }
        return paras
    }
    
    func adsValueInfos(value: Double, currency: String, source: String, platform: String, unitid: String, placement: String, format: String) -> [String: Any] {
        let param: [String: Any] = [
            "lyrebird": value, // 预估收益, admob取出来的值可以直接使用（x/10^6）=> 美元， Max的值为美元, 需要 * 10^6在上报
            "ar": currency, // 预估收益的货币单位
            "balboa": source, // 广告网络，广告真实的填充平台，例如admob的bidding，填充了Facebook的广告，此值为Facebook
            "sherrill": platform, // 广告SDK，admob，max等
            "umbrage": unitid, // 广告位id，例如: ca-app-pub-7068043263440714/75724612
            "conclude": placement, // 广告位逻辑编号，例如: page1_bottom, connect_finished
            "maureen": format // 广告类型，插屏，原生，banner，激励视频等
        ]
        Analytics.logEvent("Ad_impression_revenue", parameters: [
                          AnalyticsParameterAdPlatform: platform,
                          AnalyticsParameterAdSource: source,
                          AnalyticsParameterAdFormat: format,
                          AnalyticsParameterAdUnitName: unitid,
                          AnalyticsParameterCurrency: currency,
                          AnalyticsParameterValue: value
                        ])
        return param
    }
}

extension TbaManager {
    func idfa() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func idfv() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    func distinctId() -> String {
        if let disId = UserDefaults.standard.value(forKey: EventDistinctId) as? String {
            return disId
        } else {
            let disId = UUID().uuidString
            UserDefaults.standard.set(disId, forKey: EventDistinctId)
            return disId
        }
    }
    
    func iPhoneSysInfo() -> String {
        var info = utsname()
        uname(&info)
        let machineMirror = Mirror(reflecting: info.machine)
        let sysInfo = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return sysInfo
    }
    
    func networkName() -> String {
        var name = ""
        let info = CTTelephonyNetworkInfo()
        if let providers = info.serviceSubscriberCellularProviders {
            let values = providers.values
            if let infoName = values.first {
                name = infoName.carrierName ?? ""
            }
        }
        return name
    }
}

extension Date {
    func toYMD(_ format: String = "yyyy-MM-dd") -> String {
        let f = DateFormatter()
        f.dateFormat = format
        return f.string(from: self)
    }

    func isToDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: date)
        let cmps = calendar.dateComponents(unit, from: self)
        return (cmps.year == nowComps.year) &&
        (cmps.month == nowComps.month) &&
        (cmps.day == nowComps.day)
    }

    func isThreeDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: date)
        let cmps = calendar.dateComponents(unit, from: self)
        return ((nowComps.day ?? 0) - (cmps.day ?? 0)) >= 3
    }

    func isDayHour(_ date: Date) -> Bool { // 24 h
        let h: TimeInterval = 3600 * 24
        let diff = date.timeIntervalSince(self)
        if diff < h, diff > -h { /// 正负一小时内
            return true
        }
        return false
    }

    func isHour(_ date: Date) -> Bool {
        let h: TimeInterval = 3600
        let diff = date.timeIntervalSince(self)
        if diff < h, diff > -h { /// 正负一小时内
            return true
        }
        return false
    }
}
