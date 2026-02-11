//
//  SceneDelegate.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var noFirst: Bool = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let w = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: w)
        self.window?.rootViewController = StartController()
        self.window?.makeKeyAndVisible()
        if let userActivity = connectionOptions.userActivities.first {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        } else if let url = connectionOptions.urlContexts.first?.url {
            AppsFlyerLib.shared().handleOpen(url, options: nil)
        }
        self.configAppFlyer()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
//        PremiumTool.instance.requestProductInfo(type: .refresh)
//        PremiumTool.instance.requestServiceReceiptData(product: nil, type: .refresh)
//        if isOpen == false {
//            EventTool.instance.addEvent(type: .session, event: .session, paramter: nil)
//            isOpen = true
//            return
//        }
//        if let vc = ESBaseTool.instance.keyVC(), vc.isKind(of: AdmobController.self) {
//            return
//        }
//        guard ESBaseTool.instance.showAdomb == false else { return }
//        guard ESBaseTool.instance.toPay == false else { return }
//
//        if isOpen {
//            ESBaseTool.instance.adsPlayState = .openHot
//            AdmobTool.instance.show(.mode_open) { _ in
//                
//            }
//        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Universal Link - Background -> foreground
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // Background -> foreground
        if let url = URLContexts.first?.url {
            AppsFlyerLib.shared().handleOpen(url, options: nil)
        }
    }
    
    func configAppFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "sfasdfa"
        AppsFlyerLib.shared().appleAppID = "61231231224623"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().start()
    }
    
    private func reSetTabbarVC() {
        NotificationCenter.default.post(name: Noti_AppDeep, object: nil, userInfo: nil)
    }
}

extension SceneDelegate: AppsFlyerLibDelegate, DeepLinkDelegate {
    func onConversionDataFail(_ error: any Error) {
        
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard let info: DeepLink = result.deepLink else { return }
        if let url = info.deeplinkValue, url.count > 0 {
            HubTool.share.deepUrl = url
            HubTool.share.isLinkDeep = !info.isDeferred
            self.reSetTabbarVC()
        }
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let data = conversionInfo as NSDictionary? as? [String: Any] {
                if let done = data["is_first_launch"] as? Bool, done == true {
                    if !data.keys.contains("deep_link_value") && data.keys.contains("fruit_name") {
                        if let url: String = data["fruit_name"] as? String, url.count > 0 {
                            print("close --- linkname")
                            HubTool.share.deepUrl = url
                            self.reSetTabbarVC()
                        }
                    }
                }
            }
        }
    }
}


