import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/native_call_service.dart';

/// [NativeCallService]を提供する。
final nativeCallServiceProvider = Provider<NativeCallService>(
  (ref) => NativeCallService(),
);
