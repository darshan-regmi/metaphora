import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:metaphora/screens/auth/login_screen.dart';
import 'package:metaphora/screens/main_navigation_screen.dart';
import 'package:metaphora/screens/splash_screen.dart';
import 'package:metaphora/theme/app_theme.dart';
import 'package:metaphora/theme/theme_provider.dart';
import 'package:metaphora/services/app_initializer.dart';
import 'package:metaphora/services/offline_service.dart';
import 'package:metaphora/widgets/error_screens.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize app services and configurations
    await AppInitializer.initialize();
    
    // Initialize Google Fonts
    await GoogleFonts.pendingFonts([
      GoogleFonts.playfairDisplay(),
      GoogleFonts.merriweather(),
      GoogleFonts.montserrat(),
    ]);
    
    // Start connectivity monitoring
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Sync pending actions when connection is restored
        OfflineService().syncPendingActions();
      }
    });
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error starting app: $e');
    // Show error screen if initialization fails
    runApp(MaterialApp(
      home: ErrorScreen(
        title: 'Startup Error',
        message: 'Unable to start the app. Please try again.',
        onRetry: () => main(),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        StreamProvider<ConnectivityResult>.value(
          value: Connectivity().onConnectivityChanged.cast<ConnectivityResult>(),
          initialData: ConnectivityResult.none,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Metaphora',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.initialize();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }
    
    final authController = Provider.of<AuthController>(context);
    
    if (authController.isAuthenticated) {
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}
