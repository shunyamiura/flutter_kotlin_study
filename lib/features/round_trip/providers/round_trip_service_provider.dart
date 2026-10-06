import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/round_trip_service.dart';

/// [RoundTripService]を提供する。破棄時にチャンネルのハンドラを解除する。
final roundTripServiceProvider = Provider.autoDispose<RoundTripService>((ref) {
  final service = RoundTripService();
  ref.onDispose(service.dispose);
  return service;
});
