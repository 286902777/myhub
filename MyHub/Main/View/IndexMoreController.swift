//
//  IndexMoreController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexMoreController: UIViewController {
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 16)
        label.textColor = UIColor.rgbHex("#14171C")
        label.textAlignment = .center
        return label
    }()
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    let cellIdentifier: String = "IndexMoreCellIdentifier"
    lazy var collectV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.register(IndexMoreCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let cellW: CGFloat = 68
    let space: CGFloat = ceil((ScreenWidth - 4  * 68 - 68) / 3)
    var listArr: [HomeMoreData] = []
    private var model: VideoData = VideoData()
    private var type: HUB_HomeListType = .history

    var renameBlock:((_ name: String) -> Void)?

    var deleteBlock:(() -> Void)?
    
    init(model: VideoData, type: HUB_HomeListType) {
        self.model = model
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.5)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.nameL)
        self.contentView.addSubview(self.collectV)
        self.view.addSubview(self.closeBtn)
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.contentView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentView.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
    
        self.nameL.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        self.collectV.snp.makeConstraints { make in
            make.top.equalTo(self.nameL.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(108)
            make.bottom.equalTo(-20)
        }
 
        self.nameL.text = self.model.name
        addData()
    }
    
    func addData() {
        switch self.model.state {
        case .downing, .downWait:
            listArr.append(self.addModel(type: .downloading, title: "Download"))
        case .downDone:
            listArr.append(self.addModel(type: .downDone, title: "Download"))
        default:
            listArr.append(self.addModel(type: .download, title: "Download"))
        }
        listArr.append(self.addModel(type: .rename, title: "Rename"))
        listArr.append(self.addModel(type: .share, title: "Share"))
        listArr.append(self.addModel(type: .delete, title: "Delete"))
        self.collectV.reloadData()
    }
    
    func addModel(type: HUB_HomeMoreType, title: String) -> HomeMoreData {
        let model = HomeMoreData()
        model.imageType = type
        model.title = title
        return model
    }
    
    // MARK: - login
    func userIsLogin() -> Bool {
        if (LoginManager.share.isLogin == false) {
            LoginManager.share.loginRequest(self) { success in
               
            }
            return false
        } else {
            return true
        }
    }
    
    func clickItemAction(_ mod: HomeMoreData) {
        switch mod.imageType {
        case .download:
            guard self.userIsLogin() else { return }
            ToastTool.instance.show("Added to download list")
            if let m = self.listArr.first(where: {$0.imageType == .download}) {
                m.imageType = .downloading
                self.collectV.reloadData()
            }
            if let mod = HubDB.instance.readDatas().first(where: {$0.id == self.model.id}) {
//                FileUploadDownTool.instance.downLoad(mod)
//            } else {
//                FileUploadDownTool.instance.downLoad(self.model)
            }
        case .downloading:
            break
        case .downDone:
            break
        case .share:
            guard self.userIsLogin() else { return }
            let vc = ShareController(list: [self.model])
            vc.modalPresentationStyle = .overFullScreen
            vc.resultBlock = { [weak self] url in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let copyVC = ShareCopyController()
                    copyVC.modalPresentationStyle = .overFullScreen
                    copyVC.url = url
                    self.present(copyVC, animated: false)
                }
            }
            self.present(vc, animated: false)
        case .rename:
            guard self.userIsLogin() else { return }
            let vc = NewFolderController(parentId: "")
            vc.modalPresentationStyle = .overFullScreen
            vc.isFixName = true
            vc.fileId = self.model.id
            vc.fixSuccessBlock = { [weak self] name in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.model.name = name
                    HubDB.instance.updateMovieData(self.model)
                    self.renameBlock?(name)
                    self.dismiss(animated: false)
                }
            }
            self.present(vc, animated: false)
        case .delete:
            if self.type == .history {
                let vc = AlertController(title: "Delete", info: "Shall I delete the selected files?")
                vc.modalPresentationStyle = .overFullScreen
                vc.okBlock = { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        HubDB.instance.deleteData(self.model)
                        self.deleteBlock?()
                        self.dismiss(animated: false)
                    }
                }
                self.present(vc, animated: false)
            } else {
                let vc = AlertController(title: "Delete", info: "Shall I delete the selected files?")
                vc.modalPresentationStyle = .overFullScreen
                vc.okBlock = { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        HttpManager.share.deleteFileApi([self.model]) {   [weak self] status, errMsg in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                if status == .success {
                                    self.dismiss(animated: false)
                                }
                            }
                        }
                    }
                }
                self.present(vc, animated: false)
            }
        default:
            break
        }
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}

extension IndexMoreController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! IndexMoreCell
        if let mod = listArr.safeIndex(indexPath.item) {
            cell.initData(mod)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mod = listArr.safeIndex(indexPath.item) {
            self.clickItemAction(mod)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: 108)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        self.space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}
