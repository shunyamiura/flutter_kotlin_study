package com.example.flutter_kotlin.plugins

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 単発のメソッド呼び出しを受けるプラグイン(Dart側の native_call 機能に対応)。
 *
 * 公開プラグインと同じ構造(FlutterPlugin + MethodCallHandler)で書いている。
 * 処理はすべて軽いので、メインスレッドのまま実行して問題ない。
 */
class NativeCallPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    // Engineに登録されたとき。チャンネルを作ってハンドラを設定する
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    // Engineから外れるとき。ハンドラを解除して参照を手放す
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceInfo" ->
                result.success("${Build.MANUFACTURER} ${Build.MODEL} (Android ${Build.VERSION.RELEASE})")

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

    companion object {
        // Dart側(core/native_channel.dart)と一致させる
        const val CHANNEL_NAME = "com.example.flutter_kotlin/native_call"
    }
}
