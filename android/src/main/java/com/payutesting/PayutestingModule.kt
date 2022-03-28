package com.payutesting

import java.io.UnsupportedEncodingException
import java.net.URLEncoder
import java.net.URL

import androidx.annotation.Nullable
import android.app.Activity
import android.content.Intent
import android.content.Context
import android.util.Log
import android.widget.Toast
import org.json.JSONObject

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ActivityEventListener
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.bridge.ReadableMap
import com.payutesting.ReactNativeUtils

import okhttp3.OkHttpClient

import okhttp3.RequestBody
import okhttp3.ResponseBody
import okhttp3.FormBody



import com.payutesting.utilities.AvenuesParams
import com.payutesting.view.WebViewActivity

class PayutestingModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var promise: Promise? = null
    private var paymentData : PaymentDetails? = null
    private var billingData : BillingDetails? = null
    private var deliveryData : DeliveryDetails? = null
    private var merchantParamData : MerchantParamDetails? = null
    private var otherData : OtherDetails? = null

    private val mActivityEventListener = object:BaseActivityEventListener() {
        override fun onActivityResult(activity:Activity, requestCode:Int, resultCode:Int, data:Intent) {
            parseActivityResult(requestCode, resultCode, data)
        }
    }

    companion object {
        val REACT_CLASS = "CcavenuePayment"
        val WEBVIEW_REQUEST_CODE = 1011
        private val TAG: String = "CcavenuePaymentModule"
    }

    init {
        getReactApplicationContext().addActivityEventListener(mActivityEventListener)
    }

    override fun getName() = REACT_CLASS


    @Suppress("UNUSED_PARAMETER")
    private fun parseActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        Log.d(TAG, "parseActivityResult")
        if (requestCode == WEBVIEW_REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
            sendFailure(data.getStringExtra("ErrorType") as String,data.getStringExtra("ErrorMsg") as String)
        }else if (requestCode == WEBVIEW_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            val result : String = data.getStringExtra("result") as String
            val resultMap : WritableMap  =  WritableNativeMap()
            val arrCcavEncResponse : List<String> = result.split("&")
            for(strField in arrCcavEncResponse) {
                val arrField = strField.split("=").toTypedArray()
                resultMap.putString(arrField[0],arrField[1])
            }
            promise!!.resolve(resultMap)
        }
    }

    fun sendSuccess(message : JSONObject){
        promise!!.resolve(ReactNativeUtils.convertJsonToMap(message))
    }

    fun sendFailure(code : String,message : String){
        promise!!.reject(code, message)
    }

    fun getParamValue(paymentDetails : ReadableMap,param : String,type: String) : String? {
        if(paymentDetails.hasKey(param) && type.equals("STRING")){
            return paymentDetails.getString(param)
        }else
            return null
    }

    // Example method
    // See https://facebook.github.io/react-native/docs/native-modules-android
    @ReactMethod
    fun start() {
        this.promise = promise
        Log.e("What happened","Just Testing");
//        paymentData = PaymentDetails(
//            //paymentDetails.getString(AvenuesParams.ACCESS_CODE)!!,paymentDetails.getString(AvenuesParams.MERCHANT_ID)!!,
//            //paymentDetails.getString(AvenuesParams.ORDER_ID)!!,
//            //paymentDetails.getString(AvenuesParams.CURRENCY)!!,paymentDetails.getString(AvenuesParams.AMOUNT)!!,
//            //paymentDetails.getString(AvenuesParams.LANGUAGE)!!,paymentDetails.getString(AvenuesParams.RSA_KEY_URL)!!,
//            paymentDetails.getString(AvenuesParams.REDIRECT_URL)!!,
//            //paymentDetails.getString(AvenuesParams.CANCEL_URL)!!,
//            paymentDetails.getString(AvenuesParams.TRANS_URL)!!
//        )
//        startPayment();
            //getParamValue(paymentDetails,AvenuesParams.PAYMENT_OPTION,"STRING"))


//        billingData = BillingDetails(getParamValue(paymentDetails,AvenuesParams.BILLING_NAME,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_ADDRESS,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_CITY,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_STATE,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_ZIP,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_COUNTRY,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_TEL,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.BILLING_EMAIL,"STRING"))


//        deliveryData = DeliveryDetails(getParamValue(paymentDetails,AvenuesParams.DELIVERY_NAME,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_ADDRESS,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_CITY,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_STATE,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_ZIP,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_COUNTRY,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.DELIVERY_TEL,"STRING"))

//        merchantParamData = MerchantParamDetails(getParamValue(paymentDetails,AvenuesParams.MERCHANT_PARAM1,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.MERCHANT_PARAM2,"STRING"),getParamValue(paymentDetails,AvenuesParams.MERCHANT_PARAM3,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.MERCHANT_PARAM4,"STRING"),getParamValue(paymentDetails,AvenuesParams.MERCHANT_PARAM5,"STRING"))

//        otherData = OtherDetails(getParamValue(paymentDetails,AvenuesParams.PROMO_CODE,"STRING"),
//            getParamValue(paymentDetails,AvenuesParams.CUSTOMER_IDENTIFIER,"STRING"))


//        getRSAKey()
        }



