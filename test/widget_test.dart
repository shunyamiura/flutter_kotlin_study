import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kotlin/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Kotlin側の代わりにMethodChannelをモックする
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.flutter_kotlin/native'),
      (call) async {
        if (call.method == 'greet') {
          return 'こんにちは、${call.arguments['name']} さん!';
        }
        return null;
      },
    );
  });

  testWidgets('greetボタンでKotlinの結果が表示される', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('greet を呼ぶ'));
    await tester.pump();

    expect(find.textContaining('こんにちは、テスト太郎 さん'), findsOneWidget);
  });
}
