//
//  UploadDownTool.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import Foundation

class UploadDownTool {
    static let instance = UploadDownTool()
    var uploadList: [VideoData] = []
    var downList: [VideoData] = []
    
    // MARK: - upload
    func upload(_ model: VideoData){
        if UploadDownTool.instance.uploadList.count == 0 {
            model.state = .uploadWait
            if model.id.count == 0 {
                model.id = "\(Int(Date().timeIntervalSince1970 * 1000))"
            }
            DispatchQueue.main.async {
                HubDB.instance.updateMovieData(model)
                ToastTool.instance.show("Add the upload list")
            }
            FileUploadTool.instance.initRequest(model)
            UploadDownTool.instance.uploadList.append(model)
            NotificationCenter.default.post(name: Noti_AddUpload, object: nil, userInfo: nil)
        } else {
            DispatchQueue.main.async {
                ToastTool.instance.show("Add the upload list")
                if UploadDownTool.instance.uploadList.contains(where: {$0.date == model.date}) == false {
                    model.state = .uploadWait
                    if model.id.count == 0 {
                        model.id = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    }
                    UploadDownTool.instance.uploadList.append(model)
                    HubDB.instance.updateMovieData(model)
                    NotificationCenter.default.post(name: Noti_AddUpload, object: nil, userInfo: nil)
                }
            }
        }
    }
    
    func uploadNext(_ model: VideoData) {
        UploadDownTool.instance.uploadList.removeAll(where: {$0.date == model.date})
        if let m = UploadDownTool.instance.uploadList.first {
            FileUploadTool.instance.initRequest(m)
        }
    }
    
    // MARK: - down
    func downLoad(_ model: VideoData){
        if self.downList.count == 0 {
            model.state = .downWait
            if model.id.count == 0 {
                model.id = "\(Int(Date().timeIntervalSince1970 * 1000))"
            }
            model.date = Date().timeIntervalSince1970 * 1000
            HubDB.instance.updateMovieData(model)
            self.downList.append(model)
            DownTool.instance.startFile(model)
            NotificationCenter.default.post(name: Noti_AddDown, object: nil, userInfo: nil)
        } else {
            guard let _ = self.downList.first(where: {$0.id == model.id}) else {
                model.state = .downWait
                if model.id.count == 0 {
                    model.id = "\(Int(Date().timeIntervalSince1970 * 1000))"
                }
                model.date = Date().timeIntervalSince1970 * 1000
                HubDB.instance.updateMovieData(model)
                self.downList.append(model)
                NotificationCenter.default.post(name: Noti_AddDown, object: nil, userInfo: nil)
                return
            }
        }
    }
    
    func downNext(_ model: VideoData) {
        self.downList.removeAll(where: {$0.id == model.id})
        if let m = self.downList.first {
            DownTool.instance.startFile(m)
        }
    }
}

