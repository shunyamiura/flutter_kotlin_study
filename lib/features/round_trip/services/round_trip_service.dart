import 'package:flutter/services.dart';

import '../../../core/native_channel.dart';
import '../state/round_trip_result.dart';

/// Kotlinとの往復処理を担当するサービス。
///
/// MethodChannelは双方向なので、同じチャンネルで次の両方を扱う。
/// - Dart → Kotlin: `runRoundTrip` を呼ぶ
/// - Kotlin → Dart: `onIntermediate` を呼ばれる(`setMethodCallHandler`で受ける)
class RoundTripService {
  RoundTripService({
    MethodChannel? channel,
    this.flutterDelay = const Duration(milliseconds: 500),
  }) : _channel = channel ?? const MethodChannel(roundTripChannelName) {
    // Kotlinからの呼び出しを受けるハンドラを登録する
    _channel.setMethodCallHandler(_onKotlinCall);
  }

  final MethodChannel _channel;

  /// Flutter側の「何かしらの処理」に見立てた待ち時間。
  ///
  /// テストで短縮できるよう注入可能にしている。
  final Duration flutterDelay;

  // 実行中の経過ログ。同時実行はUI側のボタン無効化で防ぐ
  var _steps = <String>[];

  /// ① Kotlinへ処理を依頼し、④の最終結果を待つ。
  Future<RoundTripResult> run(String input) async {
    _steps = ['① Flutter → Kotlin: 「$input」を送信'];

    // ②③の往復が終わるまで、この Future は完了しない
    final result = await _channel.invokeMapMethod<String, Object?>(
      'runRoundTrip',
      {'input': input},
    );

    final finalMessage = result?['final'] as String?;
    if (finalMessage == null) {
      throw StateError('Kotlinから最終結果が返りませんでした');
    }
    _steps.add('④ Kotlin → Flutter: 最終結果「$finalMessage」を返却');

    return RoundTripResult(
      steps: List.unmodifiable(_steps),
      finalMessage: finalMessage,
    );
  }

  /// ②③ Kotlinからの呼び出しを受け、加工して返す。
  Future<Object?> _onKotlinCall(MethodCall call) async {
    switch (call.method) {
      case 'onIntermediate':
        final value = (call.arguments as Map)['value'] as String;
        _steps.add('② Kotlin → Flutter: 「$value」を受信');

        // Flutter側の非同期処理に見立てて待つ
        await Future<void>.delayed(flutterDelay);
        final reply = String.fromCharCodes(value.runes.toList().reversed);

        _steps.add('③ Flutter → Kotlin: 反転して「$reply」を返却');
        // 戻り値がそのままKotlin側の Result.success に渡る
        return {'value': reply};
      default:
        // Kotlin側には notImplemented として伝わる
        throw MissingPluginException('未対応のメソッド: ${call.method}');
    }
  }

  /// Kotlinからの呼び出しの受け付けを終了する。
  void dispose() => _channel.setMethodCallHandler(null);
}
