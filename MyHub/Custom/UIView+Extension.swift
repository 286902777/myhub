//
//  UIView+Extension.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import Kingfisher

extension UIView {
    func addGradLayer(_ oColor: UIColor, _ tColor: UIColor, _ rect: CGRect, _ v: Bool = false) {
        let lay = CAGradientLayer()
        lay.colors = [oColor.cgColor, tColor.cgColor]
        lay.locations = [0, 1]
        lay.frame = rect
        if v {
            lay.startPoint = CGPoint(x: 0.5, y: 0)
            lay.endPoint = CGPoint(x: 0.5, y: 1.0)
        } else {
            lay.startPoint = CGPoint(x: 0, y: 0.5)
            lay.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        self.layer.insertSublayer(lay, at: 0)
    }
    
    func addRedius(_ corners: UIRectCorner, _ radius: CGFloat, _ rect: CGRect = UIScreen.main.bounds) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let lay = CAShapeLayer()
        lay.path = path.cgPath
        lay.frame = rect
        self.layer.mask = lay
    }
}

extension UIView {
    func addCornerShadow(_ corner: CGFloat, _ offset: CGSize, _ color: UIColor, _ radius: CGFloat, _ opacity: Float = 1.0) {
        self.layer.cornerRadius = corner
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color.cgColor
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    func addEffectView(_ size: CGSize, _ style: UIBlurEffect.Style = UIBlurEffect.Style.dark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = size
        blurView.layer.masksToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
    }
}

extension UIImage {
    func compressSize(with maxSize: Int) -> Data? {
        // 先判断当前质量是否满足要求，不满足再进行压缩
        guard var finallImageData = jpegData(compressionQuality: 1.0) else { return nil }
        if finallImageData.count / 1024 <= maxSize {
            return finallImageData
        }
        // 先调整分辨率
        var defaultSize = CGSize(width: 1024, height: 1024)
        guard let compressImage = scaleSize(defaultSize), let compressImageData = compressImage.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        finallImageData = compressImageData

        // 保存压缩系数
        var compressionQualityArray = [CGFloat]()
        let avg: CGFloat = 1.0 / 250
        var value = avg
        var i: CGFloat = 250.0
        repeat {
            i -= 1
            value = i * avg
            compressionQualityArray.append(value)
        } while i >= 1

        // 调整大小，压缩系数数组compressionQualityArr是从大到小存储，思路：使用二分法搜索
        guard let halfData = twoHalf(array: compressionQualityArray, image: compressImage, sourceData: finallImageData, maxSize: maxSize) else {
            return nil
        }
        finallImageData = halfData
        // 如果还是未能压缩到指定大小，则进行降分辨率
        while finallImageData.count == 0 {
            // 每次降100分辨率
            if defaultSize.width - 100 <= 0 || defaultSize.height - 100 <= 0 {
                break
            }
            defaultSize = CGSize(width: defaultSize.width - 100, height: defaultSize.height - 100)
            guard let lastValue = compressionQualityArray.last,
                  let newImageData = compressImage.jpegData(compressionQuality: lastValue),
                  let tempImage = UIImage(data: newImageData),
                  let tempCompressImage = tempImage.scaleSize(defaultSize),
                  let sourceData = tempCompressImage.jpegData(compressionQuality: 1.0),
                  let halfData = twoHalf(array: compressionQualityArray, image: tempCompressImage, sourceData: sourceData, maxSize: maxSize)
            else {
                return nil
            }
            finallImageData = halfData
        }
        return finallImageData
    }

    // MARK: - 调整图片分辨率/尺寸（等比例缩放）

    func scaleSize(_ newSize: CGSize) -> UIImage? {
        let heightScale = size.height / newSize.height
        let widthScale = size.width / newSize.width

        var finallSize = CGSize(width: size.width, height: size.height)
        if widthScale > 1.0, widthScale > heightScale {
            finallSize = CGSize(width: size.width / widthScale, height: size.height / widthScale)
        } else if heightScale > 1.0, widthScale < heightScale {
            finallSize = CGSize(width: size.width / heightScale, height: size.height / heightScale)
        }
        UIGraphicsBeginImageContext(CGSize(width: Int(finallSize.width), height: Int(finallSize.height)))
        draw(in: CGRect(x: 0, y: 0, width: finallSize.width, height: finallSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    // MARK: - 二分法
    private func twoHalf(array: [CGFloat], image: UIImage, sourceData: Data, maxSize: Int) -> Data? {
        var tempFinallImageData = sourceData
        var finallImageData = Data()
        var start = 0
        var end = array.count - 1
        var index = 0

        var difference = Int.max
        while start <= end {
            index = start + (end - start) / 2
            guard let data = image.jpegData(compressionQuality: array[index]) else {
                return nil
            }
            tempFinallImageData = data
            let sizeOrigin = tempFinallImageData.count
            let sizeOriginKB = sizeOrigin / 1024
            if sizeOriginKB > maxSize {
                start = index + 1
            } else if sizeOriginKB < maxSize {
                if maxSize - sizeOriginKB < difference {
                    difference = maxSize - sizeOriginKB
                    finallImageData = tempFinallImageData
                }
                if index <= 0 {
                    break
                }
                end = index - 1
            } else {
                break
            }
        }
        return finallImageData
    }
    /// 生成纯色图片
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// 修改图片颜色
    func tintImage(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0.0)
        let context = UIGraphicsGetCurrentContext()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let context = context {
            context.setBlendMode(.sourceAtop)
        }
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
}

extension UIImage {
    /// 智能压缩图片大小
    func smartCompressImage() -> Data? {
        guard let finallImageData = jpegData(compressionQuality: 1.0) else { return nil }
        if finallImageData.count / 1024 <= 300 {
            return finallImageData
        }
        var width = size.width
        var height = size.height
        let longSide = max(width, height)
        let shortSide = min(width, height)
        let scale = shortSide / longSide
        if shortSide < 1080 || longSide < 1080 {
            return jpegData(compressionQuality: 0.5)
        } else {
            if width < height {
                width = 1080
                height = 1080 / scale
            } else {
                width = 1080 / scale
                height = 1080
            }
            UIGraphicsBeginImageContext(CGSize(width: width, height: height))
            draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            let compressImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return compressImage?.jpegData(compressionQuality: 0.5)
        }
    }
}


extension UIImageView {
    typealias CompleteBlock = (_ image: UIImage?)->()
    func setImage(_ url: String?, placeholder: String = "video_bg", complete: CompleteBlock? = nil) {
        let placeImg = UIImage(named: placeholder)
        var imageAddress: String? = url

        // 解决url已被后台urlEncode，先将url Decode后，再Encode
        if let d = url?.removingPercentEncoding {
            imageAddress = d
        }

        guard let url = imageAddress?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            self.image = placeImg
            complete?(nil)
            return
        }

        let imgUrl = URL(string: url)
        self.kf.setImage(with: imgUrl, placeholder: placeImg, options: [.cacheSerializer(DefaultCacheSerializer.default)], progressBlock: nil) { (result) in
            switch result {
            case let .success(info):
                complete?(info.image.kf.normalized)
            case let .failure(error):
                print(error)
                break
            }
        }
    }
}
