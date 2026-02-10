//
//  ShareDayController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

enum HUB_ShareDayName: String {
    case permanent = "Permanent"
    case one = "1 Day"
    case seven = "7 Days"
    case month = "30 Days"
}

class ShareDayController: UIViewController {
    lazy var contentV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#F8FCFF")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 16)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        label.text = "Valid time"
        return label
    }()
    
    let cellIdentifier: String = "ShareDayCellIdentifier"
    lazy var collectionV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.register(ShareDayCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    let cellW: CGFloat = ScreenWidth - 52

    var listArr: [ShareDayData] = []
    
    private var name: HUB_ShareDayName = .permanent
    private var type: HUB_ShareDateType = .none

    var clickBlock:((_ name: HUB_ShareDayName, _ type: HUB_ShareDateType) -> Void)?
    
    init(name: HUB_ShareDayName, type: HUB_ShareDateType) {
        super.init(nibName: nil, bundle: nil)
        self.name = name
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        self.addData()
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.closeBtn)
        self.contentV.addSubview(self.titleL)
        self.contentV.addSubview(self.collectionV)
        
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        self.titleL.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(14)
        }
        self.collectionV.snp.makeConstraints { make in
            make.top.equalTo(self.titleL.snp.bottom).offset(12)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(248)
            make.bottom.equalTo(-6)
        }
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
    }
    
    func addData() {
        listArr.removeAll()
        listArr.append(self.addModel(name: .permanent, type: .none))
        listArr.append(self.addModel(name: .one, type: .day))
        listArr.append(self.addModel(name: .seven, type: .week))
        listArr.append(self.addModel(name: .month, type: .month))
        self.collectionV.reloadData()
    }
    
    func addModel(name: HUB_ShareDayName, type: HUB_ShareDateType) -> ShareDayData {
        let model = ShareDayData()
        model.name = name
        model.type = type
        model.isSelect = self.type == type
        return model
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}

extension ShareDayController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ShareDayCell
        if let mod = listArr.safeIndex(indexPath.item) {
            cell.initData(mod)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listArr.forEach { mod in
            mod.isSelect = false
        }
        if let mod = listArr.safeIndex(indexPath.item) {
            mod.isSelect = true
            self.clickBlock?(mod.name, mod.type)
            self.dismiss(animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
}

class ShareDayData: SuperData {
    var name: HUB_ShareDayName = .permanent
    var type: HUB_ShareDateType = .none
    var isSelect: Bool = false
}
