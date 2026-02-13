//
//  HubTool.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import AVFoundation
import Photos
import Kingfisher

let ScreenBounds = UIScreen.main.bounds

let ScreenSize = UIScreen.main.bounds.size
let ScreenHeight: CGFloat = ScreenSize.height
let ScreenWidth: CGFloat = ScreenSize.width
let CusTabBarHight: CGFloat = 84
var playRate: HUB_RateState = .one

var TopSafeH: CGFloat {
    get {
        let s = UIApplication.shared.connectedScenes.first
        guard let w = s as? UIWindowScene else { return 0}
        guard let key = w.windows.first else { return 0}
        return key.safeAreaInsets.top
    }
}

var NavBarH: CGFloat {
    get {
        return TopSafeH + 44
    }
}

var TabBarH: CGFloat {
    get {
        return BottomSafeH + 49
    }
}

var StatusBarH: CGFloat {
    get {
        let s = UIApplication.shared.connectedScenes.first
        guard let w = s as? UIWindowScene else { return 0}
        guard let st = w.statusBarManager else { return 0}
        return st.statusBarFrame.height
    }
}

var BottomSafeH: CGFloat {
    get {
        let s = UIApplication.shared.connectedScenes.first
        guard let w = s as? UIWindowScene else {return 0}
        guard let key = w.windows.first else {return 0}
        return key.safeAreaInsets.bottom
    }
}

enum HUB_RateState: Float {
    case two = 2.0
    case oneBan = 1.5
    case oneTwo = 1.25
    case one = 1.0
    case sevenFive = 0.75
    case ban = 0.5
}

enum HUB_DataType: Int {
    case folder = 0
    case photo
    case video
}

enum HUB_FileState: Int {
    case normal = 0
    case upload
    case uploadWait
    case uploading
    case uploadFaid
    case downing
    case downWait
    case downFail
    case downDone
}

enum HUB_PlatformType: String {
    case box = "syncxbox"    // box
    case cash = "a"  // cash 印度
    case quick = "b"   // quick 中东
}

enum HUB_BackEventSource: String {
    case landpage = "landpage"
    case channelpage = "channelpage"
    case history = "history"
    case mid_recommend = "mid_recommend"
    case playlist_recommend = "playlist_recommend"
    case download = "download"
    case upload = "upload"
}

enum HUB_PlaySource: String {
    case channel_hot = "a"
    case channel_recently = "b"
    case channel_file = "c"
    case channel_recommend = "f"
    case landpage_hot = "e"
    case landpage_recently = "x"
    case landpage_file = "bs"
    case landpage_recommend = "se"
    case download_list = "bx"
    case upload_home = "bas"
    case playlist_file = "wer"
    case playlist_recommend = "bsx"
    case history = "bsadf"
    case cloud = "baer"
}

enum HUB_AdsPlayState: String {
    case channelPage = "ss"
    case download = "sa"
    case donwloadpage = "sb"
    case playTen = "b"
    case playNext = "c"
    case playBack = "d"
    case openCool = "e"
    case openHot = "f"
    case play = "g"
}

enum HUB_ChannelSourceType: String {
    //landpage_avtor、landpage_hot_recently、landpage_recommend、home_channel、channellist、channelpage_recommend

    case homeChannel = "a"
    case channelList = "b"
    case landpageAvtor = "c"
    case landpage_hot_recently = "d"
    case landpage_recommend = "e"
    case channelpage_recommend = "f"
}

enum HUB_PremiumMethod: String {
    case vip_auto = "a"
    case vip_click = "b"
}

enum HUB_PremiumSource: String {
    case vip_home = "a"
    case vip_playPage = "b"
    case vip_chennelPage = "c"
    case vip_landPage = "d"
    case vip_Ad = "e"
    case vip_Accelerate = "f"
}

class HubTool {
    static let share = HubTool()
    
    var preMethod: HUB_PremiumMethod = .vip_auto
    
    var preSource: HUB_PremiumSource = .vip_home

