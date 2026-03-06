//
//  BoxDeepController.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit
import SnapKit
import MJRefresh

class BoxDeepController: UIViewController {

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
    private var allSelect: Bool = false
    private var list: [OpenUrlData] = []
    private var userModel: OpenUserData = OpenUserData()
    private var linkId: String = ""
    private var currentPage: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.list.forEach { m in
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
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.headView.snp.bottom)
        }
//        self.headView.clickBlock = { [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                
//            }
//        }
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(64)
        }
        self.bottomView.isHidden = true
        self.bottomView.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch idx {
                case 0:
                    if let m = self.list.first(where: {$0.file_type == .video}) {
                        PlayTool.instance.pushPage(self, HubTool.share.changeModel(m, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform), HubTool.share.changeList(self.list, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform))
                    }
                case 1:
                    guard HubTool.share.userIsLogin(self) else { return }
                    let m: VideoData = VideoData()
                    m.id = self.linkId
                    m.linkId = self.linkId
                    m.userId = self.userModel.id
                    m.name = self.userModel.username
                    m.isShare = true
                    m.platform = .box
                    HubDB.instance.updateMovieData(m)
                    ToastTool.instance.show("Save Successful​")
                default:
                    guard HubTool.share.userIsLogin(self) else { return }
                    HubTool.share.eventSource = .download
                    HubTool.share.adsPlayState = .download
                    self.downFile()
//                    AdmobTool.instance.show(.mode_down) { success in
//                        if success == false {
//                            self.downData()
//                        }
//                    }
                }
            }
        }
    }
    
    func downFile() {
            let list = self.list.filter({$0.file_type != .folder && $0.isSelect == true})
            let localList = HubDB.instance.readDatas()
            list.forEach { m in
                if let localModel = localList.first(where: {$0.id == m.file_id}) {
                    if localModel.state != .downDone {
                        UploadDownTool.instance.downLoad(localModel)
                    }
                } else {
                    let mod: VideoData = VideoData()
                    mod.id = m.file_id
                    mod.pubData = m.create_time
                    mod.size = m.file_meta.size.computeFileSize()
                    mod.file_size = m.file_meta.size
                    mod.thumbnail = m.file_meta.thumbnail
                    mod.name = m.file_meta.display_name
                    mod.file_type = m.file_type
                    mod.vid_qty = m.vid_qty
                    mod.ext = m.file_meta.ext
                    mod.linkId = self.linkId
                    mod.platform = .box
                    mod.userId = self.userModel.id
                    UploadDownTool.instance.downLoad(mod)
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
        HttpManager.share.getShareUrlApi(self.linkId, self.currentPage) { [weak self] status, model, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if status == .success {
//                    let firstLink: Bool = UserDefaults.standard.bool(forKey: FirstOpenLink)
//                    EventTool.instance.addEvent(type: .custom, event: .landpageExpose, paramter: [EventParaName.value.rawValue: EventParaValue.box.rawValue, EventParaName.linkSource.rawValue: ESBaseTool.instance.isLinkDeep ? EventParaValue.delayLink.rawValue : EventParaValue.link.rawValue, EventParaName.isFirstLink.rawValue: !firstLink])
                    self.tableView.isHidden = false
                    LoginManager.share.userId = model.user.id
                    if self.currentPage == 0 {
                        self.userModel = model.user
                        self.headView.setDeepHeadData(model.user)
                        HubTool.share.boxUId = model.user.id
                        HubTool.share.boxLinkId = self.linkId
                    }
                    self.list.append(contentsOf: model.page.records)
                    self.tableView.mj_footer?.endRefreshing()
                    if model.page.total == self.list.count {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer?.isHidden = true
                    } else {
                        self.currentPage += 1
                    }
                    self.tableView.reloadData()
                } else {
//                    EventTool.instance.addEvent(type: .custom, event: .landpageFail, paramter: nil)
                    if let e = errMsg {
                        ToastTool.instance.show(e, .fail)
                    }
                }
            }
        }
    }
    
    func pushModelVC(_ model: OpenUrlData) {
        HubTool.share.eventSource = .landpage
        HubTool.share.uploadPlatform = .box
        switch model.file_type {
        case .folder:
            let vc = BoxDeepListController(model: HubTool.share.changeModel(model, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform), linkId: self.linkId, userId: self.userModel.id, userName: self.userModel.username, platform: HubTool.share.platform)
            self.navigationController?.pushViewController(vc, animated: true)
        case .photo:
            let vc = OpenPhotoController(model: HubTool.share.changeModel(model, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform))
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, HubTool.share.changeModel(model, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform), HubTool.share.changeList(self.list, linkId: self.linkId, uId: self.userModel.id, platform: HubTool.share.platform))
        }
    }
    
    @objc func clickAllAction() {
        self.allSelect = !self.allSelect
        self.list.forEach { m in
            m.isSelect = self.allSelect
        }
        self.disPlayBottom()
        self.tableView.reloadData()
    }
    
    func disPlayBottom() {
        let arr = self.list.filter({$0.isSelect == true})
        self.bottomView.isHidden = arr.count == 0
    }
}

extension BoxDeepController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FileCell
        if let m = self.list.safeIndex(indexPath.row) {
            cell.initDeepData(m)
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
        self.list.count
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
        if let m = self.list.safeIndex(indexPath.row) {
            self.pushModelVC(m)
        }
    }
}
