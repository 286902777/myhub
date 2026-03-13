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
        return collectionView
    }()
    
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
}

extension ChannelInfoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.listArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let user = listArr.safeIndex(section) {
            return user.users.count
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
}

