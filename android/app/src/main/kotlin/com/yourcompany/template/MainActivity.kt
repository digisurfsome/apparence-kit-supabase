package com.yourcompany.template
    
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
  private val CHANNEL = "apparence_kit/advertising_id"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      if (call.method == "getAdvertisingId") {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(applicationContext)
            val advertisingId = adInfo?.id
            withContext(Dispatchers.Main) { result.success(advertisingId ?: "") }
          } catch (e: Exception) {
            withContext(Dispatchers.Main) { result.success("") }
          }
        }
      } else {
        result.notImplemented()
      }
    }
  }
}