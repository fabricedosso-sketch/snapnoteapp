import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/screens/add_edit_screen.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

/// Page qui affiche les détails complets d'une note
/// Permet de modifier ou supprimer la note
class ViewNoteScreen extends StatelessWidget {
  final Note note;

  ViewNoteScreen({required this.note});

  // Instance de la base de données
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Formatter une date pour l'affichage
  String _formatDateTime(String dateTime) {
    final DateTime dt = DateTime.parse(dateTime);
    final now = DateTime.now();

    // Si c'est aujourd'hui
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Aujourd\'hui, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    // Sinon, date complète
    return '${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Afficher une boîte de dialogue pour confirmer la suppression
  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Supprimer la note",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Es-tu sûr de vouloir supprimer cette note ?",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Bouton Supprimer
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Supprimer",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Si l'utilisateur confirme
    if (confirm == true) {
      // Supprimer la note de la base de données
      await _databaseHelper.deleteNote(note.id!);

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note supprimée'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Retourner à la page précédente
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la couleur de la note
    final noteColor = Color(int.parse(note.color));

    return Scaffold(
      // Fond de la couleur de la note
      backgroundColor: noteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Bouton retour
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          // Bouton pour modifier la note
          IconButton(
            onPressed: () async {
              // Ouvrir la page de modification
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(note: note),
                ),
              );
            },
            icon: Icon(Icons.edit, color: Colors.white),
          ),
          // Bouton pour supprimer la note
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec le titre et la date
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la note
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Date de la note avec icône
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        _formatDateTime(note.dateTime),
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
            // Contenu de la note dans un container blanc
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // Coins arrondis en haut
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(), // Effet de rebond iOS
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.8),
                      height: 1.6, // Espacement entre les lignes
                      letterSpacing: 0.2, // Espacement entre les lettres
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ⭐ AJOUT DE LA BARRE DE NAVIGATION EN BAS ⭐
      // On utilise le widget BottomNavigation qu'on a créé
      // currentIndex: 0 car cette page fait partie de la section "Accueil"
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}
