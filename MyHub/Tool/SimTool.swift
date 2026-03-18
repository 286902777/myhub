//
//  SimTool.swift
//  MyHub
//
//  Created by myhub-ios on 3/18/26.
//

import Foundation
import CoreTelephony
import UIKit

class SimTool {
    static let instance = SimTool()

    func isSim() -> Bool {
        let result = CTTelephonyNetworkInfo()
        return result.serviceCurrentRadioAccessTechnology?.values.count ?? 0 != 0
    }

    func isEmulator() -> Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
    }

    func isVpnConnected() -> Bool {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return false } // 获取接口列表失败
        guard let firstAddr = ifaddr else { return false }
        defer { freeifaddrs(ifaddr) } // 释放内存
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let ifaName = String(cString: interface.ifa_name)
            // 判断接口名称是否为 VPN 类型
            if ifaName.hasPrefix("utun") || ifaName.hasPrefix("ipsec") || ifaName.hasPrefix("gre") {
                return true
            }
        }
        return false
    }

    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
