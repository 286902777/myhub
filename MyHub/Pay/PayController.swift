//
//  PayController.swift
//  MyHub
//
//  Created by myhub-ios on 3/27/26.
//

import UIKit
import SnapKit

class PayController: UIViewController {
    lazy var stroeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Restore", for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 12)
        btn.setTitleColor(UIColor.rgbHex("#181818"), for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.rgbHex("#181818", 0.5).cgColor
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var bgImgV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "pre_bg")
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "pre")
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var navbar: NaviBar = {
        let view = NaviBar.xibView()
        return view
    }()
    
    let bottomV: PayVipBottomV = PayVipBottomV.view()

    let infoCellIdentifier: String = "PayInfoListCellID"
    let textCellIdentifier = "PayTextCellID"
    let benefitsCellIdentifier = "PayBenefitsCellID"
    let deadCellIdentifier = "PayDeadCellID"
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.register(PayInfoListCell.self, forCellReuseIdentifier: infoCellIdentifier)
        table.register(PayTextCell.self, forCellReuseIdentifier: textCellIdentifier)
        table.register(PayBenefitsCell.self, forCellReuseIdentifier: benefitsCellIdentifier)
        table.register(PayDeadCell.self, forCellReuseIdentifier: deadCellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()

    private var currentData: PayData = PayData() {
        didSet {
            self.bottomV.setData(currentData)
        }
    }
    
    private var list: [PayTableData] = []
    private var productList: [PayData] = []
    
    var returnBlock: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.refreshUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.bgImgV)
        self.bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.addSubview(self.navbar)
        self.navbar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(NavBarH)
        }
        self.navbar.clickBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.navbar.bgView.addSubview(self.stroeBtn)
        self.stroeBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.size.equalTo(CGSize(width: 68, height: 28))
            make.centerY.equalToSuperview()
        }
        self.stroeBtn.addTarget(self, action: #selector(clickStoreAction), for: .touchUpInside)
        
        self.view.addSubview(self.iconV)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom).offset(8)
            make.right.equalTo(-24)
            make.size.equalTo(CGSize(width: 84, height: 84))
        }
        
        self.view.addSubview(self.titleL)
        self.titleL.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconV)
            make.left.equalTo(14)
            make.right.equalTo(self.iconV.snp.left).offset(14)
        }
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.tableView)
        self.view.addSubview(self.bottomV)
        self.bottomV.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        self.contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.iconV.snp.bottom).offset(16)
            make.bottom.equalTo(self.bottomV.snp.top)
        }
        self.tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(12)
        }
        self.contentView.setNeedsLayout()
        self.contentView.addRedius([.topLeft, .topRight], 24)
        
        self.bottomV.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch idx {
                case 0:
                    self.clickTermsAction()
                case 1:
                    self.clickPolicyAction()
                default:
                    self.clickNextAction()
                }
            }
        }
        
        TbaManager.instance.addEvent(type: .custom, event: .premiumVipExpose, paramter: [EventParaName.vip_popup.rawValue: false, EventParaName.vip_auto.rawValue: HubTool.share.preMethod == .vip_auto, EventParaName.source.rawValue: HubTool.share.preSource.rawValue])

        self.productList = PayManager.instance.productDatas
        self.productList.forEach { data in
            data.isSelect = false
            if data.product_id == PayManager.instance.defaultProduct.rawValue {
                data.isSelect = true
            }
        }
        
        if let data = self.productList.first(where: {$0.isSelect == true}) {
            self.currentData = data
        }
        
        NotificationCenter.default.addObserver(forName: Noti_UserVip, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            self.refreshUI()
        }
    }
    
    func refreshUI() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.alignment = .left
        self.titleL.attributedText = NSAttributedString(string: PayManager.instance.isVip ? "Congrats! " : "Ad-free experience", attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(weight: .bold, size: 36), .foregroundColor: UIColor.rgbHex("#14171C")])
        self.list.removeAll()
        if PayManager.instance.isVip {
            let noneData = PayTableData()
            noneData.info = "As a new member, you can take advantage of all premium perks."
            self.list.append(noneData)
            let benefits = PayTableData()
            benefits.type = .benefits
            benefits.benefits = [PayBenefitsData(imageType: .ad), PayBenefitsData(imageType: .down), PayBenefitsData(imageType: .video)]
            self.list.append(benefits)
            let deadData = PayTableData()
            deadData.type = .deadline
            let name = UserDefaults.standard.string(forKey: PayName) ?? ""
            let fu = UserDefaults.standard.string(forKey: PayDisplayF) ?? ""
            var disText: String = ""
            switch PayType(rawValue: name) {
            case .weekly:
                disText = "Auto-renews weekly at \(fu). Cancel any time."
            case .yearly:
                disText = "\(fu) per year, auto-renewal. Cancel at any time."
            default:
                disText = "Lifetime access with a one-time purchase, no need for renewal."
            }
            deadData.info = disText
            self.list.append(deadData)
        } else {
            let planData = PayTableData()
            planData.type = .plans
            planData.plans = self.productList
            self.list.append(planData)
            let benefits = PayTableData()
            benefits.type = .benefits
            benefits.benefits = [PayBenefitsData(imageType: .ad), PayBenefitsData(imageType: .down), PayBenefitsData(imageType: .video)]
            self.list.append(benefits)
            let renewalData = PayTableData()
            renewalData.type = .renewal
            renewalData.info = "Automatic renewal of the subscription will persist until canceled, as detailed in the terms. Cancellation can be initiated at any time. To avoid incurring additional fees, please cancel at least 24 hours prior to the renewal. Note that no refunds will be provided if the subscription period has not expired."
            self.list.append(renewalData)
        }
        
        self.tableView.reloadData()
    }
    
    @objc func clickStoreAction() {
        PayManager.instance.clickReStore()
    }
    
    func clickTermsAction() {
        let vc = HtmlController()
        vc.linkType = .privacy
        vc.name = "Privacy Policy"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func clickPolicyAction() {
        let vc = HtmlController()
        vc.linkType = .terms
        vc.name = "Terms of Service"
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickNextAction() {
        TbaManager.instance.addEvent(type: .custom, event: .premiumVipClick, paramter: [EventParaName.value.rawValue: self.currentData.name, EventParaName.vip_popup.rawValue: false, EventParaName.vip_auto.rawValue: HubTool.share.preMethod == .vip_auto, EventParaName.source.rawValue: HubTool.share.preSource.rawValue])
        PayManager.instance.pay(data: self.currentData, type: .pay, isPop: false)
    }
}

extension PayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! PayTextCell
        if let data = self.list.safeIndex(indexPath.section) {
            switch data.type {
            case .plans:
                let infoCell = tableView.dequeueReusableCell(withIdentifier: infoCellIdentifier) as! PayInfoListCell
                infoCell.setData(data.plans)
                infoCell.clickItemBlock = { [weak self] mod in
                    guard let self = self else { return }
                    self.currentData = mod
                }
                return infoCell
            case .benefits:
                let beneCell = tableView.dequeueReusableCell(withIdentifier: benefitsCellIdentifier) as! PayBenefitsCell
                if let mod = data.benefits.safeIndex(indexPath.row) {
                    beneCell.initData(mod)
                }
                return beneCell
            case .deadline:
                let deadCell = tableView.dequeueReusableCell(withIdentifier: deadCellIdentifier) as! PayDeadCell
                deadCell.initData(data)
                return deadCell
            default:
                textCell.initData(data)
            }
        }
        return textCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.list.safeIndex(section) {
            switch data.type {
            case .benefits:
                return data.benefits.count
            default:
                return 1
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let data = self.list.safeIndex(section) {
            switch data.type {
            case .none, .renewal:
                return 0.01
            default:
                return 34
            }
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 34))
        view.backgroundColor = .white
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.75)
        label.font = UIFont.GoogleSans(size: 14)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalToSuperview()
        }
        if let data = self.list.safeIndex(section) {
            switch data.type {
            case .benefits, .plans, .deadline:
                label.text = data.type.rawValue
                return view
            default:
                return nil
            }
        }
        return nil
    }
}

enum PayTableType: String {
    case plans = "Premium plans"
    case benefits = "Benefits"
    case deadline = "Deadline"
    case none = "none"
    case renewal = "renewal"
}

class PayTableData: SuperData {
    var type: PayTableType = .none
    var info: String = ""
    var plans: [PayData] = []
    var benefits: [PayBenefitsData] = []
}
