//
//  FileBottomView.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class FileBottomView: UIView {
    let cellIdentifier: String = "FileBottomCellIdentifier"
    let cellW: CGFloat = floor((ScreenWidth - 52) * 0.25)
    
    var listArr: [FileBottomData] = []
    
    let collectV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var clickBlock: ((_ type: HUB_FileBottomType) -> Void)?
    class func view() -> FileBottomView {
        let view = FileBottomView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.addSubview(self.collectV)
        self.backgroundColor = .clear
        self.collectV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.collectV.register(FileBottomCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.collectV.dataSource = self
        self.collectV.delegate = self
    }
    
    func setReNameState(_ able: Bool) {
        listArr.removeAll()
        listArr.append(self.addModel(type: .download, title: "Download"))
        listArr.append(self.addModel(type: .share, title: "Share"))
        listArr.append(self.addModel(type: .delete, title: "Delete"))
        listArr.append(self.addModel(type: able ? .rename: .disName, title: "Rename", able: able))
        self.collectV.reloadData()
        self.setNeedsLayout()
        self.collectV.addCornerShadow(42, CGSize(width: 3, height: -3), UIColor.rgbHex("#000000", 0.1), 3)
    }
    
    func addModel(type: HUB_FileBottomType, title: String, able: Bool = true) -> FileBottomData {
        let model = FileBottomData()
        model.imageType = type
        model.isAble = able
        model.title = title
        return model
    }
}

extension FileBottomView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FileBottomCell
        if let data = listArr.safeIndex(indexPath.item) {
            cell.initData(data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mod = listArr.safeIndex(indexPath.item) {
            self.clickBlock?(mod.imageType)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: 84)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

