//
//  Font+Extension.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
//GoogleSans-Regular
//GoogleSans-Italic
//GoogleSans-MediumItalic
//GoogleSans-SemiBold
//GoogleSans-SemiBoldItalic
//GoogleSans-Bold
//GoogleSans-BoldItalic

extension UIFont {
    static func GoogleSans(weight: UIFont.Weight = .regular, size: CGFloat) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "GoogleSans-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .bold:
            return UIFont(name: "GoogleSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .semibold:
            return UIFont(name: "GoogleSans-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .medium:
            return UIFont(name: "GoogleSans-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .heavy:
            return UIFont(name: "GoogleSans-MediumItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .light:
            return UIFont(name: "GoogleSans-Italic", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        case .black:
            return UIFont(name: "GoogleSans-BoldItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        default:
            return UIFont(name: "GoogleSans-SemiBoldItalic", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
