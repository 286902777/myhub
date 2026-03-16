//
//  OtherDeepController.swift
//  MyHub
//
//  Created by hub on 3/8/26.
//

import UIKit
import SnapKit
import MJRefresh

class OtherDeepController: UIViewController {
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addRedius([.topLeft, .topRight], 20)
        return view
    }()
    
    let cellIdentifier: String = "FileCellIdentifier"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(FileCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    let headView: BoxDeepHeadView = BoxDeepHeadView.view()
    let bottomView: DeepBottomView = DeepBottomView.view()
    let hotHeadView: DeepHeadView = DeepHeadView.view()
    private var allSelect: Bool = false
    private var dataModel: ChannelListData = ChannelListData()
    private var linkId: String = ""
    private var currentPage: Int = 1
    private var recommendPage: Int = 1
    private var isRecommend: Bool = false
    private var recommendList: [ChannelData] = []
    private var recommenduId: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dataModel.files.forEach { m in
            m.isSelect = false
        }
        self.tableView.reloadData()
        self.bottomView.isHidden = true
    }
    
    init(linkId: String) {
        super.init(nibName: nil, bundle: nil)
        self.linkId = linkId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addFooter()
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            guard let vc = HubTool.share.keyVC(), vc.isKind(of: OtherDeepController.self) else { return }
            if HubTool.share.adsPlayState == .download {
                self.downFile()
                VipPopManager.instance.openPopPage(self)
            }
        }
    }
    
    func setup() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.closeBtn)
        self.view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(NavBarH)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.top)
            make.size.equalTo(CGSizeMake(52, 52))
        }
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        
        self.contentView.addSubview(self.headView)
        self.headView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(82)
        }
        self.contentView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.headView.snp.bottom)
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        self.headView.clickBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                HubTool.share.channelSource = .homeChannel
                HubTool.share.platform = HubTool.share.platform
                let vc = PingController(uId: self.dataModel.userInfo.id, platform: HubTool.share.platform)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.tableView.tableHeaderView = self.hotHeadView
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(0)
        }
        self.bottomView.isHidden = true
        self.bottomView.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            switch idx {
            case 0:
                var pushList = HubTool.share.channelList(self.dataModel.files, linkId: self.linkId, uId: self.dataModel.userInfo.id, platform: HubTool.share.platform)
                if self.recommendList.count > 0 {
                    pushList.append(contentsOf: HubTool.share.channelList(self.recommendList, linkId: "", uId: self.recommenduId, platform: HubTool.share.platform))
                }
                DispatchQueue.main.async {
                    if let m = self.dataModel.files.first(where: {$0.file_type == .video}) {
                        PlayTool.instance.pushPage(self, HubTool.share.channelModel(m, linkId: self.linkId, uId: self.dataModel.userInfo.id, platform: HubTool.share.platform), pushList)
                    } else if let m = self.recommendList.first(where: {$0.file_type == .video}) {
                        PlayTool.instance.pushPage(self, HubTool.share.channelModel(m, linkId: self.linkId, uId: self.dataModel.userInfo.id, platform: HubTool.share.platform), pushList)
                    }
                }
            case 1:
                guard HubTool.share.userIsLogin(self) else { return }
                DispatchQueue.main.async {
                    let arr = HubDB.instance.readDatas().filter({$0.isShare == true})
                    if let _ = arr.first(where: {$0.id == self.linkId}) {
                        ToastTool.instance.show("The file has been saved")
                    } else {
                        let m: VideoData = VideoData()
                        m.id = self.linkId
                        m.linkId = self.linkId
                        m.userId = self.dataModel.userInfo.id
                        m.name = self.dataModel.userInfo.name
                        m.isShare = true
                        m.platform = HubTool.share.platform
                        HubDB.instance.updateMovieData(m)
                        ToastTool.instance.show("Save Successful​")
                    }
                }
            default:
                guard HubTool.share.userIsLogin(self) else { return }
                HubTool.share.eventSource = .download
                HubTool.share.adsPlayState = .download
                DispatchQueue.main.async {
                    HubTool.share.show(.play) { [weak self] success in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if success == false {
                                self.downFile()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func downFile() {
        let list = self.dataModel.files.filter({$0.file_type != .folder && $0.isSelect == true})
        let localList = HubDB.instance.readDatas()
        list.forEach { m in
            if let localModel = localList.first(where: {$0.id == m.id}) {
                if localModel.state != .downDone {
                    UploadDownTool.instance.downLoad(localModel)
                    HubTool.share.downEvent(localModel)
                }
            } else {
                let mod: VideoData = VideoData()
                mod.id = m.id
                mod.pubData = m.update_time
                mod.size = m.file_meta.size.computeFileSize()
                mod.file_size = m.file_meta.size
                mod.thumbnail = m.file_meta.thumbnail
                mod.name = m.fileName
                mod.file_type = m.file_type
                mod.vid_qty = m.vid_qty
                mod.ext = m.file_meta.ext
                mod.linkId = self.linkId
                mod.platform = HubTool.share.platform
                mod.userId = self.dataModel.userInfo.id
                UploadDownTool.instance.downLoad(mod)
                HubTool.share.downEvent(mod)
            }
        }
        ToastTool.instance.show("The contents, excluding the folder, have been added to the download list.")
    }
    
    @objc func clickCloseAction() {
        TabbarTool.instance.displayOrHidden(true)
        self.dismiss(animated: false)
    }
    
    func addFooter() {
        let foot = BaseRefreshFooter { [weak self] in
            guard let self = self else { return }
            self.netRequest()
        }
        self.tableView.mj_footer = foot
        self.tableView.mj_footer?.beginRefreshing()
    }
    
    func netRequest() {
        LoadManager.instance.show(self)
        HttpManager.share.channel(self.linkId, "", self.currentPage) { [weak self] status, model, errMsg, refresh in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            DispatchQueue.main.async {
                if refresh {
                    self.netRequest()
                    return
                }
                if status == .success {
                    let firstLink: Bool = UserDefaults.standard.bool(forKey: FirstOpenLink)
                    TbaManager.instance.addEvent(type: .custom, event: .landpageExpose, paramter: [EventParaName.value.rawValue: EventParaValue.box.rawValue, EventParaName.linkSource.rawValue: HubTool.share.isLinkDeep ? EventParaValue.delayLink.rawValue : EventParaValue.link.rawValue, EventParaName.isFirstLink.rawValue: !firstLink])
                    self.tableView.isHidden = false
                    if self.currentPage == 1 {
                        self.dataModel = model
                        self.headView.setOtherDeepHeadData(model.userInfo)
                        HubDB.instance.updateUserInfo(model.userInfo)
                        HubTool.share.uId = model.userInfo.id
                        HubTool.share.linkId = self.linkId
                        HubTool.share.email = model.userInfo.email
                        HubTool.share.boxUId = ""
                        HubTool.share.boxLinkId = ""
                        self.hotHeadView.setData(model, linkId: self.linkId, uId: model.userInfo.id, name: model.userInfo.name, platform: HubTool.share.platform)
                        UserDefaults.standard.set(model.userInfo.email, forKey: EventSaveEmail)
                        UserDefaults.standard.set(self.linkId, forKey: EventSaveLinkId)
                        UserDefaults.standard.set(model.userInfo.id, forKey: EventSaveUserId)
                        UserDefaults.standard.synchronize()
                        self.uploadOpenDeepLink()
                    } else {
                        self.dataModel.files.append(contentsOf: model.files)
                    }
                    
                    self.tableView.mj_footer?.endRefreshing()
                    if model.files.count < HttpManager.share.pageSize {
                        self.isRecommend = true
                        self.requestUserLoop()
                    } else {
                        self.currentPage += 1
                    }
                    self.tableView.reloadData()
                } else {
                    TbaManager.instance.addEvent(type: .custom, event: .landpageFail, paramter: nil)
                    if let e = errMsg {
                        ToastTool.instance.show(e, .fail)
                    }
                }
            }
        }
    }
    
    func requestUserLoop() {
        let userList = HubDB.instance.readUsers().filter({$0.platform == self.dataModel.userInfo.platform})
        if userList.count > 0 {
            let userListCount: UInt32 = UInt32(userList.count - 1)
            if let m = userList.safeIndex(Int(arc4random_uniform(userListCount))) {
                HttpManager.share.channelUserList(m.id, m.platform) { [weak self] status, list, errMsg, refresh in
                    guard let self = self else { return }
                    if refresh {
                        self.requestUserLoop()
                    }
                    if status == .success, list.count > 0 {
                        let result = list.filter({$0.id != m.id})
                        if result.count > 0 {
                            let listCount: UInt32 = UInt32(result.count - 1)
                            if let mod = result.safeIndex(Int(arc4random_uniform(listCount))) {
                                self.recommenduId = mod.id
                                self.requestRecommend()
                            }
                        } else {
                            self.recommenduId = m.id
                            self.requestRecommend()
                        }
                    }
                }
            }
        } else {
            self.recommenduId = self.dataModel.userInfo.id
            self.requestRecommend()
        }
    }
    
    func requestRecommend() {
        HttpManager.share.channel("", self.recommenduId, self.recommendPage) { [weak self] status, model, errMsg, refresh in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if refresh {
                    self.requestRecommend()
                    return
                }
                if status == .success {
                    model.files.forEach { data in
                        data.recommoned = true
                        self.recommendList.append(data)
                    }
                    self.tableView.mj_footer?.endRefreshing()
                    if model.files.count < HttpManager.share.pageSize {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer?.isHidden = true
                    } else {
                        self.recommendPage += 1
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func uploadOpenDeepLink() {
        TbaManager.instance.installEvent(link: true)
        let firstLink: Bool = UserDefaults.standard.bool(forKey: FirstOpenLink)
        TbaManager.instance.addEvent(type: .custom, event: .landpageExpose, paramter: [EventParaName.value.rawValue: HubTool.share.platform.rawValue, EventParaName.linkSource.rawValue: HubTool.share.isLinkDeep ? EventParaValue.delayLink.rawValue : EventParaValue.link.rawValue, EventParaName.isFirstLink.rawValue: !firstLink])
        let m = VideoData()
        m.linkId = self.linkId
        HttpManager.share.uploadEventApi(event: .view_app, currency: "", val: 0, model: m) { [weak self] success in
            guard let self = self else { return }
            if success == false {
                self.uploadOpenDeepLink()
            }
        }
    }
    
    func pushModelVC(_ model: ChannelData) {
        HubTool.share.eventSource = .landpage
        HubTool.share.uploadPlatform = HubTool.share.platform
        HubTool.share.playSource = .landpage_file
        switch model.file_type {
        case .folder:
            let vc = OtherFolderListController(model: HubTool.share.channelModel(model, linkId: self.linkId, uId: model.recommoned ? self.recommenduId : self.dataModel.userInfo.id, platform: HubTool.share.platform), linkId: self.linkId, userId: model.recommoned ? self.recommenduId :  self.dataModel.userInfo.id, userName: self.dataModel.userInfo.name, platform: HubTool.share.platform, channel: false)
            self.navigationController?.pushViewController(vc, animated: true)
        case .photo:
            let vc = OpenPhotoController(model: HubTool.share.channelModel(model, linkId: "", uId: "", platform: HubTool.share.platform))
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            var pushList = HubTool.share.channelList(self.dataModel.files, linkId: self.linkId, uId: self.dataModel.userInfo.id, platform: HubTool.share.platform)
            if self.recommendList.count > 0 {
                pushList.append(contentsOf: HubTool.share.channelList(self.recommendList, linkId: "", uId: self.recommenduId, platform: HubTool.share.platform))
            }
            if model.recommoned {
                PlayTool.instance.pushPage(self, HubTool.share.channelModel(model, linkId: "", uId: self.recommenduId, platform: HubTool.share.platform), pushList)
            } else {
                PlayTool.instance.pushPage(self, HubTool.share.channelModel(model, linkId: self.linkId, uId: self.dataModel.userInfo.id, platform: HubTool.share.platform), pushList)
            }
        }
    }
    @objc func clickAllAction() {
        self.allSelect = !self.allSelect
        self.dataModel.files.forEach { m in
            m.isSelect = self.allSelect
        }
        self.disPlayBottom()
        self.tableView.reloadData()
    }
    
    func disPlayBottom() {
        let arr = self.dataModel.files.filter({$0.isSelect == true})
        self.bottomView.isHidden = arr.count == 0
        self.bottomView.snp.updateConstraints { make in
            make.height.equalTo(arr.count == 0 ? 0 : 64)
        }
    }
}

extension OtherDeepController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FileCell
        if let m = self.dataModel.files.safeIndex(indexPath.row) {
            cell.initPlatformData(m, true)
            cell.selectBlock = { [weak self] on in
                guard let self = self else { return }
                m.isSelect = on
                self.disPlayBottom()
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataModel.files.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "All Videos"
        label.textColor = UIColor.rgbHex("#141414")
        label.font = UIFont.GoogleSans(weight: .medium, size: 16)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        let btn = UIButton()
        btn.setTitle("Select all", for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 12)
        btn.setTitleColor(UIColor.rgbHex("#14171C", 0.5), for: .normal)
        btn.addTarget(self, action: #selector(clickAllAction), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(78)
        }
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.dataModel.files.safeIndex(indexPath.row) {
            self.pushModelVC(m)
        }
    }
}
