//
//  OtherFolderListController.swift
//  MyHub
//
//  Created by hub on 3/9/26.
//

import UIKit
import SnapKit
import MJRefresh

class OtherFolderListController: UIViewController {
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    lazy var vipBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "home_pre"), for: .normal)
        return btn
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addRedius([.topLeft, .topRight], 20)
        return view
    }()
    private var model: VideoData = VideoData()
    private var linkId: String = ""
    private var userId: String = ""
    private var userName: String = ""
    
    private var currentPage: Int = 0
    
    private var platform: HUB_PlatformType = .box
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
    
    let headView: BoxDeepListHeadView = BoxDeepListHeadView.view()
    let bottomView: DeepBottomView = DeepBottomView.view()
    let emptyView: FileEmptyView = FileEmptyView.view()
    private var list: [VideoData] = []
    private var allSelect: Bool = false
    private var isChannel: Bool = false
    init(model: VideoData, linkId: String, userId: String, userName: String, platform: HUB_PlatformType, channel: Bool) {
        self.model = model
        self.linkId = linkId
        self.userId = userId
        self.userName = userName
        self.platform = platform
        self.isChannel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addFooter()
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            guard let vc = HubTool.share.keyVC(), vc.isKind(of: OtherFolderListController.self) else { return }
            if HubTool.share.adsPlayState == .download {
                self.downFile()
                PayPopManager.instance.openPopPage(self)
            }
        }
    }
    
    func setUI() {
        self.view.addSubview(self.closeBtn)
        self.view.addSubview(self.vipBtn)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.headView)
        self.contentView.addSubview(self.emptyView)
        self.contentView.addSubview(self.tableView)
        self.contentView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(NavBarH)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.top)
            make.size.equalTo(CGSizeMake(52, 44))
        }
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.vipBtn.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.centerY.equalTo(self.closeBtn)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        self.vipBtn.addTarget(self, action: #selector(clickVipAction), for: .touchUpInside)
        self.headView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(74)
        }
        self.emptyView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        self.headView.nameL.text = self.model.name
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(64)
        }
        self.bottomView.isHidden = true
        self.headView.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch idx {
                case 0:
                    self.hiddenBottomView()
                    self.dismiss(animated: false)
                default:
                    self.clickAllAction()
                }
            }
        }
        self.bottomView.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch idx {
                case 0:
                    self.hiddenBottomView()
                    if let m = self.list.first(where: {$0.file_type == .video}) {
                        PlayTool.instance.pushPage(self, m, self.list)
                    }
                case 1:
                    guard HubTool.share.userIsLogin(self) else { return }
                    let arr = HubDB.instance.readDatas().filter({$0.isShare == true})
                    if let _ = arr.first(where: {$0.id == (self.isChannel ? self.userId : self.linkId)}) {
                        ToastTool.instance.show("The file has been saved")
                    } else {
                        let m: VideoData = VideoData()
                        m.id = self.isChannel ? self.userId : self.linkId
                        m.linkId = self.linkId
                        m.userId = self.userId
                        m.name = self.userName
                        m.isShare = true
                        m.platform = self.platform
                        HubDB.instance.updateMovieData(m)
                        ToastTool.instance.show("Save Successful​")
                    }
                default:
                    guard HubTool.share.userIsLogin(self) else { return }
                    HubTool.share.eventSource = .download
                    HubTool.share.adsPlayState = .download
                    HubTool.share.show() { success in
                        if success == false {
                            DispatchQueue.main.async {
                                self.downFile()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func clickVipAction() {
        HubTool.share.preSource = .vip_landPage
        HubTool.share.preMethod = .vip_click
        let vc = PayController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @objc func clickCloseAction() {
        NotificationCenter.default.post(name: Noti_ClosePresent, object: nil, userInfo: nil)
    }
    
    func downFile() {
        let list = self.list.filter({$0.file_type != .folder && $0.isSelect == true})
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
                mod.pubData = m.pubData
                mod.size = m.size
                mod.file_size = m.file_size
                mod.thumbnail = m.thumbnail
                mod.name = m.name
                mod.file_type = m.file_type
                mod.vid_qty = m.vid_qty
                mod.ext = m.ext
                mod.linkId = self.linkId
                mod.platform = self.platform
                mod.userId = self.userId
                UploadDownTool.instance.downLoad(mod)
                HubTool.share.downEvent(mod)
            }
        }
        ToastTool.instance.show("The contents, excluding the folder, have been added to the download list.")
    }
    
    func clickAllAction() {
        self.allSelect = !self.allSelect
        self.list.forEach { m in
            m.isSelect = self.allSelect
        }
        self.disPlayBottom()
        self.tableView.reloadData()
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
        HttpManager.share.folderData(uId: self.userId, dirId: self.model.id, currentPage: self.currentPage) {[weak self] status, files, errMsg, refresh in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                if refresh {
                    self.netRequest()
                } else {
                    if status == .success {
                        if files.count < HttpManager.share.pageSize {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer?.isHidden = true
                        }
                        self.list.append(contentsOf: self.folderChangeToDataList(files))
                        if files.count < HttpManager.share.pageSize {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer?.isHidden = true
                        } else {
                            self.currentPage += 1
                        }
                        if self.list.count == 0 {
                            self.emptyView.isHidden = false
                            self.tableView.isHidden = true
                        } else {
                            self.emptyView.isHidden = true
                            self.tableView.isHidden = false
                        }
                        self.tableView.reloadData()
                    } else {
                        ToastTool.instance.show(errMsg, .fail)
                    }
                }
            }
        }
    }
    
    func folderChangeToDataList(_ list: [FolderData]) -> [VideoData] {
        var results: [VideoData] = []
        list.forEach { model in
            let mod = VideoData()
            mod.id = model.id
            mod.pubData = model.update_time
            mod.vid_qty = model.vid_qty
            mod.file_type = model.file_type
            mod.thumbnail = model.file_meta.thumbnail
            mod.file_size = model.file_meta.size
            mod.size = model.file_meta.size.computeFileSize()
            mod.ext = model.file_meta.ext
            mod.isNet = true
            mod.name = model.fileName
            mod.platform = self.platform
            mod.userId = self.userId
            mod.linkId = self.linkId
            results.append(mod)
        }
        return results
    }
    
    func pushModelVC(_ model: VideoData) {
        self.hiddenBottomView()
        switch model.file_type {
        case .folder:
            let vc = OtherFolderListController(model: model, linkId: self.linkId, userId: model.userId, userName: self.userName, platform: self.platform, channel: self.isChannel)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        case .photo:
            let vc = OpenPhotoController(model: model)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        case .video:
            PlayTool.instance.pushPage(self, model, self.list)
        }
    }
    
    func disPlayBottom() {
        let arr = self.list.filter({$0.isSelect == true})
        self.bottomView.isHidden = arr.count == 0
        self.bottomView.snp.updateConstraints { make in
            make.height.equalTo(arr.count == 0 ? 0 : 64)
        }
    }
    
    func hiddenBottomView() {
        self.list.forEach { m in
            m.isSelect = false
        }
        self.bottomView.isHidden = true
        self.bottomView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        self.tableView.reloadData()
    }
}

extension OtherFolderListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FileCell
        if let m = self.list.safeIndex(indexPath.row) {
            cell.initVideoData(m)
            cell.selectBlock = { [weak self] on in
                guard let self = self else { return }
                m.isSelect = on
                DispatchQueue.main.async {
                    self.disPlayBottom()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.row) {
            self.pushModelVC(m)
        }
    }
}
