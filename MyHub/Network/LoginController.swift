//
//  LoginController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import AuthenticationServices

enum HUB_loginSource: String {
//    cloudtab、metab、upload、download、transfer
    case file = "a"
    case set = "b"
    case upload = "c"
    case transfer = "d"
}

class LoginController: UIViewController {

    @IBOutlet weak var PolicyL: UILabel!
    
    @IBOutlet weak var TermsL: UILabel!
    
    @IBOutlet weak var loginV: UIView!
    
    @IBOutlet weak var loginL: UILabel!
    
    @IBOutlet weak var hoL: UILabel!
    
    
    var loginSuccessBlock: (() -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
//        EventTool.instance.addEvent(type: .custom, event: .loginPageExpose, paramter: [EventParaName.value.rawValue: ESBaseTool.instance.loginSource.rawValue])
    }
    
    func setUI() {
        self.PolicyL.attributedText = NSAttributedString(string: "Privacy Policy", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.rgbHex("#000000", 0.5), .font: UIFont.systemFont(ofSize: 10, weight: .medium)])
        
        self.TermsL.attributedText = NSAttributedString(string: "Terms of Service", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.rgbHex("#000000", 0.5), .font: UIFont.systemFont(ofSize: 10, weight: .medium)])
        let pTap = UITapGestureRecognizer(target: self, action: #selector(clickPrivacy))
        self.PolicyL.isUserInteractionEnabled = true
        self.PolicyL.addGestureRecognizer(pTap)
        
        let sTap = UITapGestureRecognizer(target: self, action: #selector(clickTerms))
        self.TermsL.isUserInteractionEnabled = true
        self.TermsL.addGestureRecognizer(sTap)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        self.hoL.attributedText = NSAttributedString(string: "Hi,\nwelcome to\nMyhub", attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(weight: .bold, size: 32), .foregroundColor: UIColor.white])
        self.loginL.font = UIFont.GoogleSans(weight: .medium, size: 16)
        self.loginV.layer.cornerRadius = 30
        
        self.loginV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickLoginAction))
        self.loginV.addGestureRecognizer(tap)

    }

    @objc func clickPrivacy() {
        let vc = HtmlController()
        vc.linkType = .privacy
        vc.name = "Privacy Policy"
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @objc func clickTerms() {
        let vc = HtmlController()
        vc.linkType = .terms
        vc.name = "Terms of Service"
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }

    @objc func clickLoginAction() {
//        EventTool.instance.addEvent(type: .custom, event: .loginClick, paramter: [EventParaName.value.rawValue: "apple"])

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]  // 请求用户信息范围
        
        let authorController = ASAuthorizationController(authorizationRequests: [request])
        authorController.delegate = self
        authorController.presentationContextProvider = self
        authorController.performRequests()
    }
    
    func requestServer(_ token: String) {
        LoadManager.instance.show(self)
        HttpManager.share.loginApi(token) {[weak self] status, model, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if status == .success {
//                    EventTool.instance.addEvent(type: .custom, event: .loginSuc, paramter: [EventParaName.value.rawValue: "apple"])
                    LoginManager.share.userId = model.user.id
                    LoginManager.share.userUserId = model.user.user_id
                    LoginManager.share.userName = model.user.username
                    LoginManager.share.userEmail = model.user.email
                    LoginManager.share.userAppId = model.user.app_id
                    LoginManager.share.userAvtar = model.user.avtar_url
                    LoginManager.share.userToken = model.token
                    LoginManager.share.isLogin = true
                    NotificationCenter.default.post(name: Noti_Login, object: nil, userInfo: nil)
                    self.dismiss(animated: false) {
                        self.loginSuccessBlock?()
                    }
                } else {
//                    EventTool.instance.addEvent(type: .custom, event: .loginFail, paramter: [EventParaName.value.rawValue: "apple", EventParaName.reason.rawValue: errMsg ?? "request fail!"])
                    LoginManager.share.userId = ""
                    LoginManager.share.userUserId = ""
                    LoginManager.share.userName = ""
                    LoginManager.share.userEmail = ""
                    LoginManager.share.userAppId = ""
                    LoginManager.share.userAvtar = ""
                    LoginManager.share.userToken = ""
                    if let e = errMsg {
                        ToastTool.instance.show(e, .fail)
                    }
                }
                HubDB.instance.config()
            }
        }
    }
    
    @IBAction func clickCloseAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}

extension LoginController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let userID = appleIDCredential.user       // 用户唯一标识（永久不变）
//            let email = appleIDCredential.email      // 邮箱（可能为空或代理邮箱）
//            let fullName = appleIDCredential.fullName // 全名（首次授权有效）
            if let token = String(data: credential.identityToken!, encoding: .utf8) {
                requestServer(token)            // 发送数据到服务器验证
            }
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let authError = error as? ASAuthorizationError
        switch authError?.code {
        case .invalidResponse: print("Invalid")
        case .canceled: print("cancel")
        default:
            let msg: String = String(describing: authError?.localizedDescription)
//            EventTool.instance.addEvent(type: .custom, event: .loginFail, paramter: [EventParaName.value.rawValue: "apple", EventParaName.reason.rawValue:             msg.count == 0 ? "request fail!" : msg])
            print("fail: \(String(describing: authError?.localizedDescription))")
        }
    }
}

extension LoginController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // iOS 13+ 需指定窗口
    }
}

