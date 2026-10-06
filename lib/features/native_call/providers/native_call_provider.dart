import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/native_call_state.dart';
import 'native_call_service_provider.dart';

/// ネイティブ呼び出しページの状態を提供する。
final nativeCallProvider =
    NotifierProvider<NativeCallNotifier, NativeCallState>(
      NativeCallNotifier.new,
    );

/// ネイティブ呼び出しページの状態を管理する。
class NativeCallNotifier extends Notifier<NativeCallState> {
  @override
  NativeCallState build() => const NativeCallState();

  /// 端末情報を取得して表示する。
  Future<void> getDeviceInfo() =>
      _call(() => ref.read(nativeCallServiceProvider).getDeviceInfo());

  /// [name]宛ての挨拶を取得して表示する。
  Future<void> greet(String name) =>
      _call(() => ref.read(nativeCallServiceProvider).greet(name));

  // 呼び出し共通処理。Kotlin側のエラーはPlatformExceptionで受け取る
  Future<void> _call(Future<String> Function() action) async {
    state = NativeCallState(message: state.message, isLoading: true);
    try {
      state = NativeCallState(message: await action());
    } on PlatformException catch (e) {
      state = NativeCallState(message: 'エラー: ${e.code} ${e.message}');
    }
  }
}
