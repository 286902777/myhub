//
//  FileUploadTool.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import Foundation
import UniformTypeIdentifiers
import Alamofire
import OBS

class FileUploadTool: NSObject {
    static let instance: FileUploadTool = FileUploadTool()
    var client: OBSClient?
    
    var fileRequest: OBSPutObjectWithFileRequest?
    
    func initRequest(_ model: VideoData) {
        let mimeType = self.mimeType(for: model.ext)
        HttpManager.share.uploadFileApi(model, mime: mimeType ?? "", sign: "") { status, mod, errMsg in
            if status == .success {
                FileUploadTool.instance.uploadBucket(mod, uploadModel: model)
            } else {
                let m = FileTransData()
                m.state = .uploadFaid
                m.transId = model.id
                model.state = .uploadFaid
                HubDB.instance.updateMovieData(model)
                NotificationCenter.default.post(name: Noti_Upload, object: nil, userInfo: ["mod": m])
                UploadDownTool.instance.uploadNext(model)
                ToastTool.instance.show(errMsg ?? "Request fail", .fail)
            }
        }
    }
    
    func uploadBucket(_ model: FileData, uploadModel: VideoData) {
        let pr = OBSStaticCredentialProvider(accessKey: model.access_id, secretKey: model.access_secret)
        pr?.securityToken = model.token
        let config = OBSServiceConfiguration(urlString: "https://\(model.endpoint)", credentialProvider: pr)
        if self.client == nil {
            self.client = OBSClient(configuration: config)
        } else {
            self.client?.refresh(pr, error: nil)
        }
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let localUrl = documentsDirectory.appendingPathComponent(uploadModel.name)
        guard FileManager.default.fileExists(atPath: localUrl.path) else {
            return
        }
        
        self.fileRequest = OBSPutObjectWithFileRequest(bucketName: model.bucket_name, objectKey: model.file_key, uploadFilePath: localUrl.path)
        self.fileRequest?.background = true
        self.fileRequest?.uploadProgressBlock = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
            print("upload:", bytesSent, totalBytesSent, totalBytesExpectedToSend)
            let m = FileTransData()
            m.state = .uploading
            m.transId = uploadModel.id
            m.doneSize = Double(totalBytesSent)
            uploadModel.upload_size = m.doneSize
            uploadModel.state = .uploading
            HubDB.instance.updateMovieData(uploadModel)
            NotificationCenter.default.post(name: Noti_Upload, object: nil, userInfo: ["mod": m])
        }
        self.client?.putObject(self.fileRequest) { response, error in
            if let res = response, Int(res.statusCode) == 200 {
                print("upload success")
                HttpManager.share.uploadResultApi(model.id) { status, mod, errMsg in
                    DispatchQueue.main.async {
                        if status == .success {
                            let m = FileTransData()
                            m.state = .upload
                            m.transId = uploadModel.id
                            m.obs_fileId = mod.obs_fileId
                            uploadModel.obs_fileId = mod.obs_fileId
                            uploadModel.state = .upload
                            HubDB.instance.updateMovieData(uploadModel)
                            NotificationCenter.default.post(name: Noti_UploadSuccess, object: nil, userInfo: ["mod": m])
                            UploadDownTool.instance.uploadList.removeAll(where: {$0.date == uploadModel.date})
                            UploadDownTool.instance.uploadNext(uploadModel)
                        } else {
                            ToastTool.instance.show(errMsg ?? "Request fail", .fail)
                            let m = FileTransData()
                            m.state = .uploadFaid
                            m.transId = uploadModel.id
                            uploadModel.state = .uploadFaid
                            uploadModel.upload_size = 0
                            HubDB.instance.updateMovieData(uploadModel)
                            NotificationCenter.default.post(name: Noti_Upload, object: nil, userInfo: ["mod": m])
                            UploadDownTool.instance.uploadNext(uploadModel)
                        }
                    }
                }
            } else {
                print("upload fail")
                DispatchQueue.main.async {
                    let m = FileTransData()
                    m.state = .uploadFaid
                    m.transId = uploadModel.id
                    uploadModel.state = .uploadFaid
                    uploadModel.upload_size = 0
                    HubDB.instance.updateMovieData(uploadModel)
                    NotificationCenter.default.post(name: Noti_Upload, object: nil, userInfo: ["mod": m])
                    UploadDownTool.instance.uploadNext(uploadModel)
                }
            }
        }
    }
    
    func cancelRequest() {
        self.fileRequest?.cancel()
    }
    
    func mimeType(for fileExtension: String) -> String? {
        guard let uttype = UTType(filenameExtension: fileExtension) else {
            return nil
        }
        return uttype.preferredMIMEType
    }
}

