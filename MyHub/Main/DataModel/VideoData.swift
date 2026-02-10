//
//  VideoData.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import UIKit

enum HUB_HomeListType: String {
    case history = "Recently"
    case channel = "Channel"
    case upload = "Upload"
}

enum HUB_HomeMoreType: String {
    case download = "down"
    case downloading = "alert_down_downing"
    case downDone = "alert_down_done"
    case share = "share"
    case rename = "rename"
    case un_rename = "un_rename"
    case delete = "delete"
}

class HomeData: SuperData {
    var type: HUB_HomeListType = .history
    var lists: [VideoData] = []
    var users: [ChannelUserData] = []
}

class VideoData: SuperData {
    var id: String = ""
    var state: HUB_FileState = .normal
    var name: String = ""
    var size: String = ""
    var file_size: Double = 0
    var parent_id: String = ""
    var done_size: Double = 0
    var upload_size: Double = 0
    var image: UIImage?
    var ext: String = ""
    var movieAddress: String = ""
    var playTime: Double = 0
    var totalTime: Double = 0
    var date: Double = 0
    var pubData: Double = 0
    var thumbnail: String = ""
    var isNet: Bool = false
    var file_type: HUB_DataType = .video
    var vid_qty: Int = 0
    var history: Bool = false
    var recommend: Bool = false
    var userId: String = ""
    var linkId: String = ""
    var email: String = ""
    var platform: HUB_PlatformType = .box
    var labels: [[String: String]] = []
    var duration: String = ""
    var transId: String = ""
    var obs_fileId: String = ""
    var isSelect: Bool = false
    var isPass: HUB_ModerateType = .initl
    var isShare: Bool = false
}

class HomeMoreData: SuperData {
    var imageType: HUB_HomeMoreType = .download
    var title: String = ""
}
