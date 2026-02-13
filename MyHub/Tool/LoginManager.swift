//
//  LoginManager.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit

class LoginManager {
    static let share = LoginManager()
    
    var successBlock: (() -> Void)?
    
    var userName: String {
        get { UserDefaults.standard.string(forKey: HUB_UserName) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserName) }
    }
    var userId: String {
        get { UserDefaults.standard.string(forKey: HUB_UserId) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserId) }
    }
    var userUserId: String {
        get { UserDefaults.standard.string(forKey: HUB_UserUserId) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserUserId) }
    }
    var userAvtar: String {
        get { UserDefaults.standard.string(forKey: HUB_UserAvtar) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserAvtar) }
    }
    var userEmail: String {
        get { UserDefaults.standard.string(forKey: HUB_UserEmail) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserEmail) }
    }
    
    var userAppId: String {
        get { UserDefaults.standard.string(forKey: HUB_UserToken) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserToken) }
    }
    var userToken: String {
        get { UserDefaults.standard.string(forKey: HUB_UserToken) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserToken) }
    }
//    var isLogin: Bool = true
    var isLogin: Bool {
        get { UserDefaults.standard.bool(forKey: HUB_UserIsLogin) }
        set { UserDefaults.standard.set(newValue, forKey: HUB_UserIsLogin) }
    }
    
    func loginRequest(_ topVC: UIViewController, _ completion: @escaping (Bool) -> Void) {
        let vc = LoginController()
        vc.modalPresentationStyle = .overFullScreen
        vc.loginSuccessBlock = {
            completion(true)
        }
        topVC.present(vc, animated: false)
    }
}

