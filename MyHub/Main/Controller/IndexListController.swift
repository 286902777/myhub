//
//  IndexListController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class IndexListController: SuperController {
    let cellIdentifier: String = "IndexListCellIdentifier"
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: BottomSafeH, right: 0)
        table.register(IndexListCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    private var lists: [VideoData] = []
    private var type: HUB_HomeListType = .history
    
    init(list: [VideoData], type: HUB_HomeListType) {
        self.lists = list
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        NotificationCenter.default.addObserver(forName: Noti_DeleteFileSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let result = data.userInfo?["list"] as? [String] {
                result.forEach { id in
                    self.lists.removeAll(where: {$0.id == id})
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func initUI() {
        self.navbar.nameL.text = self.type.rawValue
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    func pushSubVC(_ model: VideoData, _ lists: [VideoData]) {
        switch model.file_type {
        case .folder:
            break
        case .photo:
            let vc = OpenPhotoController(model: model)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .video:
            PlayTool.instance.pushPage(self, model, lists.filter({$0.file_type == .video}))
        }
    }
}

extension IndexListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IndexListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IndexListCell
        if let m = self.lists.safeIndex(indexPath.row) {
            cell.initData(m)
            cell.clickMoreBlock = { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let vc = IndexMoreController(model: m, type: self.type)
                    if let dataBaseModel = HubDB.instance.readDatas().first(where: {$0.id == m.id}) {
                        m.state = dataBaseModel.state
                        m.movieAddress = dataBaseModel.movieAddress
                    }
                    vc.deleteBlock = { [weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if self.type == .history {
                                m.history = false
                                HubDB.instance.updateMovieData(m)
                                self.lists.remove(at: indexPath.row)
                                self.tableView.reloadData()
                            } else {
                                HttpManager.share.deleteFileApi([m]) { status, errMsg in
                                    DispatchQueue.main.async {
                                        if status == .success {
                                            HubDB.instance.deleteData(m)
                                            NotificationCenter.default.post(name: Noti_DeleteFileSuccess, object: nil, userInfo: nil)
                                            self.lists.remove(at: indexPath.row)
                                            self.tableView.reloadData()
                                        } else {
                                            ToastTool.instance.show(errMsg, .fail)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    vc.renameBlock = { name in
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
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.lists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        122
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = self.lists.safeIndex(indexPath.row) {
            self.pushSubVC(m, self.lists)
        }
    }
}
