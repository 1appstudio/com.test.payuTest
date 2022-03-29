package com.payutesting

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.facebook.react.bridge.*
import com.payutesting.view.WebViewActivity
import org.json.JSONObject
import java.io.UnsupportedEncodingException

class PayutestingModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var promise: Promise? = null
    private val TAG: String = "Payutestingmodule"
    val WEBVIEW_REQUEST_CODE = 1011

    override fun getName(): String {
        return "Payutesting"
    }


    private val mActivityEventListener = object:BaseActivityEventListener() {
        override fun onActivityResult(activity: Activity, requestCode:Int, resultCode:Int, data:Intent) {
            Log.e("Called Activity Result","...");
            parseActivityResult(requestCode, resultCode, data)
        }
    }

    init {
        getReactApplicationContext().addActivityEventListener(mActivityEventListener)
    }

    @Suppress("UNUSED_PARAMETER")
    private fun parseActivityResult(requestCode: Int, resultCode: Int, data: Intent) {

        try{
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
        }catch(e: Exception){
            sendFailure(data.getStringExtra("ErrorType") as String,data.getStringExtra("ErrorMsg") as String)
        }

    }

    fun sendSuccess(message : JSONObject){
        Log.e("Message",""+message.toString());
        promise!!.resolve(ReactNativeUtils.convertJsonToMap(message))
    }

    fun sendFailure(code : String,message : String){
        promise!!.reject(code, message)
    }

    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    fun multiply(a: Int, b: Int, promise: Promise) {
    
      promise.resolve(a * b)
    
    }

    @ReactMethod
    fun start(paymentDetails:ReadableMap, promise: Promise) {
        this.promise = promise
        Log.e("Open Url: ",""+paymentDetails.getString("trans_url"));
        try {
            val activity : Activity = getReactApplicationContext().getCurrentActivity() as Activity
            val intent : Intent  = Intent(activity,WebViewActivity::class.java)
            intent.putExtra("trans_url", paymentDetails.getString("trans_url"))
            intent.putExtra("redirect_url", paymentDetails.getString("redirect_url"))
            intent.setFlags(0)
            activity.startActivityForResult(intent,WEBVIEW_REQUEST_CODE)

        } catch (e : UnsupportedEncodingException) {
            e.printStackTrace()
        }
    }
}
