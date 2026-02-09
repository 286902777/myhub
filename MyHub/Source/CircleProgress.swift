//
//  CircleProgress.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class CircleProgress: UIView {
    /// 底条颜色
    var backLineColor: UIColor = UIColor.rgbHex("#FFFFFF", 0.2)
    
    /// 底条宽度
    var backLineWidth: CGFloat = 8.0
    
    /// 进度条颜色
    var progressColor: UIColor = UIColor.rgbHex("#F0FC94")
    
    /// 进度条宽度
    var progressWidth: CGFloat = 8.0
    
    /// 进度比例（0～1）
    var ratio: CGFloat = 0 {
        didSet {
            var newValue = ratio
            if newValue < 0 {
                newValue = 0
            } else if (newValue > 1) {
                newValue = 1
            }
            self.lineLayer?.strokeEnd  = newValue
        }
    }
    
    /// 开始弧度
    var startAngle: CGFloat = CGFloat(-(Double.pi / 2))
    
    /// 结束弧度
    var endAngle: CGFloat = CGFloat(Double.pi / 2 * 3)
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 2
        view.axis = .vertical
        return view
    }()
    
    /// 中间文本框
    lazy private(set) var useLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.font = UIFont.GoogleSans(weight: .medium, size: 16)
        return textLabel
    }()
    
    lazy private(set) var totalLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = UIColor.rgbHex("#FFFFFF", 0.5)
        textLabel.textAlignment = .center
        textLabel.font = UIFont.GoogleSans(weight: .medium, size: 12)
        return textLabel
    }()
    
    private var lineLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.backgroundColor = .clear
        addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.useLabel)
        self.stackView.addArrangedSubview(self.totalLabel)
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let radius: CGFloat = ((self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width)-(self.backLineWidth > self.progressWidth ? self.backLineWidth : self.progressWidth))*0.5;
        
        let path = UIBezierPath()
        let centerPoint = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        path.addArc(withCenter: centerPoint, radius: radius, startAngle: self.startAngle, endAngle: self.endAngle, clockwise: true)
        
        let backLayer = CAShapeLayer()
        backLayer.frame = self.bounds
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.lineWidth = self.backLineWidth
        backLayer.strokeColor = self.backLineColor.cgColor
        backLayer.strokeStart = 0
        backLayer.strokeEnd = 1
        backLayer.lineCap = .round
        backLayer.path = path.cgPath
        self.layer.addSublayer(backLayer)
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = self.progressWidth
        lineLayer.strokeColor = self.progressColor.cgColor
        lineLayer.strokeStart = 0
        lineLayer.strokeEnd = self.ratio
        lineLayer.lineCap = .round
        lineLayer.path = path.cgPath
        self.layer.addSublayer(lineLayer)
        self.lineLayer = lineLayer
    }
}