//    fun getRSAKey() {
//        //setLoading(true)
//        val headersMap: MutableMap<String, String> = linkedMapOf()
//        headersMap.put("Content-Type","application/x-www-form-urlencoded")
//        val formBody : RequestBody  =  FormBody.Builder()
//            .addEncoded(AvenuesParams.ACCESS_CODE, paymentData?.accessCode as String)
//            .addEncoded(AvenuesParams.ORDER_ID, paymentData?.orderId as String)
//            .build()
//
//        val rsaURL : URL  = URL(paymentData?.rsaKeyUrl as String)
//        val rsaProtocol : String = rsaURL.getProtocol().plus("://")
//        val RSAKeyRequest : Call<ResponseBody> = ApiService.getCCAvenueServices(rsaProtocol.plus(rsaURL.getHost()).plus("/")).getRSAKey(paymentData?.rsaKeyUrl as String,headersMap,formBody)
//        RSAKeyRequest.enqueue(object : retrofit2.Callback<ResponseBody> {
//            override fun onResponse(call : Call<ResponseBody>,response : Response<ResponseBody>) {
//                //setLoading(false)
//                if (response.isSuccessful()) {
//                    val rsakey : String = response.body()?.string() as String
//
//                    if (!rsakey.equals("") && !rsakey.contains("!ERROR!")) {
//                        val vEncVal = StringBuilder()
//                        vEncVal.append(AvenuesParams.AMOUNT.plus("=").plus(paymentData?.amount as String))
//                        vEncVal.append("&".plus(AvenuesParams.CURRENCY).plus("=").plus(paymentData?.currency as String))
//                        val encAmtVal : String = RSAUtility.encrypt(vEncVal.substring(0, vEncVal.length), rsakey) as String
//                        startPayment(encAmtVal)
//                    }
//                } else {
//                    val byteArray = response.errorBody()?.bytes()
//                    if (byteArray != null) {
//                        Log.e(TAG, "errorBody - ${String(byteArray)}")
//                    }
//                }
//            }
//            override fun onFailure(call: Call<ResponseBody> ?, t: Throwable ?) {
//                // something went completely south (like no internet connection)
//                //setLoading(false)
//                sendFailure("ERROR_GENERAL",t!!.message.toString())
//                Log.d("Error", t.message)
//            }
//        })
//    }

