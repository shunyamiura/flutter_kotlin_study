package com.example.flutter_kotlin

import com.example.flutter_kotlin.plugins.NativeCallPlugin
import com.example.flutter_kotlin.plugins.RoundTripPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 公開プラグインはGeneratedPluginRegistrantが登録してくれる。
        // アプリ内に置いた自作プラグインは、ここで手動登録する
        flutterEngine.plugins.add(NativeCallPlugin())
        flutterEngine.plugins.add(RoundTripPlugin())
    }
}
