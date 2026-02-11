//
//  SaveController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class SaveController: UIViewController {

    let cellW: CGFloat = floor(ScreenWidth - 36) * 0.5

    let cellIdentifier: String = "SaveCellIdentifier"

    let noContentV: EmptyView = EmptyView.view()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.register(SaveCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var list: [VideoData] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addData()
        TabbarTool.instance.displayOrHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabbarTool.instance.displayOrHidden(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.noContentV)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.noContentV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.noContentV.upBtn.isHidden = true
        self.noContentV.infoL.text = "You have not saved any content yet!"
    }
    
    func addData() {
        self.list = HubDB.instance.readDatas().filter({$0.isShare == true})
        self.collectionView.reloadData()
        if self.list.count == 0 {
            self.noContentV.isHidden = false
            self.collectionView.isHidden = true
        } else {
            self.noContentV.isHidden = true
            self.collectionView.isHidden = false
        }
    }
}

extension SaveController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        list.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SaveCell
        if let data = self.list.safeIndex(indexPath.item) {
            cell.initData(data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let m = self.list.safeIndex(indexPath.item) {
//            let vc = DeepController(linkId: m.linkId)
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: 156)
    }
}
