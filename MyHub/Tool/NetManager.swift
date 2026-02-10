//
//  NetManager.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import Foundation
import Network

class NetManager {
    static let instance: NetManager = NetManager()
    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var networkName: String = ""
    
    func startChecking() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            NotificationCenter.default.post(name: Noti_NetworkStatus, object: nil, userInfo: nil)
            switch path.status {
            case .satisfied:
                if path.usesInterfaceType(.wifi) {
                    self?.networkName = "wifi"
                } else if path.usesInterfaceType(.cellular) {
                    self?.networkName = "cellular"
                } else {
                    self?.networkName = "wiredEthernet"
                }
            case .unsatisfied:
                self?.networkName = "unknown"
            case .requiresConnection:
                self?.networkName = "unknown"
            @unknown default:
                self?.networkName = "unknown"
            }
        }
        
        let queue = DispatchQueue(label: "NetworkQueue")
        monitor.start(queue: queue)
    }
}
