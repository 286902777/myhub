//
//  DeepRecentlyController.swift
//  MyHub
//
//  Created by Ever on 2026/3/5.
//

import UIKit
import SnapKit

class DeepRecentlyController: UIViewController {
    let cellIdentifier: String = "DeepHotCellIdentifier"

    var clickBlock: ((_ data: ChannelData) -> Void)?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        collectionView.register(DeepHotCell.self, forCellWithReuseIdentifier: cellIdentifier)
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
    
    private var lists: [ChannelData] = []
    private var linkId: String = ""
    private var uId: String = ""
    private var name: String = ""
    private var platform: HUB_PlatformType = .cash
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setDatas(lists: [ChannelData], linkId: String, uId: String, name: String, platform: HUB_PlatformType) {
        self.lists = lists
        self.linkId = linkId
        self.uId = uId
        self.name = name
        self.platform = platform
        self.collectionView.reloadData()
    }
    
    func pushDataVC(_ mod: ChannelData) {
        if self.linkId.count > 0 {
            HubTool.share.playSource = .landpage_recently
        } else {
            HubTool.share.playSource = .channel_recently
        }
        HubTool.share.uploadPlatform = self.platform
        self.clickBlock?(mod)
//        switch mod.file_type {
//        case .video:
//            PlayTool.instance.pushPage(self, HubTool.share.channelModel(mod, linkId: self.linkId, uId: self.uId, platform: self.platform), HubTool.share.channelList(self.lists, linkId: self.linkId, uId: self.uId, platform: self.platform))
//        case .folder:
//            let vc = OtherFolderListController(model: HubTool.share.channelModel(mod, linkId: self.linkId, uId: self.uId, platform: self.platform), linkId: self.linkId, userId: self.uId, userName: self.name, platform: self.platform, channel: self.linkId.count == 0)
//            self.navigationController?.pushViewController(vc, animated: true)
//        case .photo:
//            let vc = OpenPhotoController(model: HubTool.share.channelModel(mod, linkId: self.linkId, uId: self.uId, platform: self.platform))
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}

extension DeepRecentlyController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DeepHotCell
        if let m = self.lists.safeIndex(indexPath.item) {
            cell.initData(m, false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = self.lists.safeIndex(indexPath.item) {
            self.pushDataVC(data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 192, height: 126)
    }
}
