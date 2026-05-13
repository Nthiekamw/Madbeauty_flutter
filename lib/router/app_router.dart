


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login/routes/login_route.dart';
import '../features/home/screens/home_screen.dart';
import '../features/prestataire/screens/prestataire_hub_screen.dart';
import '../features/prestataire/screens/onboarding/provider_onboarding_screen.dart';
import '../features/client/screens/client_hub_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/',
        builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login',
        builder: (context, state) => const LoginRoute()),
      GoRoute(path: '/prestataire',
        builder: (context, state) => const PrestataireHubScreen()),
      GoRoute(path: '/prestataire/onboarding',
        builder: (context, state) => const ProviderOnboardingScreen()),
      GoRoute(path: '/client',
        builder: (context, state) => const ClientHubScreen()),
    ],
  );
});











































































// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../features/auth/login/routes/login_route.dart';
// import '../features/home/screens/home_screen.dart';
// import '../features/prestataire/screens/prestataire_hub_screen.dart';
// import '../features/prestataire/screens/onboarding/provider_onboarding_screen.dart';

// final goRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/',
//     routes: [
//       GoRoute(path: '/',
//         builder: (context, state) => const HomeScreen()),
//       GoRoute(path: '/login',
//         builder: (context, state) => const LoginRoute()),
//       GoRoute(path: '/prestataire',
//         builder: (context, state) => const PrestataireHubScreen()),
//       GoRoute(path: '/prestataire/onboarding',
//         builder: (context, state) => const ProviderOnboardingScreen()),
//     ],
//   );
// });

// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';

// // import '../features/auth/login/routes/login_route.dart';
// // import '../features/home/screens/home_screen.dart';
// // import '../features/prestataire/screens/prestataire_hub_screen.dart';

// // final goRouterProvider = Provider<GoRouter>((ref) {
// //   return GoRouter(
// //     initialLocation: '/',
// //     routes: [
// //       GoRoute(
// //         path: '/',
// //         builder: (context, state) => const HomeScreen(),
// //       ),
// //       GoRoute(
// //         path: '/login',
// //         builder: (context, state) => const LoginRoute(),
// //       ),
// //       GoRoute(
// //         path: '/prestataire',
// //         builder: (context, state) => const PrestataireHubScreen(),
// //       ),
// //     ],
// //   );
// // });
