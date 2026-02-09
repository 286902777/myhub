//
//  HubRefresh.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import MJRefresh

class BaseRefreshFooter: MJRefreshAutoStateFooter {
    override func prepare() {
        super.prepare()
        self.mj_h = 44
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = UIColor.rgbHex("#000000")
        self.setTitle("", for: .idle)
        self.setTitle("", for: .refreshing)
        self.setTitle("", for: .noMoreData)
    }
}
