//
//  ChannelInfoController.swift
//  MyHub
//
//  Created by myhub-ios on 3/13/26.
//

import UIKit
import SnapKit

class ChannelInfoController: SuperController {
    let cellIdentifier: String = "ChannelCellIdentifier"
    lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.register(ChannelCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: BottomSafeH, right: 14)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView")
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "FooterView")
        return collectionView
    }()
    
    private var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "channel_open"), for: .normal)
        btn.backgroundColor = UIColor.rgbHex("#FAFAFA")
        btn.layer.cornerRadius = 13
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private var isShow: Bool = false {
        didSet {
            self.moreBtn.setImage(UIImage(named: isShow ? "channel_close" : "channel_open"), for: .normal)
        }
    }
    let cellW: CGFloat = floor((ScreenWidth - 44) / 3)
    let cellH: CGFloat = floor((ScreenWidth - 44) / 3) + 30
    
    var listArr: [UserInfoListData] = []
    var model: ChannelUserData = ChannelUserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
        HubTool.share.eventSource = .channelpage
        TbaManager.instance.addEvent(type: .custom, event: .channellistExpose, paramter: nil)
        self.moreBtn.addTarget(self, action: #selector(clickShowAction), for: .touchUpInside)
    }
    
    func setUI() {
        self.navbar.nameL.text = "Channel"
        self.view.addSubview(self.collectionV)
        self.collectionV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navbar.snp.bottom)
        }
    }
    
    func loadData() {
        let list = HubDB.instance.readUsers()
        let mod = UserInfoListData()
        mod.type = .followed
        mod.users = list
        self.listArr.append(mod)
        self.requestData()
    }
    
    func requestData() {
        LoadManager.instance.show(self)
        HttpManager.share.channelUserList(self.model.id, self.model.platform) { [weak self] status, list, errMsg, refresh in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if refresh {
                    self.requestData()
                }
                if status == .success, list.count > 0 {
                    let mod = UserInfoListData()
                    mod.type = .recommend
                    mod.users = list
                    self.listArr.append(mod)
                    self.collectionV.reloadData()
                }
            }
        }
    }
    
    @objc func clickShowAction() {
        self.isShow = !self.isShow
        self.collectionV.reloadData()
    }
}

extension ChannelInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.listArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let user = listArr.safeIndex(section) {
            if section == 0 {
                if user.users.count > 6 {
                    if self.isShow {
                        return user.users.count
                    } else {
                        return 6
                    }
                } else {
                    return user.users.count
                }
            } else {
                return user.users.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ChannelCell
        if let m = listArr.safeIndex(indexPath.section), let data = m.users.safeIndex(indexPath.item) {
            cell.initData(data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let user = self.listArr.safeIndex(indexPath.section), let data = user.users.safeIndex(indexPath.item) {
            HubTool.share.channelSource = .channelList
            HubTool.share.platform = data.platform
            HubTool.share.currentPlatform = data.platform
            let vc = PingController(uId: data.id, platform: data.platform)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: cellH)
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
        if indexPath.section == 0 {
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "FooterView",
                    for: indexPath
                )
                footer.subviews.forEach { v in
                    v.removeFromSuperview()
                }
                // 配置 Header
                footer.backgroundColor = UIColor.clear
                guard let m = self.listArr.safeIndex(indexPath.section), m.users.count > 6 else {
                    return UICollectionReusableView()
                }
                if let _ = footer.viewWithTag(indexPath.section) as? UIButton {
                    
                } else {
                    footer.addSubview(self.moreBtn)
                    self.moreBtn.tag = indexPath.section
                    self.moreBtn.snp.makeConstraints { make in
                        make.top.equalTo(4)
                        make.centerX.equalToSuperview()
                        make.size.equalTo(CGSize(width: 120, height: 24))
                    }
                }
                return footer
            }
        } else {
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "HeaderView",
                    for: indexPath
                )
                header.subviews.forEach { v in
                    v.removeFromSuperview()
                }
                header.backgroundColor = UIColor.clear
                if let _ = header.viewWithTag(indexPath.section) as? UILabel {
                    
                } else {
                    let label = UILabel()
                    label.text = "Recommend"
                    label.font = UIFont.GoogleSans(size: 16)
                    label.textColor = UIColor.rgbHex("#434343")
                    header.addSubview(label)
                    label.snp.makeConstraints { make in
                        make.left.centerY.equalToSuperview()
                    }
                }
                return header
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section > 0 {
            return CGSize(width: collectionView.frame.width, height: 32)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard section == 0, let m = self.listArr.safeIndex(section), m.users.count > 6 else {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

