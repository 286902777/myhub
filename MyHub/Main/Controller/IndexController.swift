//
//  IndexController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexController: SuperController {
    private let headL: UILabel = {
        let label = UILabel()
        label.text = "MyHub"
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .black, size: 18)
        return label
    }()
    
    let emptyV: EmptyView = EmptyView.view()
    
    let cellIdentifier: String = "IndexCellIdentifier"
    let historyCellIdentifier: String = "IndexHistoryListCellIdentifier"
    
    let tableHeadV: IndexHeadView = IndexHeadView.view()
        
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.register(IndexCell.self, forCellReuseIdentifier: cellIdentifier)
        table.register(IndexHistoryListCell.self, forCellReuseIdentifier: historyCellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    private var historyList: [VideoData] = []
    private var channelList: [ChannelUserData] = []
    private var requestlist: [HomeListData] = []
    private var list: [HomeListData] = []
    
    private var isOpenUpload: Bool = false
    private var isHisUpload: Bool = false
    private var isGroupUpload: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestBoxSpace()
        self.loadData()
        TabbarTool.instance.displayOrHidden(true)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        databaseInfo()
        uploadFirstOpenApp()
        if HubTool.share.deepUrl.count > 0 {
            self.appFlyerPushSubVC(HubTool.share.deepUrl)
        }
        NotificationCenter.default.addObserver(forName: Noti_AppDeep, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if HubTool.share.deepUrl.count > 0 {
                self.appFlyerPushSubVC(HubTool.share.deepUrl)
            }
        }
        NotificationCenter.default.addObserver(forName: Noti_Login, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.requestBoxSpace()
            self.loadData()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_Logout, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.requestBoxSpace()
            self.loadData()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_NetworkStatus, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.list.count == 0 {
                self.emptyV.isHidden = false
                if NetManager.instance.isReachable {
                    self.emptyV.type = .noContent
                } else {
                    self.emptyV.type = .noNet
                }
            } else {
                self.emptyV.isHidden = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_DeleteFileSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let result = data.userInfo?["list"] as? [String] {
                result.forEach { id in
                    if let m = self.list.first(where: {$0.type == .upload}) {
                        m.lists.removeAll(where: {$0.id == id})
                    }
                }
                if let m = self.list.first(where: {$0.type == .upload}), m.lists.count == 0 {
                    self.list.removeLast()
                }
                self.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_NetworkStatus, object: nil, queue: .main) { _ in
            if NetManager.instance.isReachable {
                return
            }
            UploadDownTool.instance.uploadList.removeAll()
            UploadDownTool.instance.downList.removeAll()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if HubTool.share.deepUrl.count > 0 {
                self.appFlyerPushSubVC(HubTool.share.deepUrl)
            }
        }
    }
    
    func databaseInfo() {
        let list = HubDB.instance.readDatas()
        list.forEach { m in
            if m.state == .uploading || m.state == .uploadWait {
                m.state = .uploadFaid
                HubDB.instance.updateMovieData(m)
            }
            if m.state == .downing || m.state == .downWait {
                m.state = .downFail
                HubDB.instance.updateMovieData(m)
            }
        }
    }
    
    private func uploadFirstOpenApp() {
        if UserDefaults.standard.bool(forKey: HUB_FirstOpenApp) == false {
            HttpManager.share.uploadEventApi(event: .download_app_first_time_open, currency: "", val: 0, model: VideoData()) { [weak self] success in
                guard let self = self else { return }
                if success == false {
                    self.uploadFirstOpenApp()
                } else {
                    UserDefaults.standard.set(true, forKey: HUB_FirstOpenApp)
                    UserDefaults.standard.synchronize()
                }
            }
        }
//        EventTool.share.installEvent(link: false)
    }
    
//    @objc func clickVipAction() {
//        HubTool.share.preSource = .vip_home
//        HubTool.share.preMethod = .vip_click
//        let vc = PremiumController()
//        vc.hidesBottomBarWhenPushed = true
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
//    }

    func requestBoxSpace() {
        if LoginManager.share.isLogin {
            HttpManager.share.getBoxSpaceApi { [weak self] status, model, errMsg in
                guard let self = self else { return}
                DispatchQueue.main.async {
                    if status == .success {
                        let use_space = model.user_space.computeFileSize()
                        let max_space = model.max_space.computeFileSize()
                        HubTool.share.spaceUse = use_space
                        HubTool.share.spaceTotal = max_space
//                        if (self.isOpenUpload == false) {
//                            EventTool.instance.addEvent(type: .custom, event: .homeExpose, paramter: [EventParaName.cloudTotal.rawValue: ESBaseTool.instance.spaceTotal, EventParaName.cloudUse.rawValue: ESBaseTool.instance.spaceUse])
//                            self.isOpenUpload = true
//                        }
                        self.tableHeadV.setData(model)
                    }
                }
            }
        } else {
//            if (self.isOpenUpload == false) {
//                EventTool.instance.addEvent(type: .custom, event: .homeExpose, paramter: nil)
//                self.isOpenUpload = true
//            }
            self.tableHeadV.setData(nil)
        }
    }
    
    func appFlyerPushSubVC(_  info: String) {
        guard HubTool.share.showAdomb == false else { return }
//        HubTool.share.addEvent(type: .custom, event: .deeplinkOpen, paramter: [EventParaName.commonLin.rawValue: HubTool.share.isLinkDeep])

        if let url = URL(string: info), let para = url.parameters {
            if let linkId = para["a"], let platform = para["b"] {
                HubTool.share.platform = HUB_PlatformType(rawValue: platform) ?? .box
                guard self.canClackInfo(linkId) else { return }
                self.driveDeep(linkId)
            }
            if let linkId = para["unmenial"], let platform = para["tackingly"] {
                guard self.canClackInfo(linkId) else { return }
                HubTool.share.platform = HUB_PlatformType(rawValue: platform) ?? .cash
                UserDefaults.standard.set(linkId, forKey: EventSaveLinkId)
                UserDefaults.standard.set(platform, forKey: EventSavePlatform)
                UserDefaults.standard.synchronize()
                HubTool.share.currentPlatform = HUB_PlatformType(rawValue: platform) ?? .cash
                self.platformDeep(linkId)
            }
            HubTool.share.deepUrl = ""
        }
    }
    
    // MARK: - open 个人网盘承接页 1996146961945858049
    func driveDeep(_ linkId: String) {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.tabBarController?.selectedIndex = 0
            self.popRootVC()
//            let vc = DriveDeepController(linkId: linkId)
//            vc.returnBlock = {
//                PlayManager.instance.adsPushPremium(HubTool.share.adsPlayState, .vip_home, self)
//            }
//            HubTool.share.deepUrl = ""
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - open 中东印度承接页
    func platformDeep(_ linkId: String) {
        self.uploadDownApp(linkId)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.tabBarController?.selectedIndex = 0
            self.popRootVC()
//            let vc = PlatformDeepController(linkId: linkId)
//            vc.returnBlock = {
//                PlayManager.instance.adsPushPremium(HubTool.share.adsPlayState, .vip_home, self)
//            }
//            HubTool.share.deepUrl = ""
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func uploadDownApp(_ linkId: String) {
        if UserDefaults.standard.bool(forKey: HUB_AppDown) == false {
            let m: VideoData = VideoData()
            m.linkId = linkId
            HttpManager.share.uploadEventApi(event: .down_app, currency: "", val: 0, model: m) {[weak self] success in
                guard let self = self else { return }
                if success == false {
                    self.uploadDownApp(linkId)
                } else {
                    UserDefaults.standard.set(true, forKey: HUB_AppDown)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    func canClackInfo(_ linkId: String) -> Bool {
//        var isOpen: Bool = false
//        let isSim = HubTool.share.clackData.sim
//        let isSimlimit = HubTool.share.clackData.limitSim
//        let isEmulator = HubTool.share.clackData.emulator
//        let isEmulatorlimit = HubTool.share.clackData.limitEmulator
//        let isVpn = HubTool.share.clackData.vpn
//        let isVpnlimit = HubTool.share.clackData.limitVpn
//        let isPad = HubTool.share.clackData.iPad
//        let isPadlimit = HubTool.share.clackData.limitiPad
//        var hasSIM: Bool = false
//        var hasEmulator: Bool = false
//        var hasVpn: Bool = false
//        var hasPad: Bool = false
//        
//        var openSimDeep: Bool = true
//        var openEmulatorDeep: Bool = true
//        var openVpnDeep: Bool = true
//        var openPadDeep: Bool = true
//
//        hasSIM = ClackTool.instance.isSim()
//        HubTool.share.isSim = hasSIM
//
//        if isSim {
//            if hasSIM {
//                openSimDeep = !isSimlimit
//            } else {
//                openSimDeep = isSimlimit
//            }
//        }
//        
//        hasEmulator = ClackTool.instance.isEmulator()
//        HubTool.share.isEmulator = hasEmulator
//
//        if isEmulator {
//            if hasEmulator {
//                openEmulatorDeep = !isEmulatorlimit
//            } else {
//                openEmulatorDeep = isEmulatorlimit
//            }
//        }
//        
//        hasVpn = ClackTool.instance.isVpnConnected()
//        HubTool.share.isVpn = hasVpn
//        if isVpn {
//            if hasVpn {
//                openVpnDeep = !isVpnlimit
//            } else {
//                openVpnDeep = isVpnlimit
//            }
//        }
//        
//        hasPad = ClackTool.instance.isIPad()
//        HubTool.share.isPod = hasPad
//
//        if isPad {
//            if hasPad {
//                openPadDeep = !isPadlimit
//            } else {
//                openPadDeep = isPadlimit
//            }
//        }
//        if openSimDeep, openEmulatorDeep, openVpnDeep, openPadDeep {
//            isOpen = true
//        } else {
//            isOpen = false
//        }
//        return isOpen
        return true
    }
    
    func insertUser(_ users: [ChannelUserData], _ list: [ChannelRecommedData],  _ platform: HUB_PlatformType) -> [ChannelUserData] {
        var datas: [ChannelUserData] = []
        for item in list {
            if let _ = users.first(where: ({$0.id == item.id})) {
                
            } else {
                let m = ChannelUserData()
                m.id = item.id
                m.name = item.name
                m.platform = platform
                m.thumbnail = item.thumbnail
                datas.append(m)
            }
        }
        
        var userArr: [ChannelUserData] = users
        if users.count > 2 {
            for (idx, _) in users.enumerated() {
                if idx % 2 == 0, idx > 0 {
                    if let temp = datas.randomElement() {
                        userArr.insert(temp, at: idx)
                        datas = datas.filter({$0.id != temp.id})
                    }
                }
            }
        } else {
            if let userFirst = datas.randomElement() {
                userArr.append(userFirst)
            }
        }
        return userArr
    }
    
    func popRootVC() {
        if let keyVC = HubTool.share.keyVC(), keyVC.isKind(of: IndexController.self) {
            return
        } else {
            if let vc = HubTool.share.keyWindow?.rootViewController, vc.presentedViewController != nil {
                vc.dismiss(animated: false)
            }
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    func setup() {
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.headL)
        self.headL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        self.emptyV.isHidden = true
        self.view.addSubview(self.emptyV)
        self.emptyV.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.emptyV.clickBlock = { [weak self] type in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if type == .noContent {
                    HubTool.share.loginSource = .upload
                    UploadTool.instance.openVC(self)
                } else {
                    self.emptyV.type = NetManager.instance.isReachable == true ? .noContent : .noNet
                }
            }
        }
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.tableView.tableHeaderView = self.tableHeadV
    }
    
    // MARK: - Load Data
    func loadData() {
        self.historyList = HubDB.instance.readDatas().filter({$0.history == true}).sorted(by: {$0.date > $1.date})
        if self.historyList.count > 0 {
            if self.isHisUpload == false {
//                EventTool.instance.addEvent(type: .custom, event: .homeHistoryExpose, paramter: nil)
                self.isHisUpload = true
            }
        }
        self.channelList = HubDB.instance.readUsers()
        if self.channelList.count > 0 {
            if self.isGroupUpload == false {
//                EventTool.instance.addEvent(type: .custom, event: .homeChannelExpose, paramter: [EventParaName.history.rawValue: self.channelList.count])
                self.isGroupUpload = true
            }
        }
        self.netRequestUpload()
    }
    
    func netRequestUpload() {
        self.requestlist.removeAll()
        if self.historyList.count > 0 {
            let m = HomeListData()
            m.type = .history
            m.lists = self.historyList
            self.requestlist.append(m)
        }
        if self.channelList.count > 0 {
            let m = HomeListData()
            m.type = .channel
            m.users = self.channelList
            self.requestlist.append(m)
        }

        var channels: [ChannelUserData] = []
        var uploads: [VideoData] = []
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        if LoginManager.share.isLogin == true {
            group.enter()
            queue.async {
                HttpManager.share.selectFolderApi("") { status, list, errMsg in
                    DispatchQueue.main.async {
                        if status == .success {
                            let arr = list.filter({$0.file_type != .folder})
                            if arr.count > 0 {
                                uploads = arr
                            }
                            group.leave()
                        } else {
                            ToastTool.instance.show(errMsg ?? "Request fail", .fail)
                            group.leave()
                        }
                    }
                }
            }
        }
        group.enter()
        queue.async { [weak self] in
            guard let self = self else { return }
            if let m = self.channelList.first(where: {$0.platform != .box}) {
                let _ = HttpManager.share.channelUserList(m.id, m.platform) { status, list, errMsg, refresh in
                    if refresh {
                        self.netRequestUpload()
                        return
                    }
                    if status == .success {
                        if list.count > 0 {
                            let userArr = self.insertUser(self.channelList, list, m.platform)
                            channels = userArr
                        }
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.notify(queue: queue) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if LoginManager.share.isLogin == true {
                    if let mmm = self.requestlist.first(where: {$0.type == .upload}) {
                        mmm.lists = uploads
                    } else {
                        let m = HomeListData()
                        m.type = .upload
                        m.lists = uploads
                        self.requestlist.append(m)
                    }
                }
                self.requestlist.first(where: {$0.type == .channel})?.users = channels
                if self.requestlist.count == 0 {
                    self.emptyV.isHidden = false
                    self.emptyV.type = NetManager.instance.isReachable == true ? .noContent : .noNet
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                    self.emptyV.isHidden = true
                    self.list = self.requestlist
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func clickHeadAction(_ sender: UITapGestureRecognizer) {
        if let m = self.list.safeIndex(sender.view?.tag ?? 0) {
            if m.type == .channel {
//                let vc = ChannelListController()
//                vc.model = m.users.first ?? ChannelUserData()
//                vc.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = IndexListController(list: m.lists, type: m.type)
                vc.hidesBottomBarWhenPushed = true
                TabbarTool.instance.displayOrHidden(false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension IndexController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IndexCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IndexCell
        if let m = self.list.safeIndex(indexPath.section) {
            switch m.type {
            case .history:
                break
            case .channel:
                break
            case .upload:
                if let mod = m.lists.safeIndex(indexPath.row) {
                    cell.initData(mod)
                    cell.clickMoreBlock = {[weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if let dataBaseModel = HubDB.instance.readDatas().first(where: {$0.id == mod.id}) {
                                mod.state = dataBaseModel.state
                                mod.movieAddress = dataBaseModel.movieAddress
                            }
                            let vc = IndexMoreController(model: mod, type: m.type)
                            vc.deleteBlock = {
                                DispatchQueue.main.async {
                                    HttpManager.share.deleteFileApi([mod]) { [weak self] status, errMsg in
                                        guard let self = self else { return }
                                        DispatchQueue.main.async {
                                            if status == .success {
                                                HubDB.instance.deleteData(mod)
                                                NotificationCenter.default.post(name: Noti_DeleteFileSuccess, object: nil, userInfo: nil)
                                                m.lists.remove(at: indexPath.row)
                                                if m.lists.count == 0 {
                                                    self.list.removeLast()
                                                }
                                                self.tableView.reloadData()
                                                if self.list.count == 0 {
                                                    self.emptyV.isHidden = false
                                                    self.tableView.isHidden = true
                                                } else {
                                                    self.emptyV.isHidden = true
                                                    self.tableView.isHidden = false
                                                }
                                            } else {
                                                ToastTool.instance.show(errMsg, .fail)
                                            }
                                        }
                                    }
                                }
                            }
                            vc.renameBlock = { name in
                                mod.name = name
                                DispatchQueue.main.async {
                                    let dbList = HubDB.instance.readDatas()
                                    self.list.forEach { itemM in
                                        itemM.lists.forEach { subM in
                                            if subM.id == mod.id {
                                                subM.name = name
                                                dbList.forEach { ssM in
                                                    if ssM.id == subM.id || ssM.obs_fileId == subM.id {
                                                        ssM.name = name
                                                        HubDB.instance.updateMovieData(ssM)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    NotificationCenter.default.post(name: Noti_ReNameSuccess, object: nil, userInfo: nil)
                                    self.tableView.reloadData()
                                }
                            }
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(vc, animated: false)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.list.safeIndex(section) {
            if m.type == .upload {
                return m.lists.count
            } else {
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.section) {
            if let mod = m.lists.safeIndex(indexPath.row), mod.isPass == .passed {
                HubTool.share.email = mod.email
                HubTool.share.uId = mod.userId
                HubTool.share.uploadPlatform = mod.platform
                if m.type == .history {
                    HubTool.share.playSource = .history
                    HubTool.share.eventSource = .history
                } else {
                    HubTool.share.playSource = .history
                    HubTool.share.eventSource = .history
                }
                self.pushSubVC(mod, m.lists)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32))
        view.backgroundColor = .clear
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 16)
        label.textColor = UIColor.rgbHex("#434343")
        let imageV = UIImageView()
        imageV.image = UIImage(named: "arrow")
        view.addSubview(label)
        view.addSubview(imageV)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.bottom.equalTo(-8)
        }
        imageV.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.right.equalTo(-14)
        }
        if let m = self.list.safeIndex(section) {
            label.text = m.type.rawValue
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickHeadAction(_:)))
        view.tag = section
        view.addGestureRecognizer(tap)
        return view
    }
    
    func pushSubVC(_ model: VideoData, _ lists: [VideoData]) {
        switch model.file_type {
        case .folder:
            break
        case .photo:
            let vc = OpenPhotoController(model: model)
            vc.hidesBottomBarWhenPushed = true
            TabbarTool.instance.displayOrHidden(false)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, model, lists.filter({$0.file_type == .video}), true)
        }
    }
}

extension URL {
    var parameters: [String: String]? {
        guard let compon = URLComponents(url: self, resolvingAgainstBaseURL: true), let mod = compon.queryItems else { return nil }
        return mod.reduce(into: [String: String]()) { result, model in
            result[model.name] = model.value
        }
    }
}
