import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/native_call_provider.dart';

/// Kotlinの単発メソッドを呼び出すページ。
class NativeCallPage extends ConsumerStatefulWidget {
  const NativeCallPage({super.key});

  @override
  ConsumerState<NativeCallPage> createState() => _NativeCallPageState();
}

class _NativeCallPageState extends ConsumerState<NativeCallPage> {
  final _nameController = TextEditingController(text: 'テスト太郎');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nativeCallProvider);
    final notifier = ref.read(nativeCallProvider.notifier);

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
            FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () => notifier.greet(_nameController.text),
              child: const Text('greet を呼ぶ'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state.isLoading ? null : notifier.getDeviceInfo,
              child: const Text('getDeviceInfo を呼ぶ'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/round-trip'),
              child: const Text('往復処理ページへ'),
            ),
            const SizedBox(height: 24),
            Text(state.message, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
