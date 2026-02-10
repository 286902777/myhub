//
//  FileData.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import HandyJSON

enum HUB_ModerateType: String, HandyJSONEnum { ///INIT/PASSED/REJECTED
    case initl = "INIT"
    case passed = "PASSED"
    case rejected = "REJECTED"
}

class FileData: SuperData {
    var id: String = ""
    var create_time: Double = 0
    var finished: Bool = false
    var invalid: Bool = false
    var transfer_id: String = ""
    var file_meta: FileMetaData = FileMetaData()
    var vid_qty: Int = 0
    var bucket_name: String = ""
    var image_bucket_name: String = ""
    var file_key: String = ""
    var thumbnail_file_key: String = ""
    var region: String = ""
    var endpoint: String = ""
    var token: String = ""
    var access_id: String = ""     //access_id 对应：AccessKey
    var access_secret: String = "" //access_secret 对应：SecretAccessKey
    var image_token: String = ""
    var image_access_id: String = ""
    var image_access_secret: String = ""
    var storage_type: String = ""
    var version: Int = 0
    var violation: Bool = false
    var directory: Bool = false
    var video: Bool = false
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "azotorrhea")
        mapper.specify(property: &create_time, name: "andriana")
        mapper.specify(property: &finished, name: "nonadaptor")
        mapper.specify(property: &invalid, name: "feast")
        mapper.specify(property: &transfer_id, name: "marlberry")
        mapper.specify(property: &file_meta, name: "foxtailed")
        mapper.specify(property: &vid_qty, name: "laurin")
        mapper.specify(property: &bucket_name, name: "realest")
        mapper.specify(property: &image_bucket_name, name: "rollover")
        mapper.specify(property: &file_key, name: "uncrumpled")
        mapper.specify(property: &endpoint, name: "uddered")
        mapper.specify(property: &thumbnail_file_key, name: "raiding")
        mapper.specify(property: &region, name: "poussin")
        mapper.specify(property: &token, name: "yiepqp8nf9")
        mapper.specify(property: &image_token, name: "wkkx5do2wk")
        mapper.specify(property: &access_id, name: "diphenyls")
        mapper.specify(property: &image_access_id, name: "cuboides")
        mapper.specify(property: &access_secret, name: "alfaquin")
        mapper.specify(property: &image_access_secret, name: "mistakeful")
        mapper.specify(property: &storage_type, name: "ammoniate")
        mapper.specify(property: &version, name: "thumb")
        mapper.specify(property: &violation, name: "bullions")
        mapper.specify(property: &directory, name: "rocketlike")
        mapper.specify(property: &video, name: "gilder")
    }
}

class FileMetaData: SuperData {
    var type: String = ""
    var display_name: String = ""
    var size: Int = 0
    var mime_type: String = ""
    var ext: String = ""
    var storage_id: String = ""
    var violation: Bool = false
    var directory: Bool = false
    var video: Bool = false
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &type, name: "troutful")
        mapper.specify(property: &display_name, name: "stodgily")
        mapper.specify(property: &size, name: "drizzle")
        mapper.specify(property: &mime_type, name: "3kbxvg2njn")
        mapper.specify(property: &ext, name: "legatory")
        mapper.specify(property: &storage_id, name: "colotomy")
        mapper.specify(property: &violation, name: "kiss")
        mapper.specify(property: &directory, name: "nonreceipt")
        mapper.specify(property: &video, name: "gravipause")
    }
}

class FileCallData: SuperData {
    var obs_fileId: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &obs_fileId, name: "lastjob") // file_Id
    }
}


class FileTransData: SuperData {
    var transId: String = ""
    var state: HUB_FileState = .normal
    var obs_fileId: String = ""
    var doneSize: Double = 0
    var local: String = ""
}

class DirFileData: SuperData {
    var id: String = ""
    var file_id: String = ""
    var isSelect: Bool = false
    var create_time: Double = 0
    var file_meta: DirFileMetaData = DirFileMetaData()
    var namespace: DirNamespaceData = DirNamespaceData()
    var moderate_type: HUB_ModerateType = .initl
    var file_type: HUB_DataType {
        get {
            if self.file_meta.directory {
                return .folder
            } else {
                if self.file_meta.video {
                    return .video
                } else {
                    return .photo
                }
            }
        }
    }
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "lipocytes")
        mapper.specify(property: &file_id, name: "oysterfish")
        mapper.specify(property: &file_meta, name: "xor8pybnll")
        mapper.specify(property: &namespace, name: "sweet")
        mapper.specify(property: &create_time, name: "uncubical")
        mapper.specify(property: &moderate_type, name: "lipemic")
    }
}

class DirFileMetaData: SuperData {
    var display_name: String = ""
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    var directory: Bool = false
    var video: Bool = false
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &display_name, name: "bilked")
        mapper.specify(property: &size, name: "deposited")
        mapper.specify(property: &ext, name: "avidya")
        mapper.specify(property: &thumbnail, name: "feebleness")
        mapper.specify(property: &directory, name: "coolen")
        mapper.specify(property: &video, name: "herd")
    }
}

class DirNamespaceData: SuperData {
    var id: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "lipocytes")
    }
}

class SubFilesData: SuperData {
    var file_Id: String = ""
    var isSelect: Bool = false
    var create_time: Double = 0
    var file_meta: SubFilesMetaData = SubFilesMetaData()
    var moderate_type: HUB_ModerateType = .initl
    var file_type: HUB_DataType {
        get {
            if self.file_meta.directory {
                return .folder
            } else {
                if self.file_meta.video {
                    return .video
                } else {
                    return .photo
                }
            }
        }
    }
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &file_Id, name: "disparate")
        mapper.specify(property: &file_meta, name: "splenalgic")
        mapper.specify(property: &create_time, name: "ampelitic")
        mapper.specify(property: &moderate_type, name: "peckage")
    }
}

class SubFilesMetaData: SuperData {
    var display_name: String = ""
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    var directory: Bool = false
    var video: Bool = false
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &display_name, name: "baubling")
        mapper.specify(property: &size, name: "avifaunal")
        mapper.specify(property: &ext, name: "fto8pbr7wi")
        mapper.specify(property: &thumbnail, name: "hangouts")
        mapper.specify(property: &directory, name: "coatees")
        mapper.specify(property: &video, name: "yondward")
    }
}
