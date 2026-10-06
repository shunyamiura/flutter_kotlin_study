import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/round_trip_provider.dart';
import '../widgets/round_trip_result_view.dart';

/// Flutter ⇄ Kotlin の往復処理を試すページ。
class RoundTripPage extends ConsumerStatefulWidget {
  const RoundTripPage({super.key});

  @override
  ConsumerState<RoundTripPage> createState() => _RoundTripPageState();
}

class _RoundTripPageState extends ConsumerState<RoundTripPage> {
  final _inputController = TextEditingController(text: 'hello');

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roundTripProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('往復処理 (Flutter ⇄ Kotlin)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(labelText: '入力'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              // 実行中は二重実行を防ぐ
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(roundTripProvider.notifier)
                        .run(_inputController.text),
              child: const Text('往復処理を実行'),
            ),
            const SizedBox(height: 24),
            // ⑤ 受け取った結果を表示する
            state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('エラー: $error'),
              data: (result) => result == null
                  ? const Text('未実行です')
                  : RoundTripResultView(result: result),
            ),
          ],
        ),
      ),
    );
  }
}
