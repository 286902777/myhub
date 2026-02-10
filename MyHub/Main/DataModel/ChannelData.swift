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
        mapper.specify(property: &recents, name: "tenementer") ///recent_videos
        mapper.specify(property: &files, name: "frisco")
        mapper.specify(property: &hots, name: "ortstein") /// top100_view_count_videos
        mapper.specify(property: &userInfo, name: "dewanee")
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
    var fileName: String {
        get {
            return displayName.thenness
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
        mapper.specify(property: &id, name: "rigour")
        mapper.specify(property: &directory, name: "b1mrtwxl_p")
        mapper.specify(property: &video, name: "enceint")
        mapper.specify(property: &vid_qty, name: "flattener")
        mapper.specify(property: &update_time, name: "nonaphetic")
        mapper.specify(property: &file_meta, name: "maundering")
        mapper.specify(property: &displayName, name: "distilland")
    }
}

class DisplayNameData: SuperData { ///distilland/thenness
    var thenness: String = ""
}

class ChannelFileMetaData: SuperData {
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &size, name: "chanoyu")
        mapper.specify(property: &ext, name: "schediasm")
        mapper.specify(property: &thumbnail, name: "plex")
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
        mapper.specify(property: &id, name: "rigour")
        mapper.specify(property: &account, name: "airframes")
        mapper.specify(property: &name, name: "cartage")
        mapper.specify(property: &email, name: "collates")
        mapper.specify(property: &thumbnail, name: "greyed") ///picture
        mapper.specify(property: &labels, name: "y2cw72r5wu")
    }
}

class ChannelRecommedData: SuperData {
    var id: String = ""
    var name: String = ""
    var thumbnail: String = ""
    var platform: HUB_PlatformType = .cash

    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "checkage")  /// uid
        mapper.specify(property: &name, name: "stomachs") /// uname
        mapper.specify(property: &thumbnail, name: "pampa") ///picture
    }
}

class ChannelUserLabelData: SuperData {
    var id: String = ""
    var label_name: String = ""
    var first_label_code: String = ""
    var second_label_code: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "rigour")
        mapper.specify(property: &label_name, name: "metricity")
        mapper.specify(property: &first_label_code, name: "drawbeam")
        mapper.specify(property: &second_label_code, name: "philtre")
    }
}

enum HUB_ChannelType: String {
    case followed = "Followed"
    case recommend = "Recommend"
}

class UserInfoListData: SuperData {
    var type: HUB_ChannelType = .recommend
    var recommends: [ChannelRecommedData] = []
    var users: [ChannelUserData] = []
}

class UserData: SuperData {
    var token: String = ""
    var user: UserInfoData = UserInfoData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &token, name: "beglerbeg")
        mapper.specify(property: &user, name: "secundus")
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
        mapper.specify(property: &id, name: "manasic")
        mapper.specify(property: &app_id, name: "singerie")
        mapper.specify(property: &username, name: "jlfe7kaln6")
        mapper.specify(property: &email, name: "skeltering")
        mapper.specify(property: &user_id, name: "oxyneurine")
        mapper.specify(property: &avtar_url, name: "kyschty")
    }
}
// MARK: - DeleteUser

class UserDeleteData: SuperData {
    var accepted: Bool = false
    var entity: UserDeleteInfoData = UserDeleteInfoData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &accepted, name: "ibilmqkoxp")
        mapper.specify(property: &entity, name: "taluto")
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
        mapper.specify(property: &id, name: "leashless")
        mapper.specify(property: &app_id, name: "draggingly")
        mapper.specify(property: &username, name: "cerecloth")
        mapper.specify(property: &email, name: "squadrism")
        mapper.specify(property: &avtar_url, name: "boothes")
    }
}

class UserSpaceData: SuperData {
    var user_space: Double = 0 //已用空间
    var max_space: Double = 0  //最多空间

    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &user_space, name: "taipan")
        mapper.specify(property: &max_space, name: "azilian")
    }
}
