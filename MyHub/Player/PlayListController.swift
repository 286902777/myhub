//
//  PlayListController.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class PlayListController: UIViewController {
    private lazy var titleL: UILabel = {
        let label = UILabel()
        label.text = "Playlist"
        label.textColor = .white
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        return label
    }()
    
    private lazy var contentV: UIView = {
        let view = UIView()
        return view
    }()
    
    let cellIdentifier: String = "PlayListCellIdentifier"
    var selectBlock: ((_ model: VideoData) -> Void)?
    private var currentIdx: Int = 0
    private var currentModel: VideoData = VideoData()

    private lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(PlayListCell.self, forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    private var recommonedUserId: String = ""
    private var recommonedList: [ChannelData] = []

    private var isHistory: Bool = false
    init(model: VideoData, history: Bool) {
        self.currentModel = model
        self.isHistory = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.scrollToIdx()
        NotificationCenter.default.addObserver(forName: Noti_NextPlay, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let m = data.userInfo?["mod"] as? VideoData {
                self.currentModel = m
                self.scrollToIdx()
            }
        }
        if PlayTool.instance.list.last?.recommend == false, self.isHistory == false {
            self.requestUserLoop()
        }
    }
    
    func requestUserLoop() {
        LoadManager.instance.show(self)
        let userList = HubDB.instance.readUsers().filter({$0.platform == self.currentModel.platform})
        if userList.count > 0 {
            let userListCount: UInt32 = UInt32(userList.count - 1)
            if let m = userList.safeIndex(Int(arc4random_uniform(userListCount))) {
                HttpManager.share.channelUserList(m.id, m.platform) { [weak self] status, list, errMsg, refresh in
                    guard let self = self else { return }
                    if refresh {
                        self.requestUserLoop()
                    }
                    if status == .success, list.count > 0 {
                        let result = list.filter({$0.id != m.id})
                        if result.count > 0 {
                            let listCount: UInt32 = UInt32(result.count - 1)
                            if let mod = result.safeIndex(Int(arc4random_uniform(listCount))) {
                                self.recommonedUserId = mod.id
                                self.requestRecommoned()
                            }
                        } else {
                            self.recommonedUserId = m.id
                            self.requestRecommoned()
                        }
                    } else {
                        LoadManager.instance.dismiss()
                    }
                }
            }
        } else {
            self.recommonedUserId = self.currentModel.id
            self.requestRecommoned()
        }
    }
    
    func requestRecommoned() {
        HttpManager.share.channel("", self.recommonedUserId, 1) { [weak self] status, model, errMsg, refresh in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            DispatchQueue.main.async {
                if refresh {
                    self.requestRecommoned()
                    return
                }
                if status == .success {
                    model.files.forEach { data in
                        data.recommoned = true
                        self.recommonedList.append(data)
                    }
                    PlayTool.instance.list.append(contentsOf: HubTool.share.channelList(self.recommonedList, linkId: "", uId: self.recommonedUserId, platform: self.currentModel.platform))
                    self.tableView.reloadData()
                } else {
                    ToastTool.instance.show("request fail!", .fail)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(self.contentV)
        self.contentV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(ScreenHeight * 0.6)
        }
        self.contentV.addSubview(self.titleL)
        self.contentV.addSubview(self.tableView)
        self.titleL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(self.titleL.snp.bottom).offset(6)
        }
        
        self.contentV.layoutIfNeeded()
        self.contentV.backgroundColor = UIColor.rgbHex("#000000", 0.6)
        self.contentV.addEffectView(self.contentV.frame.size, .light)
        let tap = UITapGestureRecognizer(target: self, action: #selector(pageDismiss))
        view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    func scrollToIdx() {
        for (i, item) in PlayTool.instance.list.enumerated() {
            if (item.id == self.currentModel.id) {
                currentIdx = i
                break
            }
        }
        
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.tableView.scrollToRow(at: IndexPath(row: self.currentIdx, section: 0), at: .none, animated: false)
        }
    }
    
    @objc func pageDismiss() {
        self.dismiss(animated: false)
    }
}

extension PlayListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlayListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PlayListCell
        if let m = PlayTool.instance.list.safeIndex(indexPath.row) {
            cell.initData(m, self.currentIdx == indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PlayTool.instance.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let m = PlayTool.instance.list.safeIndex(indexPath.row) {
            self.selectBlock?(m)
            self.currentIdx = indexPath.row
            self.tableView.reloadData()
        }
    }
}

extension PlayListController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if contentV.bounds.contains(touch.location(in: contentV)) {
            return false
        }
        return true
    }
}
