import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/round_trip_result.dart';
import 'round_trip_service_provider.dart';

/// 往復処理の状態(未実行 / 実行中 / 結果 / エラー)を提供する。
final roundTripProvider =
    AsyncNotifierProvider<RoundTripNotifier, RoundTripResult?>(
      RoundTripNotifier.new,
    );

/// 往復処理の状態を管理する。
///
/// 状態が`null`のときは未実行を表す。
class RoundTripNotifier extends AsyncNotifier<RoundTripResult?> {
  @override
  FutureOr<RoundTripResult?> build() {
    // autoDisposeのProviderは、watchされていないと実行直後に破棄される。
    // 破棄されるとKotlinからの呼び出しを受けるハンドラも解除され、
    // Kotlin側が返事を待ち続けて止まってしまう。
    // そのためNotifierが生きている間は、サービスもwatchして生かしておく
    ref.watch(roundTripServiceProvider);
    return null;
  }

  /// [input]を使って往復処理を実行する。
  Future<void> run(String input) async {
    state = const AsyncLoading();
    // PlatformExceptionなどはAsyncErrorとして状態に入る
    state = await AsyncValue.guard(
      () => ref.read(roundTripServiceProvider).run(input),
    );
  }
}
