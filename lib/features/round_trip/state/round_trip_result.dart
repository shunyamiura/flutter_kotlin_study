/// 往復処理の結果。
///
/// 画面には各ステップの経過と最終結果を表示する。
class RoundTripResult {
  const RoundTripResult({required this.steps, required this.finalMessage});

  /// 往復の経過ログ。
  final List<String> steps;

  /// Kotlinが最後に返したメッセージ。
  final String finalMessage;
}
