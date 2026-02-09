//
//  HubTabItem.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit

class HubTabItem: NSObject {
    static let empty = HubTabItem(image: UIImage(), tag: 0)
    public let selectedImage: UIImage?
    public let normalImage: UIImage?
    public let tag: Int

    public init(selectedImage: UIImage?, normalImage: UIImage?, tag: Int) {
        self.selectedImage = selectedImage
        self.normalImage = normalImage
        self.tag = tag
    }

    public init(image: UIImage, tag: Int) {
        self.selectedImage = image
        self.normalImage = image
        self.tag = tag
    }

}
