import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

/// Page pour ajouter ou modifier une note
/// Si note est null = mode ajout, sinon = mode modification
class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Services nécessaires
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  // Couleur sélectionnée pour la note
  Color _selectedColor = Colors.amber;

  // Liste des couleurs disponibles
  final List<Color> _colors = [
    Color.fromRGBO(248, 156, 8, 100),
    Color.fromRGBO(46, 111, 64, 100),
    Color.fromRGBO(187, 11, 11, 100),
    Color.fromRGBO(137, 81, 41, 100),
    Color.fromRGBO(2, 95, 181, 100),
    Color.fromRGBO(199, 21, 133, 100),
    Color.fromRGBO(255, 207, 57, 100),
  ];

  /// Initialiser les champs si on est en mode modification
  @override
  void initState() {
    super.initState();
    // Si on modifie une note existante
    if (widget.note != null) {
      // Remplir les champs avec les valeurs existantes
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(int.parse(widget.note!.color));
    }
  }

  /// Libérer les ressources
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Sauvegarder la note (création ou modification)
  Future<void> _saveNote() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    try {
      // Récupérer l'ID de l'utilisateur connecté
      final userId = _authService.getCurrentUserId();

      // Vérifier qu'un utilisateur est bien connecté
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Créer l'objet Note avec les informations
      final note = Note(
        id: widget
            .note
            ?.id, // null si nouvelle note, ID existant si modification
        userId: userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        color: _selectedColor.value.toString(),
        dateTime: DateTime.now().toString(),
      );

      // Mode ajout ou modification
      if (widget.note == null) {
        // Ajouter une nouvelle note
        await _databaseHelper.insertNote(note, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note créée avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Mettre à jour une note existante
        await _databaseHelper.updateNote(note);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note mise à jour'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // Retourner à la page précédente
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.note == null ? 'Ajouter une note' : 'Modifier une note',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Column(
                    // Aligner le titre et le champ de texte au début (à gauche)
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Titre",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Champ Titre
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Ex: Les courses du mois",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF50C878),
                              width: 2,
                            ),
                          ),
                        ),
                        // Validation: le titre ne doit pas être vide
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer le titre de votre note";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    // Aligner le titre et le champ de texte au début (à gauche)
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contenu",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Champ Contenu
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "Ex: Les courses du mois sont : ...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF50C878),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 10, // Permet plusieurs lignes
                        // Validation: le contenu ne doit pas être vide
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer le contenu de votre note";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  // Sélecteur de couleur
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Défilement horizontal
                      child: Row(
                        children: _colors.map((color) {
                          // Vérifier si c'est la couleur sélectionnée
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              // Changer la couleur sélectionnée
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle, // Forme circulaire
                                // Bordure noire si sélectionné
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black45
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              // Icône de validation si sélectionné
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Bouton "Enregistrer"
                  InkWell(
                    onTap: () async {
                      await _saveNote();
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(118, 189, 255, 100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
