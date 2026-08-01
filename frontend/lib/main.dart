import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/network/api_client.dart';
import 'core/network/websocket_client.dart';
import 'core/services/voice_distress_service.dart';
import 'core/services/motion_analysis_service.dart';
import 'core/services/ai_engine.dart';
import 'core/services/location_service.dart';
import 'core/services/sms_fallback_service.dart';
import 'core/services/sos_service.dart';
import 'core/services/evidence_service.dart';
import 'core/services/fake_call_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/sos_provider.dart';
import 'core/providers/location_provider.dart';
import 'core/providers/incident_provider.dart';
import 'core/providers/user_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  final storage = StorageService();
  await storage.init();

  final apiClient = ApiClient(storage: storage);
  final wsClient = WebSocketClient();

  // AI services
  final voiceService = VoiceDistressService();
  final motionService = MotionAnalysisService();
  final aiEngine = AiEngine(
    voiceService: voiceService,
    motionService: motionService,
  );

  // Location & SMS
  final locationService = LocationService();
  final smsFallback = SmsFallbackService(locationService: locationService);

  // SOS services
  final evidenceService = EvidenceService();
  final fakeCallService = FakeCallService();
  final sosService = SosService(
    apiClient: apiClient,
    wsClient: wsClient,
    locationService: locationService,
    smsFallback: smsFallback,
    evidenceService: evidenceService,
  );

  // Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            storage: storage,
          ),
        ),

        // SOS
        ChangeNotifierProvider(
          create: (_) => SosProvider(
            sosService: sosService,
            aiEngine: aiEngine,
            fakeCallService: fakeCallService,
            storage: storage,
          ),
        ),

        // Location
        ChangeNotifierProvider(
          create: (_) => LocationProvider(locationService: locationService)..initialize(),
        ),

        // Incidents
        ChangeNotifierProvider(
          create: (_) => IncidentProvider(apiClient: apiClient),
        ),

        // User
        ChangeNotifierProvider(
          create: (_) => UserProvider(apiClient: apiClient),
        ),
      ],
      child: const SafeHerApp(),
    ),
  );
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHer AI',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
