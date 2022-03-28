//
//  CCWebViewController.swift
//  payutesting
//
//  Created by JK on 28/03/22.
//

import Foundation
//
//  CCWebViewController.swift
//

import UIKit
import Foundation
import WebKit

/**
 * class: CCWebViewController
 * CCWebViewController is responsible for to take all the values from the merchant and process futher for the payment
 * We will generate the RSA Key for this transaction first by using access code of the merchant and the unique order id for this transaction
 * After generating Successful RSA Key we will use that key for encrypting amount and currency and the encrypted details will use for intiate the transaction
 */
class CCWebViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {
    var paymentData : PaymentDetails?
    static var statusCode = 0//zero means success or else error in encrption with rsa
    var encStr = String()
    var isHere = false
    var callback : ((ResponseData) -> Void)?
    
    private var notification: NSObjectProtocol?
    
    lazy var viewWeb: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 72, width: view.frame.width, height: view.frame.height), configuration: webConfiguration)
        webView.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        //webView.scalesPageToFit = true
        webView.contentMode = UIView.ContentMode.scaleAspectFill
        webView.tag = 1011
        
        
        return webView
    }()
    
    var request: NSMutableURLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewWeb.navigationDelegate = self
        setupWebView()
        notification = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {
            [unowned self] notification in
            self.checkResponseUrl()
        }
    }
    
    deinit {
        if let notification = notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
    
    fileprivate func checkResponseUrl(){
        let string = (viewWeb.url?.absoluteString)!
        print("String :: \(string)")
        if(string.contains(paymentData!.redirectUrl))
        {
            viewWeb.evaluateJavaScript("document.getElementById('result').value"){ (result, error) in
                if error != nil {
                   let ccavResponse = result as! String
                   print("html :: ",ccavResponse)
                   var responseDict = [String: Any]()
                   let arrCcavEncResponse:[String] = ccavResponse.components(separatedBy: "&")
                   for strField in arrCcavEncResponse {
                       let arrField = strField.components(separatedBy:"=")
                       responseDict[arrField[0]] = arrField[1]
                   }
                    
                   self.callback!(ResponseData(action: ResponseAction.OK, msg: responseDict))
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isHere {
            isHere = true
            self.startTransaction()
        }
    }
    
    
    private func startTransaction() {
         NSLog("START TRANSACTION", ""+paymentData!.transUrl)
         do{
            CCWebViewController.statusCode = 0
            //Preparing for webview call
            if CCWebViewController.statusCode == 0{
                CCWebViewController.statusCode = 1
                let encryptedStr = encStr
                let myRequestData = encryptedStr.data(using: String.Encoding.utf8)
                
                request  = NSMutableURLRequest(url: URL(string: paymentData!.transUrl)! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
                request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
                request?.setValue(paymentData!.transUrl, forHTTPHeaderField: "Referer")
                request?.httpMethod = "POST"
                request?.httpBody = myRequestData
                self.viewWeb.load(self.request! as URLRequest)
            }
            else{
                self.callback!(ResponseData(errorType:"ERROR_GENERAL", errorMsg : "Unable to create requestURL", action: ResponseAction.CANCEL))
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        LoadingOverlay.shared.showOverlay(view: self.view)
    }
    
    //MARK:
    //MARK: setupWebView
    
    private func setupWebView(){
        //setup webview
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 30, width: view.frame.width, height: 72)
        let title = UIBarButtonItem(title: "CCAvenue Payment", style: .done, target: nil, action: nil)
        let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onWebViewExit))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        title.tintColor = UIColor.gray
        close.tintColor = UIColor.black
        toolbar.setItems([title,space,close], animated: true)
        toolbar.barTintColor = UIColor.white
        toolbar.barStyle = UIBarStyle.blackTranslucent
        toolbar.sizeToFit()
        view.addSubview(toolbar)
        view.addSubview(viewWeb)
    }
    
    @objc func onWebViewExit(button: UIButton) {
        //TODO: Destroy the tab. Remove the new tab from the current window or controller.
        let refreshAlert = UIAlertController(title: "CCAvenue", message: "Are you sure to Cancel this transaction ?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
              self.callback!(ResponseData(errorType:"ERROR_USER_CANCELLED", errorMsg : "User Cancelled", action: ResponseAction.CANCEL))
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        present(refreshAlert, animated: true, completion: nil)
        
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nserror = error as NSError
        switch nserror.code{
            case NSURLErrorNetworkConnectionLost:
                self.callback!(ResponseData(errorType:"ERROR_NETWORK", errorMsg : "No Network Connection", action: ResponseAction.CANCEL))
                break
            default:
                self.callback!(ResponseData(errorType:"ERROR_GENERAL", errorMsg : nserror.localizedDescription, action: ResponseAction.CANCEL))
                break
        }
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingOverlay.shared.hideOverlayView()
        let string = (webView.url?.absoluteString)!
        if(string.contains(paymentData!.redirectUrl))
        {
            webView.evaluateJavaScript("document.getElementById('result').value"){ (result, error) in
                let ccavResponse = result as! String
                if (ccavResponse != nil && !ccavResponse.isEmpty) {
                   print("html :: ",ccavResponse)
                   var responseDict = [String: Any]()
                   let arrCcavEncResponse:[String] = ccavResponse.components(separatedBy: "&")
                   for strField in arrCcavEncResponse {
                       let arrField = strField.components(separatedBy:"=")
                       responseDict[arrField[0]] = arrField[1]
                   }
                   self.callback!(ResponseData(action: ResponseAction.OK, msg: responseDict))
                  
                }else{
                    self.callback!(ResponseData(errorType:"ERROR_GENERAL", errorMsg : "Failure in Response!!!", action: ResponseAction.CANCEL))
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

