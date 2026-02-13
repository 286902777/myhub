//
//  HttpManager.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import AdSupport
import CryptoSwift
import CoreTelephony
import HandyJSON

enum BackEventName: String {
    case adv_profit = "a" //广告收益
    case play_video = "b" //播放视频
    case view_app = "c" //承接页打开链接
    case down_video = "d" // 下载文件
    case down_app = "e" //下载App
//    case app_adv_profit = "app_adv_profit" //app本地广告收益
//    case app_play_video = "app_play_video" //app本地视频播放
    case new_user_active_by_play_video = "f"//用户下载app，并完成一次播放后触发事件
    case download_app_first_time_open = "s"
}

enum HttpApi: String {
    case login = "serrano/boza/villae" ///login/app/ios
    case deleteUser = "doubleted/as2rkgjrhj/canacuas" /// app/user/delete
    case uploadFile = "houlet/restudies/incanous/overhating" ///app/file/local/upload
    case uploadResult = "confounds/semifluid/fixing" /// app/file/upload_callback
    case userSpace = "onanistic/sketchlike/sko_uph0gg" /// app/user/space
    case deleteFile = "emparl/widegab/nucleotide" /// app/file/delete_files
    case createFolder = "spurlike/nonnumeral/pitsaw"  /// app/file/create_directory
    case lsDir = "plumbago/peerless/sampi/chases" /// app/user/file/list
  
    case fixName = "spagnuolo/dahoman/cimbal"  ///  app/file/rename_file
    case shareFile = "indorsable/idrisid/conditione"  /// app/file/share_files
    case downLoadUrl = "6twb5vdamb/evangels/bauno"  ///app/file/download_url
    case selectFiles = "unparallel/ghzb2txj6l/amoritish/kgsxniyaxn"  /// app/user/file/list_by_file_ids
    case openShareUrl = "braker/raying/steppe"  /// app/user_share_link/open
    case openFolder = "ammoniuret/isoelastic/artemision"   ///app/file/list_by_parent

    /// 承接页接口
    case channel = "v12"  /// v1/app/open/data
    case download = "v1asf"     /// v1/app/download/file/
    case folder = "v1/asdf"     /// v1/app/open/file/{uid}/{dirId}
    case event = "v1/sdfs"              /// v1/app/events
    case recommendChannel = "v1/njejxa0kpo"/// v1/app/push_operation_pools
}

enum HttpHeadValue: String {
    case login = "ghegish"
    case deleteUser = "sneakily"
    case uploadFile = "x9pj1ybtq0"
    case uploadCall = "harmonize"
    case userSpace = "abos"
    case deleteFile = "jfe5lc73rp"
    case createFolder = "stokavian"
    case lsDir = "pocking"
    case fixName = "snoring"
    case shareFile = "platysmata"
    case downLoadUrl = "brazilians"
    case selectFiles = "guardable"
    case openShareUrl = "viricide"
    case openFolder = "shrubbish"
}

class HttpManager {
    static let share = HttpManager()
    
    let userHeadKey: String = "kinspeople" // x-api-id
    
    let appHeadKey: String = "2as"
    
    let tokenKey: String = "X-Token"
    
    let userHost: String = "https://xbox2c-test-myhub.tbxbxdev.com/"
    
    let userHostAddress: String = "xbox2c-test-myhub.tbxbxdev.com"
    
    var appHost: String = "https://c.sdbfsf.com/"
    
    let pageSize: Int = 500
    //MARK: - Login
    
