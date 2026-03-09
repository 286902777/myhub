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
    case homeExpose = "KtMcPuTGNu"
    case homeChannelExpose = "lLRpJsDnvK"
    case homeHistoryExpose = "XfFT"
    case cloudpageExpose = "xOKJ"
    case landpageExpose = "LEBokHR"
    case landpageFail = "aqEnefl"
    case landpageUploadedExpose = "voBe"
    case playStartAll = "hxLqpY"
    case playSource = "VgY"
    case playSuc = "NIzy"
    case playFail = "cMNAfJ"
    case adsreqPlacement = "kUEL"
    case adsreqSuc = "vac"
    case adsreqFail = "ePfmh"
    case adsneedShow = "FkXOIJ"
    case adsshowPlacement = "sFkGxw"
    case adsshowFail = "DcsU"
    case adsclick = "uhj"
    case historyExpose = "gIUJ"
    case historyClick = "zKuGvJH"
    case deeplinkOpen = "BGUGg"
    case channellistExpose = "CwzluBD"
    case channellistClick = "ENsHnRSZVY"
    case channelpageExpose = "hEJh"
    
    case shareClick = "XNphvtULkM"
    case downloadpageExpose = "fnYuXergDg"
    case downloadSuc = "bVnIAIij"
    case downloadFail = "cHUSG"
    case downloadClick = "nghUQP"
    case uploadpageExpose = "oEqUeltWuf"
    case uploadSuc = "SNZD"
    case uploadFail = "vsrAWzFWiW"
    case uploadClick = "HZEGUb"

    case loginPageExpose = "yLk"
    case loginClick = "JQR"
    case loginSuc = "RPPdVxTPct"
    case loginFail = "RQrPS"
    case logout = "KjTBPycn"
    
    case premiumVipExpose = "QOqV"
    case premiumVipClick = "zLFqPYKGA"
    case premiumVipSuc = "opzqyUov"
    case premiumVipFail = "MZyCXKYU"
    
    case install = "install"
    case max = "ads"
    case session = "session"
}

enum EventParaName: String {
    case value = "uzIelRWW"
    case type = "AsipS"
    case method = "wdw"
    case source = "uVxxp"
    case code = "tcjVUeEx"
    case history = "vpApGgRGL"
    case iplayerUid = "ESNn"
    case iplayerEmail = "ZFHT"
    case iplayerLinkid = "VoAyg"
    case iplayerResource = "xATaYnw"
    case iplayerRecentEmail = "SfznYMKuGR"
    case iplayerRecentUid = "Rko"
    case channelPlatform = "ENkB"
    case iplayerUser = "HsmdaSQSGW"
    case linkSource = "uLsjfBMj"
    case isFirstLink = "SEGOrUgeC"
    case adCount = "swUuWnhoL"
    case isNewUser = "NEGEBf"
    case adType = "KAOmDPoJ"
    case entrance = "IIXO"
    case landpageLinkId = "aoRFoLMezC"
    case cloudTotal = "FcAAC"
    case cloudUse = "WFWhOWlthN"
    case reason = "WxfwPrhNM"
    case commonLin = "aRn"
    case vip_popup = "ZubKrZV"
    case vip_auto = "xlEtY"
}

enum EventParaValue: String {
    case noPading = "no_pading"
    case history = "vKVPL"
    case home = "dYJvb"
    case list = "zDoi"
    case recommend = "bThaB"
    case lifeTime = "MyWAOm"
    case year = "jGUF"
    case weak = "latGQjsTx"
    case vip_page = "tzlfhxfNPT"
    case vip_click = "XqJFH"
    case vip_playPage = "NuVtn"
    case vip_chennelPage = "rnIyviei"
    case vip_landPage = "LHhuo"
    case vip_Ad = "udAFtZiml"
    case vip_Accelerate = "GGxFhBKs"
    case delayLink = "LFLpIPahYN"
    case link = "pPFOxSa"
    case box = "XuN"
    case cash = "bovtB"
    case quick = " "
}

enum EventType {
    case install, session, ad, custom // install, session, ad, cus
}

class TbaManager {
    static let instance = TbaManager()
    
    let hostUrl = "https://xzzx.sdf.com/cc/nn"

    var uploadList: [[String: Any]] = UserDefaults.standard.value(forKey: EventUploadArray) == nil ? [] : UserDefaults.standard.value(forKey: EventUploadArray) as! [[String: Any]] {
        didSet {
            UserDefaults.standard.set(uploadList, forKey: EventUploadArray)
        }
    }

