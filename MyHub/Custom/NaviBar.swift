//
//  NaviBar.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit

class NaviBar: UIView {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var nameL: UILabel!
    
    var clickBlock: (() -> Void)?
    
    class func xibView() -> NaviBar {
        let view = Bundle.main.loadNibNamed(String(describing: NaviBar.self), owner: nil)?.first as! NaviBar
        view.nameL.font = UIFont.GoogleSans(weight: .medium, size: 16)
        return view
    }
    
    @IBAction func clickBackAction(_ sender: Any) {
        self.clickBlock?()
    }
}
