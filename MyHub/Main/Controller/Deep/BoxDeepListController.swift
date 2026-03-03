//
//  BoxDeepListController.swift
//  MyHub
//
//  Created by Ever on 2026/3/2.
//

import UIKit
import SnapKit
import MJRefresh

class BoxDeepListController: UIViewController {
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
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.headView)
        self.contentView.addSubview(self.tableView)
        self.contentView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(NavBarH)
        }
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
            make.height.equalTo(0)
        }
        self.bottomView.isHidden = true
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
            self.navigationController?.pushViewController(vc, animated: true)
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
