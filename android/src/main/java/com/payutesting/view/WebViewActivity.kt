package com.payutesting.view

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.view.View
import android.webkit.*
import android.widget.Toast
import android.util.Log

import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDialog
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.payutesting.R
import com.payutesting.utilities.NetworkUtils
import com.payutesting.utilities.AvenuesParams

import kotlinx.android.synthetic.main.activity_webview.*

class WebViewActivity : AppCompatActivity() {

    private val networkUtils = NetworkUtils()
    private var transactionData : String? = null
    private var transactionURL : String? = null
    private var returnURL : String? = null
    private var cancelURL : String? = null
    private var intentWithResult : Intent  = Intent()

    companion object {
        private val TAG: String = "WebViewActivity"
    }

    override fun onStart() {
        super.onStart()

        LocalBroadcastManager.getInstance(this).registerReceiver(
            mNotificationReceiverInternet,
            IntentFilter(getString(R.string.keySendInternetStatus))
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_webview)

        val webViewIntent : Intent = getIntent()
        transactionURL = webViewIntent.getStringExtra("paymenturl")


        
        if (networkUtils.haveNetworkConnection(this@WebViewActivity)) {
            loadWeb(transactionURL!!)
        } else {
            imgv_network_error.setVisibility(View.GONE)
            webView.setVisibility(View.VISIBLE)
            overlayView.visibility = View.VISIBLE
            sendErrorMessage("ERROR_NETWORK","No Network Connection")
        }
    }

    /**
     */
    @SuppressLint("SetJavaScriptEnabled", "AddJavascriptInterface", "ClickableViewAccessibility")
    private fun loadWeb(url: String) {
        val webSettings = webView.getSettings()
        webSettings.setJavaScriptEnabled(true)
        webSettings.setBuiltInZoomControls(false)
        webView.setWebViewClient(myWebClient())
        webView.addJavascriptInterface(JavaScriptHandler(), "HTMLOUT")
        try {
            transactionData?.toByteArray()?.let { webView.postUrl(url, it) }
        } catch (e: Exception) {
            sendErrorMessage("ERROR_GENERAL",e.message as String)
        }
    }

    /**
     *
     */
    inner class myWebClient : WebViewClient() {
        override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
            if (networkUtils.haveNetworkConnection(this@WebViewActivity)) {
                imgv_network_error.setVisibility(View.GONE)
                webView.setVisibility(View.VISIBLE)
                overlayView.visibility = View.VISIBLE
                super.onPageStarted(view, url, favicon)
            } else {
                webView.setVisibility(View.GONE)
                imgv_network_error.setVisibility(View.VISIBLE)
                overlayView.visibility = View.VISIBLE
                sendErrorMessage("ERROR_NETWORK","No Network Connection")
            }
        }

        override fun onPageFinished(view: WebView, url: String) {
            if (networkUtils.haveNetworkConnection(this@WebViewActivity)) {
                webView.setVisibility(View.VISIBLE)
                overlayView.visibility = View.GONE
                if (url.indexOf(returnURL as String) != -1) {
                    webView.loadUrl("javascript:window.HTMLOUT.processData(document.getElementById('result').value);");
                }
                super.onPageFinished(view, url)
            }else
                sendErrorMessage("ERROR_NETWORK","No Network Connection")
        }

        override fun onReceivedError(view: WebView, request: WebResourceRequest, error: WebResourceError) {
            try {
                webView.setVisibility(View.GONE)
                imgv_network_error.setVisibility(View.VISIBLE)
                overlayView.visibility = View.VISIBLE
            } catch (e: Exception) {
                sendErrorMessage("ERROR_GENERAL",e.message as String)
            }

        }
    }


    inner class JavaScriptHandler internal constructor() {
        @JavascriptInterface
        fun processData(result: String) {
            Log.d(TAG, result)
            intentWithResult.putExtra("result", result)
            setResult(RESULT_OK, intentWithResult)
            finish()
        }
    }

    /**
     * Back press callback onBackPressed
     */
    override fun onBackPressed() {
        generalDailog("CCAvenue", "Are you sure you want to quit?")
    }

    /**
     * Back Press Alert Dialog
     */
    fun generalDailog(title: String, message: String) {
        try {
            val builder = AlertDialog.Builder(this@WebViewActivity)

            builder.setTitle(title)
            builder.setMessage(message)
            builder.setCancelable(false)
            builder.setPositiveButton("YES") { _, _ ->
                try {
                    sendErrorMessage("ERROR_USER_CANCELLED","User Cancelled Transaction")
                } catch (e: Exception) {
                    sendErrorMessage("ERROR_GENERAL",e.message as String)
                }
            }
            builder.setNegativeButton("No") { dialog, _ ->
                dialog.cancel()
            }
            val dialog: AlertDialog = builder.create()
            dialog.show()
        } catch (e: Exception) {
            sendErrorMessage("ERROR_GENERAL",e.message as String)
        }
    }

    fun sendErrorMessage(errorType : String,errorMsg : String){
        intentWithResult.putExtra("ErrorType",errorType )
        intentWithResult.putExtra("ErrorMsg",errorMsg)
        setResult(RESULT_CANCELED,intentWithResult)
        finish()
    }


    
     
    private val mNotificationReceiverInternet = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {

            if (intent != null && intent.extras != null && !intent.extras!!.isEmpty) {
                if (!intent.getBooleanExtra("isConnected", false)) {
                    showToast("No Internet Connection")
                    sendErrorMessage("ERROR_NETWORK","No Network Connection")
                }
            }
        }
    }

    private fun unRegisterListener(){
         try {
            LocalBroadcastManager.getInstance(this).unregisterReceiver(mNotificationReceiverInternet)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     */
    private fun showToast(text: String) {
        Toast.makeText(this, text, Toast.LENGTH_LONG).show()
    }

    

    /**
     *
     */
    override fun onDestroy() {
        unRegisterListener()
        super.onDestroy()
    }

}