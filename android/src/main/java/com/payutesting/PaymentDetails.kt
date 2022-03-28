package com.payutesting


data class PaymentDetails(var redirectUrl:String,var transUrl:String)

data class BillingDetails(val billingName: String? = null, val billingAddress: String? = null, val billingCity: String? = null,
									val billingState : String? = null ,val billingZip : String? = null,val billingCountry:String? = null,
									val billingTel:String? = null,val billingEmail : String? = null)

data class DeliveryDetails(val deliveryName: String? = null, val deliveryAddress: String? = null, val deliveryCity: String? = null,
									val deliveryState : String? = null,val deliveryZip : String? = null,val deliveryCountry:String? = null,
									val deliveryTel:String? = null)

data class MerchantParamDetails(val merchantParam1: String?= null,val merchantParam2: String? = null,val merchantParam3: String? = null,
								val merchantParam4: String? = null,val merchantParam5: String? = null)

data class OtherDetails(val promoCode: String?= null,val customerIdentifier: String? = null)
