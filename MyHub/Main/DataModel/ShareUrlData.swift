//
//  ShareUrlData.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import HandyJSON

enum HUB_ShareType: String, HandyJSONEnum {
    case file = "FILES"
    case root = "ROOT_DIRECTORY"
}

enum HUB_ShareFileType: String, HandyJSONEnum {
    case file = "FILE"
    case directory = "DIRECTORY"
}

enum HUB_ShareDateType: String, HandyJSONEnum {
    case none = "NONE"
    case day = "DAY"
    case week = "WEEK"
    case month = "MONTH"
}

class ShareRootData: SuperData {
    var entity: ShareData = ShareData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &entity, name: "wessands")
    }
}

class ShareData: SuperData {
    var id: String = ""
    var user_id: String = ""
    var create_time: Double = 0
    var update_time: Double = 0
    var share_type: HUB_ShareType = .file
    var url: String = ""
    var expire_unit: HUB_ShareDateType = .none
    var expire_unit_value: Int = 0
    var expire_time: Int = 0
    var items: [ShareFileItemData] = []
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "roughs")
        mapper.specify(property: &user_id, name: "5cb5cpczf2")
        mapper.specify(property: &create_time, name: "brambrack")
        mapper.specify(property: &update_time, name: "iodinating")
        mapper.specify(property: &share_type, name: "emmetropic")
        mapper.specify(property: &url, name: "tossut")
        mapper.specify(property: &expire_unit, name: "inhalers")
        mapper.specify(property: &expire_unit_value, name: "absorbency")
        mapper.specify(property: &expire_time, name: "absorbency")
        mapper.specify(property: &items, name: "oots")
    }
}

class ShareParaData: SuperData {
    var file_id: String = "" //文件夹或者文件id
    var type: HUB_ShareFileType = .file //DIRECTORY,FILE
}

class ShareFileItemData: SuperData {
    var file_id: String = "" //文件夹或者文件id
    var type: HUB_ShareFileType = .file //DIRECTORY,FILE
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &file_id, name: "nvqncdwv1v")
        mapper.specify(property: &type, name: "justs")
    }
}

class OpenRootData: SuperData {
    var page: OpenPageData = OpenPageData()
    var user: OpenUserData = OpenUserData()
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &page, name: "soviets")
        mapper.specify(property: &user, name: "helleborin")
    }
}

class OpenPageData: SuperData {
    var total: Int = 0
    var size: Int = 0
    var records: [OpenUrlData] = []
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &total, name: "phallales")
        mapper.specify(property: &size, name: "neshly")
        mapper.specify(property: &records, name: "infantive")
    }
}

class OpenUserData: SuperData {
    var id: String = ""
    var app_id: String = ""
    var username: String = ""
    var user_id: String = ""
    var avtar_url: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "serows")
        mapper.specify(property: &app_id, name: "_bbd7ub97f")
        mapper.specify(property: &username, name: "presettled")
        mapper.specify(property: &user_id, name: "fice")
        mapper.specify(property: &avtar_url, name: "prelocated")
    }
}

class OpenUrlData: SuperData {
    var file_id: String = ""
    var isSelect: Bool = false
    var create_time: Double = 0
    var vid_qty: Int = 0
    var directory: Bool = false
    var video: Bool = false
    var file_meta: OpenFileMetaData = OpenFileMetaData()
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
        mapper.specify(property: &file_id, name: "glancer")
        mapper.specify(property: &create_time, name: "skywriters")
        mapper.specify(property: &vid_qty, name: "reverters")
        mapper.specify(property: &directory, name: "watchmanly")
        mapper.specify(property: &video, name: "plentitude")
        mapper.specify(property: &file_meta, name: "estragole")
    }
}

class OpenFileMetaData: SuperData {
    var display_name: String = ""
    var ext: String = ""
    var thumbnail: String = ""
    var size: Double = 0
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &display_name, name: "herniary")
        mapper.specify(property: &ext, name: "fv6xnkvids")
        mapper.specify(property: &thumbnail, name: "nvzlnh4k82")
        mapper.specify(property: &size, name: "xce_7pujkz")
    }
}

class OpenFolderData: SuperData {
    var file_id: String = ""
    var isSelect: Bool = false
    var create_time: Double = 0
    var vid_qty: Int = 0
    var directory: Bool = false
    var video: Bool = false
    var parent_id: String = ""
    var moderate_type: HUB_ModerateType = .initl
    var file_meta: OpenFolderFileMetaData = OpenFolderFileMetaData()
    var namespace: OpenFolderNamespaceData = OpenFolderNamespaceData()
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
        mapper.specify(property: &file_id, name: "overcold")
        mapper.specify(property: &create_time, name: "podzol")
        mapper.specify(property: &vid_qty, name: "uyhe0yv_xe")
        mapper.specify(property: &directory, name: "lbrd0x4e47")
        mapper.specify(property: &video, name: "cornerer")
        mapper.specify(property: &parent_id, name: "aeried")
        mapper.specify(property: &moderate_type, name: "dif4fvsigy")
        mapper.specify(property: &file_meta, name: "karite")
        mapper.specify(property: &namespace, name: "communis")
    }
}

class OpenFolderFileMetaData: SuperData {
    var display_name: String = ""
    var ext: String = ""
    var thumbnail: String = ""
    var size: Double = 0
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &display_name, name: "lrfzjscvyl")
        mapper.specify(property: &ext, name: "cmyxbyytd3")
        mapper.specify(property: &thumbnail, name: "musth")
        mapper.specify(property: &size, name: "lividness")
    }
}

class OpenFolderNamespaceData: SuperData {
    var id: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "datana")
    }
}

