//
//  UploadTool.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import Foundation

class UploadTool {
    static let instance = UploadTool()
    
    var clickCreateBlock: (() -> Void)?
    
    func openVC(_ controller: UIViewController, _ folder: Bool = false, _ parentId: String = "") {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.startTrack()
        }
        if UserDefaults.standard.bool(forKey: HUB_FirstUpload) {
            self.presetUpload(controller, parentId, folder)
        } else {
            UserDefaults.standard.set(true, forKey: HUB_FirstUpload)
            UserDefaults.standard.synchronize()
            let vc = AlertController(title: "", info: "Do not upload any illegal content, including but not limited to child pornography, violence, terrorism, or other unlawful material. Accounts may be banned upon discovery.", type: .ok)
            vc.okBlock = { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.presetUpload(controller, parentId, folder)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            controller.present(vc, animated: false)
        }
    }
    
    private func presetUpload(_ controller: UIViewController, _ parentId: String, _ folder: Bool = false) {
        if (LoginManager.share.isLogin == false) {
            LoginManager.share.loginRequest(controller) { _ in
                
            }
        } else {
            let uploadVC = UploadController(parent_id: parentId)
            uploadVC.modalPresentationStyle = .overFullScreen
            uploadVC.isNewFolder = folder
            uploadVC.folderBlock = { [weak self] in
                guard let self = self else { return }
                self.clickCreateBlock?()
            }
            controller.present(uploadVC, animated: false)
        }
    }
}
