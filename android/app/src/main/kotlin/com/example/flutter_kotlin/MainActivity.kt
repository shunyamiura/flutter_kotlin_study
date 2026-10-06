package com.example.flutter_kotlin

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Dart側と同じチャンネル名を使う
    private val channelName = "com.example.flutter_kotlin/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 引数なし: 端末情報を返す
                    "getDeviceInfo" -> {
                        result.success("${Build.MANUFACTURER} ${Build.MODEL} (Android ${Build.VERSION.RELEASE})")
                    }
                    // 引数あり: 名前を受け取って挨拶を返す
                    "greet" -> {
                        val name = call.argument<String>("name")
                        if (name.isNullOrBlank()) {
                            result.error("INVALID_ARGUMENT", "name は必須です", null)
                        } else {
                            result.success("こんにちは、$name さん!Kotlinからです")
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
