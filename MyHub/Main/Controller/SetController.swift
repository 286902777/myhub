//
//  SetController.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import SnapKit

class SetController: SuperController {
    lazy var logoutBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "out"), for: .normal)
        return btn
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "")
        view.backgroundColor = .red
        view.layer.cornerRadius = 34
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.GoogleSans(weight: .semibold, size: 22)
        label.text = ""
        return label
    }()
    
    lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var gradV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var cirV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "cir")
        return view
    }()
    
    lazy var cirRightV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var bottomV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        return view
    }()
    
    private var list: [SetData] = []
    private var size: String = ""

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabbarTool.instance.displayOrHidden(true)
        HubTool.share.getCacheSize({ [weak self] size in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setItemView(size)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        self.view.backgroundColor = UIColor.rgbHex("#14171C")
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.logoutBtn)
        self.logoutBtn.snp.makeConstraints { make in
            make.right.equalTo(-2)
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerY.equalToSuperview()
        }
        self.logoutBtn.addTarget(self, action: #selector(clickLogoutAction), for: .touchUpInside)
        self.view.addSubview(self.iconV)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom).offset(36)
            make.left.equalTo(20)
            make.size.equalTo(CGSize(width: 68, height: 68))
        }
        self.view.addSubview(self.nameL)
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(self.iconV)
        }
        
        self.view.addSubview(self.cirV)
        self.cirV.snp.makeConstraints { make in
            make.top.equalTo(self.iconV.snp.bottom).offset(-10)
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 108, height: 20))
        }
        let cView: UIView = UIView()
        cView.backgroundColor = UIColor.rgbHex("#FAFAFA")
        self.view.addSubview(cView)
        cView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.cirV.snp.bottom)
            make.size.equalTo(CGSize(width: 108, height: 40))
            
        }
        self.view.addSubview(self.cirRightV)
        self.cirRightV.snp.makeConstraints { make in
            make.top.equalTo(self.cirV.snp.top).offset(6)
            make.right.equalToSuperview()
            make.left.equalTo(self.cirV.snp.right).offset(-30)
            make.height.equalTo(40)
        }
        
        self.view.addSubview(self.bottomV)
        self.bottomV.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(self.iconV.snp.bottom).offset(16)
        }
        
        self.bottomV.addSubview(self.mainV)
        self.mainV.snp.makeConstraints { make in
            make.top.equalTo(2)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(316)
        }
        
        self.mainV.addSubview(self.gradV)
        self.gradV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
    
    func setItemView(_ size: String) {
        self.nameL.text = LoginManager.share.userName
        self.list.removeAll()
        let policy: SetData = SetData()
        policy.idx = 0
        policy.imageName = "privacy"
        policy.name = "Privacy\nPolicy"
        self.list.append(policy)
        let terms: SetData = SetData()
        terms.idx = 1
        terms.imageName = "service"
        terms.name = "Terms of\nService"
        self.list.append(terms)
        let feed: SetData = SetData()
        feed.idx = 2
        feed.imageName = "feedback"
        feed.name = "Feedback"
        self.list.append(feed)
        let ver: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let about: SetData = SetData()
        about.idx = 3
        about.imageName = "about"
        about.name = "About"
        about.info = ver
        about.hasInfo = true
        self.list.append(about)
        let cache: SetData = SetData()
        cache.idx = 4
        cache.imageName = "clear"
        cache.name = "Clear cache"
        cache.info = size
        cache.hasInfo = true
        self.list.append(cache)
        let del: SetData = SetData()
        del.idx = 5
        del.imageName = "delete"
        del.name = "Delete\naccount"
        self.list.append(del)
        self.list.forEach { m in
            let v = self.createItem(m)
            self.gradV.addSubview(v)
            v.snp.makeConstraints { make in
                if m.idx % 2 == 0 {
                    make.left.equalToSuperview()
                } else {
                    make.right.equalToSuperview()
                }
                make.size.equalTo(CGSize(width: (ScreenWidth - 44) * 0.5, height: 100))
                make.top.equalTo(m.idx / 2 * 100)
            }
        }
        let topLineV: UIView = UIView()
        topLineV.backgroundColor = UIColor.rgbHex("#EDEDED", 0.75)
        let botLineV: UIView = UIView()
        botLineV.backgroundColor = UIColor.rgbHex("#EDEDED", 0.75)
        let midLineV: UIView = UIView()
        midLineV.backgroundColor = UIColor.rgbHex("#EDEDED", 0.75)
        self.gradV.addSubview(topLineV)
        self.gradV.addSubview(botLineV)
        self.gradV.addSubview(midLineV)
        topLineV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(100)
            make.height.equalTo(1)
        }
        botLineV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(200)
            make.height.equalTo(1)
        }
        midLineV.snp.makeConstraints { make in
            make.top.centerX.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
    }
    
    func createItem(_ data: SetData) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.tag = data.idx
        let imgV: UIImageView = UIImageView()
        imgV.image = UIImage(named: data.imageName)
        view.addSubview(imgV)
        imgV.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        let nameL: UILabel = UILabel()
        nameL.textColor = UIColor.rgbHex("#454545")
        nameL.font = UIFont.GoogleSans(weight: .medium, size: 14)
        nameL.textAlignment = .center
        nameL.numberOfLines = 2
        view.addSubview(nameL)
        nameL.snp.makeConstraints { make in
            make.top.equalTo(imgV.snp.bottom).offset(data.idx == 2 ? 17 :8)
            make.left.right.equalToSuperview()
        }
        
        if data.hasInfo {
            let infoL: UILabel = UILabel()
            infoL.textColor = UIColor.rgbHex("#808080")
            infoL.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            infoL.textAlignment = .center
            view.addSubview(infoL)
            infoL.snp.makeConstraints { make in
                make.top.equalTo(nameL.snp.bottom).offset(2)
                make.left.right.equalToSuperview()
            }
            infoL.text = data.info
        }
        nameL.text = data.name
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickItemAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }
    
    @objc func clickItemAction(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            let vc = HtmlController()
            vc.linkType = .privacy
            vc.name = "Privacy Policy"
            vc.hidesBottomBarWhenPushed = true
            TabbarTool.instance.displayOrHidden(false)
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = HtmlController()
            vc.linkType = .terms
            vc.name = "Terms of Service"
            vc.hidesBottomBarWhenPushed = true
            TabbarTool.instance.displayOrHidden(false)
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            self.openEmail()
        case 4:
            if (self.size != "0MB") {
                let vc = AlertController(title: "Clear cache", info: "Do you want to clear cache?")
                vc.modalPresentationStyle = .overFullScreen
                vc.okBlock = { [weak self] in
                    guard let self = self else { return }
                    HubTool.share.clearCache()
                    DispatchQueue.main.async {
                        self.setItemView("0MB")
                    }
                }
                self.present(vc, animated: false)
            }
        case 5:
            let vc = AccountController()
            vc.hidesBottomBarWhenPushed = true
            TabbarTool.instance.displayOrHidden(false)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    @objc func clickLogoutAction() {
        let vc = AlertController(title: "Confirm Exit?", info: " Exiting ends the current content. You will need to re-verify your identity next time.")
        vc.modalPresentationStyle = .overFullScreen
        vc.okBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.exitLogin()
            }
        }
        self.present(vc, animated: false)
    }
    
    func openEmail() {
        let email = "sd@outlook.com"
        let subject = ""
        let body = ""
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            // 检查是否可以打开URL
            if UIApplication.shared.canOpenURL(url) {
                // 打开邮箱
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // 无法打开邮箱应用
                print("无法打开邮箱应用")
            }
        }
    }
    
    func clearDataBase() {
        let list = HubDB.instance.readDatas()
        list.forEach { m in
            if (m.state == .uploading) {
                FileUploadTool.instance.cancelRequest()
            }
            if m.state == .uploading || m.state == .uploadWait {
                m.state = .uploadFaid
                HubDB.instance.updateMovieData(m)
            }
            if m.state == .downing || m.state == .downWait {
                m.state = .downFail
                HubDB.instance.updateMovieData(m)
            }
        }
    }
    
    func exitLogin() {
        clearDataBase()
        LoginManager.share.isLogin = false
        LoginManager.share.userId = ""
        LoginManager.share.userUserId = ""
        LoginManager.share.userName = ""
        LoginManager.share.userEmail = ""
        LoginManager.share.userAppId = ""
        LoginManager.share.userAvtar = ""
        LoginManager.share.userToken = ""
        HubDB.instance.config()
        NotificationCenter.default.post(name: Noti_Logout, object: nil, userInfo: nil)
        ToastTool.instance.show("Logout successed!")
//        self.tabBarController?.selectedIndex = 0
    }
}

class SetData: SuperData {
    var idx: Int = 0
    var imageName: String = ""
    var name: String = ""
    var info: String = ""
    var hasInfo: Bool = false
}
