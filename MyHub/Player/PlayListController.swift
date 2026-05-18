//
//  PlayListController.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit
import MJRefresh

class PlayListController: UIViewController {
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    private lazy var contentV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.rgbHex("#000000", 0.25)
        return view
    }()
    
    let cellIdentifier: String = "PlayListCellIdentifier"
    var selectBlock: ((_ model: VideoData) -> Void)?
    private var currentIdx: Int = 0
    private var currentScetion: Int = 0
    private var currentModel: VideoData = VideoData()
    private var recommendModel: VideoData?
    
    let cellW: CGFloat = floor((ScreenWidth - 64) * 0.5)
    let cellH: CGFloat = floor((ScreenWidth - 64) * 0.5 * 0.55)
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.sectionHeadersPinToVisibleBounds = true
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

    private var lists: [ChannelRecommendData] = []
    private var defaultList: [VideoData] = []
    private var isHistory: Bool = false
    init(model: VideoData, list: [VideoData], history: Bool) {
        self.currentModel = model
        self.defaultList = list
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
        m.lists = self.defaultList
        self.lists.append(m)

        self.collectionView.reloadData()
       
        self.scrollToIdx()
        if self.isHistory == false {
            self.requestUserLoop()
        }
    }
    
    func requestUserLoop() {
        let resultList = HubDB.instance.readUsers().filter({$0.platform == self.currentModel.platform})
        if resultList.count > 0 {
            let userListCount: UInt32 = UInt32(resultList.count - 1)
            if let m = resultList.safeIndex(Int(arc4random_uniform(userListCount))) {
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
                                self.addFooter()
                            }
                        } else {
                            self.recommonedUserId = m.id
                            self.addFooter()
                        }
                    } else {
                        LoadManager.instance.dismiss()
                    }
                }
            }
        }
    }
    
    func addFooter() {
        let foot = BaseRefreshFooter { [weak self] in
            guard let self = self else { return }
            self.requestRecommoned()
        }
        self.collectionView.mj_footer = foot
        self.collectionView.mj_footer?.beginRefreshing()
    }
    
    func requestRecommoned() {
        HttpManager.share.requestRecommend(self.recommonedUserId, self.recommendModel) { [weak self] status, list, errMsg, refresh in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if refresh {
                    self.requestRecommoned()
                    return
                }
                self.collectionView.mj_footer?.endRefreshing()
                var arr: [VideoData] = []
                if status == .success {
                    if list.count > 0 {
                        list.forEach { data in
                            arr.append(self.recommendToVideo(data))
                        }
                        PlayTool.instance.list.append(contentsOf: arr)
                        self.collectionView.reloadData()
                        self.recommendModel = arr.last
                        if let resultList = self.lists.first(where: {$0.type == .recommend}) {
                            resultList.lists.append(contentsOf: arr)
                        } else {
                            let m = ChannelRecommendData()
                            m.type = .recommend
                            m.lists = arr
                            self.lists.append(m)
                        }
                    } else {
                        self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else {
                    ToastTool.instance.show("request fail!", .fail)
                }
            }
        }
    }
    
    func recommendToVideo(_ model: RecommendFileData) -> VideoData {
        var result: VideoData = VideoData()
        let dbData: [VideoData] = HubDB.instance.readDatas()
        if let mod = dbData.first(where: {$0.id == model.id && $0.file_type == .video}) {
            result = mod
            result.recommend = true
        } else {
            result.id = model.id
            result.userId = self.recommonedUserId
            result.size = "\(model.file_meta.size.computeFileSize())"
            result.file_size = model.file_meta.size
            result.ext = model.file_meta.ext
            result.isNet = true
            result.recommend = true
            result.pubData = model.update_time
            result.name = model.fileName
            result.isPass = .passed
            result.thumbnail = model.file_meta.thumbnail
            result.file_type = model.file_type
            result.vid_qty = model.vid_qty
            result.platform = self.currentModel.platform
        }
        return result
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
        self.contentV.layoutIfNeeded()
        self.contentV.backgroundColor = UIColor.rgbHex("#000000", 0.2)
        self.contentV.addEffectView(self.contentV.frame.size, .light)
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

extension PlayListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: cellH)
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
                make.left.equalToSuperview()
                make.centerY.equalToSuperview().offset(indexPath.section == 0 ? 0 : 8)
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
        return CGSize(width: collectionView.frame.width, height: section != 0 ? 50 : 44)
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
