//
//  GoogleNativeController.swift
//  MyHub
//
//  Created by hub on 3/5/26.
//

import UIKit
import GoogleMobileAds

class GoogleNativeController: UIViewController {

    var adContent: NativeAd?
    
    var s_adContent: NativeAd?

    var adsTime: Int = 7
    var adsRate: Int = 0
    var isClickAds: Bool = false
    var timer: DispatchSourceTimer?
    let queue = DispatchQueue(label: "admobNative")
    private var isUpAds: Bool = false
    private var isUpClose: Bool = false
    private var showC: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
}
