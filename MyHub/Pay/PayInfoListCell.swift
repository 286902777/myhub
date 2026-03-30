//
//  PayInfoListCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/27/26.
//

import UIKit
import SnapKit

class PayInfoListCell: UITableViewCell {
    let cellIdentifier: String = "PayInfoCellIdentifier"
    lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.register(PayInfoCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var clickItemBlock: ((_ data: PayData) -> Void)?
    private var list: [PayData] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() { //136
        self.addSubview(self.collectionV)
        self.collectionV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(4)
            make.height.equalTo(120)
            make.bottom.equalTo(-14)
        }
    }
    
    func setData(_ arr: [PayData]) {
        self.list = arr
        self.collectionV.reloadData()
    }
}

extension PayInfoListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PayInfoCell
        if let data = self.list.safeIndex(indexPath.item) {
            cell.initData(data)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.list.forEach { m in
            m.isSelect = false
        }
        if let data = self.list.safeIndex(indexPath.item) {
            data.isSelect = true
            collectionView.reloadData()
            self.clickItemBlock?(data)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 116, height: 120)
    }
}
