//
//  PayData.swift
//  MyHub
//
//  Created by myhub-ios on 3/25/26.
//

import Foundation
import HandyJSON

enum PayStatus: Int {
    case restore = 0
    case pay
    case refresh
}

enum PayType: String, HandyJSONEnum {
    case weekly = "Weekly"
    case yearly = "Yearly"
    case lifetime = "Lifetime"
}

enum PayID: String, HandyJSONEnum {
    case weak = "myhub_week"
    case year = "myhub_year"
    case life = "myhub_lifetime"
}

class PayListData: SuperData {
    var infoList: [PayData] = []
}

//product_id: 商品的唯一标识符。
//price: 商品的单价。fff
//quantity: Hot标识，true有hot，false无hot。
//order: 商品在订阅列表中的顺序，从1开始，从上到下。
//default_selected: 是否为默认选中的商品，true表示默认选中，false表示不选中。
class PayData: SuperData {
    var product_id: String = ""
    var price: String = ""
    var hot: Bool = false
    var index: Int = 1
    var isSelect: Bool = false
    var name: String = ""
//    var fu: String = "$"
    var showPrice: String = ""
}

class PayEntityData: SuperData {
    var latest_receipt_info: [PayReceiptData] = []
    var pending_renewal_info: [PayRenewalData] = []
    var environment = ""
    var status = 0
    var receipt = ""
    var device_id = ""
    var ok: Bool = false
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &latest_receipt_info, name: "kissably")
        mapper.specify(property: &pending_renewal_info, name: "shacko")
        mapper.specify(property: &environment, name: "5avyddccrz")
        mapper.specify(property: &status, name: "dainteous")
        mapper.specify(property: &receipt, name: "ghatti")
        mapper.specify(property: &device_id, name: "garbage")
        mapper.specify(property: &ok, name: "goldenwing")
    }
}

class PayReceiptData: SuperData {
    var product_id = ""
    var transaction_id = ""
    var quantity = ""
    var expires_date_ms: TimeInterval = 0
    var expires_date: TimeInterval = 0
    var expires_date_pst = ""
    var purchase_date_ms: TimeInterval = 0
    var purchase_date = ""
    var purchase_date_pst = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &product_id, name: "wheft")
        mapper.specify(property: &transaction_id, name: "colorisms")
        mapper.specify(property: &quantity, name: "prologed")
        mapper.specify(property: &expires_date_ms, name: "rompingly")
        mapper.specify(property: &expires_date, name: "scaliness")
        mapper.specify(property: &expires_date_pst, name: "nonanemic")
        mapper.specify(property: &purchase_date_ms, name: "peptidic")
        mapper.specify(property: &purchase_date, name: "0jlk0hyzkn")
        mapper.specify(property: &purchase_date_pst, name: "crazyweed")
    }
}

class PayRenewalData: SuperData {
    var original_transaction_id = ""
    var auto_renew_status = ""
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &original_transaction_id, name: "extramodal")
        mapper.specify(property: &auto_renew_status, name: "seersucker")
    }
}

class ApplePayData: SuperData {
    var entity = PayEntityData()
    var auto_renew_status: String {
        return entity.pending_renewal_info.first?.auto_renew_status ?? "2"
    }
    var product_id: String {
        return entity.latest_receipt_info.first?.product_id ?? ""
    }
    var expires_date_ms: TimeInterval {
        return entity.latest_receipt_info.first?.expires_date_ms ?? 0
    }
    
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        mapper.specify(property: &entity, name: "horrorize")
    }
}
