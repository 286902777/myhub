//
//  HubTabbar.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import SnapKit

let pi = CGFloat.pi
let pi2 = CGFloat.pi / 2

extension CGFloat {
    public func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}

@IBDesignable class HubTabBar: UITabBar {
    
    @IBInspectable public var barBackColor : UIColor = UIColor.black
    @IBInspectable public var barHeight : CGFloat = 60
    @IBInspectable public var barTopRadius : CGFloat = 30
    @IBInspectable public var barBottomRadius : CGFloat = 30

    @IBInspectable public var circleRadius : CGFloat = 0
    
    @IBInspectable var marginBottom : CGFloat = 4
    @IBInspectable var marginTop : CGFloat = 24

    private let margin: CGFloat = 15

    private lazy var circle: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        btn.setImage(UIImage(named: "add"), for: .highlighted)
        btn.setImage(UIImage(named: "add"), for: .selected)
        return btn
    }()
    
    private let addW: CGFloat = 64

    var currentIdx: Int = 0 {
        didSet {
            self.tabBtns.forEach { btn in
                btn.isSelected = btn.tag == currentIdx
            }
        }
    }
    var tabbarItems: [HubTabItem] = []
    
    private var tabBtns: [UIButton] = []
    
    let pitCornerRad : CGFloat = 4
    
    let pitCircleDistanceOffset : CGFloat = 4

    var clickBlock:((_ idx: Int) -> Void)?
    var clickAddBlock:(() -> Void)?

    @objc func clickBarAction(_ sender: UIButton) {
        self.currentIdx = sender.tag
        self.clickBlock?(self.currentIdx)
    }
    
    @objc func clickAddAction() {
        self.clickAddBlock?()
    }
    
    func addItems() {
        let btnW: CGFloat = (UIScreen.main.bounds.width - self.margin * 2 - self.addW) * 0.25
        tabBtns.removeAll()
        tabbarItems.forEach { item in
            let btn = UIButton()
            btn.setImage(item.normalImage, for: .normal)
            btn.setImage(item.normalImage, for: .highlighted)
            btn.setImage(item.selectedImage, for: .selected)
            btn.tag = item.tag
            btn.addTarget(self, action: #selector(clickBarAction(_:)), for: .touchUpInside)
            self.addSubview(btn)
            self.tabBtns.append(btn)
            let left: Int = Int(CGFloat(btn.tag) * btnW) + Int(self.margin) + (btn.tag > 1 ? Int(self.addW) : 0)
            btn.snp.makeConstraints { make in
                make.top.equalTo(marginTop)
                make.left.equalTo(left)
                make.size.equalTo(CGSize(width: btnW, height: 60))
            }
        }
        self.currentIdx = 0
    }
    
    private var barRect : CGRect{
        get{
            let h = self.barHeight
            let w = bounds.width - (margin * 2)
            let x = bounds.minX + margin
            let y = marginTop + circleRadius
            
            let rect = CGRect(x: x, y: y, width: w, height: h)
            return rect
        }
    }
    
    private func createCircleRect() -> CGRect{
        let backRect = barRect
        let radius = circleRadius
        let circleXCenter = getCircleCenter()
        let x : CGFloat = circleXCenter - radius
        let y = backRect.origin.y - radius + pitCircleDistanceOffset
        let pos = CGPoint(x: x, y: y)
        let result = CGRect(origin: pos, size: CGSize(width: radius * 2, height: radius * 2))
        return result
    }
    
    private func createCirclePath() -> CGPath{
        let circleRect = createCircleRect()
        let result = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRect.height / 2);
        
        return result.cgPath
    }
    
    private func getCircleCenter() -> CGFloat{
        let totalWidth = self.bounds.width
        var x = totalWidth / 2
        if let v = getViewForItem(item: self.selectedItem){
            x = v.frame.minX + (v.frame.width / 2)
        }
        self.circle.frame = CGRect(x: (self.bounds.width - 56) * 0.5, y: 0, width: 56, height: 56)
        return x
    }
    
    func createPitMaskPath(rect: CGRect) -> CGMutablePath {
        let circleXcenter = getCircleCenter()
        let backRect = barRect
        let x : CGFloat = circleXcenter + pitCornerRad
        let y = backRect.origin.y
        let center = CGPoint(x: x, y: y)
        let maskPath = CGMutablePath()
        maskPath.addRect(rect)
        
        let pit = createPitPath(center: center)
        maskPath.addPath(pit)
        
        return maskPath
    }

    func createPitPath(center : CGPoint) -> CGPath{
        let rad: CGFloat = 32
        let x = center.x - rad - pitCornerRad
        let y = center.y
        
        let result = UIBezierPath()
        result.lineWidth = 0
        result.move(to: CGPoint(x: x - 0, y: y + 0))
        
        result.addArc(withCenter: CGPoint(x: (x - pitCornerRad), y: (y + pitCornerRad)), radius: pitCornerRad, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        
        result.addArc(withCenter: CGPoint(x: (x + rad), y: (y + pitCornerRad ) ), radius: rad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)
        
        result.addArc(withCenter: CGPoint(x: (x + (rad * 2) + pitCornerRad), y: (y + pitCornerRad) ), radius: pitCornerRad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        
        result.addLine(to: CGPoint(x: x + (pitCornerRad * 2) + (rad * 2), y: y)) // rounding errors correction lines
        result.addLine(to: CGPoint(x: 0, y: 0))
        
        result.close()
        
        return result.cgPath
    }
    
    private func createBackgroundPath() -> CGPath{
        let rect = barRect
        let topLeftRadius = self.barTopRadius
        let topRightRadius = self.barTopRadius
        let bottomRigtRadius = self.barBottomRadius
        let bottomLeftRadius = self.barBottomRadius
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topLeftRadius, y:rect.minY))
        
        path.addArc(withCenter: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle:3 * pi2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRigtRadius))
        path.addArc(withCenter: CGPoint(x: rect.maxX - bottomRigtRadius, y: rect.maxY - bottomRigtRadius), radius: bottomRigtRadius, startAngle: 0, endAngle: pi2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX + bottomRigtRadius, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: pi2, endAngle: pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(withCenter: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: pi, endAngle: 3 * pi2, clockwise: true)
        path.close()
        return path.cgPath
    }
    
    private lazy var background: CAShapeLayer = {
        let result = CAShapeLayer();
        result.fillColor = self.barBackColor.cgColor
        result.mask = self.backgroundMask
        return result
    }()
    
//    private lazy var circle: CAShapeLayer = {
//        let result = CAShapeLayer()
//        result.fillColor = UIColor.white.cgColor
//        return result
//    }()
    
    private lazy var backgroundMask : CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillRule = CAShapeLayerFillRule.evenOdd
        return result
    }()

    private func getViewForItem(item : UITabBarItem?) -> UIView?{
        if let item = item {
            let v = item.value(forKey: "view") as? UIView
            return v
        }
        return nil
    }
 
    private func layoutElements(selectedChanged : Bool){
        self.background.path = self.createBackgroundPath()
        if self.backgroundMask.path == nil {
            self.backgroundMask.path = self.createPitMaskPath(rect: self.bounds)
//            self.circle.path = self.createCirclePath()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.fillColor = self.barBackColor.cgColor
        self.layoutElements(selectedChanged: false)
    }
    
    override func prepareForInterfaceBuilder() {
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        background.fillColor = self.barBackColor.cgColor
        self.circle.frame = self.createCircleRect()
    }
    
    private func setup(){
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()

        self.layer.insertSublayer(background, at: 0)
        self.addSubview(self.circle)
        self.circle.addTarget(self, action: #selector(clickAddAction), for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}



