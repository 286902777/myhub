//
//  FileController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class FileController: UIViewController {
    let noContentV: EmptyView = EmptyView.view()

    let cellIdentifier: String = "FileCellIdentifier"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.isHidden = true
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CusTabBarHight, right: 0)
        table.register(FileCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    lazy var sortV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var sortL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 12)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        return label
    }()
    lazy var sortImageV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "xia")
        return view
    }()
    
    let bottomView: FileBottomView = FileBottomView.view()
    
    private var list: [VideoData] = []
    private var sortType: HUB_SortType = .upload
    private var sortAsc: Bool = true
    private var isShowBottom: Bool = false
    
    var clickUploadBlock: (() -> Void)?
    var showCountBlock: ((_ count: Int) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.netRequest()
        TabbarTool.instance.displayOrHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabbarTool.instance.displayOrHidden(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(self.sortV)
        self.sortV.addSubview(self.sortL)
        self.sortV.addSubview(self.sortImageV)
        view.addSubview(self.tableView)
        self.sortV.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(28)
        }
        self.sortL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        self.sortImageV.snp.makeConstraints { make in
            make.left.equalTo(self.sortL.snp.right)
            make.size.equalTo(CGSize(width: 12, height: 12))
            make.centerY.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.sortV.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickSortAction))
        self.sortV.addGestureRecognizer(tap)
        
        view.addSubview(self.noContentV)
        self.noContentV.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        self.noContentV.clickBlock = { [weak self] type in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.clickUploadBlock?()
            }
        }
        NotificationCenter.default.addObserver(forName: Noti_DeleteFileSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let result = data.userInfo?["list"] as? [String] {
                result.forEach { id in
                    self.list.removeAll(where: {$0.id == id})
                }
                self.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_ReNameSuccess, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let dbList = HubDB.instance.readDatas()
            self.list.forEach { m in
                if let mod = dbList.first(where: {$0.id == m.id}) {
                    m.name = mod.name
                }
            }
            self.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: Noti_AppDeep, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.list.forEach { m in
                m.isSelect = false
            }
            self.tableView.reloadData()
            self.dismissBottomView()
        }
    }
    
    func disPlayBottomView(_ show: Bool) {
        TabbarTool.instance.displayOrHidden(false)
        self.isShowBottom = true
        self.sortV.isHidden = true
        self.sortV.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        let selectList = self.list.filter({$0.isSelect == true})
        self.showCountBlock?(selectList.count)
        if selectList.count > 0 {
            HubTool.share.keyWindow?.addSubview(self.bottomView)
            self.bottomView.setReNameState(selectList.count == 1)
            self.bottomView.snp.makeConstraints { make in
                make.left.equalTo(14)
                make.right.equalTo(-14)
                make.height.equalTo(84)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
            self.bottomView.clickBlock = { [weak self] type in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.bottomAction(type, selectList)
                }
            }
        } else {
            self.dismissBottomView()
        }
    }
    
    @objc func clickSortAction() {
        let vc = SortController()
        vc.currentType = self.sortType
        vc.currentAsc = self.sortAsc
        vc.modalPresentationStyle = .overFullScreen
        vc.clickBlock = { [weak self] type, asc in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.sortType = type
                self.sortAsc = asc
                self.sortData(type, asc)
            }
        }
        self.present(vc, animated: false)
    }
    
    func dismissBottomView() {
        TabbarTool.instance.displayOrHidden(true)
        self.isShowBottom = false
        self.sortV.isHidden = false
        self.sortV.snp.updateConstraints { make in
            make.height.equalTo(28)
        }
        self.bottomView.removeFromSuperview()
    }
    
    func bottomAction(_ type: HUB_FileBottomType, _ results: [VideoData]) {
        switch type {
        case .download:
            let dbList = HubDB.instance.readDatas()
            var isDown: Bool = false
            results.forEach { m in
                if m.file_type != .folder {
//                    if let mod = dbList.first(where: {$0.id == m.id}) {
//                        if mod.state != .downDone {
//                            FileUploadDownTool.instance.downLoad(m)
//                            isDown = true
//                        }
//                    } else {
//                        FileUploadDownTool.instance.downLoad(m)
//                        isDown = true
//                    }
                }
            }
            if isDown {
                ToastTool.instance.show("The contents, excluding the folder, have been added to the download list.")
            } else {
                ToastTool.instance.show("The file has been downloaded.")
            }
        case .share:
            let vc = ShareController(list: results)
            vc.modalPresentationStyle = .overFullScreen
            vc.resultBlock = { [weak self] url in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let copyVC = ShareCopyController()
                    copyVC.modalPresentationStyle = .overFullScreen
                    copyVC.url = url
                    self.present(copyVC, animated: false)
                }
            }
            self.present(vc, animated: false)
        case .delete:
            let vc = AlertController(title: "Delete", info: "Shall I delete the selected files?")
            vc.modalPresentationStyle = .overFullScreen
            vc.okBlock = { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    HttpManager.share.deleteFileApi(results) { [weak self] status, errMsg in
                        guard let self = self else { return }
                        if status == .success {
                            results.forEach { m in
                                if m.isSelect {
                                    HubDB.instance.deleteData(m)
                                }
                            }
                            self.list = self.list.filter({$0.isSelect == false})
                            DispatchQueue.main.async {
                                self.dismissBottomView()
                                self.tableView.reloadData()
                            }
                        } else {
                            ToastTool.instance.show(errMsg, .fail)
                        }
                    }
                }
            }
            self.present(vc, animated: false)
        case .rename:
            let vc = NewFolderController(parentId: "")
            vc.modalPresentationStyle = .overFullScreen
            if let m = self.list.first(where: {$0.isSelect == true}) {
                vc.isFixName = true
                vc.fileId = m.id
                vc.fixSuccessBlock = { [weak self] name in
                    guard let self = self else { return }
                    m.name = name
                    DispatchQueue.main.async {
                        let dbList = HubDB.instance.readDatas()
                        dbList.forEach { ssM in
                            if ssM.id == m.id || ssM.obs_fileId == m.id {
                                ssM.name = name
                                HubDB.instance.updateMovieData(ssM)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            self.present(vc, animated: false)
        default:
            break
        }
    }
    
    func netRequest() {
        LoadManager.instance.show(self)
        HttpManager.share.selectFolderApi("") { [weak self] status, list, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if status == .success {
                    self.list = list
                    self.sortData(self.sortType, self.sortAsc)
                    self.tableView.isHidden = self.list.count == 0
                    self.tableView.reloadData()
                    self.refreshUI()
                } else {
                    ToastTool.instance.show(errMsg ?? "Request fail", .fail)
                }
            }
        }
    }
    
    func refreshUI() {
        if self.list.count == 0 {
            self.noContentV.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noContentV.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    func sortData(_ type: HUB_SortType, _ asc: Bool) {
        let foldList = self.list.filter({$0.file_type == .folder})
        var otherList = self.list.filter({$0.file_type != .folder})
        self.sortType = type
        self.sortAsc = asc
        switch type {
        case .upload:
            if asc {
                otherList = otherList.sorted(by: {$0.pubData < $1.pubData})
            } else {
                otherList = otherList.sorted(by: {$0.pubData > $1.pubData})
            }
        case .size:
            if asc {
                otherList = otherList.sorted(by: {$0.file_size < $1.file_size})
            } else {
                otherList = otherList.sorted(by: {$0.file_size > $1.file_size})
            }
        case .type:
            if asc {
                otherList = otherList.sorted(by: {$0.ext < $1.ext})
            } else {
                otherList = otherList.sorted(by: {$0.ext > $1.ext})
            }
        }
        self.list.removeAll()
        self.list.append(contentsOf: foldList)
        self.list.append(contentsOf: otherList)
        self.tableView.reloadData()
    }
    
    func pushSubVC(_ model: VideoData) {
        guard self.isShowBottom == false else { return }
        switch model.file_type {
        case .folder:
            let vc = FileListController(model: model)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .photo:
            let vc = OpenPhotoController(model: model)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, model, self.list.filter({$0.file_type == .video}))
        }
    }
}

extension FileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FileCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FileCell
        if let m = self.list.safeIndex(indexPath.row) {
            cell.initDirData(m)
            cell.selectBlock = { [weak self] on in
                guard let self = self else { return }
                m.isSelect = on
                DispatchQueue.main.async {
                    self.disPlayBottomView(true)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.row), m.isPass == .passed {
            self.pushSubVC(m)
        }
    }
}

