import 'package:flutter/services.dart';
import 'package:flutter_kotlin/core/native_channel.dart';
import 'package:flutter_kotlin/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(nativeCallChannelName);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  testWidgets('greetボタンでKotlinの結果が表示される', (tester) async {
    // Kotlin側の代わりにMethodChannelをモックする
    messenger.setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'greet') {
        return 'こんにちは、${call.arguments['name']} さん!';
      }
      return null;
    });

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('greet を呼ぶ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('こんにちは、テスト太郎 さん'), findsOneWidget);
  });

  testWidgets('Kotlinがエラーを返すとエラー内容が表示される', (tester) async {
    messenger.setMockMethodCallHandler(_channel, (call) async {
      throw PlatformException(code: 'INVALID_ARGUMENT', message: 'name は必須です');
    });

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('greet を呼ぶ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('INVALID_ARGUMENT'), findsOneWidget);
  });
}
