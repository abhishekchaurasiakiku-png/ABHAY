import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../features/sos/fake_call_screen.dart';
import '../../features/sos/live_tracking_screen.dart';
import '../../features/maps/safe_route_screen.dart';

/// GoRouter configuration with auth guards.
class AppRouter {
  static GoRouter create({required bool isAuthenticated, required bool isOnboarded}) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAtLogin = state.matchedLocation == '/login';
        final isAtRegister = state.matchedLocation == '/register';
        final isAtOnboarding = state.matchedLocation == '/onboarding';
        final isAtSplash = state.matchedLocation == '/';

        if (!isAuthenticated && !isAtLogin && !isAtRegister && !isAtSplash) {
          return '/login';
        }

        if (isAuthenticated && !isOnboarded && !isAtOnboarding) {
          return '/onboarding';
        }

        if (isAuthenticated && isOnboarded && (isAtLogin || isAtRegister || isAtSplash)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/fake-call',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            return FakeCallScreen(
              callerName: extra?['callerName'] ?? 'Mom',
              callerNumber: extra?['callerNumber'] ?? '+91 98765 43210',
            );
          },
        ),
        GoRoute(
          path: '/live-tracking',
          builder: (context, state) => const LiveTrackingScreen(),
        ),
        GoRoute(
          path: '/safe-route',
          builder: (context, state) => const SafeRouteScreen(),
        ),
      ],
    );
  }
}
