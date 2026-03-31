//
//  GoogleAdsData.swift
//  MyHub
//
//  Created by hub on 3/6/26.
//

import Foundation
import GoogleMobileAds
import AppLovinSDK
import HandyJSON

enum GoogleAdsSource: String, HandyJSONEnum {
    case admob = "admob"
    case max = "max"
}

enum AdsShowMode: String, HandyJSONEnum {
    case play = "play"
    case playing = "playing"
    case plus = "plus"
    case three = "three"
}

enum AdsType: String, HandyJSONEnum {
    case open = "open"
    case interstitial = "interstitial"
    case rewarded = "rewarded"
    case native = "native"
}

class GoogleAdsFireData: SuperData {
    var playMiddleTime: Int = 600
    var spaceTime: Int = 60
    var startTime: Int = 7
    var nativeTime: Int = 7
    var nativeClickRate: Int = 50
    var playingIndex: Int = 5
    var playingTime: Int = 10
    var playNativeTime: Int = 7
    var playNativeClickRate: Int = 80
    var s_NativeTime: Int = 7
    var s_NativeClickRate: Int = 80
    var play: [GoogleAdsData] = []
    var playing: [GoogleAdsData] = []
    var plus: [GoogleAdsData] = []
    var three: [GoogleAdsData] = []
}

class GoogleAdsData: SuperData {
    var type: AdsType = .open
    var source: GoogleAdsSource = .admob
    var index: Int = 0
    var id: String = ""
    var s_id: String = ""
    var native: NativeAd?
    var s_native: NativeAd?
    
    override func mapping(mapper: HelpingMapper) {
           super.mapping(mapper: mapper)
           mapper.specify(property: &type, name: "type") { (info) -> (AdsType) in
               let ty = AdsType(rawValue: info.lowercased())
               return ty ?? .interstitial
           }
           mapper.specify(property: &source, name: "source") { (info) -> (GoogleAdsSource) in
               let s = GoogleAdsSource(rawValue: info.lowercased())
               return s ?? .admob
           }
           mapper.specify(property: &id, name: "id")
           mapper.specify(property: &index, name: "index")
       }
}

class GoogleAdsListData: SuperData {
    var playMode: AdsShowMode = .play
    var lists: [GoogleAdsData] = []
    var ad: NSObject?
}
 
class GoogleAdsCacheData: SuperData {
    var adsType: AdsType = .open
    var index: Int = 0
    var id: String = ""
    var ad: NSObject?
    var s_id: String = ""
    var s_ad: NSObject?
    var mode: AdsShowMode = .play
    var source: GoogleAdsSource = .admob
    var time: TimeInterval = 0
}
 
class GoogleAdsCacheListData: SuperData {
    var mode: AdsShowMode = .play
    var lists: [GoogleAdsCacheData] = []
}
