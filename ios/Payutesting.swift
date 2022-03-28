//@objc(Payutesting)
//class Payutesting: NSObject {
//
//    @objc(multiply:withB:withResolver:withRejecter:)
//    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
//        resolve(a*b)
//    }
//}
@objc(Payutesting)
class Payutesting: NSObject {
    var resolve: RCTPromiseResolveBlock?
    var reject: RCTPromiseRejectBlock?
    var paymentData : PaymentDetails?
    var billingData : BillingDetails?
    var deliveryData : DeliveryDetails?
    var merchantParamData : MerchantParamDetails?
    var otherData : OtherDetails?
    var orderParams : Dictionary<String, String> = Dictionary()
   /**
    * In this method we will generate RSA Key from the URL for this we will pass order id and the access code as the request parameter
    * after the successful key generation we'll pass the data to the request handler using complition block
    */

    private func gettingRsaKey(completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()){
        DispatchQueue.main.async {
            let rsaKeyDataStr = "access_code=\(self.paymentData!.accessCode)&order_id=\(self.paymentData!.orderId)"
            print(rsaKeyDataStr)
            let requestData = rsaKeyDataStr.data(using: String.Encoding.utf8)
            
            guard let urlFromString = URL(string: self.paymentData!.rsaKeyUrl) else{
                return
            }
            var urlRequest = URLRequest(url: urlFromString)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            print("session",session)
            
            session.dataTask(with: urlRequest as URLRequest) {
                (data, response, error) -> Void in
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode{
                        guard let responseData = data else{
                            print("No value for data")
                            completion(false, "Not proper data for RSA Key" as AnyObject?)
                            return
                        }
                        print("data :: ",responseData)
                        completion(true, responseData as AnyObject?)
                }
                else{
                    completion(false, "Unable to generate RSA Key please check" as AnyObject?)                }
                }.resume()
        }
    }
    
    
    private func addToPostParams(paramKey : String,paramValue : String?) -> String{
        if(nil != paramValue && !(paramValue!.isEmpty)){
            return "&" + paramKey + "=" + paramValue!
        }else{
            return ""
        }
    }
    
    /**
     * encyptCardDetails method we will use the rsa key to encrypt amount and currency and onece the encryption is done we will pass this encrypted data to the initTrans to initiate payment
     */
    private func encyptAmtDetails(data: Data) -> String{
           guard let rsaKeytemp = String(bytes: data, encoding: String.Encoding.ascii) else{
               print("No value for rsaKeyTemp")
               return ""
           }

       
            if(rsaKeytemp == "" && rsaKeytemp.contains("ERROR")){
                return ""
            }
            
           var rsaKey = rsaKeytemp
           rsaKey = rsaKey.trimmingCharacters(in: CharacterSet.newlines)
           rsaKey =  "-----BEGIN PUBLIC KEY-----\n\(rsaKey)\n-----END PUBLIC KEY-----\n"
           print("rsaKey :: ",rsaKey)
           
           var myRequestString = "\(AvenueParams.MERCHANT_ID)=\(self.paymentData!.merchantId)"
        myRequestString += self.addToPostParams(paramKey: AvenueParams.AMOUNT,paramValue: paymentData?.amount)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.CURRENCY,paramValue: paymentData?.currency)
        
