import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_kotlin/core/native_channel.dart';
import 'package:flutter_kotlin/features/round_trip/services/round_trip_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(roundTripChannelName);
const _codec = StandardMethodCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  test('往復処理: Kotlinからの呼び出しをFlutterが加工して返し、最終結果を得る', () async {
    // Kotlin側のモック。実機と同じく「②Flutterを逆呼び出し → ③結果を加工 → ④返す」を再現する
    messenger.setMockMethodCallHandler(_channel, (call) async {
      expect(call.method, 'runRoundTrip');
      final input = call.arguments['input'] as String;

      // Kotlin → Dart の呼び出しをシミュレートし、Dartハンドラの戻り値を受け取る
      final completer = Completer<ByteData?>();
      messenger.handlePlatformMessage(
        roundTripChannelName,
        _codec.encodeMethodCall(
          MethodCall('onIntermediate', {
            'value': '${input.toUpperCase()} (Kotlin)',
          }),
        ),
        completer.complete,
      );
      final reply = _codec.decodeEnvelope((await completer.future)!) as Map;

      return {'final': '${reply['value']} [最終]'};
    });

    final service = RoundTripService(flutterDelay: Duration.zero);
    addTearDown(service.dispose);

    final result = await service.run('ab');

    // 'AB (Kotlin)' をFlutterが反転 → ')niltoK( BA' をKotlinが加工
    expect(result.finalMessage, ')niltoK( BA [最終]');
    expect(result.steps, hasLength(4));
  });
}
