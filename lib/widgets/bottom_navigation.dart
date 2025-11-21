import 'package:flutter/material.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/profile_screen.dart';


/// Widget de navigation en bas de l'écran
/// Permet de naviguer entre Accueil et Profil
class BottomNavigation extends StatelessWidget {
  // Cette variable indique sur quelle page on est actuellement
  // 0 = Accueil, 1 = Profil
  final int currentIndex;

  // Constructeur : c'est comme une recette qui dit comment créer ce widget
  // On DOIT donner le currentIndex quand on crée ce widget
  const BottomNavigation({super.key, required this.currentIndex});

  // ==========================================================================
  // FONCTION POUR CHANGER DE PAGE
  // ==========================================================================
  // Cette fonction est appelée quand on clique sur un des boutons
  // Elle reçoit 2 informations :
  // - context : les infos sur l'écran actuel (comme une carte d'identité)
  // - index : le numéro du bouton cliqué (0 ou 1)
  // ==========================================================================
  void _onItemTapped(BuildContext context, int index) {
    // ========================================================================
    // VÉRIFICATION : Est-ce qu'on clique sur le bouton de la page actuelle ?
    // ========================================================================
    // Si on est déjà sur la page et qu'on re-clique dessus, on fait rien
    // Sauf si on est sur l'accueil (index 0), dans ce cas on retourne à la
    // page d'accueil principale (au cas où on serait dans une sous-page)
    if (index == currentIndex) {
      if (index == 0) {
        // On est sur Accueil et on clique sur Accueil
        // → Retourner à la page d'accueil principale
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(),
            transitionDuration: Duration.zero, // Pas d'animation
          ),
          (route) => false, // Supprimer toutes les pages précédentes
        );
      }
      return; // Arrêter la fonction ici
    }

    // ========================================================================
    // NAVIGATION VERS UNE NOUVELLE PAGE
    // ========================================================================
    // Si on arrive ici, c'est qu'on veut changer de page !
    // On regarde quel bouton a été cliqué (index 0 ou 1)

    if (index == 0) {
      // ======================================================================
      // BOUTON ACCUEIL CLIQUÉ
      // ======================================================================
      // On va vers la page d'accueil (HomeScreen)
      // pushAndRemoveUntil = aller à une page ET supprimer les pages avant
      // Pourquoi ? Pour éviter d'avoir trop de pages en mémoire
      Navigator.pushAndRemoveUntil(
        context, // Les infos sur l'écran actuel
        PageRouteBuilder(
          // PageRouteBuilder = une façon de créer une nouvelle page
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionDuration: Duration.zero, // Pas d'animation de transition
        ),
        (route) => false, // false = supprimer TOUTES les pages avant
      );
    } else if (index == 1) {
      // ======================================================================
      // BOUTON PROFIL CLIQUÉ
      // ======================================================================
      // On va vers la page de profil (ProfileScreen)
      // Même principe que pour l'accueil
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProfileScreen(),
          transitionDuration: Duration.zero, // Pas d'animation
        ),
        (route) => false, // Supprimer toutes les pages avant
      );
    }
  }

  // ==========================================================================
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée ce qu'on voit à l'écran
  // Elle est appelée automatiquement par Flutter
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      // Container = une boîte qui peut contenir d'autres éléments

      // ======================================================================
      // DÉCORATION DU CONTAINER (l'apparence de la barre)
      // ======================================================================
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond : blanc
        // Ombre sous la barre pour la faire ressortir
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Ombre noire transparente
            blurRadius: 8, // Flou de l'ombre
            offset: Offset(0, -2), // Position de l'ombre (vers le haut)
          ),
        ],
      ),

      // ======================================================================
      // SAFEAREA : ZONE SÛRE DE L'ÉCRAN
      // ======================================================================
      // SafeArea évite que notre barre soit cachée par les boutons du téléphone
      // ou l'encoche de l'écran
      child: SafeArea(
        // ====================================================================
        // 📏 PADDING : ESPACE AUTOUR DES BOUTONS
        // ====================================================================
        // On ajoute un peu d'espace autour pour que ce soit joli
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          // horizontal: 40 = 40 pixels à gauche et à droite
          // vertical: 8 = 8 pixels en haut et en bas

          // ==================================================================
          // ROW : LIGNE HORIZONTALE
          // ==================================================================
          // Row = aligner les éléments horizontalement (côte à côte)
          child: Row(
            // Distribuer l'espace également entre les boutons
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            // ================================================================
            // LES DEUX BOUTONS DE NAVIGATION
            // ================================================================
            children: [
              // ==============================================================
              // PREMIER BOUTON : ACCUEIL
              // ==============================================================
              _buildNavItem(
                context: context, // Infos sur l'écran
                icon: Icons.home_outlined, // Icône quand pas sélectionné
                activeIcon: Icons.home, // Icône quand sélectionné
                label: 'Accueil', // Texte sous l'icône
                index: 0, // Numéro du bouton (0 = premier bouton)
                isActive: currentIndex == 0, // Est-ce le bouton actif ?
              ),

              // ==============================================================
              // DEUXIÈME BOUTON : PROFIL
              // ==============================================================
              _buildNavItem(
                context: context,
                icon: Icons.person_outline, // Icône quand pas sélectionné
                activeIcon: Icons.person, // Icône quand sélectionné
                label: 'Profil', // Texte sous l'icône
                index: 1, // Numéro du bouton (1 = deuxième bouton)
                isActive: currentIndex == 1, // Est-ce le bouton actif ?
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FONCTION POUR CRÉER UN BOUTON DE NAVIGATION
  // ==========================================================================
  // Cette fonction crée un bouton avec une icône et un texte
  // On l'utilise pour créer les boutons "Accueil" et "Profil"
  // C'est comme une petite usine à boutons ! 
  // ==========================================================================
  Widget _buildNavItem({
    required BuildContext context, // Infos sur l'écran
    required IconData icon, // L'icône normale
    required IconData activeIcon, // L'icône quand c'est sélectionné
    required String label, // Le texte (ex: "Accueil")
    required int index, // Le numéro du bouton (0 ou 1)
    required bool isActive, // true = bouton actuellement sélectionné
  }) {
    // ========================================================================
    // INKWELL : RENDRE LE BOUTON CLIQUABLE
    // ========================================================================
    // InkWell = un widget qui détecte les clics et fait un petit effet visuel
    return InkWell(
      onTap: () => _onItemTapped(context, index), // Quand on clique
      borderRadius: BorderRadius.circular(12), // Coins arrondis
      // ======================================================================
      // CONTAINER : BOÎTE POUR LE CONTENU DU BOUTON
      // ======================================================================
      child: Container(
        // Espace autour du contenu
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        // ==================================================================
        // COLUMN : EMPILER L'ICÔNE ET LE TEXTE VERTICALEMENT
        // ==================================================================
        // Column = aligner les éléments verticalement (l'un au-dessus de l'autre)
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prendre le minimum d'espace
          children: [
            // ================================================================
            // ICÔNE DU BOUTON
            // ================================================================
            Icon(
              // Si le bouton est actif, on montre activeIcon, sinon icon
              isActive ? activeIcon : icon,
              size: 22, // Taille de l'icône
              // Couleur : noir si actif, gris si pas actif
              color: isActive ? Color.fromRGBO(118, 189, 255, 100) : Colors.grey[600],
            ),

            SizedBox(height: 4), // Petit espace entre l'icône et le texte
            // ================================================================
            // TEXTE DU BOUTON
            // ================================================================
            Text(
              label, // Le texte (ex: "Accueil")
              style: TextStyle(
                fontSize: 10, // Taille du texte
                // Couleur : noir si actif, gris si pas actif
                color: isActive ? Colors.black87 : Colors.grey[600],
                // Si actif : gras (bold), sinon : normal
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}