        let myRequestData : String = myRequestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("Request String :: ",myRequestData)
           do{
            let encodedData = try RSAUtils.encryptWithRSAPublicKey(str: myRequestData, pubkeyBase64: rsaKey)
               var encodedStr = encodedData?.base64EncodedString(options: [])
               let validCharSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
               encodedStr = encodedStr?.addingPercentEncoding(withAllowedCharacters: validCharSet)
            return encodedStr!
           }
           catch let err {
            self.sendFailure(code: "ERROR_GENERAL",message: err.localizedDescription)
           }
            return ""
       }
    
    func sendSuccess(message : Dictionary<String, Any>?){
           if(self.resolve != nil){
               self.resolve!(message)
           }
       }
       
       func sendFailure(code : String,message : String){
         
           if(self.reject != nil){
                 print("Failure : ",message)
               self.reject!(code, message,nil)
           }
       }
    
    func getEncryptedParams(encAmtVal : String) -> String{
        var myRequestString = "\(AvenueParams.MERCHANT_ID)=\(self.paymentData!.merchantId)"
        myRequestString += self.addToPostParams(paramKey: AvenueParams.ORDER_ID,paramValue: paymentData?.orderId)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.ENC_VAL,paramValue: encAmtVal)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.ACCESS_CODE,paramValue: paymentData?.accessCode)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.REDIRECT_URL,paramValue: paymentData?.redirectUrl)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.CANCEL_URL,paramValue: paymentData?.cancelUrl)
        myRequestString += self.addToPostParams(paramKey: AvenueParams.PAYMENT_OPTION,paramValue: paymentData?.paymentOption)
        myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_NAME, paramValue: billingData?.billingName)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_ADDRESS, paramValue: billingData?.billingAddress)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_CITY, paramValue: billingData?.billingCity)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_STATE, paramValue: billingData?.billingState)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_ZIP, paramValue: billingData?.billingZip)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_COUNTRY, paramValue: billingData?.billingCountry)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_TEL, paramValue: billingData?.billingTel)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.BILLING_EMAIL, paramValue: billingData?.billingEmail)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_NAME, paramValue: deliveryData?.deliveryName)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_ADDRESS, paramValue: deliveryData?.deliveryAddress)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_CITY, paramValue: deliveryData?.deliveryCity)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_STATE, paramValue: deliveryData?.deliveryState)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_ZIP, paramValue: deliveryData?.deliveryZip)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_COUNTRY, paramValue: deliveryData?.deliveryCountry)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.DELIVERY_TEL, paramValue: deliveryData?.deliveryTel)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM1, paramValue: merchantParamData?.merchantParam1)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM2, paramValue: merchantParamData?.merchantParam2)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM3, paramValue: merchantParamData?.merchantParam3)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM4, paramValue: merchantParamData?.merchantParam4)
       myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM5, paramValue: merchantParamData?.merchantParam5)
        myRequestString +=  self.addToPostParams(paramKey: AvenueParams.PROMO_CODE, paramValue: otherData?.promo_code)
        myRequestString +=  self.addToPostParams(paramKey: AvenueParams.MERCHANT_PARAM5, paramValue: otherData?.customer_identifier)
       return myRequestString
    }
    
    @objc(start:withResolver:withRejecter:)
    func start(paymentDetails : NSDictionary, resolve:@escaping RCTPromiseResolveBlock,reject:@escaping RCTPromiseRejectBlock) -> Void {
        self.resolve = resolve
        self.reject = reject
        DispatchQueue.main.async {
            let ctx : UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
            
            self.paymentData = PaymentDetails(
              accessCode: paymentDetails[AvenueParams.ACCESS_CODE] as! String,
              merchantId: paymentDetails[AvenueParams.MERCHANT_ID] as! String,
              orderId: paymentDetails[AvenueParams.ORDER_ID] as! String,
              currency : paymentDetails[AvenueParams.CURRENCY] as! String,
              amount : paymentDetails[AvenueParams.AMOUNT] as! String,
              language:paymentDetails[AvenueParams.LANGUAGE] as! String,
              rsaKeyUrl:paymentDetails[AvenueParams.RSA_KEY_URL] as! String,
              redirectUrl:paymentDetails[AvenueParams.REDIRECT_URL] as! String,
              cancelUrl : paymentDetails[AvenueParams.CANCEL_URL] as! String,
             transUrl : paymentDetails[AvenueParams.TRANS_URL] as! String,
             paymentOption : paymentDetails[AvenueParams.PAYMENT_OPTION] as? String)
 
            self.billingData = BillingDetails(
                billingName: paymentDetails[AvenueParams.BILLING_NAME] as? String, billingAddress: paymentDetails[AvenueParams.BILLING_ADDRESS] as? String,
                    billingCity: paymentDetails[AvenueParams.BILLING_CITY] as? String,
                    billingState: paymentDetails[AvenueParams.BILLING_STATE] as? String,
                    billingZip: paymentDetails[AvenueParams.BILLING_ZIP] as? String,
                    billingCountry: paymentDetails[AvenueParams.BILLING_COUNTRY] as? String,
                    billingTel: paymentDetails[AvenueParams.BILLING_TEL] as? String,
                    billingEmail: paymentDetails[AvenueParams.BILLING_EMAIL] as? String)

            self.deliveryData = DeliveryDetails(
                deliveryName: paymentDetails[AvenueParams.DELIVERY_NAME] as? String,
                deliveryAddress: paymentDetails[AvenueParams.DELIVERY_ADDRESS] as? String,
                deliveryCity: paymentDetails[AvenueParams.DELIVERY_CITY] as? String,
                deliveryState: paymentDetails[AvenueParams.DELIVERY_STATE] as? String,
                deliveryZip: paymentDetails[AvenueParams.DELIVERY_ZIP] as? String,
                deliveryCountry: paymentDetails[AvenueParams.DELIVERY_COUNTRY] as? String,
                deliveryTel: paymentDetails[AvenueParams.DELIVERY_TEL] as? String)
            
            
            self.merchantParamData = MerchantParamDetails(
                merchantParam1: paymentDetails[AvenueParams.MERCHANT_PARAM1] as? String,
                merchantParam2: paymentDetails[AvenueParams.MERCHANT_PARAM2] as? String,
                merchantParam3: paymentDetails[AvenueParams.MERCHANT_PARAM3] as? String,
                merchantParam4: paymentDetails[AvenueParams.MERCHANT_PARAM4] as? String,
                merchantParam5: paymentDetails[AvenueParams.MERCHANT_PARAM5] as? String)
            
            self.otherData = OtherDetails(promo_code: paymentDetails[AvenueParams.PROMO_CODE] as? String, customer_identifier: paymentDetails[AvenueParams.CUSTOMER_IDENTIFIER] as? String)
            let controller:CCWebViewController = CCWebViewController()
            controller.paymentData = self.paymentData
            controller.callback = {
                (responseData) in
                let result = responseData as ResponseData
                
                if(result.action==ResponseAction.OK){
                    self.sendSuccess(message: result.msg)
                }else{
                    self.sendFailure(code: result.errorType!,message: result.errorMsg!)
                }
                controller.dismiss(animated: true)
            }
            self.gettingRsaKey(){
                (success, object) -> () in
                DispatchQueue.main.sync {
                    if success {
                        let encAmtVal : String = self.encyptAmtDetails(data: object as! Data)
                        if(encAmtVal.isEmpty){
                            self.sendFailure(code: "ERROR_GENERAL",message: "Encryption Failed !!!")
                        }else{
                            controller.encStr = self.getEncryptedParams(encAmtVal: encAmtVal)
                            if #available(iOS 13, *) {
                                controller.modalPresentationStyle = .fullScreen
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+1.2, execute: {
                                ctx.present(controller, animated: true, completion: nil)
                            })
                        }
                    }else{
                        self.sendFailure(code: "ERROR_GENERAL",message: object as! String)
                    }
                }
            }
            
            
        }
    }
}

