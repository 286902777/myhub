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
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    private lazy var contentV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.rgbHex("#000000", 0.25)
        return view
    }()
    
    let cellIdentifier: String = "PlayListCellIdentifier"
    var selectBlock: ((_ model: VideoData) -> Void)?
    private var currentIdx: Int = 0
    private var currentScetion: Int = 0
    private var currentModel: VideoData = VideoData()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        collectionView.register(PlayListCell.self, forCellWithReuseIdentifier: cellIdentifier)
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
    private var lists: [ChannelRecommendData] = []
    
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
        NotificationCenter.default.addObserver(forName: Noti_NextPlay, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let m = data.userInfo?["mod"] as? VideoData {
                self.currentModel = m
                self.currentModel.isSelect = true
                self.scrollToIdx()
            }
        }
        let m = ChannelRecommendData()
        m.type = .playlist
        m.lists = PlayTool.instance.list.filter({$0.recommend == false})
        self.lists.append(m)
        let remArr = PlayTool.instance.list.filter({$0.recommend == true})
        if remArr.count > 0 {
            let reData = ChannelRecommendData()
            reData.type = .recommend
            reData.lists = remArr
            self.lists.append(reData)
        }
        self.collectionView.reloadData()
       
        self.scrollToIdx()
        if PlayTool.instance.list.last?.recommend == false, self.isHistory == false {
            self.requestUserLoop()
        }
    }
    
    func requestUserLoop() {
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
                    let arr = HubTool.share.channelList(self.recommonedList, linkId: "", uId: self.recommonedUserId, platform: self.currentModel.platform)
                    PlayTool.instance.list.append(contentsOf: arr)
                    if let data = self.lists.first(where: {$0.type == .recommend}) {
                        data.lists.append(contentsOf: arr)
                    } else {
                        let m = ChannelRecommendData()
                        m.type = .recommend
                        m.lists = arr
                        self.lists.append(m)
                    }
                    self.collectionView.reloadData()
                } else {
                    ToastTool.instance.show("request fail!", .fail)
                }
            }
        }
    }
    
    func initUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.closeBtn)
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(ScreenHeight * 0.4)
        }
        self.contentV.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
      
        self.closeBtn.addTarget(self, action: #selector(pageDismiss), for: .touchUpInside)
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
    }
    
    func scrollToIdx() {
        for (i, item) in self.lists.enumerated() {
            for (j, data) in item.lists.enumerated() {
                if (data.id == self.currentModel.id) {
                    self.currentIdx = j
                    self.currentScetion = i
                    data.isSelect = true
                    break
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIdx, section: self.currentScetion), at: .centeredVertically, animated: false)
        }
    }
    
    @objc func pageDismiss() {
        self.dismiss(animated: false)
    }
}

extension PlayListFullController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let m = self.lists.safeIndex(section) {
            return m.lists.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayListCell
        if let m = self.lists.safeIndex(indexPath.section) {
            if let data = m.lists.safeIndex(indexPath.item) {
                cell.initData(data)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (i, item) in self.lists.enumerated() {
            for (j, data) in item.lists.enumerated() {
                if data.isSelect {
                    data.isSelect = false
                    collectionView.reloadItems(at: [IndexPath(item: j, section: i)])
                }
            }
        }
        if let m = self.lists.safeIndex(indexPath.section) {
            if let data = m.lists.safeIndex(indexPath.item) {
                data.isSelect = true
                self.selectBlock?(data)
                collectionView.reloadItems(at: [indexPath])
            }
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
            
            header.subviews.forEach { v in
                v.removeFromSuperview()
            }
            // 配置 Header
            header.backgroundColor = UIColor.clear
            let label = UILabel()
            label.font = UIFont.GoogleSans(weight: .medium, size: 18)
            label.textColor = .white
            header.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.centerY.equalToSuperview()
            }
            if let m = self.lists.safeIndex(indexPath.section) {
                label.text = m.type.rawValue
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
        CGSize(width: 156, height: 86)
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
