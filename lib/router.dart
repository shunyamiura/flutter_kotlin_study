import 'package:go_router/go_router.dart';

import 'features/native_call/pages/native_call_page.dart';
import 'features/round_trip/pages/round_trip_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const NativeCallPage()),
    GoRoute(
      path: '/round-trip',
      builder: (context, state) => const RoundTripPage(),
    ),
  ],
);
