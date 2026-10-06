/// ネイティブ呼び出しページの状態。
class NativeCallState {
  const NativeCallState({
    this.message = 'ボタンを押してKotlinを呼び出してください',
    this.isLoading = false,
  });

  /// 画面に表示するメッセージ(Kotlinからの結果またはエラー)。
  final String message;

  /// Kotlinの呼び出し中かどうか。
  final bool isLoading;
}