    var deepUrl: String = ""
        
    var isLinkDeep: Bool = false
    
    var platform: HUB_PlatformType = .box {
        didSet {
            if platform != .box {
                UserDefaults.standard.set(platform.rawValue, forKey: HUB_LastPlatform)
                UserDefaults.standard.synchronize()
            }
        }
    }

    var currentPlatform: HUB_PlatformType = .cash {
        didSet {
            if currentPlatform == .cash {
                HttpManager.share.appHost = "https://api.a.com/"
            } else {
                HttpManager.share.appHost = "https://api.b.com/"
            }
        }
    }
    var uploadPlatform: HUB_PlatformType = .box

    var boxLinkId: String = ""
    
    var boxUId: String = ""
    
    var linkId: String = ""
    
    var uId: String = ""

    var fileId: String = ""

    var email: String = ""

    var toPay: Bool = false

    var eventSource: HUB_BackEventSource = .landpage
    
    var playSource: HUB_PlaySource = .playlist_file
    
    var adsPlayState: HUB_AdsPlayState = .openCool
    
    var channelSource: HUB_ChannelSourceType = .homeChannel
    
    var showAdomb: Bool = false

    var isSim: Bool = false
    
    var isEmulator: Bool = false

    var isVpn: Bool = false

    var isPod: Bool = false
    
//    var clackData: ClackData = ClackData()
    
    var spaceUse: String = ""
    
    var spaceTotal: String = ""
    
    var isCountMiddlePlay: Bool = false
    
    var loginSource: HUB_loginSource = .upload
    
    var playLinkId: String = ""
    
    var playUserId: String = ""

    var preMiumCount: Int = 0
    
    var preMiumMagin: Int = 0
    
    var preMiumLists: [String] = []
    
    var keyWindow: UIWindow? {
        guard let s = UIApplication.shared.connectedScenes.first else { return nil }
        guard let w = s as? UIWindowScene else { return nil }
        guard let key = w.windows.first else { return nil }
        return key
    }
    
    func keyVC(_ controller: UIViewController? = HubTool.share.keyWindow?.rootViewController) -> UIViewController? {
        guard let controller = controller else { return nil }
        if let presented = controller.presentedViewController {
            return keyVC(presented)
        } else if let navigationController = controller as? UINavigationController {
            return keyVC(navigationController.visibleViewController)
        } else if let tabBarController = controller as? UITabBarController {
            return keyVC(tabBarController.selectedViewController)
        }
        return controller
    }
    
    let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    // 获取缓存大小
    func getCacheSize(_ completion: @escaping (_ size: String) -> ()) {
        ImageCache.default.calculateDiskStorageSize { result in
            var sizeString = "0MB"
            //保留2位小数
            switch result {
            case .success(let success):
                if success >= 1024*1024*1024 {
                    sizeString = String(format: "%.2f", Double(success)/1024.0/1024.0/1024.0) + "GB"
                } else if success > 0 {
                    sizeString = String(format: "%.2f", Double(success)/1024.0/1024.0) + "MB"
                }
            case .failure(_):
                break
            }
            completion(sizeString)
        }
    }
    
    // 清空缓存
    func clearCache() {
        ImageCache.default.clearDiskCache()
    }
    
    func changeModel(_ model: OpenUrlData, linkId: String, uId: String, platform: HUB_PlatformType) -> VideoData {
        let m = VideoData()
        let dbData: [VideoData] = HubDB.instance.readDatas()
        if let mod = dbData.first(where: {$0.id == model.file_id && $0.file_type == .video}) {
            mod.linkId = linkId
            return mod
        } else {
            m.id = model.file_id
            m.userId = uId
            m.linkId = linkId
            m.size = "\(model.file_meta.size.computeFileSize())"
            m.file_size = model.file_meta.size
            m.ext = model.file_meta.ext
            m.isNet = true
            m.date = model.create_time
            m.name = model.file_meta.display_name
            m.thumbnail = model.file_meta.thumbnail
            m.file_type = model.file_type
            m.vid_qty = model.vid_qty
            m.platform = platform
            return m
        }
    }
    
