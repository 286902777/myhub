//
//  FolderData.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import HandyJSON

class FolderListData: SuperData {
    var files: [FolderData] = []
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &files, name: "8whmfaxhaz")
    }
}

class FolderData: SuperData {
    var id: String = ""
    var directory: Bool = false
    var video: Bool = false
    var isSelect: Bool = false
    var vid_qty: Int = 0
    var update_time: Double = 0
    var file_meta: FolderFileMetaData = FolderFileMetaData()
    var displayName: FolderDisplayNameData = FolderDisplayNameData()
    var fileName: String {
        get {
            return displayName.caranx
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
        mapper.specify(property: &id, name: "eloin")
        mapper.specify(property: &directory, name: "indesert")
        mapper.specify(property: &video, name: "ranarian")
        mapper.specify(property: &vid_qty, name: "furfooz")
        mapper.specify(property: &update_time, name: "uncrest")
        mapper.specify(property: &file_meta, name: "scallion")
        mapper.specify(property: &displayName, name: "aphylly")///aphylly/caranx
    }
}

class FolderDisplayNameData: SuperData { ///aphylly/caranx
    var caranx: String = ""
}

class FolderFileMetaData: SuperData {
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &size, name: "champions")
        mapper.specify(property: &ext, name: "chimaerid")
        mapper.specify(property: &thumbnail, name: "tenue")
    }
}
