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
    let channelCellIdentifier: String = "ChannelListCellIdentifier"
    let historyCellIdentifier: String = "IndexHistoryListCellIdentifier"
    
    let tableHeadV: IndexHeadView = IndexHeadView.view()
        
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CusTabBarHight + 24, right: 0)
        table.register(IndexCell.self, forCellReuseIdentifier: cellIdentifier)
        table.register(ChannelListCell.self, forCellReuseIdentifier: channelCellIdentifier)
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
        self.loadData()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabbarTool.instance.displayOrHidden(true)
        if HubTool.share.deepUrl.count > 0 {
            self.appFlyerPushSubVC(HubTool.share.deepUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        databaseInfo()
        uploadFirstOpenApp()

        NotificationCenter.default.addObserver(forName: Noti_Login, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.loadData()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_Logout, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
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
        TbaManager.instance.installEvent(link: false)
    }
    
//    @objc func clickVipAction() {
//        HubTool.share.preSource = .vip_home
//        HubTool.share.preMethod = .vip_click
//        let vc = PremiumController()
//        vc.hidesBottomBarWhenPushed = true
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
//    }
    
    func appFlyerPushSubVC(_  info: String) {
        guard HubTool.share.showAdomb == false else { return }
        TbaManager.instance.addEvent(type: .custom, event: .deeplinkOpen, paramter: [EventParaName.commonLin.rawValue: HubTool.share.isLinkDeep])

        if let url = URL(string: info), let para = url.parameters {
            if let linkId = para["video"], let platform = para["bealach"] {
                HubTool.share.platform = HUB_PlatformType(rawValue: platform) ?? .box
                guard self.simCheckResult(linkId) else { return }
                self.driveDeep(linkId)
            }
            if let linkId = para["spanged"], let platform = para["unfixed"] {
                guard self.simCheckResult(linkId) else { return }
                HubTool.share.platform = HUB_PlatformType(rawValue: platform) ?? .cash
                UserDefaults.standard.set(linkId, forKey: EventSaveLinkId)
                UserDefaults.standard.set(platform, forKey: EventSavePlatform)
                UserDefaults.standard.synchronize()
                HubTool.share.currentPlatform = HUB_PlatformType(rawValue: platform) ?? .cash
                self.platformDeep(linkId, HubTool.share.platform)
            }
            HubTool.share.deepUrl = ""
        }
    }
    
    // MARK: - open 个人网盘承接页
    func driveDeep(_ linkId: String) {
        DeepManager.share.openBoxDeep(linkId: linkId, rootVC: self)
    }
    
    // MARK: - open 中东印度承接页
    func platformDeep(_ linkId: String, _ platform: HUB_PlatformType) {
        self.uploadDownApp(linkId)
        DeepManager.share.openOtherDeep(linkId: linkId, uId: "", platform: platform, rootVC: self)
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
    
    func simCheckResult(_ linkId: String) -> Bool {
//        var isOpen: Bool = false
//        let isSim = HubTool.share.simData.sim
//        let isSimlimit = HubTool.share.simData.limitSim
//        let isEmulator = HubTool.share.simData.emulator
//        let isEmulatorlimit = HubTool.share.simData.limitEmulator
//        let isVpn = HubTool.share.simData.vpn
//        let isVpnlimit = HubTool.share.simData.limitVpn
//        let isPad = HubTool.share.simData.iPad
//        let isPadlimit = HubTool.share.simData.limitiPad
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
//        hasSIM = SimTool.instance.isSim()
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
//        hasEmulator = SimTool.instance.isEmulator()
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
//        hasVpn = SimTool.instance.isVpnConnected()
//        HubTool.share.isVpn = hasVpn
//        if isVpn {
//            if hasVpn {
//                openVpnDeep = !isVpnlimit
//            } else {
//                openVpnDeep = isVpnlimit
//            }
//        }
//        
//        hasPad = SimTool.instance.isIPad()
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
    
    func setup() {
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.headL)
        self.headL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        self.view.addSubview(self.tableHeadV)
        self.tableHeadV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.navbar.snp.bottom)
            make.height.equalTo(140)
        }
        self.emptyV.isHidden = true
        self.view.addSubview(self.emptyV)
        self.emptyV.snp.makeConstraints { make in
            make.top.equalTo(self.tableHeadV.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-CusTabBarHight)
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
            make.top.equalTo(self.tableHeadV.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // MARK: - Load Data
    func loadData() {
        self.historyList = HubDB.instance.readDatas().filter({$0.history == true}).sorted(by: {$0.date > $1.date})
        if self.historyList.count > 0 {
            if self.isHisUpload == false {
                TbaManager.instance.addEvent(type: .custom, event: .homeHistoryExpose, paramter: nil)
                self.isHisUpload = true
            }
        }
//        self.channelList = HubDB.instance.readUsers()
//        if self.channelList.count > 0 {
//            if self.isGroupUpload == false {
//                TbaManager.instance.addEvent(type: .custom, event: .homeChannelExpose, paramter: [EventParaName.history.rawValue: self.channelList.count])
//                self.isGroupUpload = true
//            }
//        }
        self.tableView.reloadData()
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
//        if self.channelList.count > 0 {
//            let m = HomeListData()
//            m.type = .channel
//            m.users = self.channelList
//            self.requestlist.append(m)
//        }

        var channels: [ChannelUserData] = []
        var uploads: [VideoData] = []
        
        var userData: UserSpaceData = UserSpaceData()
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        if LoginManager.share.isLogin == true {
            group.enter()
            queue.async {
                HttpManager.share.getBoxSpaceApi { [weak self] status, model, errMsg in
                    guard let self = self else { return}
                    if status == .success {
                        let use_space = model.user_space.computeFileSize()
                        let max_space = model.max_space.computeFileSize()
                        HubTool.share.spaceUse = use_space
                        HubTool.share.spaceTotal = max_space
                        userData = model
                        if (self.isOpenUpload == false) {
                            TbaManager.instance.addEvent(type: .custom, event: .homeExpose, paramter: [EventParaName.cloudTotal.rawValue: HubTool.share.spaceTotal, EventParaName.cloudUse.rawValue: HubTool.share.spaceUse])
                            self.isOpenUpload = true
                        }
                    }
                    group.leave()
                }
            }
            group.enter()
            queue.async {
                HttpManager.share.selectFolderApi("") { status, list, errMsg in
                    if status == .success {
                        let arr = list.filter({$0.file_type != .folder})
                        if arr.count > 0 {
                            uploads = arr
                        }
                    } else {
                        ToastTool.instance.show(errMsg ?? "Request fail", .fail)
                    }
                    group.leave()
                }
            }
            //        group.enter()
            //        queue.async { [weak self] in
            //            guard let self = self else { return }
            //            if let m = self.channelList.first(where: {$0.platform != .box}) {
            //                let _ = HttpManager.share.channelUserList(m.id, m.platform) { status, list, errMsg, refresh in
            //                    if refresh {
            //                        self.netRequestUpload()
            //                        return
            //                    }
            //                    if status == .success {
            //                        if list.count > 0 {
            //                            let userArr = self.insertUser(self.channelList, list, m.platform)
            //                            channels = userArr
            //                        }
            //                    }
            //                    group.leave()
            //                }
            //            } else {
            //                group.leave()
            //            }
            //        }
        } else {
            TbaManager.instance.addEvent(type: .custom, event: .homeExpose, paramter: nil)
        }
        group.notify(queue: queue) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if LoginManager.share.isLogin == true {
                    if let mmm = self.requestlist.first(where: {$0.type == .upload}) {
                        mmm.lists = uploads
                    } else {
                        if uploads.count > 0 {
                            let m = HomeListData()
                            m.type = .upload
                            m.lists = uploads
                            self.requestlist.append(m)
                        }
                    }
                    self.tableHeadV.setData(userData)
                } else {
                    self.tableHeadV.setData(nil)
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
                let vc = ChannelInfoController()
                vc.model = m.users.first ?? ChannelUserData()
                vc.hidesBottomBarWhenPushed = true
                TabbarTool.instance.displayOrHidden(false)
                self.navigationController?.pushViewController(vc, animated: true)
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
                let hisCell: IndexHistoryListCell = tableView.dequeueReusableCell(withIdentifier: historyCellIdentifier) as! IndexHistoryListCell
                hisCell.initData(m.lists)
                hisCell.clickBlock = { [weak self] data in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        HubTool.share.email = data.email
                        HubTool.share.uId = data.userId
                        HubTool.share.uploadPlatform = data.platform
                        HubTool.share.playSource = .history
                        HubTool.share.eventSource = .history
                        PlayTool.instance.pushPage(self, data, m.lists, true)
                    }
                }
                return hisCell
            case .channel:
                let channelCell: ChannelListCell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier) as! ChannelListCell
                channelCell.initData(m.users)
                channelCell.clickBlock = { [weak self] data in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        HubTool.share.channelSource = .homeChannel
                        HubTool.share.platform = data.platform
                        let vc = PingController(uId: data.id, platform: data.platform)
                        vc.hidesBottomBarWhenPushed = true
                        TabbarTool.instance.displayOrHidden(false)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                return channelCell
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
        if let m = self.list.safeIndex(indexPath.section) {
            if m.type == .history {
                return 120
            }
        }
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.section) {
            switch m.type {
            case .upload:
                if let mod = m.lists.safeIndex(indexPath.row), mod.isPass == .passed {
                    HubTool.share.email = mod.email
                    HubTool.share.uId = mod.userId
                    HubTool.share.uploadPlatform = mod.platform
                    HubTool.share.playSource = .upload_home
                    PlayTool.instance.pushPage(self, mod, m.lists, false)
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32))
        view.backgroundColor = .white
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
}

extension URL {
    var parameters: [String: String]? {
        guard let compon = URLComponents(url: self, resolvingAgainstBaseURL: true), let mod = compon.queryItems else { return nil }
        return mod.reduce(into: [String: String]()) { result, model in
            result[model.name] = model.value
        }
    }
}
