//
//  PlayListFullController.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class PlayListFullController: UIViewController {
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
    
    let cellIdentifier: String = "PlayListFullCellIdentifier"
    var selectBlock: ((_ model: VideoData) -> Void)?
    private var currentIdx: Int = 0
    private var currentModel: VideoData = VideoData()

    lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        collectionView.register(PlayListFullCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        return collectionView
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
        
//        if PlayTool.instance.list.last?.recommend == false, self.isHistory == false {
//            self.requestUserLoop()
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(self.contentV)
        self.contentV.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(276)
        }
        self.contentV.addSubview(self.collectionV)
    
        self.collectionV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentV.backgroundColor = UIColor.rgbHex("#8c8c8c")
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
        
        self.collectionV.reloadData()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.collectionV.scrollToItem(at: IndexPath(item: self.currentIdx, section: 0), at: .centeredVertically, animated: false)
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
                    self.collectionV.reloadData()
                } else {
                    ToastTool.instance.show("request fail!", .fail)
                }
            }
        }
    }
    
    @objc func pageDismiss() {
        self.dismiss(animated: false)
    }
}

extension PlayListFullController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        PlayTool.instance.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayListFullCell
        if let m = PlayTool.instance.list.safeIndex(indexPath.item) {
            cell.initData(m, self.currentIdx == indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let m = PlayTool.instance.list.safeIndex(indexPath.item) {
            self.selectBlock?(m)
            self.currentIdx = indexPath.row
            self.collectionV.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath
            )
            
            // 配置 Header
            header.backgroundColor = UIColor.rgbHex("#8c8c8c")
            
            // 添加 UILabel
            if let label = header.viewWithTag(indexPath.section) as? UILabel {
                label.text = indexPath.section == 0 ? "PlayList" : "Recommend"
            } else {
                let label = UILabel()
                label.tag = indexPath.section
                label.frame = CGRect(x: 16, y: 0, width: header.frame.width - 32, height: header.frame.height)
                label.font = UIFont.GoogleSans(weight: .medium, size: 18)
                label.text = indexPath.section == 0 ? "PlayList" : "Recommend"
                label.textColor = .white
                header.addSubview(label)
            }
            return header
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 120, height: 100)
    }
}

extension PlayListFullController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if contentV.bounds.contains(touch.location(in: contentV)) {
            return false
        }
        return true
    }
}
