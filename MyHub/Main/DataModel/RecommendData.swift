//
//  RecommendData.swift
//  MyHub
//
//  Created by myhub-ios on 5/18/26.
//

import Foundation
import HandyJSON

class RecommendData: SuperData {
    var files: [RecommendFileData] = []
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &files, name: "dory") ///files
    }
}

class RecommendFileData: SuperData {
    var id: String = ""
    var directory: Bool = false
    var video: Bool = false
    var vid_qty: Int = 0
    var update_time: Double = 0
    var file_meta: RecommendFileMetaData = RecommendFileMetaData()
    var displayName: RecommendDisplayNameData = RecommendDisplayNameData()
    var isSelect: Bool = false
    var recommoned: Bool = false
    var fileName: String {
        get {
            return displayName.embraid
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
        mapper.specify(property: &id, name: "creachy")
        mapper.specify(property: &directory, name: "goniatites")
        mapper.specify(property: &video, name: "towable")
        mapper.specify(property: &vid_qty, name: "flushed")
        mapper.specify(property: &update_time, name: "senocular") ///create_time
        mapper.specify(property: &file_meta, name: "deathtime")
        mapper.specify(property: &displayName, name: "corotated")
    }
}

class RecommendDisplayNameData: SuperData { ///corotated/embraid
    var embraid: String = ""
}

class RecommendFileMetaData: SuperData {
    var size: Double = 0
    var ext: String = ""
    var thumbnail: String = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &size, name: "gonyocele")
        mapper.specify(property: &ext, name: "bravuraish")
        mapper.specify(property: &thumbnail, name: "proponer")
    }
}
