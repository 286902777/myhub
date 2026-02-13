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
        mapper.specify(property: &id, name: "fulminates")
        mapper.specify(property: &create_time, name: "crimper")
        mapper.specify(property: &finished, name: "dinaric")
        mapper.specify(property: &invalid, name: "joyfulness")
        mapper.specify(property: &transfer_id, name: "apf5uzfbgt")
        mapper.specify(property: &file_meta, name: "amidated")
        mapper.specify(property: &vid_qty, name: "reassert")
        mapper.specify(property: &bucket_name, name: "grandpappy")
        mapper.specify(property: &image_bucket_name, name: "hmbmhebcty")
        mapper.specify(property: &file_key, name: "mourning")
        mapper.specify(property: &endpoint, name: "manualii")
        mapper.specify(property: &thumbnail_file_key, name: "autotoxin")
        mapper.specify(property: &region, name: "emulgens")
        mapper.specify(property: &token, name: "maranon")
        mapper.specify(property: &image_token, name: "8gwrnzrck4")
        mapper.specify(property: &access_id, name: "subradical")
        mapper.specify(property: &image_access_id, name: "xwbuiklzh3")
        mapper.specify(property: &access_secret, name: "perfuses")
        mapper.specify(property: &image_access_secret, name: "thetically")
        mapper.specify(property: &storage_type, name: "barbells")
        mapper.specify(property: &version, name: "pantalgia")
        mapper.specify(property: &violation, name: "bullions")
        mapper.specify(property: &directory, name: "barghests")
        mapper.specify(property: &video, name: "ovulated")
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
        mapper.specify(property: &obs_fileId, name: "uniat") // file_Id
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
        mapper.specify(property: &id, name: "ivoriness")
        mapper.specify(property: &file_id, name: "looking")
        mapper.specify(property: &file_meta, name: "saliently")
        mapper.specify(property: &namespace, name: "surnames")
        mapper.specify(property: &create_time, name: "immotioned")
        mapper.specify(property: &moderate_type, name: "chuje")
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
        mapper.specify(property: &display_name, name: "disloyalty")
        mapper.specify(property: &size, name: "costumic")
        mapper.specify(property: &ext, name: "clearweed")
        mapper.specify(property: &thumbnail, name: "unicell")
        mapper.specify(property: &directory, name: "kcf9ueic_l")
        mapper.specify(property: &video, name: "gaoled")
    }
}

class DirNamespaceData: SuperData {
    var id: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &id, name: "ivoriness")
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
        mapper.specify(property: &file_Id, name: "maulvi")
        mapper.specify(property: &file_meta, name: "drlksgkv_b")
        mapper.specify(property: &create_time, name: "bitterroot")
        mapper.specify(property: &moderate_type, name: "aurilave")
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
        mapper.specify(property: &display_name, name: "fluerics")
        mapper.specify(property: &size, name: "catgut")
        mapper.specify(property: &ext, name: "strands")
        mapper.specify(property: &thumbnail, name: "mainsails")
        mapper.specify(property: &directory, name: "thwaite")
        mapper.specify(property: &video, name: "immersible")
    }
}
