//
//  IndexController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexController: SuperController {
    private let headL: UILabel = {
        let label = UILabel()
        label.text = "MyHub"
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .black, size: 18)
        return label
    }()
    
    let emptyV: EmptyView = EmptyView.view()
    
    let cellIdentifier: String = "IndexCellIdentifier"
    let historyCellIdentifier: String = "IndexHistoryListCellIdentifier"
    
    let tableHeadV: IndexHeadView = IndexHeadView.view()
    
    private var list: [HomeListData] = []
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.bounces = false
        table.register(IndexCell.self, forCellReuseIdentifier: cellIdentifier)
        table.register(IndexHistoryListCell.self, forCellReuseIdentifier: historyCellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabbarTool.instance.displayOrHidden(true)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        let m = HomeListData()
        m.type = .upload
        m.lists = [VideoData()]
        self.list.append(m)
        self.tableView.reloadData()
    }
    
    func setup() {
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.headL)
        self.headL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.tableView.tableHeaderView = self.tableHeadV
        
        self.tableHeadV.setData()
    }
    
    @objc func clickHeadAction(_ sender: UITapGestureRecognizer) {
        if let m = self.list.safeIndex(sender.view?.tag ?? 0) {
            if m.type == .channel {
//                let vc = ChannelListController()
//                vc.model = m.users.first ?? ChannelUserData()
//                vc.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = IndexListController(list: m.lists, type: m.type)
                vc.hidesBottomBarWhenPushed = true
                TabbarTool.instance.displayOrHidden(false)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension IndexController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IndexCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! IndexCell
        if let m = self.list.safeIndex(indexPath.section) {
            switch m.type {
            case .history:
                break
            case .channel:
                break
            case .upload:
                if let mod = m.lists.safeIndex(indexPath.row) {
                    cell.initData(mod)
                    cell.clickMoreBlock = {[weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if let dataBaseModel = HubDB.instance.readDatas().first(where: {$0.id == mod.id}) {
                                mod.state = dataBaseModel.state
                                mod.movieAddress = dataBaseModel.movieAddress
                            }
                            let vc = IndexMoreController(model: mod, type: m.type)
                            vc.deleteBlock = {
                                DispatchQueue.main.async {
                                    HttpManager.share.deleteFileApi([mod]) { [weak self] status, errMsg in
                                        guard let self = self else { return }
                                        DispatchQueue.main.async {
                                            if status == .success {
                                                HubDB.instance.deleteData(mod)
                                                NotificationCenter.default.post(name: Noti_DeleteFileSuccess, object: nil, userInfo: nil)
                                                m.lists.remove(at: indexPath.row)
                                                if m.lists.count == 0 {
                                                    self.list.removeLast()
                                                }
                                                self.tableView.reloadData()
                                                if self.list.count == 0 {
                                                    self.emptyV.isHidden = false
                                                    self.tableView.isHidden = true
                                                } else {
                                                    self.emptyV.isHidden = true
                                                    self.tableView.isHidden = false
                                                }
                                            } else {
                                                ToastTool.instance.show(errMsg, .fail)
                                            }
                                        }
                                    }
                                }
                            }
                            vc.renameBlock = { name in
                                mod.name = name
                                DispatchQueue.main.async {
                                    let dbList = HubDB.instance.readDatas()
                                    self.list.forEach { itemM in
                                        itemM.lists.forEach { subM in
                                            if subM.id == mod.id {
                                                subM.name = name
                                                dbList.forEach { ssM in
                                                    if ssM.id == subM.id || ssM.obs_fileId == subM.id {
                                                        ssM.name = name
                                                        HubDB.instance.updateMovieData(ssM)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    NotificationCenter.default.post(name: Noti_ReNameSuccess, object: nil, userInfo: nil)
                                    self.tableView.reloadData()
                                }
                            }
                            vc.modalPresentationStyle = .overFullScreen
                            self.present(vc, animated: false)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.list.safeIndex(section) {
            if m.type == .upload {
                return m.lists.count
            } else {
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if let m = self.list.safeOfItem(indexPath.section) {
        //            if let mod = m.lists.safeOfItem(indexPath.row), mod.isPass == .passed {
        //                ESBaseTool.instance.email = mod.email
        //                ESBaseTool.instance.uId = mod.userId
        //                ESBaseTool.instance.uploadPlatform = mod.platform
        //                if m.type == .history {
        //                    ESBaseTool.instance.playSource = .history
        //                    ESBaseTool.instance.eventSource = .history
        //                } else {
        //                    ESBaseTool.instance.playSource = .history
        //                    ESBaseTool.instance.eventSource = .history
        //                }
        //                self.pushSubVC(mod, m.lists)
        //            }
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 32))
        view.backgroundColor = .clear
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 16)
        label.textColor = UIColor.rgbHex("#434343")
        let imageV = UIImageView()
        imageV.image = UIImage(named: "arrow")
        view.addSubview(label)
        view.addSubview(imageV)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.bottom.equalTo(-8)
        }
        imageV.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.right.equalTo(-14)
        }
        if let m = self.list.safeIndex(section) {
            label.text = m.type.rawValue
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickHeadAction(_:)))
        view.tag = section
        view.addGestureRecognizer(tap)
        return view
    }
}

extension URL {
    var parameters: [String: String]? {
        guard let compon = URLComponents(url: self, resolvingAgainstBaseURL: true), let mod = compon.queryItems else { return nil }
        return mod.reduce(into: [String: String]()) { result, model in
            result[model.name] = model.value
        }
    }
}
