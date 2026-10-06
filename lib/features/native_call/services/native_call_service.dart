import 'package:flutter/services.dart';

import '../../../core/native_channel.dart';

/// Kotlinの単発メソッドを呼び出すサービス。
///
/// Kotlin側のエラーは[PlatformException]として投げられる。
class NativeCallService {
  NativeCallService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(nativeCallChannelName);

  final MethodChannel _channel;

  /// 端末情報を取得する。
  Future<String> getDeviceInfo() async {
    final result = await _channel.invokeMethod<String>('getDeviceInfo');
    return result ?? '(null)';
  }

  /// [name]宛ての挨拶を取得する。
  Future<String> greet(String name) async {
    final result = await _channel.invokeMethod<String>('greet', {'name': name});
    return result ?? '(null)';
  }
}
