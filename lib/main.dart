import 'package:flutter/material.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/services/auth_service.dart';

// ==============================================================================
// POINT D'ENTRÉE DE L'APPLICATION
// ==============================================================================
// C'est la toute première fonction qui est exécutée quand on lance l'application
// C'est comme la porte d'entrée de notre maison numérique !
// ==============================================================================
void main() {
  runApp(const MyApp()); // Lance l'application en démarrant MyApp
}

// ==============================================================================
// WIDGET PRINCIPAL DE L'APPLICATION
// ==============================================================================
// MyApp est le widget racine, c'est lui qui configure toute l'application
// Il définit le thème, les couleurs, et quelle page afficher au démarrage
// ==============================================================================
class MyApp extends StatelessWidget {
  // Constructeur : comment créer ce widget
  const MyApp({super.key});

  // ==========================================================================
  // CONSTRUCTION DE L'APPLICATION
  // ==========================================================================
  // Cette fonction crée la structure de base de toute l'application
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // MaterialApp = le conteneur principal pour une app Flutter

      // ======================================================================
      // CONFIGURATION DE L'APPLICATION
      // ======================================================================
      
      debugShowCheckedModeBanner: false, // Cacher la bannière "Debug" en haut à droite
      title: 'SnapNote App', // Nom de l'application (visible dans le gestionnaire de tâches)
      
      // ======================================================================
      // THÈME DE L'APPLICATION
      // ======================================================================
      // Le thème définit l'apparence générale : couleurs, formes, styles...
      theme: ThemeData(
        // Adapter la densité selon la plateforme (iOS, Android, etc.)
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Style de la barre d'en-haut (AppBar)
        appBarTheme: AppBarTheme(color: Colors.black87), // Gris très foncé
        
        // Schéma de couleurs basé sur le blanc
        // seedColor = couleur de base qui génère toutes les autres couleurs
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        
        useMaterial3: true, // Utiliser la dernière version du design Material
      ),
      
      // ======================================================================
      // PAGE DE DÉMARRAGE
      // ======================================================================
      // C'est la première page qu'on voit quand on ouvre l'app
      home: SplashScreen(), // Écran de chargement (Splash Screen)
    );
  }
}

// ==============================================================================
// ÉCRAN DE CHARGEMENT (SPLASH SCREEN)
// ==============================================================================
// Cet écran s'affiche au démarrage de l'application
// Pendant ce temps, on vérifie si l'utilisateur est déjà connecté ou pas
// C'est comme un sas d'entrée qui vérifie qui tu es avant de te laisser passer !
// ==============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  // Cette fonction crée "l'état" du widget (la partie qui peut changer)
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ==============================================================================
// ÉTAT DU SPLASH SCREEN
// ==============================================================================
// Cette classe gère ce qui se passe sur l'écran de chargement
// ==============================================================================
class _SplashScreenState extends State<SplashScreen> {
  // ==========================================================================
  // SERVICE D'AUTHENTIFICATION
  // ==========================================================================
  // AuthService = un outil qui gère la connexion/déconnexion des utilisateurs
  // C'est comme un gardien qui vérifie les cartes d'identité
  final AuthService _authService = AuthService();

  // ==========================================================================
  // INITIALISATION DE LA PAGE
  // ==========================================================================
  // Cette fonction est appelée automatiquement quand la page est créée
  // C'est le moment parfait pour vérifier si quelqu'un est connecté !
  // ==========================================================================
  @override
  void initState() {
    super.initState(); // Toujours appeler cette ligne en premier
    _checkAuthStatus(); // Vérifier le statut de connexion
  }

  // ==========================================================================
  // VÉRIFIER SI UN UTILISATEUR EST CONNECTÉ
  // ==========================================================================
  // Cette fonction vérifie si quelqu'un est déjà connecté ou pas
  // Puis elle redirige vers la bonne page selon le résultat
  // ==========================================================================
  Future<void> _checkAuthStatus() async {
    // Future = une tâche qui prend du temps (comme charger des données)
    // async = cette fonction fait des choses qui prennent du temps
    // await = "attends que cette tâche soit finie avant de continuer"

    // ========================================================================
    // PETIT DÉLAI DE 2 SECONDES
    // ========================================================================
    // On attend 2 secondes pour que l'utilisateur puisse voir le logo
    // C'est plus joli qu'un écran qui change immédiatement !
    await Future.delayed(Duration(seconds: 2));

    // ========================================================================
    // CHARGER LA SESSION UTILISATEUR
    // ========================================================================
    // On demande au AuthService : "Est-ce que quelqu'un est connecté ?"
    // isLoggedIn sera true (vrai) si oui, false (faux) si non
    final isLoggedIn = await _authService.loadUserSession();

    // ========================================================================
    // REDIRECTION SELON LE STATUT
    // ========================================================================
    // mounted = vérifie que la page existe toujours (pas fermée entre temps)
    if (mounted) {
      if (isLoggedIn) {
        // ====================================================================
        // UTILISATEUR CONNECTÉ
        // ====================================================================
        // Quelqu'un est connecté → aller directement à l'accueil
        Navigator.pushReplacement(
          context, // Infos sur l'écran actuel
          MaterialPageRoute(builder: (context) => HomeScreen()),
          // pushReplacement = remplacer la page actuelle (pas de retour possible)
        );
      } else {
        // ====================================================================
        // PERSONNE N'EST CONNECTÉ
        // ====================================================================
        // Personne n'est connecté → aller à la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  // ==========================================================================
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée ce qu'on voit pendant le chargement
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold = structure de base d'une page Flutter
      
      // ======================================================================
      // COULEUR DE FOND
      // ======================================================================
      backgroundColor: Colors.white, // Fond blanc
      
      // ======================================================================
      // CONTENU DE LA PAGE
      // ======================================================================
      body: Center(
        // Center = centrer tout ce qu'il contient au milieu de l'écran
        child: Column(
          // Column = empiler les éléments verticalement
          mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
          
          children: [
            // ================================================================
            // LOGO DE L'APPLICATION
            // ================================================================
            SizedBox(
              height: 200, // Hauteur de la zone du logo
              child: Image.asset(
                "assets/images/logo.png", // Chemin vers l'image du logo
                
                // ==============================================================
                // GESTION D'ERREUR : SI L'IMAGE N'EXISTE PAS
                // ==============================================================
                // errorBuilder = que faire si l'image ne charge pas ?
                errorBuilder: (context, error, stackTrace) {
                  // Si l'image n'existe pas, on affiche une icône à la place
                  return Icon(
                    Icons.note_alt_rounded, // Icône de note
                    size: 85, // Taille de l'icône
                    color: Colors.white, // Couleur blanche
                  );
                },
              ),
            ),
            
            SizedBox(height: 40), // Espace de 40 pixels entre le logo et le spinner

            // ================================================================
            // INDICATEUR DE CHARGEMENT (SPINNER)
            // ================================================================
            // Ce petit cercle qui tourne pour montrer que ça charge !
            CircularProgressIndicator(
              // Couleur du spinner : bleu clair personnalisé
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(118, 189, 255, 100),
                // fromRGBO = créer une couleur avec Rouge, Vert, Bleu, Opacité
                // 118 = Rouge, 189 = Vert, 255 = Bleu, 100 = Opacité
              ),
              strokeWidth: 3, // Épaisseur du cercle de chargement
            ),
          ],
        ),
      ),
    );
  }
}