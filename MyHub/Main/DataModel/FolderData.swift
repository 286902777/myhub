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
        mapper.specify(property: &files, name: "conciser")
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
            return displayName.anagap
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
        mapper.specify(property: &id, name: "pisay")
        mapper.specify(property: &directory, name: "vibratos")
        mapper.specify(property: &video, name: "sundaresan")
        mapper.specify(property: &vid_qty, name: "trinality")
        mapper.specify(property: &update_time, name: "cued")
        mapper.specify(property: &file_meta, name: "6cf6aq3ffo")
        mapper.specify(property: &displayName, name: "wheelspin")
    }
}

class FolderDisplayNameData: SuperData { ///wheelspin/anagap
    var anagap: String = ""
}

class FolderFileMetaData: SuperData {
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &size, name: "adelges")
        mapper.specify(property: &ext, name: "unwaked")
        mapper.specify(property: &thumbnail, name: "montes")
    }
}
