//
//  HubDB.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import Realm
import RealmSwift
import HandyJSON

class HubDB {
    static let instance = HubDB()
    var realm: Realm?
    
    func config() {
        let ver: UInt64 = 1
        guard let p = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return
        }
        let path = p as String
        var dbPath = ""
        if LoginManager.share.userUserId.count > 0 {
            dbPath = path.appending("/\(LoginManager.share.userId).realm")
        } else {
            dbPath = path.appending("/not_account.realm")
        }
        
        guard let url: URL = URL(string: dbPath) else { return }
        let config = Realm.Configuration(fileURL: url, inMemoryIdentifier: nil, encryptionKey: nil, readOnly: false, schemaVersion: ver, migrationBlock: { (mig, version) in
        }, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
        Realm.Configuration.defaultConfiguration = config
    }
    
    func getDataBaseData() -> Realm? {
        guard let p = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        let path = p as String
        var dbPath = ""
        if LoginManager.share.userUserId.count  > 0 {
            dbPath = path.appending("/\(LoginManager.share.userId).realm")
        } else {
            dbPath = path.appending("/not_account.realm")
        }
        
        do {
            if let url = URL(string: dbPath) {
                let config = try Realm(fileURL: url)
                return config.isInWriteTransaction ? nil : config
            } else {
                return nil
            }
        } catch( let error as NSError) {
            print("error domain：\(error.domain)")
            print("code：\(error.code)") // 重点：看看是不是 10
            print("error info：\(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - User info
    func getUserInfo(_ id: String) -> ChannelUserRealm?{
        let list = self.selectData(ChannelUserRealm())
        if let user = list.first(where: {$0.id == id}) {
            return user
        } else {
            return nil
        }
    }
    
    func updateUserInfo(_ user: ChannelUserData) {
        if let uModel = self.getUserInfo(user.id) {
            if let realm = self.getDataBaseData() {
                do {
                    try realm.write {
                        uModel.name = user.name
                        uModel.account = user.account
                        uModel.email = user.email
                        uModel.thumbnail = user.thumbnail
                        uModel.platform = user.platform.rawValue
                        uModel.date = Double(Date().timeIntervalSince1970 * 1000)
                        uModel.labels = user.labels.toJSONString() ?? ""
                    }
                } catch {}
            }
        } else {
            self.addData(self.userToRealm(user))
        }
    }
    
    func userToRealm(_ user: ChannelUserData) -> ChannelUserRealm {
        let uModel: ChannelUserRealm = ChannelUserRealm()
        uModel.id = user.id
        uModel.name = user.name
        uModel.account = user.account
        uModel.email = user.email
        uModel.thumbnail = user.thumbnail
        uModel.platform = user.platform.rawValue
        uModel.date = Double(Date().timeIntervalSince1970 * 1000)
        uModel.labels = user.labels.toJSONString() ?? ""
        return uModel
    }
    
    func selectUserInfo(_ id: String) -> ChannelUserData? {
        let list = self.selectData(ChannelUserRealm())
        if let item = list.first(where: {$0.id == id}) {
            let mod: ChannelUserData = ChannelUserData()
            mod.id = item.id
            mod.name = item.name
            mod.account = item.account
            mod.email = item.email
            mod.platform = HUB_PlatformType(rawValue: item.platform) ?? .box
            mod.thumbnail = item.thumbnail
            if let json = item.labels.data(using: .utf8) {
                do {
                    var labArr: [ChannelUserLabelData] = []
                    if let labs = try JSONSerialization.jsonObject(with: json, options: []) as? [[String: String]] {
                        for lab in labs {
                            if let m = ChannelUserLabelData.deserialize(from: lab) {
                                labArr.append(m)
                            }
                        }
                    }
                    mod.labels = labArr
                } catch {
                    
                }
            }
            return mod
        } else {
            return nil
        }
    }
    
    func readUsers() -> [ChannelUserData] {
        let list = self.selectData(ChannelUserRealm()).sorted(by: {$0.date > $1.date})
        var datas: [ChannelUserData] = []
        for item in list {
            let mod: ChannelUserData = ChannelUserData()
            mod.id = item.id
            mod.name = item.name
            mod.account = item.account
            mod.email = item.email
            mod.platform = HUB_PlatformType(rawValue: item.platform) ?? .cash
            mod.thumbnail = item.thumbnail
            if let json = item.labels.data(using: .utf8) {
                do {
                    var labArr: [ChannelUserLabelData] = []
                    if let labs = try JSONSerialization.jsonObject(with: json, options: []) as? [[String: String]] {
                        for lab in labs {
                            if let m = ChannelUserLabelData.deserialize(from: lab) {
                                labArr.append(m)
                            }
                        }
                    }
                    mod.labels = labArr
                } catch {
                    
                }
            }
            datas.append(mod)
        }
        return datas
    }
    
    func addData<T>(_ data: T) {
        if let realm = self.getDataBaseData() {
            do {
                try realm.write {
                    realm.add(data as! Object, update: Realm.UpdatePolicy.modified)
                }
            } catch {
                print("ss")
            }
        }
    }
    
    func addDatas<T>(_ datas: [T]) -> Void {
        if let realm = self.getDataBaseData() {
            do {
                try realm.write {
                    realm.add(datas as! [Object])
                }
            } catch {}
        }
    }
    
    func removeData<T>(_ data: T) {
        if let realm = self.getDataBaseData() {
            do {
                try realm.write {
                    realm.delete(data as! Object)
                }
            } catch {}
        }
    }
    
    func removeDatas<T>(_ datas: [T]) -> Void {
        if let realm = self.getDataBaseData() {
            do {
                try realm.write {
                    realm.delete(datas as! [Object])
                }
            } catch {}
        }
    }
    
    func selectData<T>(_ dataClass: T, info: String? = nil) -> [T] {
        if let realm = self.getDataBaseData() {
            var list: Results<Object>
            if let inf = info {
                list = realm.objects((T.self as! Object.Type).self).filter(inf)
            } else {
                list = realm.objects((T.self as! Object.Type).self)
            }
            guard list.count > 0 else { return [] }
            var arr: [T] = []
            for item in list {
                if let mod = item as? T {
                    arr.append(mod)
                }
            }
            return arr
        } else {
            return []
        }
    }
    
    // MARK: - page
    func selectRealm(_ id: String) -> VideoDataRealm?{
        let list = self.selectData(VideoDataRealm())
        if let model = list.first(where: {$0.id == id}) {
            return model
        } else {
            return nil
        }
    }
    
    func updateMovieData(_ model: VideoData) {
        if let rModel = self.selectRealm(model.id) {
            if let realm = self.getDataBaseData() {
                do {
                    try realm.write {
                        rModel.state = model.state.rawValue
                        rModel.isPass = model.isPass.rawValue
                        rModel.name = model.name
                        rModel.size = model.size
                        rModel.done_size = model.done_size
                        rModel.upload_size = model.upload_size
                        rModel.file_size = model.file_size
                        rModel.userId = model.userId
                        rModel.ext = model.ext
                        rModel.isShare = model.isShare
                        rModel.movieAddress = model.movieAddress
                        rModel.playTime = model.playTime
                        rModel.totalTime = model.totalTime
                        rModel.imageData = model.image?.pngData()
                        rModel.isNet = model.isNet
                        rModel.thumbnail = model.thumbnail
                        rModel.pubData = model.pubData
                        rModel.file_type = model.file_type.rawValue
                        rModel.vid_qty = model.vid_qty
                        rModel.history = model.history
                        rModel.email = model.email
                        rModel.linkId = model.linkId
                        rModel.transId = model.transId
                        rModel.platform = model.platform.rawValue
                        rModel.date = model.date
                        rModel.transId = model.transId
                        rModel.obs_fileId = model.obs_fileId
                    }
                } catch {
                    print("sbbbs")
                }
            }
        } else {
            self.addData(self.modelToRealm(model))
        }
    }
    
    func modelToRealm(_ model: VideoData) -> VideoDataRealm {
        let rModel: VideoDataRealm = VideoDataRealm()
        if model.id.count == 0 {
            rModel.id = "\(Int(Date().timeIntervalSince1970 * 1000))"
        } else {
            rModel.id = model.id
        }
        if model.pubData > 0 {
            rModel.pubData = model.pubData
        } else {
            rModel.pubData = Double(Date().timeIntervalSince1970 * 1000)
        }
        rModel.transId = model.transId
        rModel.obs_fileId = model.obs_fileId
        rModel.state = model.state.rawValue
        rModel.isPass = model.isPass.rawValue
        rModel.userId = model.userId
        rModel.name = model.name
        rModel.done_size = model.done_size
        rModel.upload_size = model.upload_size
        rModel.transId = model.transId
        rModel.ext = model.ext
        rModel.file_size = model.file_size
        rModel.size = model.size
        rModel.movieAddress = model.movieAddress
        rModel.playTime = model.playTime
        rModel.totalTime = model.totalTime
        rModel.email = model.email
        rModel.linkId = model.linkId
        rModel.isShare = model.isShare
        rModel.imageData = model.image?.pngData()
        rModel.date = model.date
        rModel.isNet = model.isNet
        rModel.thumbnail = model.thumbnail
        rModel.file_type = model.file_type.rawValue
        rModel.platform = model.platform.rawValue
        rModel.vid_qty = model.vid_qty
        rModel.history = model.history
        return rModel
    }
    
    func readDatas() -> [VideoData] {
        let list = self.selectData(VideoDataRealm()).sorted(by: {$0.date > $1.date})
        var datas: [VideoData] = []
        for item in list {
            let mod: VideoData = VideoData()
            mod.name = item.name
            mod.state = HUB_FileState(rawValue: item.state) ?? .normal
            mod.isPass = HUB_ModerateType(rawValue: item.isPass) ?? .initl
            mod.size = item.size
            mod.file_size = item.file_size
            mod.userId = item.userId
            mod.totalTime = item.totalTime
            mod.playTime = item.playTime
            mod.ext = item.ext
            mod.isShare = item.isShare
            mod.date = item.date
            mod.pubData = item.pubData
            mod.movieAddress = item.movieAddress
            mod.linkId = item.linkId
            mod.image = UIImage(data: item.imageData ?? Data())
            mod.id = item.id
            mod.transId = item.transId
            mod.obs_fileId = item.obs_fileId
            mod.transId = item.transId
            mod.isNet = item.isNet
            mod.done_size = item.done_size
            mod.upload_size = item.upload_size
            mod.thumbnail = item.thumbnail
            mod.file_type = HUB_DataType(rawValue: item.file_type) ?? .folder
            mod.platform = HUB_PlatformType(rawValue: item.platform) ?? .box
            mod.vid_qty = item.vid_qty
            mod.history = item.history
            mod.email = item.email
            datas.append(mod)
        }
        return datas
    }
    
    func deleteData(_ model: VideoData) {
        let list = self.selectData(VideoDataRealm())
        list.forEach { m in
            if m.id == model.id || m.id == model.obs_fileId {
                self.removeData(m)
            }
        }
    }
}

class VideoDataRealm: Object {
    @Persisted var id: String = ""
    @Persisted var transId: String = ""
    @Persisted var obs_fileId: String = ""
    @Persisted var state: Int = 0
    @Persisted var ext: String = ""
    @Persisted var isNet: Bool = false
    @Persisted var date: Double = 0
    @Persisted var name: String = ""
    @Persisted var size: String = ""
    @Persisted var playTime: Double = 0
    @Persisted var file_size: Double = 0
    @Persisted var totalTime: Double = 0
    @Persisted var imageData: Data?
    @Persisted var movieAddress: String = ""
    @Persisted var pubData: Double = 0
    @Persisted var thumbnail: String = ""
    @Persisted var file_type: Int = 0
    @Persisted var userId: String = ""
    @Persisted var email: String = ""
    @Persisted var linkId: String = ""
    @Persisted var vid_qty: Int = 0
    @Persisted var history: Bool = false
    @Persisted var platform: String = ""
    @Persisted var isPass: String = ""
    @Persisted var isShare: Bool = false
    @Persisted var done_size: Double = 0
    @Persisted var upload_size: Double = 0
//    @Persisted(primaryKey: true) var _id: ObjectId
}

class ChannelUserRealm: Object {
    @Persisted var id: String = ""
    @Persisted var name: String = ""
    @Persisted var date: Double = 0
    @Persisted var labels: String = ""
    @Persisted var email: String = ""
    @Persisted var account: String = ""
    @Persisted var thumbnail: String = ""
    @Persisted var platform: String = ""
//    @Persisted(primaryKey: true) var _id: ObjectId
}
