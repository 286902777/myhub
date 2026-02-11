//
//  HtmlController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import WebKit
import SnapKit

enum HUB_WebLink: String {
    case privacy = "https://s.com/privacy/"
    case terms = "https://s.com/terms/"
}
class HtmlController: SuperController {
    
    var linkType: HUB_WebLink = .privacy
    
    var name: String = ""
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        view.addSubview(webView)
        self.navbar.nameL.text = self.name
        webView.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        if let url = URL(string: self.linkType.rawValue) {
            webView.load(URLRequest(url: url))
        }
    }
    
    override func backAction() {
        if let vs = self.navigationController?.viewControllers, vs.count > 0 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: false)
        }
    }
}
