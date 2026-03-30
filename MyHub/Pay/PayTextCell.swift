//
//  PayTextCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/29/26.
//

import UIKit
import SnapKit

class PayTextCell: UITableViewCell {
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        self.addSubview(self.infoL)
        self.infoL.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-14)
        }
    }
    
    func initData(_ model: PayTableData) {
        if model.type == .none {
            self.infoL.snp.updateConstraints { make in
                make.top.equalTo(8)
            }
        }
        let name = UserDefaults.standard.string(forKey: PayName) ?? ""
        let fu = UserDefaults.standard.string(forKey: PayDisplayF) ?? ""
        var disText: String = ""

        switch PayType(rawValue: name) {
        case .weekly:
            disText = model.info + "\n" + "Auto-renews weekly at \(fu). Cancel any time."
        case .yearly:
            disText = model.info + "\n" + "\(fu) per year, auto-renewal. Cancel at any time."
        default:
            disText = model.info + "\n" + "Lifetime access with a one-time purchase, no need for renewal."
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        paragraphStyle.alignment = .left
        self.infoL.attributedText = NSAttributedString(string: model.type == .none ? disText : model.info, attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(size: model.type == .none ? 14 : 9), .foregroundColor: model.type == .none ? UIColor.rgbHex("#14171C") : UIColor.rgbHex("#000000", 0.25)])
    }
}

