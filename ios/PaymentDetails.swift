//
//  PaymentDetails.swift
//  payutesting
//
//  Created by JK on 28/03/22.
//

import Foundation
//
//  PaymentDetails.swift
//  CcavenuePayment
//
//  Created by M K Hari Balaji  on 17/08/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation


struct AvenueParams {
    static let  ACCESS_CODE = "access_code"
    static let  MERCHANT_ID = "merchant_id"
    static let  ORDER_ID = "order_id"
    static let  AMOUNT = "amount"
    static let  CURRENCY = "currency"
    static let  LANGUAGE = "language"
    static let  ENC_VAL = "enc_val"
    static let  REDIRECT_URL = "redirect_url"
    static let  CANCEL_URL = "cancel_url"
    static let  RSA_KEY_URL = "rsa_key_url"
    static let  TRANS_URL = "trans_url"
    static let  TRANS_DATA = "trans_data"
    static let  PAYMENT_OPTION = "payment_option"
    static let  BILLING_NAME = "billing_name"
    static let  BILLING_ADDRESS = "billing_address"
    static let  BILLING_CITY = "billing_city"
    static let  BILLING_STATE = "billing_state"
    static let BILLING_ZIP = "billing_zip"
    static let BILLING_COUNTRY = "billing_country"
    static let BILLING_TEL = "billing_tel"
    static let BILLING_EMAIL = "billing_email"
    static let DELIVERY_NAME = "delivery_name"
    static let DELIVERY_ADDRESS = "delivery_address"
    static let DELIVERY_CITY = "delivery_city"
    static let DELIVERY_STATE = "delivery_state"
    static let DELIVERY_ZIP = "delivery_zip"
    static let DELIVERY_COUNTRY = "delivery_country"
    static let DELIVERY_TEL = "delivery_tel"
    static let MERCHANT_PARAM1 = "merchant_param1"
    static let MERCHANT_PARAM2 = "merchant_param2"
    static let MERCHANT_PARAM3 = "merchant_param3"
    static let MERCHANT_PARAM4 = "merchant_param4"
    static let MERCHANT_PARAM5 = "merchant_param5"
    static let PROMO_CODE = "promo_code"
    static let CUSTOMER_IDENTIFIER = "customer_identifier"
}



struct PaymentDetails{
//    var accessCode: String
//    var merchantId: String
//    var orderId: String
//    var currency : String
//    var amount : String
//    var language:String
//    var rsaKeyUrl:String
    var redirectUrl:String
//    var cancelUrl : String
    var transUrl:String
//    var paymentOption: String?
}

struct BillingDetails{
    var billingName: String?
    var billingAddress: String?
    var billingCity: String?
    var billingState : String?
    var billingZip : String?
    var billingCountry:String?
    var billingTel:String?
    var billingEmail : String?
}


struct DeliveryDetails{
    var deliveryName: String?
    var deliveryAddress: String?
    var deliveryCity: String?
    var deliveryState : String?
    var deliveryZip : String?
    var deliveryCountry:String?
    var deliveryTel:String?
}

struct MerchantParamDetails{
    var merchantParam1: String?
    var merchantParam2: String?
    var merchantParam3: String?
    var merchantParam4: String?
    var merchantParam5: String?
}

struct OtherDetails{
    var promo_code : String?
    var customer_identifier : String?
}

enum ResponseAction: CaseIterable {
    case OK, CANCEL
}


struct ResponseData{
    var errorType : String?
    var errorMsg : String?
    var action : ResponseAction?
    var msg : [String:Any]?
}
