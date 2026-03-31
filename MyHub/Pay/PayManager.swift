//
//  PayManager.swift
//  MyHub
//
//  Created by myhub-ios on 3/25/26.
//

import Foundation
import StoreKit
import HandyJSON

class PayManager: NSObject {
    static let instance = PayManager()

    var isVip: Bool = UserDefaults.standard.bool(forKey: HUB_UserVip) {
        didSet {
            UserDefaults.standard.set(isVip, forKey: HUB_UserVip)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Noti_UserVip, object: nil)
        }
    }
      
    var isPop: Bool = false

    var defaultProduct: PayID = .life
    
    var task: URLSessionDataTask?
    
    var type: PayStatus = .pay
    
    private var payModel: PayData = PayData()
    
    var request = SKReceiptRefreshRequest()
    var productsData: [SKProduct] = []
    var product_id: String = ""
    var product_Type: String = ""
    
    var productDatas: [PayData] = []
    
    override init() {
        super.init()
        self.config()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            SKPaymentQueue.default().remove(self)
        }
    }
    
    func config() {
        let info = UserDefaults.standard.string(forKey: VipInfoKey)
        if let data = PayListData.deserialize(from: info) {
            self.productDatas = data.infoList
        }
        guard self.productDatas.count == 0 else { return }
        let life = PayData()
        life.product_id = PayID.life.rawValue
        life.index = 0
        life.isSelect = true
        life.price = "29.99"
        life.name = PayType.lifetime.rawValue
        let year = PayData()
        year.product_id = PayID.year.rawValue
        year.index = 1
        year.price = "19.99"
        year.name = PayType.yearly.rawValue
        let weak = PayData()
        weak.product_id = PayID.weak.rawValue
        weak.index = 2
        weak.price = "2.99"
        weak.name = PayType.weekly.rawValue
        self.productDatas.append(life)
        self.productDatas.append(year)
        self.productDatas.append(weak)
    }
    
    func clickReStore() {
        if PayManager.instance.isVip == false {
            if let vc = HubTool.share.keyVC() {
                LoadManager.instance.show(vc)
            }
            self.type = .restore
            self.requestProductInfo(type: .restore)
        } else {
            ToastTool.instance.show("Congrats! As a new member, you can take advantage of all premium perks.")
        }
    }
    
    func requestProductInfo(type: PayStatus) {
        self.task?.cancel()
        self.request.cancel()
        self.request = SKReceiptRefreshRequest()
        self.request.delegate = self
        self.request.start()
        self.reSetPurchaseData(type: type)
    }
    
    // MARK: - apple内购价格配置
    func reSetPurchaseData(type: PayStatus = .refresh) {
        self.type = type
        var productList: [String] = []
        self.productDatas.forEach { m in
            productList.append(m.product_id)
        }
        if SKPaymentQueue.canMakePayments() {
            let productsRequest = SKProductsRequest(productIdentifiers: Set(productList))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    /*MARK: - 准备拉起内购
     // - Parameter proId: apple内购productID
     // - Parameter from: 购买/恢复购买/验证
     // - Parameter source: 调起内购来源页面，用于日志标识
     */
    func pay(data: PayData, type: PayStatus, isPop: Bool) {
        HubTool.share.toPay = true
        self.isPop = isPop
        self.payModel = data
        if let vc = HubTool.share.keyVC() {
            LoadManager.instance.show(vc)
        }
        self.product_id = data.product_id
        self.type = type
        if let product = self.productsData.first(where: { $0.productIdentifier == self.product_id }) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            let payment = SKMutablePayment()
            payment.productIdentifier = self.product_id
            payment.quantity = 1
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func requestServiceReceiptData(product: Any?, type: PayStatus, transaction: SKPaymentTransaction? = nil) {
        if let reciptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: reciptURL.path) {
            do {
                let reciptData = try Data(contentsOf: reciptURL)
                if reciptData.count > 0 {
                    self.requestServerData(data: reciptData.base64EncodedString(options: []), type: type, transaction: transaction)
                }
            } catch {
                LoadManager.instance.dismiss()
                if type == .restore{
                    ToastTool.instance.show("Restore failed", .fail)
                }
                if type == .pay{
                    ToastTool.instance.show("Payment failed", .fail)
                }
            }
        } else {
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if type == .restore{
                    ToastTool.instance.show("Restore failed", .fail)
                }
                if type == .pay{
                    ToastTool.instance.show("Payment failed", .fail)
                }
            }
        }
    }
    
    /// admin 内购校验
    /// - Parameter from: 购买/恢复购买/验证
    /// - Parameter source: 调起内购来源页面，用于日志标识
    func requestServerData(data: String, type: PayStatus, transaction: SKPaymentTransaction?) {
        guard self.task == nil else {
            return
        }
        //        let bodyStr = String(format: "{\"device_id\":\"%@\",\"receipt_base64_data\":\"%@\",\"product_id\":\"%@\",\"package_name\":\"%@\"}", VAnalysis.shared.idfv(), data, self.product_id, appBunldeID)
        
        let bodyStr = String(format: "{\"garbage\":\"%@\",\"filiformed\":\"%@\",\"wheft\":\"%@\",\"ensorcel\":\"%@\"}", HttpManager.share.appPrimaryKey(), data, "", HUB_BuildId)
        //        let url = "\(PayHost)/v1/ios/receipt-verifier"
        let url = "https://mhb.myhubweb.com/educables/speculist/thrippence"
        
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let requestData = bodyStr.data(using: .utf8)
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("yamp", forHTTPHeaderField: "monkshoods") /// monkshoods == x-api-id
        request.timeoutInterval = 15
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        self.task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            self.task = nil
            if let transaction = transaction {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            LoadManager.instance.dismiss()
            guard error == nil else {
                switch type {
                case .pay:
                    self.reSetPurchaseData(type: .refresh)
                    ToastTool.instance.show("Payment failed", .fail)
                case .restore:
                    ToastTool.instance.show("Restore failed", .fail)
                default:
                    break
                }
                return
            }
            if let res = response as? HTTPURLResponse {
                if res.statusCode == 200, let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        DispatchQueue.main.async {[weak self] in
                            guard let self = self else { return}
                            if let model = ApplePayData.deserialize(from: json) {
                                if model.entity.ok == true {
                                    if type == .pay {
                                        self.successToPay()
                                        ToastTool.instance.show("Congrats! As a new member, you can take advantage of all premium perks.")
                                    }
                                    if let serviceModel = model.entity.latest_receipt_info.first {
                                        if let price = self.productDatas.first(where: {$0.product_id == serviceModel.product_id})?.price {
                                            UserDefaults.standard.set(price, forKey: PayPrice)
                                        }
                                        if let showPrice = self.productDatas.first(where: {$0.product_id == serviceModel.product_id})?.showPrice {
                                            UserDefaults.standard.set(showPrice, forKey: PayDisplayF)
                                        }
                                        if serviceModel.product_id == PayID.life.rawValue {
                                            UserDefaults.standard.set("", forKey: PayTime)
                                        } else {
                                            let date = Date(timeIntervalSince1970: serviceModel.expires_date_ms / 1000).toYMD()
                                            UserDefaults.standard.set(date, forKey: PayTime)
                                        }
                                        if let productType = self.productDatas.first(where: {$0.product_id == serviceModel.product_id})?.name {
                                            UserDefaults.standard.set(productType, forKey: PayName)
                                        }
                                        UserDefaults.standard.synchronize()
                                    }
                                    PayManager.instance.isVip = true
                                } else {
                                    PayManager.instance.isVip = false
                                    switch type {
                                    case .pay:
                                        ToastTool.instance.show("Payment failed", .fail)
                                        self.failToPay()
                                        self.reSetPurchaseData(type: .refresh)
                                    case .restore:
                                        ToastTool.instance.show("Restore failed", .fail)
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                    }
                } else {
                    switch type {
                    case .pay:
                        ToastTool.instance.show("Payment failed", .fail)
                        self.reSetPurchaseData(type: .refresh)
                    case .restore:
                        ToastTool.instance.show("Restore failed", .fail)
                    default:
                        break
                    }
                }
            }
        })
        self.task?.resume()
    }
    
    func successToPay() {
        HubTool.share.toPay = false
        var type: EventParaValue = .weak
        switch PayType(rawValue: self.payModel.name) {
        case .weekly:
            type = .weak
        case .yearly:
            type = .year
        default:
            type = .lifeTime
        }
        TbaManager.instance.addEvent(type: .custom, event: .premiumVipSuc, paramter: [EventParaName.value.rawValue: type.rawValue, EventParaName.vip_popup.rawValue: self.isPop, EventParaName.vip_auto.rawValue: HubTool.share.preMethod == .vip_auto, EventParaName.source.rawValue: HubTool.share.preSource.rawValue])
    }
    
    func failToPay() {
        HubTool.share.toPay = false
        var type: EventParaValue = .weak
        switch PayType(rawValue: self.payModel.name) {
        case .weekly:
            type = .weak
        case .yearly:
            type = .year
        default:
            type = .lifeTime
        }
        TbaManager.instance.addEvent(type: .custom, event: .premiumVipFail, paramter: [EventParaName.value.rawValue: type.rawValue])
    }
}

extension PayManager: SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        guard products.count > 0 else {
            return
        }
        self.productsData = products
        for item in self.productsData {
            if let m = self.productDatas.first(where: {$0.product_id == item.productIdentifier}) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = item.priceLocale
                print(formatter.locale.currencySymbol ?? "")
                print(item.price)
                if let priceString = formatter.string(from: item.price) {
                    m.showPrice = priceString
                    m.price = "\(item.price)"
//                    m.fu = formatter.locale.currencySymbol ?? ""
                }
            }
        }
    }
    // 请求产品信息失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        LoadManager.instance.dismiss()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("订阅 --- 商品添加进列表")
                break
            case .deferred:
                LoadManager.instance.dismiss()
                print("订阅 --- 交易延期")
            case .purchased:
                if (self.type == .refresh) {
                    LoadManager.instance.dismiss()
                }
                print("订阅 --- 交易完成")
                self.requestServiceReceiptData(product: self.product_id, type: self.type, transaction: transaction)
            case .failed:
                LoadManager.instance.dismiss()
                print("订阅 --- 交易失败")
                self.failToPay()
                ToastTool.instance.show("Payment failed", .fail)
            case .restored:
                print("订阅 --- 已经购买过")
                LoadManager.instance.dismiss()
                self.requestServiceReceiptData(product: self.product_id, type: .restore, transaction: transaction)
                self.reSetPurchaseData(type: .refresh)
            default:
                print("订阅 --- 未知错误")
                LoadManager.instance.dismiss()
                self.failToPay()
                ToastTool.instance.show("Payment failed", .fail)
            }
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            LoadManager.instance.dismiss()
            if self.type == .restore {
                if let vc = HubTool.share.keyVC() {
                    LoadManager.instance.show(vc)
                }
                self.requestServiceReceiptData(product: nil, type: self.type)
            }
        }
    }
}

extension NSDecimalNumber {
    /// 转换为 Double 并保留指定位数小数
    func toDouble(precision: Int = 2,
                  roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Double {
        let handler = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: Int16(precision),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return self.rounding(accordingToBehavior: handler).doubleValue
    }
}
