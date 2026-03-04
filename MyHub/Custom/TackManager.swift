//
//  TackManager.swift
//  MyHub
//
//  Created by hub on 2026/3/4.
//

import Foundation
import AppTrackingTransparency

class TackManager {
    static let share = TackManager()
    
    func startTrack() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                HubTool.share.isTrackUser = true
            default:
                HubTool.share.isTrackUser = false
            }
        }
    }
}
