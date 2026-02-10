//
//  FileListController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class FileListController: SuperController {
    let cellIdentifier: String = "FileCellIdentifier"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.isHidden = true
        table.register(FileCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    let bottomView: FileBottomView = FileBottomView.view()
    
    private var list: [VideoData] = []
    private var model: VideoData = VideoData()
    private var isShowBottom: Bool = false

    lazy var uploadBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        btn.setImage(UIImage(named: "add"), for: .highlighted)
        btn.setImage(UIImage(named: "add"), for: .selected)
        return btn
    }()
    
    init(model: VideoData) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let _ = parent {
            return
        } else {
            self.dismissBottomView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.nameL.text = self.model.name
        view.backgroundColor = .white
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        self.view.addSubview(self.uploadBtn)
        self.uploadBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(-(BottomSafeH + 49))
            make.size.equalTo(CGSize(width: 84, height: 30))
        }
        self.uploadBtn.addTarget(self, action: #selector(clickUploadAction), for: .touchUpInside)
        self.netRequest()
    }
    
    @objc func clickUploadAction() {
        self.pushUpload()
    }
    
    func pushUpload() {
        UploadTool.instance.openVC(self, true, self.model.id)
        UploadTool.instance.clickCreateBlock = {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let vc = NewFolderController(parentId: self.model.id)
                vc.modalPresentationStyle = .overFullScreen
                vc.newSuccessBlock = {
                    self.netRequest()
                }
                self.present(vc, animated: false)
            }
        }
    }
    
    func disPlayBottomView(_ show: Bool) {
        self.isShowBottom = true
        let selectList = self.list.filter({$0.isSelect == true})
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
            self.tableView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-84)
            }
        } else {
            self.dismissBottomView()
        }
    }
    
    func dismissBottomView() {
        self.isShowBottom = false
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
                        DispatchQueue.main.async {
                            if status == .success {
                                self.list.forEach { m in
                                    if m.isSelect {
                                        HubDB.instance.deleteData(m)
                                    }
                                }
                                NotificationCenter.default.post(name: Noti_DeleteFileSuccess, object: nil, userInfo: nil)
                                self.list = self.list.filter({$0.isSelect == false})
                                self.dismissBottomView()
                                self.tableView.reloadData()
                            } else {
                                ToastTool.instance.show(errMsg, .fail)
                            }
                        }
                    }
                }
            }
            self.present(vc, animated: false)
        case .rename:
            let vc = NewFolderController(parentId: self.model.id)
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
                        NotificationCenter.default.post(name: Noti_ReNameSuccess, object: nil, userInfo: nil)
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
        self.list.removeAll()
        LoadManager.instance.show(self)
        HttpManager.share.selectFolderApi(self.model.id) { [weak self] status, list, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if status == .success {
                    self.list = list
                    self.tableView.isHidden = self.list.count == 0
                    self.tableView.reloadData()
                } else {
                    ToastTool.instance.show(errMsg ?? "Request fail", .fail)
                }
            }
        }
    }
    
    func pushSubVC(_ model: VideoData) {
        guard self.isShowBottom == false else { return }
        self.dismissBottomView()
        switch model.file_type {
        case .folder:
            let vc = FileListController(model: model)
            self.navigationController?.pushViewController(vc, animated: true)
        case .photo:
            let vc = OpenPhotoController(model: model)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, model, self.list.filter({$0.file_type == .video}))
        }
    }
}

extension FileListController: UITableViewDelegate, UITableViewDataSource {
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
