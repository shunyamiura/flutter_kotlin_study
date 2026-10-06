import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter x Kotlin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NativeCallPage(),
    );
  }
}

class NativeCallPage extends StatefulWidget {
  const NativeCallPage({super.key});

  @override
  State<NativeCallPage> createState() => _NativeCallPageState();
}

class _NativeCallPageState extends State<NativeCallPage> {
  // Kotlin側と同じチャンネル名
  static const _channel = MethodChannel('com.example.flutter_kotlin/native');

  final _nameController = TextEditingController(text: 'テスト太郎');
  String _message = 'ボタンを押してKotlinを呼び出してください';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getDeviceInfo() async {
    await _call(() => _channel.invokeMethod<String>('getDeviceInfo'));
  }

  Future<void> _greet() async {
    await _call(() => _channel.invokeMethod<String>(
          'greet',
          {'name': _nameController.text},
        ));
  }

  // 呼び出し共通処理。Kotlin側のエラーはPlatformExceptionで受け取る
  Future<void> _call(Future<String?> Function() action) async {
    try {
      final result = await action();
      setState(() => _message = result ?? '(null)');
    } on PlatformException catch (e) {
      setState(() => _message = 'エラー: ${e.code} ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter x Kotlin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名前'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _greet, child: const Text('greet を呼ぶ')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _getDeviceInfo,
              child: const Text('getDeviceInfo を呼ぶ'),
            ),
            const SizedBox(height: 24),
            Text(_message, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
