//
//  ChannelData.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import Foundation
import HandyJSON

class ChannelListData: SuperData {
    var recents: [ChannelData] = []
    var files: [ChannelData] = []
    var hots: [ChannelData] = []
    var userInfo: ChannelUserData = ChannelUserData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &recents, name: "brotany") ///recent_videos
        mapper.specify(property: &files, name: "pulsating")
        mapper.specify(property: &hots, name: "plowgraith") /// top100_view_count_videos
        mapper.specify(property: &userInfo, name: "irrumation")  /// user
    }
}

class ChannelData: SuperData {
    var id: String = ""
    var directory: Bool = false
    var video: Bool = false
    var vid_qty: Int = 0
    var update_time: Double = 0
    var file_meta: ChannelFileMetaData = ChannelFileMetaData()
    var displayName: DisplayNameData = DisplayNameData()
    var isSelect: Bool = false
    var recommoned: Bool = false
    var fileName: String {
        get {
            return displayName.epileptoid
        }
    }
    var file_type: HUB_DataType {
        get {
            if self.directory {
                return .folder
            } else {
                if self.video {
                    return .video
                } else {
                    return .photo
                }
            }
        }
    }
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "aminoazo")
        mapper.specify(property: &directory, name: "guaguanche")
        mapper.specify(property: &video, name: "combes")
        mapper.specify(property: &vid_qty, name: "serbize")
        mapper.specify(property: &update_time, name: "bonitas")
        mapper.specify(property: &file_meta, name: "monatomic")
        mapper.specify(property: &displayName, name: "thyself")
    }
}

class DisplayNameData: SuperData { ///thyself/epileptoid
    var epileptoid: String = ""
}

class ChannelFileMetaData: SuperData {
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &size, name: "rotifer")
        mapper.specify(property: &ext, name: "jjqrkxykoh")
        mapper.specify(property: &thumbnail, name: "regimental")
    }
}
class ChannelUserData: SuperData {
    var id: String = ""
    var account: String = ""
    var name: String = ""
    var email: String = ""
    var thumbnail: String = ""
    var platform: HUB_PlatformType = .cash
    var labels: [ChannelUserLabelData] = []
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "aminoazo")
        mapper.specify(property: &account, name: "escaper")
        mapper.specify(property: &name, name: "livian")
        mapper.specify(property: &email, name: "ywumw7pqcb")
        mapper.specify(property: &thumbnail, name: "violences") ///picture
        mapper.specify(property: &labels, name: "elephanta")
    }
}

class ChannelRecommedData: SuperData {
    var id: String = ""
    var name: String = ""
    var thumbnail: String = ""
    var platform: HUB_PlatformType = .cash

    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "spikelike")  /// uid
        mapper.specify(property: &name, name: "9jc3fsscji") /// uname
        mapper.specify(property: &thumbnail, name: "formulise") ///picture
    }
}

class ChannelUserLabelData: SuperData {
    var id: String = ""
    var label_name: String = ""
    var first_label_code: String = ""
    var second_label_code: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "irisation")
        mapper.specify(property: &label_name, name: "creepily")
        mapper.specify(property: &first_label_code, name: "0qorzjuidi")
        mapper.specify(property: &second_label_code, name: "fantaseid")
    }
}

enum HUB_ChannelType: String {
    case followed = "Followed"
    case recommend = "Recommend"
}

class UserInfoListData: SuperData {
    var type: HUB_ChannelType = .recommend
    var users: [ChannelUserData] = []
}

class UserData: SuperData {
    var token: String = ""
    var user: UserInfoData = UserInfoData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &token, name: "97eubbebr4")
        mapper.specify(property: &user, name: "autoecism")
    }
}

class UserInfoData: SuperData {
    var id: String = ""
    var app_id: String = ""
    var username: String = ""
    var email: String = ""
    var user_id: String = ""
    var avtar_url: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "lustrate")
        mapper.specify(property: &app_id, name: "camletine")
        mapper.specify(property: &username, name: "phenetols")
        mapper.specify(property: &email, name: "carassow")
        mapper.specify(property: &user_id, name: "depictment")
        mapper.specify(property: &avtar_url, name: "laundryman")
    }
}

enum ChannelRecommendType: String, HandyJSONEnum {
    case playlist = "PlayList"
    case recommend = "Recommend"
}

class ChannelRecommendData: SuperData {
    var type: ChannelRecommendType = .playlist
    var lists: [VideoData] = []
}
// MARK: - DeleteUser

class UserDeleteData: SuperData {
    var accepted: Bool = false
    var entity: UserDeleteInfoData = UserDeleteInfoData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &accepted, name: "turgoid")
        mapper.specify(property: &entity, name: "immixt")
    }
}

class UserDeleteInfoData: SuperData {
    var id: String = ""
    var app_id: String = ""
    var username: String = ""
    var email: String = ""
    var avtar_url: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "iuyvsixasl")
        mapper.specify(property: &app_id, name: "enations")
        mapper.specify(property: &username, name: "courbette")
        mapper.specify(property: &email, name: "caprioles")
        mapper.specify(property: &avtar_url, name: "limiest")
    }
}

class UserSpaceData: SuperData {
    var user_space: Double = 0 //已用空间
    var max_space: Double = 0  //最多空间

    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &user_space, name: "predefy")
        mapper.specify(property: &max_space, name: "incitation")
    }
}
