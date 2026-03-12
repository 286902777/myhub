//
//  DownFileController.swift
//  MyHub
//
//  Created by hub on 2026/2/13.
//

import UIKit
import SnapKit

class DownFileController: UIViewController {
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
    var countBadgeBlock: ((_ num: Int) -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addData()
        HubTool.share.adsPlayState = .donwloadpage
//        AdmobTool.instance.show(.mode_down) { _ in
//            
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            guard let vc = HubTool.share.keyVC(), vc.isKind(of: DownFileController.self) else { return }
            if HubTool.share.adsPlayState == .donwloadpage {
                HubTool.share.preSource = .vip_Ad
                HubTool.share.preMethod = .vip_auto
                PlayTool.instance.adsPushPremium(.donwloadpage, .vip_Ad, self)
            }
        }
        NotificationCenter.default.addObserver(forName: Noti_AddDown, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.addData()
        }
        NotificationCenter.default.addObserver(forName: Noti_Down, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let mod = data.userInfo?["mod"] as? FileTransData {
                for (idx, item) in self.list.enumerated() {
                    for (row, m) in item.lists.enumerated() {
                        if (m.id == mod.transId) {
                            m.state = mod.state
                            m.done_size = mod.doneSize
                            self.tableView.reloadRows(at: [IndexPath(row: row, section: idx)], with: .none)
                        }
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: Noti_DownSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let mod = data.userInfo?["mod"] as? FileTransData {
                self.list.forEach { item in
                    item.lists.forEach { m in
                        if (m.id == mod.transId) {
                            m.state = mod.state
                            m.movieAddress = mod.local
                            if mod.state == .downDone {
                                HubDB.instance.updateMovieData(m)
                            }
                        }
                    }
                }
            }
            self.addData()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_NetworkStatus, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if NetManager.instance.isReachable {
                return
            }
            if let m = self.list.filter({$0.state == .inProgree}).first {
                if m.lists.count > 0 {
                    ToastTool.instance.show("Download failed!", .fail)
                }
                m.lists.forEach { mod in
                    if mod.state != .downDone {
                        if mod.state == .downing {
                            DownTool.instance.cancelReqeust()
                        }
                        mod.state = .downFail
                        HubDB.instance.updateMovieData(mod)
                    }
                }
            }
            
            UploadDownTool.instance.downList.removeAll()
            self.addData()
        }
    }
    
    func initUI() {
        view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.addSubview(self.noContentV)
        self.noContentV.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.noContentV.upBtn.isHidden = true
        self.noContentV.infoL.text = "No files."
    }
    
    func addData() {
        self.list.removeAll()
        let inproList: [VideoData] = HubDB.instance.readDatas().filter({$0.state == .downWait || $0.state == .downing || $0.state == .downFail}).sorted(by: {$0.date > $1.date})
        if inproList.count > 0 {
            let inMod = UploadDownData()
            inMod.state = .inProgree
            inMod.lists = inproList
            self.list.append(inMod)
        }
        
        let comList: [VideoData] = HubDB.instance.readDatas().filter({$0.state == .downDone}).sorted(by: {$0.date > $1.date})
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
                    if m.state == .downDone, let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let destinationURL = documentsDirectory.appendingPathComponent(m.movieAddress)
                        // 如果已存在，先删除
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try? FileManager.default.removeItem(at: destinationURL)
                        }
                    }
                    if m.state == .downing {
                        DownTool.instance.cancelReqeust()
                    }
                    m.state = .normal
                    m.isNet = true
                    m.movieAddress = ""
                    UploadDownTool.instance.downList.removeAll()
                    HubDB.instance.updateMovieData(m)
                }
            }
        }
        self.list.removeAll(where: {$0.state == state})
        UploadDownTool.instance.uploadList.removeAll()
        self.addData()
    }
    
    func resetDown(_ model: VideoData) {
        UploadDownTool.instance.downLoad(model)
    }
    
    @objc func clickHeadAction(_ sender: UIButton) {
        if let m = self.list.safeIndex(sender.tag) {
            let vc = AlertController(title: "Delete", info: "Do you want to delete these files?")
            vc.modalPresentationStyle = .overFullScreen
            vc.okBlock = {[weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.removeData(m.state)
                }
            }
            self.present(vc, animated: false)
        }
    }
}

extension DownFileController: UITableViewDelegate, UITableViewDataSource {
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
                                if data.state == .downing {
                                    DownTool.instance.cancelReqeust()
                                    UploadDownTool.instance.downNext(data)
                                } else {
                                    UploadDownTool.instance.downList.removeAll(where: {$0.id == data.id})
                                }
                                if data.state == .downDone, let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let destinationURL = documentsDirectory.appendingPathComponent(data.movieAddress)
                                    // 如果已存在，先删除
                                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                                        try? FileManager.default.removeItem(at: destinationURL)
                                    }
                                }
                                data.state = .normal
                                data.isNet = true
                                data.movieAddress = ""
                                HubDB.instance.updateMovieData(data)
                                self.addData()
                            }
                            self.present(vc, animated: false)
                        }
                    }
                    uCell.failBlock = { [weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            data.state = .downWait
                            self.resetDown(data)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.list.safeIndex(section) {
            return m.lists.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32))
        view.backgroundColor = .white
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
            make.centerY.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 32))
        }
        if let m = self.list.safeIndex(section) {
            label.text = m.state.rawValue + " · " + "\(m.lists.count)"
        }
        delBtn.tag = section
        delBtn.addTarget(self, action: #selector(clickHeadAction(_:)), for: .touchUpInside)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = self.list.safeIndex(indexPath.section), data.state == .completed {
            if let m = data.lists.safeIndex(indexPath.row) {
                if m.file_type == .video {
                    HubTool.share.playSource = .download_list
                    HubTool.share.eventSource = .download
                    PlayTool.instance.pushPage(self, m, data.lists)
                } else {
                    let vc = OpenPhotoController(model: m)
                    vc.hidesBottomBarWhenPushed = true
                    TabbarTool.instance.displayOrHidden(false)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
