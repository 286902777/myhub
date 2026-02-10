//
//  PlayTool.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit

class PlayTool {
    static let instance = PlayTool()
    
    var list: [VideoData] = []
    
    func pushPage(_ controller: UIViewController, _ mod: VideoData, _ list: [VideoData]) {
        PlayTool.instance.list = list.filter({$0.file_type == .video})
//        let vc = PlayVideoController(model: mod)
//        vc.hidesBottomBarWhenPushed = true
//        controller.navigationController?.pushViewController(vc, animated: true)
    }
}
