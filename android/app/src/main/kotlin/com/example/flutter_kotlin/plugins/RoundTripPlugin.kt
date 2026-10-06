package com.example.flutter_kotlin.plugins

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Flutter ⇄ Kotlin の往復処理を行うプラグイン(Dart側の round_trip 機能に対応)。
 *
 * ① Flutterから依頼を受ける
 * ② 中間値を同じチャンネルでFlutterへ渡し、**戻り値を待つ**
 * ③ Flutterが加工した値を戻り値として受け取る
 * ④ ③を加工し、①への応答として最終結果を返す
 *
 * 【スレッド】すべてメインスレッドで動く。
 * 待ち(delay や invokeMethodAwait)は suspend 関数なのでスレッドを塞がず、
 * 待っている間も画面描画やFlutterとのやり取りは止まらない。
 */
class RoundTripPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    // メインスレッド上で動くコルーチンのスコープ。Engineから外れたらキャンセルする
    private var scope: CoroutineScope? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        scope?.cancel() // 実行中の往復処理も中断する
        scope = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "runRoundTrip" -> {
                val input = call.argument<String>("input")
                if (input.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "input は必須です", null)
                    return
                }
                // ①の result は、往復が終わるまで保持する。全経路でちょうど1回だけ呼ぶ
                scope?.launch {
                    try {
                        result.success(runRoundTrip(input))
                    } catch (e: CancellationException) {
                        throw e // キャンセルはエラー扱いにしない
                    } catch (e: Exception) {
                        result.error("ROUND_TRIP_FAILED", e.message, null)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    // 往復処理の本体。上から順に読めるよう、Flutterの結果は戻り値として受け取る
    private suspend fun runRoundTrip(input: String): Map<String, String> {
        // 重い処理に見立てた待ち。sleepと違いスレッドを塞がない
        delay(1000)
        val intermediate = "${input.uppercase()} (Kotlin)"

        // ② Flutterを呼び、③の戻り値を待つ
        val flutterReply = channel!!.invokeMethodAwait(
            "onIntermediate",
            mapOf("value" to intermediate),
        )
        val reply = (flutterReply as? Map<*, *>)?.get("value") as? String
            ?: error("Flutterからの戻り値が不正です: $flutterReply")

        // ④ 受け取った値を加工して返す
        return mapOf("final" to "$reply [${reply.length}文字]")
    }

    companion object {
        // Dart側(core/native_channel.dart)と一致させる
        const val CHANNEL_NAME = "com.example.flutter_kotlin/round_trip"
    }
}