    func changeList(_ list: [OpenUrlData], linkId: String, uId: String, platform: HUB_PlatformType) -> [VideoData] {
        var result: [VideoData] = []
        let dbData: [VideoData] = HubDB.instance.readDatas()
        list.forEach { item in
            var m = VideoData()
            if item.file_type == .video {
                if let mod = dbData.first(where: {$0.id == item.file_id}) {
                    m = mod
                    m.linkId = linkId
                } else {
                    m.id = item.file_id
                    m.userId = uId
                    m.linkId = linkId
                    m.size = "\(item.file_meta.size.computeFileSize())"
                    m.file_size = item.file_meta.size
                    m.ext = item.file_meta.ext
                    m.isNet = true
                    m.date = item.create_time
                    m.name = item.file_meta.display_name
                    m.thumbnail = item.file_meta.thumbnail
                    m.file_type = item.file_type
                    m.vid_qty = item.vid_qty
                    m.platform = platform
                }
                result.append(m)
            }
        }
        return result
    }
    
    func channelModel(_ model: ChannelData, linkId: String, uId: String, platform: HUB_PlatformType) -> VideoData {
        let m = VideoData()
        let dbData: [VideoData] = HubDB.instance.readDatas()
        if let mod = dbData.first(where: {$0.id == model.id && $0.file_type == .video}) {
            mod.linkId = linkId
            mod.recommend = model.recommoned
            return mod
        } else {
            m.id = model.id
            m.userId = uId
            m.linkId = linkId
            m.size = "\(model.file_meta.size.computeFileSize())"
            m.file_size = model.file_meta.size
            m.ext = model.file_meta.ext
            m.isNet = true
            m.pubData = model.update_time
//            m.name = model.displayName.twattled
            m.thumbnail = model.file_meta.thumbnail
            m.file_type = model.file_type
            m.vid_qty = model.vid_qty
            m.platform = platform
            return m
        }
    }
    
    func channelList(_ list: [ChannelData], linkId: String, uId: String, platform: HUB_PlatformType) -> [VideoData] {
        var result: [VideoData] = []
        let dbData: [VideoData] = HubDB.instance.readDatas()
        list.forEach { item in
            var m = VideoData()
            if let mod = dbData.first(where: {$0.id == item.id && $0.file_type == .video}) {
                m = mod
                m.linkId = linkId
                m.recommend = item.recommoned
            } else {
                m.id = item.id
                m.userId = uId
                m.linkId = linkId
                m.size = "\(item.file_meta.size.computeFileSize())"
                m.file_size = item.file_meta.size
                m.ext = item.file_meta.ext
                m.isNet = true
                m.recommend = item.recommoned
                m.pubData = item.update_time
//                m.name = item.displayName.twattled
                m.thumbnail = item.file_meta.thumbnail
                m.file_type = item.file_type
                m.vid_qty = item.vid_qty
                m.platform = platform
            }
            result.append(m)
        }
        return result
    }
    
    // MRAK: - video image
    func getVideoImage(videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(value: 0, timescale: 1)
        generator.generateCGImagesAsynchronously(forTimes: [time as NSValue]) { _, cImage,_, _, _ in
            if let imageRe = cImage, let data = UIImage(cgImage: imageRe).compressSize(with: 1024 * 2) {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func userIsLogin(_ vc: UIViewController) -> Bool {
        if (LoginManager.share.isLogin == false) {
            LoginManager.share.loginRequest(vc) { success in
                
            }
            return false
        } else {
            return true
        }
    }
    
    func downEvent(_ data: VideoData) {
        HttpManager.share.uploadEventApi(event: .down_video, currency: "", val: 0, model: data) { [weak self] success in
            guard let self = self else { return }
            if success == false {
                self.downEvent(data)
            }
        }
    }
}

