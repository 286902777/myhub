//
//  BoxDeepListController.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit
import SnapKit
import MJRefresh

class BoxDeepListController: UIViewController {
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
    private var list: [VideoData] = []
    private var allSelect: Bool = false
    init(model: VideoData, linkId: String, userId: String, userName: String, platform: HUB_PlatformType) {
        self.model = model
        self.linkId = linkId
        self.userId = userId
        self.userName = userName
        self.platform = platform
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addFooter()
    }
    
    func setUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(self.closeBtn)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.headView)
        self.contentView.addSubview(self.tableView)
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
        self.headView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(74)
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
                    if let m = self.list.first(where: {$0.file_type == .video}) {
                        PlayTool.instance.pushPage(self, m, self.list)
                    }
                case 1:
                    guard HubTool.share.userIsLogin(self) else { return }
                    let m: VideoData = VideoData()
                    m.id = self.linkId
                    m.linkId = self.linkId
                    m.userId = self.userId
                    m.name = self.userName
                    m.isShare = true
                    m.platform = self.platform
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
            self.loadData()
        }
        self.tableView.mj_footer = foot
        self.tableView.mj_footer?.beginRefreshing()
    }
    
    func loadData() {
        LoadManager.instance.show(self)
        HttpManager.share.getShareFolderApi(self.userId, self.model.id, self.currentPage) {[weak self] status, list, errMsg in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                if status == .success {
                    if list.count < 50 {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer?.isHidden = true
                    }
                    self.list.append(contentsOf: list)
                    if list.count < HttpManager.share.pageSize {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer?.isHidden = true
                    } else {
                        self.currentPage += 1
                    }
                    self.tableView.reloadData()
                } else {
                    ToastTool.instance.show(errMsg, .fail)
                }
            }
        }
    }
    
    func pushModelVC(_ model: VideoData) {
        switch model.file_type {
        case .folder:
            let vc = BoxDeepListController(model: model, linkId: self.linkId, userId: model.userId, userName: self.userName, platform: self.platform)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        case .photo:
            let vc = OpenPhotoController(model: model)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, model, self.list)
        }
    }
    
    func disPlayBottom() {
        let arr = self.list.filter({$0.isSelect == true})
        self.bottomView.isHidden = arr.count == 0
    }
    
    @objc func clickCloseAction() {
        NotificationCenter.default.post(name: Noti_ClosePresent, object: nil, userInfo: nil)
    }
}

extension BoxDeepListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FileCell
        if let m = self.list.safeIndex(indexPath.row) {
            cell.initDirData(m)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.row) {
            self.pushModelVC(m)
        }
    }
}