//    fun addToPostParams(paramKey : String,paramValue : String?) : String{
//        if(!paramValue.isNullOrEmpty())
//            return "&".plus(paramKey).plus("=").plus(URLEncoder.encode(paramValue,"UTF-8"))
//        return ""
//    }

    fun startPayment(){
        try {
            var postData = StringBuilder()
//          //  postData.append(AvenuesParams.MERCHANT_ID.plus("=").plus(URLEncoder.encode(paymentData?.merchantId as String,"UTF-8")))
//            postData.append(addToPostParams(AvenuesParams.ACCESS_CODE, paymentData?.accessCode as String))
//            postData.append(addToPostParams(AvenuesParams.ENC_VAL, encVal))
//            postData.append(addToPostParams(AvenuesParams.ORDER_ID, paymentData?.orderId as String))
//            postData.append(addToPostParams(AvenuesParams.REDIRECT_URL, paymentData?.redirectUrl as String))
//            postData.append(addToPostParams(AvenuesParams.CANCEL_URL, paymentData?.cancelUrl as String))
//            postData.append(addToPostParams(AvenuesParams.PAYMENT_OPTION, paymentData?.paymentOption as String))
//            postData.append(addToPostParams(AvenuesParams.BILLING_NAME, billingData?.billingName))
//            postData.append(addToPostParams(AvenuesParams.BILLING_ADDRESS, billingData?.billingAddress))
//            postData.append(addToPostParams(AvenuesParams.BILLING_CITY, billingData?.billingCity))
//            postData.append(addToPostParams(AvenuesParams.BILLING_STATE, billingData?.billingState))
//            postData.append(addToPostParams(AvenuesParams.BILLING_ZIP, billingData?.billingZip))
//            postData.append(addToPostParams(AvenuesParams.BILLING_COUNTRY, billingData?.billingCountry))
//            postData.append(addToPostParams(AvenuesParams.BILLING_TEL, billingData?.billingTel))
//            postData.append(addToPostParams(AvenuesParams.BILLING_EMAIL, billingData?.billingEmail))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_NAME, deliveryData?.deliveryName))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_ADDRESS, deliveryData?.deliveryAddress))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_CITY, deliveryData?.deliveryCity))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_STATE, deliveryData?.deliveryState))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_ZIP, deliveryData?.deliveryZip))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_COUNTRY, deliveryData?.deliveryCountry))
//            postData.append(addToPostParams(AvenuesParams.DELIVERY_TEL, deliveryData?.deliveryTel))
//            postData.append(addToPostParams(AvenuesParams.MERCHANT_PARAM1, merchantParamData?.merchantParam1))
//            postData.append(addToPostParams(AvenuesParams.MERCHANT_PARAM2, merchantParamData?.merchantParam2))
//            postData.append(addToPostParams(AvenuesParams.MERCHANT_PARAM3, merchantParamData?.merchantParam3))
//            postData.append(addToPostParams(AvenuesParams.MERCHANT_PARAM4, merchantParamData?.merchantParam4))
//            postData.append(addToPostParams(AvenuesParams.MERCHANT_PARAM5, merchantParamData?.merchantParam5))
//            postData.append(addToPostParams(AvenuesParams.PROMO_CODE, otherData?.promoCode))
//            postData.append(addToPostParams(AvenuesParams.CUSTOMER_IDENTIFIER, otherData?.customerIdentifier))

            val activity : Activity = getReactApplicationContext().getCurrentActivity() as Activity
            val intent : Intent  = Intent(activity,WebViewActivity::class.java)
//            intent.putExtra(AvenuesParams.TRANS_DATA, postData.toString())
            intent.putExtra(AvenuesParams.TRANS_URL, paymentData?.transUrl as String)
            intent.putExtra(AvenuesParams.REDIRECT_URL, paymentData?.redirectUrl as String)
//            intent.putExtra(AvenuesParams.CANCEL_URL, paymentData?.cancelUrl  as String)
            intent.setFlags(0)
            activity.startActivityForResult(intent,WEBVIEW_REQUEST_CODE)

        } catch (e : UnsupportedEncodingException) {
            e.printStackTrace()
        }
    }


}