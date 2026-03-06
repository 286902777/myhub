//
//  GoogleAdsData.swift
//  MyHub
//
//  Created by hub on 3/6/26.
//

import Foundation
import GoogleMobileAds
import AppLovinSDK

enum GoogleAdsSource: String, Codable {
    case admob, max
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        switch rawValue {
        case "admob":
            self = .admob
        default:
            self = .max

        }
    }
}

enum AdsShowMode: String, Codable {
    case play, playing, plus, three
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        switch rawValue {
        case "play":
            self = .play
        case "playing":
            self = .playing
        case "plus":
            self = .plus
        default:
            self = .three
        }
    }
}

enum AdsType: String, Codable {
    case open ,interstitial, rewarded, native
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        switch rawValue {
        case "open":
            self = .open
        case "interstitial":
            self = .interstitial
        case "rewarded":
            self = .rewarded
        default:
            self = .native
        }
    }
}

nonisolated struct GoogleAdsFireData: Codable {
    var playMiddleTime: Int = 600
    var spaceTime: Int = 60
    var startTime: Int = 7
    var nativeTime: Int = 7
    var nativeClickRate: Int = 50
    var playingIndex: Int = 5
    var playingTime: Int = 10
    var playMethod: Int = 0
    var playNativeTime: Int = 7
    var playNativeClickRate: Int = 80
    var s_NativeTime: Int = 7
    var s_NativeClickRate: Int = 80
    var play: [GoogleAdsData] = []
    var playing: [GoogleAdsData] = []
    var plus: [GoogleAdsData] = []
    var three: [GoogleAdsData] = []
}

nonisolated struct GoogleAdsData {
    var type: AdsType
    var source: GoogleAdsSource
    var index: Int = 0
    var id: String = ""
    var s_id: String = ""
    var native: NativeAd?
    var s_native: NativeAd?
}

extension GoogleAdsData: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, index, source, id, s_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let e_type: String = try container.decode(String.self, forKey: .type)
        self.type = AdsType(rawValue: e_type) ?? .open
        let e_source: String = try container.decode(String.self, forKey: .source)
        self.source = GoogleAdsSource(rawValue: e_source) ?? .admob
        self.id = try container.decode(String.self, forKey: .id)
        self.s_id = try container.decode(String.self, forKey: .s_id)
        self.index = try container.decode(Int.self, forKey: .index)
        self.native = nil
        self.s_native = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(s_id, forKey: .s_id)
        try container.encode(index, forKey: .index)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(source.rawValue, forKey: .source)
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
