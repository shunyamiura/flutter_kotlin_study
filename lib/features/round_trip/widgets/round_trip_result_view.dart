import 'package:flutter/material.dart';

import '../state/round_trip_result.dart';

/// 往復処理の最終結果と経過を表示する。
class RoundTripResultView extends StatelessWidget {
  const RoundTripResultView({required this.result, super.key});

  final RoundTripResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('⑤ 最終結果', style: textTheme.titleSmall),
        Text(result.finalMessage, style: textTheme.titleLarge),
        const Divider(height: 32),
        Text('経過', style: textTheme.titleSmall),
        for (final step in result.steps) Text(step),
      ],
    );
  }
}
