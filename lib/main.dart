import 'package:flutter/material.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/services/auth_service.dart';

/// Point d'entrée de l'application
void main() {
  runApp(const MyApp());
}

/// Widget principal de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Cacher la bannière "Debug"
      debugShowCheckedModeBanner: false,
      title: 'SnapNote App',
      // Thème de l'application
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(color: Colors.black87),
        // Couleur principale verte
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      // Page de démarrage
      home: SplashScreen(),
    );
  }
}

/// Écran de démarrage (Splash Screen)
/// Vérifie si un utilisateur est connecté et redirige vers la bonne page
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Service d'authentification
  final AuthService _authService = AuthService();

  /// Fonction appelée quand la page est créée
  @override
  void initState() {
    super.initState();
    // Vérifier le statut de connexion
    _checkAuthStatus();
  }

  /// Vérifier si un utilisateur est connecté
  Future<void> _checkAuthStatus() async {
    // Petit délai pour afficher le splash screen
    await Future.delayed(Duration(seconds: 2));

    // Charger la session utilisateur
    final isLoggedIn = await _authService.loadUserSession();

    // Vérifier que le widget existe toujours
    if (mounted) {
      if (isLoggedIn) {
        // Utilisateur connecté → aller à l'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Pas connecté → aller à la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond vert
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            SizedBox(
              height: 200,
              child: Image.asset(
                "assets/images/logo.png",
                errorBuilder: (context, error, stackTrace) {
                  // Si l'image n'existe pas, afficher une icône
                  return Icon(
                    Icons.note_alt_rounded,
                    size: 85,
                    color: Colors.white,
                  );
                },
              ),
            ),
            SizedBox(height: 40),

            // Indicateur de chargement
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(118,189,255,100),),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
