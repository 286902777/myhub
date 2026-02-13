//
//  UploadFileController.swift
//  MyHub
//
//  Created by Ever on 2026/2/13.
//

import UIKit
import SnapKit

class UploadFileController: UIViewController {
    let cellIdentifier: String = "DownCellIdentifier"
    let uCellIdentifier: String = "UploadAndDownCellIdentifier"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(DownCell.self, forCellReuseIdentifier: cellIdentifier)
        table.register(UploadAndDownCell.self, forCellReuseIdentifier: uCellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    let noContentV: EmptyView = EmptyView.view()
    private var list: [UploadDownData] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        NotificationCenter.default.addObserver(forName: Noti_AddUpload, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.addData()
        }
        NotificationCenter.default.addObserver(forName: Noti_UploadSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let _ = data.userInfo?["mod"] as? FileTransData {
                self.addData()
//                self.list.forEach { m in
//                    for (idx, item) in m.lists.enumerated() {
//                        if (item.id == mod.transId) {
//                            item.state = mod.state
//                            item.done_size = item.file_size
//                            item.obs_fileId = mod.obs_fileId
//                            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
//                        }
//                    }
//                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_Upload, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let _ = data.userInfo?["mod"] as? FileTransData {
                self.addData()
//                for (idx, item) in self.list.enumerated() {
//                    if (item.id == mod.transId) {
//                        item.upload_size = mod.doneSize
//                        item.state = mod.state
//                        self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
//                    }
//                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_UploadEvent, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.addData()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_NetworkStatus, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if NetManager.instance.isReachable {
                return
            }
            self.list.forEach { m in
                if m.state == .inProgree {
                    m.lists.forEach { data in
                        data.state = .uploadFaid
                        HubDB.instance.updateMovieData(data)
                    }
                }
            }
            UploadDownTool.instance.uploadList.removeAll()
            self.addData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initUI() {
        view.backgroundColor = .white
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.addSubview(self.noContentV)
        self.noContentV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.noContentV.upBtn.isHidden = true
        self.noContentV.infoL.text = "No files."
    }
    
    func addData() {
        self.list.removeAll()
        let inproList: [VideoData] = HubDB.instance.readDatas().filter({$0.state == .uploading || $0.state == .uploadWait || $0.state == .uploadFaid }).sorted(by: {$0.date > $1.date})
        if inproList.count > 0 {
            let inMod = UploadDownData()
            inMod.state = .inProgree
            inMod.lists = inproList
            self.list.append(inMod)
        }
        
        let comList: [VideoData] = HubDB.instance.readDatas().filter({$0.state == .upload}).sorted(by: {$0.date > $1.date})
        if comList.count > 0 {
            let comMod = UploadDownData()
            comMod.state = .completed
            comMod.lists = comList
            self.list.append(comMod)
        }
        
        self.tableView.reloadData()
        self.refreshUI()
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
    
    func removeData(_ state: HUB_UploadDownState) {
        self.list.forEach { data in
            if data.state == state {
                data.lists.forEach { m in
                    if m.state == .uploading {
                        FileUploadTool.instance.cancelRequest()
                        HttpManager.share.deleteFileApi([m]) { status, errMsg in
                            
                        }
                    }
                    HubDB.instance.deleteData(m)
                }
            }
        }
        self.list.removeAll(where: {$0.state == state})
        UploadDownTool.instance.uploadList.removeAll()
        self.addData()
    }
    
    func resetUpload(_ model: VideoData) {
        UploadDownTool.instance.upload(model)
    }
}

extension UploadFileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DownCell
        let uCell: UploadAndDownCell = tableView.dequeueReusableCell(withIdentifier: uCellIdentifier) as! UploadAndDownCell
        if let m = self.list.safeIndex(indexPath.section) {
            if m.state == .inProgree {
                if let data = m.lists.safeIndex(indexPath.row) {
                    uCell.initData(data)
                    uCell.deleteBlock = { [weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            let vc = AlertController(title: "Delete", info: "Do you want to delete this file?")
                            vc.modalPresentationStyle = .overFullScreen
                            vc.okBlock = {
                                if data.state == .uploading {
                                    FileUploadTool.instance.cancelRequest()
                                    HttpManager.share.deleteFileApi([data]) { status, errMsg in
                                        
                                    }
                                }
                                UploadDownTool.instance.uploadNext(data)
                                HubDB.instance.deleteData(data)
                                // 处理删除逻辑
                                self.addData()
                            }
                            self.present(vc, animated: false)
                        }
                    }
                    return uCell
                }
            } else {
                if let data = m.lists.safeIndex(indexPath.row) {
                    cell.initData(data)
                    cell.deleteBlock = { [weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            let vc = AlertController(title: "Delete", info: "Do you want to delete this file?")
                            vc.modalPresentationStyle = .overFullScreen
                            vc.okBlock = {
                                HubDB.instance.deleteData(data)
                                // 处理删除逻辑
                                self.addData()
                            }
                            self.present(vc, animated: false)
                        }
                    }
                    return cell
                }
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.list.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.list.safeIndex(section) {
            return m.lists.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32))
        view.backgroundColor = .clear
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#14171C", 0.75)
        let delBtn = UIButton()
        delBtn.titleLabel?.font = UIFont.GoogleSans(size: 12)
        delBtn.setTitle(" Delete", for: .normal)
        delBtn.setImage(UIImage(named: "delete_down"), for: .normal)
        delBtn.setTitleColor(UIColor.rgbHex("#FF1A75"), for: .normal)
        view.addSubview(label)
        view.addSubview(delBtn)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        delBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 96, height: 32))
            make.right.equalTo(-14)
        }
        if let m = self.list.safeIndex(section) {
            label.text = m.state.rawValue + " · " + "\(m.lists.count)"
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickHeadAction(_:)))
        view.tag = section
        view.addGestureRecognizer(tap)
        return view
    }
    
    @objc func clickHeadAction(_ sender: UITapGestureRecognizer) {
        if let m = self.list.safeIndex(sender.view?.tag ?? 0) {
            self.removeData(m.state)
        }
    }
}
