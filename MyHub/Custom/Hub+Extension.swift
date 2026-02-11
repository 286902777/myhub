//
//  Hub+Extension.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import CryptoSwift

extension UIColor {
    // 16进制颜色
    class func rgbHex(_ string: String, _ alpha: CGFloat = 1.0) -> UIColor {
        var colorStr = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if colorStr.hasPrefix("#") {
            colorStr.removeFirst()
        } else if colorStr.hasPrefix("0X") {
            colorStr.removeFirst(2)
        }
        
        // 确保是6位
        guard colorStr.count == 6 else {
            return UIColor.clear
        }
        
        let scanner = Scanner(string: colorStr)
        scanner.charactersToBeSkipped = nil
        
        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            return UIColor.clear
        }
    }
}

extension Double {
    func timeToHHMMSS() -> String {
        let seconds = Int(self) % 60
        let minutes = (Int(self) / 60) % 60
        let hours = Int(self) / 3600
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    func timeToHMS() -> String {
        let seconds = Int(self) % 60
        let minutes = (Int(self) / 60) % 60
        let hours = Int(self) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func dateToYMD(_ rate: Double = 1000.0) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self/rate))
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        return format.string(from: date)
    }
    
    func dateToYMDHMS(_ rate: Double = 1000.0) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self/rate))
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return format.string(from: date)
    }
    
    func computeFileSize() -> String {
        if self >= 1024*1024*1024 {
            return String(format: "%.1f", self/1024.0/1024.0/1024.0) + "G"
        } else if self >= 1024*1024 {
            return String(format: "%.1f", self/1024.0/1024.0) + "M"
        } else {
            return String(format: "%.1f", self/1024.0) + "K"
        }
    }
}

extension Array {
    func safeIndex(_ idx: Int) -> Element? {
        guard idx >= 0, idx < count else {
            return nil
        }
        return self[idx]
    }
}

extension String {
    subscript (rang: Range<Int>) -> String {
        get {
            let s = self.index(self.startIndex, offsetBy: rang.lowerBound)
            let e = self.index(self.startIndex, offsetBy: rang.upperBound)
            return String(self[s..<e])
        }
    }
    
    
    subscript (i: Int, s: Int) -> String {
        get {
            let start = self.index(self.startIndex, offsetBy: i)
            let end = self.index(self.startIndex, offsetBy: s)
            return String(self[start..<end])
        }
    }
    
    
    func toString(_ end: Int) -> String {
        return self[0..<end]
    }
    
    func lastString(_ to: Int) -> String {
        return self[to..<self.count]
    }
    
    func AESMovieAddress() -> String? {
//        let aseKey: String = "x8sixeo12QRaKUXg8Y/RqBPJJiAyVA==" // test
        let aseKey: String = "iwlixs8hcjlL8ba9I0wCvSvjWAz6A=="
        let data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        var bytes: [UInt8] = []
        if let length = data?.length {
            for i in 0..<length {
                var temp: UInt8 = 0
                data?.getBytes(&temp, range: NSRange(location: i, length: 1))
                bytes.append(temp)
            }
            
            var bytes_d: [UInt8] = []
            let result: String = aseKey.lastString(7)
            let keyData = Data(base64Encoded: result) ?? Data()
            do {
                bytes_d = try AES(key: keyData.bytes, blockMode: ECB()).decrypt(bytes)
            } catch { }
            let encoded = Data(bytes_d)
            return String(bytes: encoded.bytes, encoding: .utf8) ?? ""
        }
        return nil
    }
    
    func readKeyChain() -> String {
        let para: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: "app_ios_bundle", kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var data: AnyObject?
        let suc = SecItemCopyMatching(para as CFDictionary, &data)
        if suc == errSecSuccess, let d = data as? Data, let uuId = String(data: d, encoding: .utf8) {
            return uuId
        } else {
            let uuId: String = UUID().uuidString
            if let data = uuId.data(using: .utf8, allowLossyConversion: false) {
                let para: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: "app_ios_bundle", kSecValueData as String: data]
                SecItemDelete(para as CFDictionary)
                SecItemAdd(para as CFDictionary, nil)
            }
            return uuId
        }
    }
}
