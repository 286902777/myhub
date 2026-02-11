//
//  HUBActiveView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit

class HUBActiveView: UIView {
    private let clayer = CAShapeLayer()
    private let slayer = CAShapeLayer()
    
    private let lineWidth: CGFloat = 2.0
    private let size: CGSize = CGSize(width: 24, height: 24)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setup()
    }
    private func setup() {
        // 1. 创建一个 270° 的圆弧路径（留 90° 缺口，更有加载感）
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 2 - lineWidth / 2
        let startAngle = CGFloat.pi * 1.0      // 270°（即 9点钟方向）
        let endAngle = startAngle + CGFloat.pi * 1.0  // 270° 弧，到 6点钟方向（总 270°）
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        let circlePath = UIBezierPath(
            ovalIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
        )
        
        // 2. 创建 CAShapeLayer
        clayer.path = circlePath.cgPath
        clayer.fillColor = UIColor.clear.cgColor      // 无填充 → 空心
        clayer.strokeColor = UIColor.rgbHex("#FFFFFF", 0.5).cgColor // 边框颜色
        clayer.lineWidth = 2.0
        
        
        // 2. 配置 ShapeLayer
        slayer.path = path.cgPath
        slayer.strokeColor = UIColor.white.cgColor  // 线条颜色
        slayer.fillColor = UIColor.clear.cgColor         // 无填充
        slayer.lineWidth = lineWidth
        slayer.lineCap = .round
        // 3. 设置图层位置（基于当前 view 的中心）
        let layerSize = size
        slayer.frame = CGRect(
            x: (bounds.width - layerSize.width) / 2,
            y: (bounds.height - layerSize.height) / 2,
            width: layerSize.width,
            height: layerSize.height
        )
        slayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        // 4. 创建动画
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        endAnimation.duration = 1.2
        endAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = 0
        startAnimation.toValue = 1
        startAnimation.duration = 1.5
        startAnimation.beginTime = 0.5
        startAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        let roAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        roAnimation.fromValue = 0
        roAnimation.toValue = CGFloat.pi * 2
        roAnimation.duration = 2.0
        roAnimation.repeatCount = .infinity
        roAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        // 5. 组合动画（可选，如果你想 stroke 和旋转同时进行）
        let group = CAAnimationGroup()
        group.animations = [endAnimation, startAnimation, roAnimation]
        group.duration = 2.0
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        // 6. 添加动画到图层
        slayer.add(group, forKey: "playLoadAnimation")
        // 7. 添加图层到视图
        self.layer.addSublayer(clayer)
        self.layer.addSublayer(slayer)
    }
}