    func loginApi(_ token: String, _ completion: @escaping (_ status: HttpCode, _ model: UserData, _ errMsg: String?) -> ()) {
        let para: [String: Any] = ["areawide": token] //access_token
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.login.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.login.rawValue, forHTTPHeaderField: userHeadKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = UserData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, UserData(), "Request fail!")
                }
            default:
                completion(status, UserData(), "Login failed!")
                return
            }
        })
        task.resume()
    }
    
    func deleteUserApi(_ completion: @escaping (_ status: HttpCode, _ model: UserDeleteData, _ errMsg: String?) -> ()) {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.deleteUser.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.deleteUser.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = UserDeleteData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, UserDeleteData(), "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, UserDeleteData(), nil)
            default:
                completion(status, UserDeleteData(), error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    // MARK: - file
    func uploadFileApi(_ mod: VideoData, mime: String, sign: String, _ completion: @escaping (_ status: HttpCode, _ model: FileData, _ errMsg: String?) -> ()) {
        //        "namespace": "用户id",
        //        "file_meta":
        //        {
        //            "directory_id": "6eb6c9b2-34f3-4fe9-b048-334154a10011",
        //            "display_name": "hello.worlsd.txt",
        //            "size": 122,
        //            "mime_type": "text/plain",
        //            "extension": "txt",
        //            "content_sign": "xxxx"
        //        }
        var para: [String: Any] = [:]
        para["entr"] = LoginManager.share.userId ///namespace
        let fileMeta: [String: Any] = ["roxy": mod.parent_id,
                                       "asynaptic": mod.name,
                                       "filicites": mod.file_size,
                                       "atmosteon": mime,
                                       "fulminates": mod.ext,
                                       "tsere": sign
        ]
        para["amidated"] = fileMeta
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.uploadFile.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.uploadFile.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = FileData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, FileData(), "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, FileData(), nil)
            default:
                completion(status, FileData(), "Request fail!")
                return
            }
        })
        task.resume()
    }
    
    func uploadResultApi(_ transferId: String, _ completion: @escaping (_ status: HttpCode, _ model: FileCallData, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["illy"] = LoginManager.share.userId ///namespace
        para["ferrule"] = transferId // transfer_id
        para["qszs_s26zd"] = true /// ok
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.uploadResult.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.uploadCall.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = FileCallData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, FileCallData(), "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, FileCallData(), nil)
            default:
                completion(status, FileCallData(), error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func getBoxSpaceApi(_ completion: @escaping (_ status: HttpCode, _ model: UserSpaceData, _ errMsg: String?) -> ()) {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.userSpace.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.userSpace.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = UserSpaceData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, UserSpaceData(), "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, UserSpaceData(), nil)
            default:
                completion(status, UserSpaceData(), error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func deleteFileApi(_ list: [VideoData], _ completion: @escaping (_ status: HttpCode, _ errMsg: String?) -> ()) {
        let fileIds = list.map({$0.id})
        var para: [String: Any] = [:]
        para["affronty"] = LoginManager.share.userId ///namespace
        para["scungili"] = fileIds // fileIds
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.deleteFile.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.deleteFile.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            DispatchQueue.main.async {
                switch status {
                case .success:
                    fileIds.forEach { id in
                        if let m = list.first(where: {$0.id == id || $0.obs_fileId == id}) {
                            m.state = .normal
                            HubDB.instance.updateMovieData(m)
                        }
                    }
                    NotificationCenter.default.post(name: Noti_DeleteFileSuccess, object: nil, userInfo: ["list": fileIds])
                    completion(status, nil)
                case .permission:
                    HttpManager.share.premissonLaterLogin()
                    completion(status, nil)
                default:
                    completion(status, error?.localizedDescription)
                    return
                }
            }
        })
        task.resume()
    }
    func createFolderApi(parentId: String, fileName: String, _ completion: @escaping (_ status: HttpCode, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        
        para["triplanes"] = LoginManager.share.userId ///namespace
        para["prejudges"] = parentId // parent_id
        para["oryx"] = fileName /// filename
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.createFolder.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.createFolder.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                completion(status, nil)
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, nil)
            default:
                completion(status, error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func selectFolderApi(_ parent_id: String, _ completion: @escaping (_ status: HttpCode, _ list: [VideoData], _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["surnames"] = LoginManager.share.userId ///namespace
        para["becram"] = parent_id // parent_id
        para["debited"] = 0 /// page_number
        para["beefcake"] = pageSize /// page_size
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.lsDir.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.lsDir.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    var result: [VideoData] = []
                    if let list = [DirFileData].deserialize(from: json) {
                        DispatchQueue.main.async {
                            let localList = HubDB.instance.readDatas()
                            list.forEach { mm in
                                guard let m = mm, m.file_id.count > 0 else { return }
                                if let localModel = localList.first(where: {$0.id == m.file_id}) {
                                    result.append(localModel)
                                } else {
                                    let mod = VideoData()
                                    mod.pubData = m.create_time
                                    mod.file_type = m.file_type
                                    mod.thumbnail = m.file_meta.thumbnail
                                    mod.name = m.file_meta.display_name
                                    mod.id = m.file_id
                                    mod.file_size = m.file_meta.size
                                    mod.size = m.file_meta.size.computeFileSize()
                                    mod.ext = m.file_meta.ext
                                    mod.isNet = true
                                    mod.isPass = m.moderate_type
                                    result.append(mod)
                                }
                            }
                            completion(status, result, nil)
                        }
                    }
                } else {
                    completion(status, [], "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, [], nil)
            default:
                completion(status, [], error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func selectFilesApi(_ file_ids: [String], _ completion: @escaping (_ status: HttpCode, _ list: [VideoData], _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["scholarity"] = LoginManager.share.userId ///namespace
        para["gamesomely"] = file_ids // file_ids
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.selectFiles.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.selectFiles.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    var result: [VideoData] = []
                    if let list = [SubFilesData].deserialize(from: json) {
                        let localList = HubDB.instance.readDatas()
                        DispatchQueue.main.async {
                            list.forEach { mm in
                                guard let m = mm else { return }
                                if let localModel = localList.first(where: {$0.id == m.file_Id}) {
                                    result.append(localModel)
                                } else {
                                    let mod = VideoData()
                                    mod.date = m.create_time
                                    mod.file_type = m.file_type
                                    mod.thumbnail = m.file_meta.thumbnail
                                    mod.name = m.file_meta.display_name
                                    mod.id = m.file_Id
                                    mod.file_size = m.file_meta.size
                                    mod.size = m.file_meta.size.computeFileSize()
                                    mod.ext = m.file_meta.ext
                                    mod.isNet = true
                                    mod.isPass = m.moderate_type
                                    result.append(mod)
                                }
                            }
                            completion(status, result, nil)
                        }
                    }
                } else {
                    completion(status, [], "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, [], nil)
            default:
                completion(status, [], error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func reNameFileApi(fileId: String, fileName: String, _ completion: @escaping (_ status: HttpCode, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["bernicles"] = LoginManager.share.userId ///namespace
        para["nullbiety"] = fileId // file_id
        para["ayahuca"] = fileName /// filename
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.fixName.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.fixName.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                completion(status, nil)
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, nil)
            default:
                completion(status, error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func shareFileApi(_ list: [VideoData], _ date: HUB_ShareDateType, _ completion: @escaping (_ status: HttpCode, _ model: ShareRootData, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        var arr: [[String: Any]] = []
        list.forEach { m in
            var subPara: [String: Any] = [:]
            subPara["behavioral"] = m.id
            subPara["onondaga"] = m.file_type == .folder ? HUB_ShareFileType.directory.rawValue : HUB_ShareFileType.file.rawValue
            arr.append(subPara)
        }
        para["boordly"] = LoginManager.share.userId ///namespace
        para["frapler"] = HUB_ShareType.file.rawValue // share_type
        if date != .none {
            para["pfnzojbksy"] = date.rawValue /// "NONE/DAY/MONTH/WEEK",
            para["uwdstbx2qv"] = 1
        }
        para["chow"] = arr
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.shareFile.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.shareFile.rawValue, forHTTPHeaderField: userHeadKey)
        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = ShareRootData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, ShareRootData(), "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, ShareRootData(), nil)
            default:
                completion(status, ShareRootData(), error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    
    func driveDownLoadUrlApi(_ fileId: String, _ completion: @escaping (_ status: HttpCode, _ address: String, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        if LoginManager.share.isLogin {
            para["blaewort"] = LoginManager.share.userId
        } else {
            para["blaewort"] = HubTool.share.boxUId
        }///namespace
        para["unspoil"] = fileId // fileId
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.downLoadUrl.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.downLoadUrl.rawValue, forHTTPHeaderField: userHeadKey)
//        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    if let json = String(data: info, encoding: .utf8), let address = json.AESMovieAddress(), address.count > 0 {
                        completion(status, address, nil)
                    }
                } else {
                    completion(.other, "", "Request fail!")
                }
            case .permission:
                HttpManager.share.premissonLaterLogin()
                completion(status, "", nil)
            default:
                completion(status, "", error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
//    func selectReView(_ currentPage: Int, _ completion: @escaping (_ status: HttpCode, _ list: [ReviewData], _ errMsg: String?) -> ()) {
//        var para: [String: Any] = [:]
//        para["dims"] = LoginManager.share.userId ///namespace
//        //        para["disulfoton"] = "" // file_id
//        para["epichirema"] = currentPage // page_number
//        para["implume"] = 20 // page_size
//        //        para["leisten"] = ["createTime__DESC"] // sort
//
//        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
//        let session: URLSession = URLSession(configuration: configuration)
//        let url: String = userHost + HttpApi.selectReview.rawValue
//        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
//        request.setValue(HttpHeadValue.selectReview.rawValue, forHTTPHeaderField: userHeadKey)
//        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
//
//        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
//            request.httpBody = pa
//        }
//        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
//            let status = self.getCode(response)
//            switch status {
//            case .success:
//                if let info = data {
//                    let json = String(data: info, encoding: .utf8)
//                    if let mod = ReviewRootData.deserialize(from: json) {
//                        completion(status, mod.records, nil)
//                    }
//                } else {
//                    completion(status, [], "Request fail!")
//                }
//            case .permission:
//                HttpManager.share.premissonLaterLogin()
//            default:
//                completion(status, [], error?.localizedDescription)
//                return
//            }
//        })
//        task.resume()
//    }
    
    // MARK: - Open Share Url
    func getShareUrlApi(_ linkId: String, _ currentPage: Int, _ completion: @escaping (_ status: HttpCode, _ model: OpenRootData, _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["acetine"] = linkId           /// linkId
        para["laplandish"] = currentPage  /// page_number
        para["elric"] = 20        /// page_size
//        para["qqrdyn8f5o"] = ""
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.openShareUrl.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.openShareUrl.rawValue, forHTTPHeaderField: userHeadKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = OpenRootData.deserialize(from: json) {
                        completion(status, model, nil)
                    }
                } else {
                    completion(status, OpenRootData(), "Request fail!")
                }
            case .permission:
                completion(status, OpenRootData(), nil)
            default:
                completion(status, OpenRootData(), error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    func getShareFolderApi(_ userId: String, _ parentId: String, _ currentPage: Int, _ completion: @escaping (_ status: HttpCode, _ list: [VideoData], _ errMsg: String?) -> ()) {
        var para: [String: Any] = [:]
        para["communis"] = userId      /// namespace
        para["aeried"] = parentId /// parentId
        para["beautihood"] = currentPage  /// page_number
        para["shushes"] = 20          /// page_size
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = userHost + HttpApi.openFolder.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HttpManager.share.userHostAddress, forHTTPHeaderField: "host")
        request.setValue(HttpHeadValue.openFolder.rawValue, forHTTPHeaderField: userHeadKey)
        //        request.setValue(LoginManager.share.userToken, forHTTPHeaderField: tokenKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let list = [OpenFolderData].deserialize(from: json) {
                        DispatchQueue.main.async {
                        let localList = HubDB.instance.readDatas()
                        var result: [VideoData] = []
                            list.forEach { mm in
                                if let m = mm {
                                    if let localModel = localList.first(where: {$0.id == m.file_id}) {
                                        result.append(localModel)
                                    } else {
                                        let mod = VideoData()
                                        mod.id = m.file_id
                                        mod.file_size = m.file_meta.size
                                        mod.size = "\(m.file_meta.size.computeFileSize())"
                                        mod.ext = m.file_meta.ext
                                        mod.isNet = true
                                        mod.pubData = m.create_time
                                        mod.name = m.file_meta.display_name
                                        mod.thumbnail = m.file_meta.thumbnail
                                        mod.file_type = m.file_type
                                        mod.vid_qty = m.vid_qty
                                        mod.parent_id = m.parent_id
                                        mod.isPass = m.moderate_type
                                        mod.userId = m.namespace.id
                                        result.append(mod)
                                    }
                                }
                            }
                            completion(status, result, nil)
                        }
                    }
                } else {
                    completion(status, [], "Request fail!")
                }
            case .permission:
                completion(status, [], nil)
            default:
                completion(status, [], error?.localizedDescription)
                return
            }
        })
        task.resume()
    }
    
    // MARK: - Channel
    func channel(_ linkId: String, _ uId: String, _ page: Int, _ completion: @escaping (_ status: HttpCode, _ model: ChannelListData, _ errMsg: String?, _ refresh: Bool) -> ()) {
        //        {
        //            "uid":"1653997851574104066",
        //            "channel_id":"1653997851574104066",
        //            "link_id": "1653997851574104066",
        //            "version":"v2",
        //            "current_page":1, //页码
        //            "page_size":50 //分页大小
        //        }
        let para: [String: Any] = ["pharmacist": uId,
                                   "mauve": ["hypocaust": linkId],
                                   "mistrysted":"v2",
                                   "eds": page,
                                   "overran": pageSize]
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let url: String = appHost + HttpApi.channel.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("transiting", forHTTPHeaderField: appHeadKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = ChannelListData.deserialize(from: json) {
                        completion(status, model, nil, false)
                    }
                } else {
                    completion(status, ChannelListData(), "Request fail!", false)
                }
            default:
                completion(status, ChannelListData(), "Request fail!", HttpManager.share.refreshAppHostUrl())
                return
            }
        })
        task.resume()
    }
    
    func channelUserList(_ uId: String, _ platform: HUB_PlatformType, _ completion: @escaping (_ status: HttpCode, _ list: [ChannelRecommedData], _ errMsg: String?, _ refresh: Bool) -> ()) {
        let url: String = appHost + HttpApi.recommendChannel.rawValue

        var plabs: [[String: String]] = []
        let dbList = HubDB.instance.readUsers().filter({$0.platform == platform})

        dbList.forEach { users in
            users.labels.forEach { item in
                let spara: [String: String] = ["weneth": item.id,
                                               "doqzea0ily": item.label_name,
                                               "manhandled": item.first_label_code,
                                               "sonants": item.second_label_code]
                plabs.append(spara)
            }
        }
        
        var para: [String: Any] = [:]
        para["checkage"] = uId
        para["flashlight"] = "ios"
        para["acker"] = Locale.current.identifier
        para["inceptors"] = ["coontie": plabs]

        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("proviant", forHTTPHeaderField: appHeadKey)
        
        if let pa = try? JSONSerialization.data(withJSONObject: para, options: []) {
            request.httpBody = pa
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let list = [ChannelRecommedData].deserialize(from: json) {
                        var results: [ChannelRecommedData] = []
                        list.forEach { mmm in
                            if let mod = mmm {
                                results.append(mod)
                            }
                        }
                        completion(status, results, nil, false)
                    }
                } else {
                    completion(status, [], "Request fail!", false)
                }
            default:
                completion(status, [], "Request fail!", HttpManager.share.refreshAppHostUrl())
                return
            }
        })
        task.resume()
    }
    
    func folderData(uId: String, dirId: String, currentPage: Int = 1, _ completion: @escaping (_ status: HttpCode, _ list: [FolderData],  _ errMsg: String?, _ refresh: Bool) -> Void) {
        let url: String = appHost + HttpApi.folder.rawValue + "/\(uId)" + "/\(dirId)" + "?malope=\(currentPage)&duomos=\(pageSize)"
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        request.setValue("glut", forHTTPHeaderField: appHeadKey)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    let json = String(data: info, encoding: .utf8)
                    if let model = FolderListData.deserialize(from: json) {
                        completion(status, model.files, nil, false)
                    }
                } else {
                    let newHost = HttpManager.share.refreshAppHostUrl()
                    completion(status, [], newHost ? "" : "Request fail!", newHost)
                }
            default:
                let newHost = HttpManager.share.refreshAppHostUrl()
                completion(status, [], newHost ? "" : "Request fail!", newHost)
                return
            }
        })
        task.resume()
    }
    
    func requestMovieAddress(_ model: VideoData, _ completion: @escaping (_ status: HttpCode, _ address: String, _ errMsg: String?, _ refresh: Bool) -> ()){
        let url: String = appHost + HttpApi.download.rawValue + "/\(model.userId)" + "/\( model.id)"
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("sluggish", forHTTPHeaderField: appHeadKey)
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            let status = self.getCode(response)
            switch status {
            case .success:
                if let info = data {
                    if let json = String(data: info, encoding: .utf8), let address = json.AESMovieAddress(), address.count > 0 {
                        completion(status, address, nil, false)
                    }
                } else {
                    let newHost = HttpManager.share.refreshAppHostUrl()
                    completion(.other, "", newHost ? "" : "Request fail!", newHost)
                }
            default:
                let newHost = HttpManager.share.refreshAppHostUrl()
                completion(status, "", newHost ? "" : "Request fail!", newHost)
            }
        })
        task.resume()
    }
    
    // MARK: - event upload
    func uploadEventApi(event: BackEventName, currency: String, val: Double, model: VideoData, _ complete: @escaping (_ success: Bool) -> Void) {
        print("_______sexxxx\(model.userId),\(model.linkId),\(event.rawValue),\(model.platform.rawValue)")
        let para: [String : Any] = ["anticomet": ["tommer": NetManager.instance.networkName], // network_type
                                    "fernery": ["unbrooch": HUB_BuildId], // bundle_id
                                    "vintress": self.appPrimaryKey(), //"app下载事件上报的唯一id，同一设备多次下载app,id不变"
                                    "decuples": event.rawValue, // event_type
                                    "ribaldish": ["huntsmen": HubTool.share.eventSource.rawValue], // event_soucre
                                    "exhalants": model.userId, // uId
                                    "sonnetised": model.linkId, // link_id
                                    "gibberose": currency, // cur
                                    "disparpled": val, // val
                                    "upstream": UUID().uuidString, // logId
                                    "digraph": model.id,  // file_id
                                    "araneae": UIDevice.current.identifierForVendor?.uuidString ?? "", // idfv
                                    "dupla": ASIdentifierManager.shared().advertisingIdentifier.uuidString, // idfa
                                    "vj8kj91nn1": self.getOperator(), // operator
                                    "malaxation": UIDevice.current.systemVersion, // os_version
                                    "tree": self.getAppUUID(), // distinctId
                                    "tammy": ["gwgcxlu83j": ["90ztcis93d": self.getTreeKey()]],
                                    //device_model
                                    "chatterer": "ios", // os
                                    "defervesce": "\(Locale.current.languageCode ?? "en")_\(Locale.current.regionCode ?? "US")", // system_language
                                    "mapo": "Apple", // manufacturer
                                    "pressel": Int(Date().timeIntervalSince1970 * 1000), // client_ts
                                    "primost": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0" // app_version
                                    ]
        let url: String = appHost + HttpApi.event.rawValue
        var request: URLRequest = URLRequest(url: URL(string: url)!, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("pleonast", forHTTPHeaderField: appHeadKey)

        if let pa = try? JSONSerialization.data(withJSONObject: [para], options: []) {
            let aseStr = self.AESEventKey(pa)
            let d_arr: [String: String] = ["barfing": aseStr]  //ciphertext
            if let aseBody = try? JSONSerialization.data(withJSONObject: d_arr, options: []) {
                request.httpBody = aseBody
            }
            print("_______parassss:\(aseStr)")
        }
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
             if let _ = error {
                 let refresh = HttpManager.share.refreshAppHostUrl()
                print("_______se\(model.userId),\(model.linkId),\(event.rawValue),\(model.platform.rawValue)")
                complete(refresh == false)
            } else {
                if let d = data {
                    do {
                        let boolValue = try JSONDecoder().decode(Bool.self, from: d)
                        complete(boolValue)
                    } catch {
                        let refresh = HttpManager.share.refreshAppHostUrl()
                        print("_serviceInfo______success\(model.userId),\(model.linkId),\(event.rawValue),\(model.platform.rawValue)")
                        complete(refresh == false)
                    }
                }
            }
        })
        task.resume()
    }
    
    func AESEventKey(_ data: Data) -> String {
        var bts: [UInt8] = []
        var key = "WJyFG"
        key = "1HbwVH" + key + "y0Gnt3q"
        key = "NodheqTX" + key + "KUBgGD" ///NodheqTX1HbwVHWJyFGy0Gnt3qKUBgGD
        var offv = "38c9Z2"
        offv = "2Xk4dLo" + offv
        offv = offv + "Q2a"
//        #if DEBUG
//        let token = "kCXpPZnxCut7LohE6J1r5tHL75CwBMQU"
//        let offv = "2Xk4dLo38c9Z2Q2a"
//        #endif
        do {
            bts = try AES(key: key, iv: offv, padding: .pkcs5).encrypt(data.bytes)
        } catch {}
        let code = Data(bts)
        return code.base64EncodedString()
    }
    
    func premissonLaterLogin() {
        DispatchQueue.main.async {
            if let vc = HubTool.share.keyVC() {
//                LoginManager.share.loginRequest(vc) { _ in }
            }
        }
    }
    
    func appPrimaryKey() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: HUB_BuildId,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data, let value = String(data: retrievedData, encoding: .utf8) {
            return value
        } else {
            let uuId: String = UUID().uuidString
            let valueData = uuId.data(using: .utf8, allowLossyConversion: false)!
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: HUB_BuildId,
                kSecValueData as String: valueData,
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
            return uuId
        }
    }
    
    func getTreeKey() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    func getAppUUID() -> String {
        if let userID = UserDefaults.standard.value(forKey: app_uuid_key) as? String {
            debugPrint("userID: \(userID)")
            return userID
        } else {
            let userID = UUID().uuidString
            UserDefaults.standard.set(userID, forKey: app_uuid_key)
            debugPrint("userID: \(userID)")
            return userID
        }
    }
    
    func getOperator() -> String {
        var result = ""
        let info = CTTelephonyNetworkInfo()
        if let providers = info.serviceSubscriberCellularProviders {
            let values = providers.values
            if let name = values.first {
                result = name.carrierName ?? ""
            }
        }
        return result
    }
}

extension HttpManager {
    enum HttpCode: Int {
        case success = 200
        case paraInvalid = 400
        case permission = 401
        case other
    }
    
    func refreshAppHostUrl() -> Bool {
        var url: String = ""
        let threeList: [String] = ["https://api.ss.com/", "https://api.sds.com/"]
        let middleList: [String] = ["https://api.sdf.com/", "https://api.sdsaa.com/"]
        if HubTool.share.platform == .cash {
            if HttpManager.share.appHost == threeList.last {
                return false
            }
            url = threeList.filter({$0 != HttpManager.share.appHost}).first ?? "https://api.ssd.com/"
        } else {
            if HttpManager.share.appHost == middleList.last {
                return false
            }
            url = middleList.filter({$0 != HttpManager.share.appHost}).first ?? "https://api.sda.com/"
        }
        HttpManager.share.appHost = url
        return true
    }
    
    func getCode(_ response: URLResponse?) -> HttpCode {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .other
        }
        let statusCode = httpResponse.statusCode
        return HttpCode(rawValue: statusCode) ?? .other
    }
}

