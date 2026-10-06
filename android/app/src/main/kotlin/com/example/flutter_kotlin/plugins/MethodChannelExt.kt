package com.example.flutter_kotlin.plugins

import io.flutter.plugin.common.MethodChannel
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine

/** Flutter側の処理がエラーを返したときに投げる例外。 */
class FlutterCallException(val code: String, message: String?) :
    Exception("Flutter側でエラー: $code $message")

/**
 * [MethodChannel.invokeMethod] を suspend 関数として使えるようにする。
 *
 * 通常の invokeMethod は Result のコールバックで結果を受け取るが、
 * これを使うと「戻り値を待って、続きの処理を書く」ことができる。
 *
 *     val reply = channel.invokeMethodAwait("onIntermediate", args)
 *
 * 待っている間もスレッドは塞がらない(メインスレッドのまま他の処理が動く)。
 * 呼び出しはメインスレッドで行うこと。
 */
suspend fun MethodChannel.invokeMethodAwait(method: String, arguments: Any?): Any? =
    suspendCancellableCoroutine { continuation ->
        invokeMethod(
            method,
            arguments,
            object : MethodChannel.Result {
                override fun success(result: Any?) = continuation.resume(result)

                override fun error(code: String, message: String?, details: Any?) =
                    continuation.resumeWithException(FlutterCallException(code, message))

                override fun notImplemented() =
                    continuation.resumeWithException(
                        FlutterCallException("NOT_IMPLEMENTED", "Flutter側にハンドラがありません"),
                    )
            },
        )
    }
