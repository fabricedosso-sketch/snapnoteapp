import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/screens/add_edit_screen.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

// ==============================================================================
// PAGE D'AFFICHAGE DÉTAILLÉ D'UNE NOTE
// ==============================================================================
// Cette page montre une note en grand avec tous ses détails
// L'utilisateur peut lire, modifier ou supprimer la note
// C'est comme ouvrir un document pour le consulter entièrement !
// ==============================================================================
class ViewNoteScreen extends StatelessWidget {
  // ==========================================================================
  // LA NOTE À AFFICHER
  // ==========================================================================
  // Cette variable contient toutes les informations de la note
  // (titre, contenu, couleur, date, etc.)
  final Note note;

  // Constructeur : on DOIT fournir une note pour créer cette page
  ViewNoteScreen({required this.note});

  // ==========================================================================
  // ACCÈS À LA BASE DE DONNÉES
  // ==========================================================================
  // On crée une instance de DatabaseHelper pour pouvoir
  // modifier ou supprimer la note dans la base de données
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ==========================================================================
  // FORMATER UNE DATE POUR L'AFFICHAGE
  // ==========================================================================
  // Cette fonction transforme une date en texte lisible
  // Par exemple : "2024-03-15 14:30:00" devient "Aujourd'hui, 14:30"
  // ou "15/03/2024, 14:30" selon la date
  // ==========================================================================
  String _formatDateTime(String dateTime) {
    // ========================================================================
    // CONVERTIR LE TEXTE EN OBJET DATE
    // ========================================================================
    // DateTime.parse() transforme un texte en objet DateTime qu'on peut manipuler
    final DateTime dt = DateTime.parse(dateTime);
    final now = DateTime.now(); // La date et l'heure actuelles

    // ========================================================================
    // VÉRIFIER SI C'EST AUJOURD'HUI
    // ========================================================================
    // On compare l'année, le mois et le jour
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      // C'est aujourd'hui ! On affiche juste l'heure
      // padLeft(2, '0') = ajouter un zéro devant si nécessaire (ex: 9 devient 09)
      return 'Aujourd\'hui, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    // ========================================================================
    // SINON, AFFICHER LA DATE COMPLÈTE
    // ========================================================================
    // Format : jour/mois/année, heure:minute
    return '${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ==========================================================================
  // AFFICHER LA BOÎTE DE DIALOGUE DE CONFIRMATION
  // ==========================================================================
  // Cette fonction montre une popup qui demande à l'utilisateur
  // de confirmer qu'il veut vraiment supprimer la note
  // C'est une sécurité pour éviter les suppressions accidentelles !
  // ==========================================================================
  Future<void> _showDeleteDialog(BuildContext context) async {
    // ========================================================================
    // AFFICHER LA BOÎTE DE DIALOGUE
    // ========================================================================
    // showDialog() affiche une popup par-dessus l'écran actuel
    // Elle retourne true si on clique sur "Supprimer", false si on annule
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Forme de la boîte avec coins arrondis
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        
        // ====================================================================
        // TITRE DE LA POPUP
        // ====================================================================
        title: Text(
          "Supprimer la note",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        
        // ====================================================================
        // MESSAGE DE CONFIRMATION
        // ====================================================================
        content: Text(
          "Es-tu sûr de vouloir supprimer cette note ?",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        
        // ====================================================================
        // BOUTONS D'ACTION
        // ====================================================================
        actions: [
          // ==================================================================
          // BOUTON ANNULER
          // ==================================================================
          // Ferme la popup sans rien faire
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Retourner false
            child: Text(
              "Annuler",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // ==================================================================
          // BOUTON SUPPRIMER
          // ==================================================================
          // Ferme la popup et confirme la suppression
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Retourner true
            child: Text(
              "Supprimer",
              style: TextStyle(
                color: Colors.redAccent, // Rouge pour indiquer le danger
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // ========================================================================
    // SI L'UTILISATEUR A CONFIRMÉ
    // ========================================================================
    if (confirm == true) {
      // ======================================================================
      // SUPPRIMER LA NOTE DE LA BASE DE DONNÉES
      // ======================================================================
      await _databaseHelper.deleteNote(note.id!);

      // ======================================================================
      // AFFICHER UN MESSAGE DE CONFIRMATION
      // ======================================================================
      // SnackBar = petit message qui apparaît en bas de l'écran
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note supprimée'),
          backgroundColor: Colors.green, // Vert pour succès
          behavior: SnackBarBehavior.floating, // Flottant au-dessus du contenu
        ),
      );

      // ======================================================================
      // RETOURNER À LA PAGE PRÉCÉDENTE
      // ======================================================================
      // Comme la note n'existe plus, on retourne à la liste des notes
      Navigator.pop(context);
    }
  }

  // ==========================================================================
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée tout ce qu'on voit à l'écran
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // RÉCUPÉRER LA COULEUR DE LA NOTE
    // ========================================================================
    // La couleur est stockée comme texte (ex: "4294198070")
    // On la convertit en objet Color
    final noteColor = Color(int.parse(note.color));

    return Scaffold(
      // Structure de base de la page
      
      // ======================================================================
      // FOND DE LA PAGE
      // ======================================================================
      // Le fond prend la couleur de la note pour un effet visuel agréable
      backgroundColor: noteColor,
      
      // ======================================================================
      // BARRE DU HAUT (APPBAR)
      // ======================================================================
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent pour voir la couleur de la note
        elevation: 0, // Pas d'ombre sous la barre
        
        // ==================================================================
        // BOUTON RETOUR
        // ==================================================================
        leading: IconButton(
          onPressed: () => Navigator.pop(context), // Retourner à la page précédente
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        
        // ==================================================================
        // BOUTONS D'ACTION À DROITE
        // ==================================================================
        actions: [
          // ================================================================
          // BOUTON MODIFIER
          // ================================================================
          IconButton(
            onPressed: () async {
              // Ouvrir la page de modification de note
              // On passe la note actuelle pour pré-remplir les champs
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(note: note),
                ),
              );
              // Quand on revient, la page se met à jour automatiquement
            },
            icon: Icon(Icons.edit, color: Colors.white),
          ),
          
          // ================================================================
          // BOUTON SUPPRIMER
          // ================================================================
          IconButton(
            onPressed: () => _showDeleteDialog(context), // Afficher la confirmation
            icon: Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      
      // ======================================================================
      // CORPS DE LA PAGE
      // ======================================================================
      body: SafeArea(
        // SafeArea évite que le contenu soit caché par l'encoche ou les boutons
        child: Column(
          // Column = empiler les éléments verticalement
          crossAxisAlignment: CrossAxisAlignment.start, // Aligner à gauche
          
          children: [
            // ================================================================
            // EN-TÊTE : TITRE ET DATE
            // ================================================================
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              // Espaces : gauche 24, haut 16, droite 24, bas 24
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================================================
                  // TITRE DE LA NOTE
                  // ==============================================================
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 28, // Grande taille pour le titre
                      fontWeight: FontWeight.bold, // Texte en gras
                      color: Colors.white, // Blanc pour contraster avec la couleur
                    ),
                  ),
                  
                  SizedBox(height: 12), // Espace entre le titre et la date
                  
                  // ==============================================================
                  // DATE DE LA NOTE AVEC ICÔNE
                  // ==============================================================
                  Row(
                    // Aligner l'icône et la date horizontalement
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.white),
                      SizedBox(width: 8), // Petit espace entre l'icône et le texte
                      Text(
                        _formatDateTime(note.dateTime), // Date formatée
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ================================================================
            // CONTENU DE LA NOTE
            // ================================================================
            // Expanded = prend tout l'espace disponible restant
            Expanded(
              child: Container(
                width: double.infinity, // Prendre toute la largeur
                padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                
                // ==============================================================
                // DÉCORATION DU CONTAINER
                // ==============================================================
                decoration: BoxDecoration(
                  color: Colors.white, // Fond blanc pour le contenu
                  // Coins arrondis uniquement en haut
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                
                // ==============================================================
                // ZONE DÉFILABLE POUR LE CONTENU
                // ==============================================================
                // SingleChildScrollView = permet de défiler si le texte est long
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(), // Effet de rebond style iOS
                  child: Text(
                    note.content, // Le contenu de la note
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.8), // Noir légèrement transparent
                      height: 1.6, // Espacement entre les lignes (interligne)
                      letterSpacing: 0.2, // Espacement entre les lettres
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ======================================================================
      // BARRE DE NAVIGATION EN BAS
      // ======================================================================
      // On utilise le widget BottomNavigation qu'on a créé
      // currentIndex: 0 car cette page fait partie de la section "Accueil"
      // L'utilisateur peut ainsi naviguer vers d'autres sections depuis ici
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}