    func configInit() {
//        self.uploadList.forEach { data in
//            if let da = data["brett"] as? String, let i = Double(da) {
//                let d = Date(timeIntervalSince1970: i / 1000)
//                if d.isThreeDay(Date()) == false {
//                    self.startEventUpload(data)
//                }
//            }
//        }
//        self.uploadList.removeAll()
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
        var request: URLRequest = URLRequest(url: URL(string: hostUrl)!)
        request.timeoutInterval = 12
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("mcc", forHTTPHeaderField: "rot") // operator
        request.setValue(self.distinctId(), forHTTPHeaderField: "chosen") // distinct_id

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
                if para["ticklish"] as? String == EventName.landpageExpose.rawValue {
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
//        Analytics.logEvent(event.rawValue, parameters: paramter)
//        self.startEventUpload(self.addEventConfig(type: type, event: event, paramter: paramter))
    }
    
    func addEventConfig(type: EventType, event: EventName, paramter: [String: Any]?) -> [String: Any] {
        var paras: [String: Any] = [:]
        paras["ella"] = HUB_BuildId
        paras["mph"] = "abetted" // {“benny”: “android”, “abetted”: “ios”, “elude”: “web”, “prior”: “macos”, “flexible”: “windows”}
        paras["con"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        paras["chosen"] = self.distinctId() // 用户排重字段，统计涉及到的排重用户数就是依据该字段，对接时需要和产品确认
        paras["novo"] = self.idfa()
        paras["soupy"] = UUID().uuidString // 日志唯一id，用于排重日志
        paras["brett"] = "\(Int(Date().timeIntervalSince1970 * 1000))"
        paras["boris"] = "Apple"
        paras["careful"] = self.iPhoneSysInfo() // 手机型号
        paras["leaky"] = UIDevice.current.systemVersion
        paras["rot"] = "mcc"
        paras["cheney"] = "\(Locale.current.languageCode ?? "en")_\(Locale.current.regionCode ?? "EN")"
        paras["hazel"] = self.idfv()

        let email = UserDefaults.standard.string(forKey: EventSaveEmail)
        let userId = UserDefaults.standard.string(forKey: EventSaveUserId)
        let linkId = UserDefaults.standard.string(forKey: EventSaveLinkId)
        let platform = UserDefaults.standard.string(forKey: EventSavePlatform) ?? ""

        let channel_platform: String = HUB_PlatformType(rawValue: platform) == .cash ? EventParaValue.cash.rawValue : EventParaValue.quick.rawValue

        // MARK: - 全局参数
        let decaturParas: [String: Any] = [
            "\(EventParaName.iplayerUid.rawValue)": userId ?? "", // iplayer_uid
            "\(EventParaName.iplayerEmail.rawValue)": email ?? "", // iplayer_email
            "\(EventParaName.iplayerLinkid.rawValue)": linkId ?? "", // iplayer_linkid
            "\(EventParaName.iplayerResource.rawValue)": HubTool.share.fileId, // iplayer_resource
            "\(EventParaName.iplayerRecentEmail.rawValue)": email ?? "", // iplayer_recent_email
            "\(EventParaName.channelPlatform.rawValue)": channel_platform,// channel_platform = quick/cash/PONslcD
            "EvIvAh": HubTool.share.isSim, // sim
            "PzR": HubTool.share.isEmulator, // simulator
            "vkeMwVs": HubTool.share.isVpn, //vpn
            "lweGSV": HubTool.share.isPod, //pad
        ]
        
        paras["absolve"] = decaturParas
        
        switch type {
        case .install:
            paras["ticklish"] = "herself"
            paras["occur"] = "build/\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "1.0.0")" // 系统构建版本，Build.ID， 以 build/ 开头
            paras["ego"] = ""// webview中的user_agent, 注意为webview的，android中的useragent有;wv关键字
            paras["colloq"] = "remote" // 用户是否启用了限制跟踪，0: 没有限制，1: 限制了；映射关系: {“evzone”: 0, “remote”: 1}
            paras["nichols"] = 0
            paras["excerpt"] = 0
            paras["bowditch"] = 0
            paras["leadeth"] = 0
            paras["veer"] = 0
            paras["okra"] = 0
        case .session:
            paras["ticklish"] = "addict"
        case .ad:
            paras["ticklish"] = "hanukkah"
            if let paramter = paramter {
                for item in paramter.keys {
                    paras[item] = paramter[item]
                }
            }
        case .custom:
            paras["ticklish"] = event.rawValue
            paras["our"] = paramter
        }
        return paras
    }
    
    func adsValueInfos(value: Double, currency: String, source: String, platform: String, unitid: String, placement: String, format: String) -> [String: Any] {
        let param: [String: Any] = [
            "idly": value, // 预估收益, admob取出来的值可以直接使用（x/10^6）=> 美元， Max的值为美元, 需要 * 10^6在上报
            "upward": currency, // 预估收益的货币单位
            "tass": source, // 广告网络，广告真实的填充平台，例如admob的bidding，填充了Facebook的广告，此值为Facebook
            "hyacinth": platform, // 广告SDK，admob，max等
            "adequacy": unitid, // 广告位id，例如: ca-app-pub-7068043263440714/75724612
            "exponent": placement, // 广告位逻辑编号，例如: page1_bottom, connect_finished
            "charity": format // 广告类型，插屏，原生，banner，激励视频等
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
