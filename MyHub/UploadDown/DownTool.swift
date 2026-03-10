//
//  DownTool.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import Foundation
import UIKit

class DownTool: NSObject, URLSessionDownloadDelegate {
    static let instance = DownTool()
    
    private var downloadTask: URLSessionDownloadTask?
    private var backgroundSession: URLSession?
    private var model: VideoData = VideoData()

    func startFile(_ model: VideoData) {
        if model.platform == .box {
            HttpManager.share.driveDownLoadUrlApi(model.id) { [weak self] status, address, errMsg in
                guard let self = self else { return }
                if status == .success {
                    model.movieAddress = address
                    self.taskDown(model)
                } else {
                    let m = FileTransData()
                    m.state = .downFail
                    m.transId = model.id
                    model.state = .downFail
                    HubDB.instance.updateMovieData(model)
                    NotificationCenter.default.post(name: Noti_Down, object: nil, userInfo: ["mod": m])
                    UploadDownTool.instance.downNext(model)
                    ToastTool.instance.show(errMsg ?? "Download failed!", .fail)
                }
            }
        } else {
            if model.movieAddress.count > 0 {
                self.taskDown(model)
            } else {
                HttpManager.share.requestMovieAddress(model) { status, address, errMsg, refresh in
                    if status == .success {
                        model.movieAddress = address
                        self.taskDown(model)
                    } else {
                        let m = FileTransData()
                        m.state = .downFail
                        m.transId = model.id
                        model.state = .downFail
                        HubDB.instance.updateMovieData(model)
                        NotificationCenter.default.post(name: Noti_Down, object: nil, userInfo: ["mod": m])
                        UploadDownTool.instance.downNext(model)
                        ToastTool.instance.show(errMsg ?? "Download failed!", .fail)
                    }
                }
            }
        }
    }
    
    func taskDown(_ model: VideoData) {
        if let url = URL(string: model.movieAddress) {
            self.model = model
            // 1. 创建后台配置（必须用唯一的 identifier）
            let config = URLSessionConfiguration.background(withIdentifier: "com.myhub.down")
            // 2. 创建 URLSession，并设置 delegate（就是当前 ViewController）
            backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            // 3. 创建下载任务
            downloadTask = backgroundSession?.downloadTask(with: url)
            downloadTask?.resume()
        }
    }
    // MARK: - URLSessionDownloadDelegate
    // 下载过程中，接收到数据时调用（用于更新进度）
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        print(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let m = FileTransData()
            m.state = .downing
            m.transId = DownTool.instance.model.id
            m.doneSize = Double(totalBytesWritten)
            self.model.done_size = m.doneSize
            self.model.state = .downing
            HubDB.instance.updateMovieData(self.model)
            NotificationCenter.default.post(name: Noti_Down, object: nil, userInfo: ["mod": m])
        }
    }
    
    // 下载完成时调用，得到一个临时文件路径
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("file cacheUrl：\(location.path)")
        // 保存到 App 的 Documents 目录
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsDirectory.appendingPathComponent(DownTool.instance.model.id).appendingPathExtension(DownTool.instance.model.ext)
        // 如果已存在，先删除
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try? FileManager.default.removeItem(at: destinationURL)
        }
        
        // 移动临时文件到目标位置
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("file save success：\(destinationURL.path)")
            let m = FileTransData()
            m.state = .downDone
            m.transId = DownTool.instance.model.id
            m.local = destinationURL.lastPathComponent
            self.model.state = .downDone
            self.model.transId = self.model.id
            self.model.movieAddress = m.local
            HubDB.instance.updateMovieData(self.model)
            NotificationCenter.default.post(name: Noti_DownSuccess, object: nil, userInfo: ["mod": m])
            UploadDownTool.instance.downNext(DownTool.instance.model)
        } catch {
            let m = FileTransData()
            m.state = .downFail
            m.transId = DownTool.instance.model.id
            self.model.state = .downFail
            HubDB.instance.updateMovieData(self.model)
            NotificationCenter.default.post(name: Noti_Down, object: nil, userInfo: ["mod": m])
            UploadDownTool.instance.downNext(self.model)
            ToastTool.instance.show("Download failed!", .fail)
        }
    }
    
    // 后台任务全部完成后，系统会调用此方法（但通常你不需要在这里处理文件）
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("🔔 所有后台任务事件已完成")
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.callCompletionHandlerIfAvailable()
            }
        }
        // 注意：你通常需要在这里调用之前保存的 completionHandler（见 AppDelegate）
        // 但由于我们没有保存它，这里只是示意
    }
    
    func cancelReqeust() {
        self.downloadTask?.cancel()
        self.backgroundSession?.invalidateAndCancel()
        self.downloadTask = nil
        self.backgroundSession = nil
    }
}

