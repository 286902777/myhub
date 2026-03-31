//
//  PayAlertController.swift
//  MyHub
//
//  Created by myhub-ios on 3/25/26.
//

import UIKit
import SnapKit

class PayAlertController: UIViewController {
    lazy var contentV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
    
    lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    lazy var bgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_alert_bg")
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_left")
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .bold, size: 20)
        label.text = "Ad-free experience."
        return label
    }()
    
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue ", for: .normal)
        btn.setImage(UIImage(named: "pre_enter"), for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        btn.backgroundColor = UIColor.rgbHex("#DDF75B")
        btn.semanticContentAttribute = .forceRightToLeft
        return btn
    }()
    
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .horizontal
        return view
    }()
    
    lazy var termsL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.text = "Terms of Service"
        label.font = UIFont.GoogleSans(size: 12)
        return label
    }()
    
    lazy var pointL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.text = "·"
        label.font = UIFont.GoogleSans(size: 12)
        return label
    }()
    
    lazy var policyL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.font = UIFont.GoogleSans(size: 12)
        label.text = "Privacy Policy"
        return label
    }()
    
    private var cellW: CGFloat = floor((ScreenWidth - 62) * 0.5)
    private var list: [PayData] = []
    private var isPlay: Bool = false
    private let contentW: CGFloat = ScreenWidth - 28
    init(play: Bool) {
        self.isPlay = play
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        HubTool.share.preSource = .vip_Ad
        HubTool.share.preMethod = .vip_auto
        TbaManager.instance.addEvent(type: .custom, event: .premiumVipExpose, paramter: [EventParaName.vip_popup.rawValue: true, EventParaName.vip_auto.rawValue: true, EventParaName.source.rawValue: HUB_PremiumSource.vip_Ad.rawValue])
        NotificationCenter.default.addObserver(forName: Noti_UserVip, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if PayManager.instance.isVip {
                self.dismiss(animated: false)
            }
        }
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentV)
        self.contentV.addSubview(self.closeBtn)
        self.contentV.addSubview(self.mainV)
        self.contentV.addSubview(self.iconV)
        self.mainV.addSubview(self.bgView)
        self.mainV.addSubview(self.titleL)
        self.mainV.addSubview(self.collectionV)
        self.mainV.addSubview(self.nextBtn)
        self.mainV.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.termsL)
        self.stackV.addArrangedSubview(self.pointL)
        self.stackV.addArrangedSubview(self.policyL)
        if self.isPlay {
            self.contentV.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(contentW)
            }
        } else {
            self.contentV.snp.makeConstraints { make in
                make.left.equalTo(14)
                make.right.equalTo(-14)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        self.mainV.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.closeBtn.snp.bottom).offset(14)
        }
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(self.mainV.snp.top).offset(-36)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        self.bgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        self.titleL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(51)
        }
        self.collectionV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.equalTo(self.titleL.snp.bottom).offset(16)
            make.height.equalTo(118)
        }
        self.nextBtn.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.equalTo(self.collectionV.snp.bottom).offset(16)
            make.height.equalTo(44)
        }
        
        self.stackV.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(self.nextBtn.snp.bottom).offset(16)
            make.height.equalTo(32)
        }
        let tTap = UITapGestureRecognizer(target: self, action: #selector(clickTermsAction))
        self.termsL.isUserInteractionEnabled = true
        self.termsL.addGestureRecognizer(tTap)
        let pTap = UITapGestureRecognizer(target: self, action: #selector(clickPolicyAction))
        self.policyL.isUserInteractionEnabled = true
        self.policyL.addGestureRecognizer(pTap)
        self.nextBtn.addTarget(self, action: #selector(clickNextAction), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.setData()
    }
 
    func setData() {
        self.list.removeAll()
        if let m = PayManager.instance.productDatas.first(where: {$0.name == PayType.lifetime.rawValue}) {
            self.list.append(m)
        }
        if let m = PayManager.instance.productDatas.first(where: {$0.name == PayType.weekly.rawValue}) {
            self.list.append(m)
        }
        self.list.forEach { data in
            data.isSelect = false
            if data.product_id == PayManager.instance.defaultProduct.rawValue {
                data.isSelect = true
            }
        }
        if self.list.count == 2 {
            if self.list.first?.isSelect == false, self.list.last?.isSelect == false {
                self.list.first?.isSelect = true
            }
        }
        self.collectionV.reloadData()
    }
    
    @objc func clickTermsAction() {
        let vc = HtmlController()
        vc.linkType = .privacy
        vc.name = "Privacy Policy"
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }

    @objc func clickPolicyAction() {
        let vc = HtmlController()
        vc.linkType = .terms
        vc.name = "Terms of Service"
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @objc func clickNextAction() {
        if let data = self.list.first(where: {$0.isSelect == true}) {
            TbaManager.instance.addEvent(type: .custom, event: .premiumVipClick, paramter: [EventParaName.value.rawValue: data.name, EventParaName.vip_popup.rawValue: true, EventParaName.vip_auto.rawValue: true, EventParaName.source.rawValue: HUB_PremiumSource.vip_Ad.rawValue])
            PayManager.instance.pay(data: data, type: .pay, isPop: true)
        }
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}

extension PayAlertController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellW, height: 118)
    }
}
