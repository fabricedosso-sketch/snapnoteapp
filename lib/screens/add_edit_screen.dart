import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

// ==============================================================================
// PAGE POUR AJOUTER OU MODIFIER UNE NOTE
// ==============================================================================
// Cette page a deux modes :
// - Mode AJOUT : si note est null, on crée une nouvelle note
// - Mode MODIFICATION : si note existe, on modifie une note existante
// C'est comme un formulaire qui peut servir à créer OU à éditer !
// ==============================================================================
class AddEditNoteScreen extends StatefulWidget {
  // ==========================================================================
  // LA NOTE À MODIFIER (OU NULL SI NOUVELLE NOTE)
  // ==========================================================================
  // Si note est null = on va créer une nouvelle note
  // Si note existe = on va modifier cette note
  final Note? note;

  const AddEditNoteScreen({this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

// ==============================================================================
// ÉTAT DE LA PAGE D'AJOUT/MODIFICATION
// ==============================================================================
// Cette classe gère les données et les actions de la page
// ==============================================================================
class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  // ==========================================================================
  // CLÉ DE VALIDATION DU FORMULAIRE
  // ==========================================================================
  // Cette clé permet de vérifier que tous les champs sont correctement remplis
  // avant de sauvegarder la note
  final _formKey = GlobalKey<FormState>();

  // ==========================================================================
  // CONTRÔLEURS POUR LES CHAMPS DE TEXTE
  // ==========================================================================
  // Les contrôleurs permettent de récupérer et modifier le contenu des champs
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // ==========================================================================
  // SERVICES NÉCESSAIRES
  // ==========================================================================
  // DatabaseHelper = pour sauvegarder/modifier la note dans la base
  // AuthService = pour savoir quel utilisateur crée/modifie la note
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  // ==========================================================================
  // COULEUR SÉLECTIONNÉE POUR LA NOTE
  // ==========================================================================
  // La couleur par défaut est ambre (jaune-orangé)
  Color _selectedColor = Colors.amber;

  // ==========================================================================
  // LISTE DES COULEURS DISPONIBLES
  // ==========================================================================
  // Ce sont les couleurs que l'utilisateur peut choisir pour sa note
  // On utilise des couleurs personnalisées avec fromRGBO
  final List<Color> _colors = [
    Color.fromRGBO(248, 156, 8, 100),   // Orange
    Color.fromRGBO(46, 111, 64, 100),   // Vert
    Color.fromRGBO(187, 11, 11, 100),   // Rouge
    Color.fromRGBO(137, 81, 41, 100),   // Marron
    Color.fromRGBO(2, 95, 181, 100),    // Bleu
    Color.fromRGBO(199, 21, 133, 100),  // Rose/Violet
    Color.fromRGBO(255, 207, 57, 100),  // Jaune
  ];

  // ==========================================================================
  // INITIALISATION DE LA PAGE
  // ==========================================================================
  // Cette fonction est appelée automatiquement quand la page est créée
  // Si on est en mode modification, on pré-remplit les champs
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    
    // ========================================================================
    // MODE MODIFICATION : PRÉ-REMPLIR LES CHAMPS
    // ========================================================================
    // Si widget.note n'est pas null, on est en mode modification
    if (widget.note != null) {
      // Remplir le champ titre avec le titre existant
      _titleController.text = widget.note!.title;
      // Remplir le champ contenu avec le contenu existant
      _contentController.text = widget.note!.content;
      // Sélectionner la couleur existante
      _selectedColor = Color(int.parse(widget.note!.color));
    }
    // Si widget.note est null, les champs restent vides (mode ajout)
  }

  // ==========================================================================
  // NETTOYAGE DES RESSOURCES
  // ==========================================================================
  // Cette fonction est appelée quand la page est détruite
  // Elle libère la mémoire utilisée par les contrôleurs
  // ==========================================================================
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SAUVEGARDER LA NOTE (CRÉATION OU MODIFICATION)
  // ==========================================================================
  // Cette fonction est appelée quand on clique sur "Enregistrer"
  // Elle crée une nouvelle note ou met à jour une note existante
  // ==========================================================================
  Future<void> _saveNote() async {
    // ========================================================================
    // VALIDATION DU FORMULAIRE
    // ========================================================================
    // validate() vérifie tous les champs avec leurs validator()
    // Si un champ est invalide, ça retourne false et affiche l'erreur
    if (!_formKey.currentState!.validate()) return;

    try {
      // ======================================================================
      // RÉCUPÉRER L'ID DE L'UTILISATEUR CONNECTÉ
      // ======================================================================
      final userId = _authService.getCurrentUserId();

      // Vérifier qu'un utilisateur est bien connecté
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // ======================================================================
      // CRÉER L'OBJET NOTE
      // ======================================================================
      final note = Note(
        // Si widget.note est null (ajout) : id sera null (auto-généré par la base)
        // Si widget.note existe (modification) : on garde le même ID
        id: widget.note?.id,
        userId: userId, // L'utilisateur propriétaire de la note
        title: _titleController.text.trim(), // trim() enlève les espaces
        content: _contentController.text.trim(),
        color: _selectedColor.value.toString(), // Convertir la couleur en texte
        dateTime: DateTime.now().toString(), // Date et heure actuelles
      );

      // ======================================================================
      // DÉCIDER : AJOUT OU MODIFICATION ?
      // ======================================================================
      if (widget.note == null) {
        // ====================================================================
        // MODE AJOUT : CRÉER UNE NOUVELLE NOTE
        // ====================================================================
        await _databaseHelper.insertNote(note, userId);
        
        if (mounted) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note créée avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // ====================================================================
        // MODE MODIFICATION : METTRE À JOUR UNE NOTE EXISTANTE
        // ====================================================================
        await _databaseHelper.updateNote(note);
        
        if (mounted) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note mise à jour'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // ======================================================================
      // RETOURNER À LA PAGE PRÉCÉDENTE
      // ======================================================================
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // ======================================================================
      // AFFICHER UN MESSAGE D'ERREUR
      // ======================================================================
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================================
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée tout ce qu'on voit à l'écran
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // ======================================================================
      // APPBAR (BARRE DU HAUT)
      // ======================================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // Bouton retour
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        // Titre qui change selon le mode (ajout ou modification)
        title: Text(
          widget.note == null ? 'Ajouter une note' : 'Modifier une note',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      // ======================================================================
      // CORPS DE LA PAGE : FORMULAIRE
      // ======================================================================
      body: Form(
        key: _formKey, // La clé pour accéder au formulaire
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // ==============================================================
                  // CHAMP TITRE
                  // ==============================================================
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
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Ex: Les courses du mois",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // Style quand le champ est sélectionné
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF50C878), // Vert
                              width: 2,
                            ),
                          ),
                        ),
                        // ========================================================
                        // VALIDATION DU TITRE
                        // ========================================================
                        // Le titre ne doit pas être vide
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer le titre de votre note";
                          }
                          return null; // null = pas d'erreur
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // ==============================================================
                  // CHAMP CONTENU
                  // ==============================================================
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
                        maxLines: 10, // Permet d'écrire sur plusieurs lignes
                        // ========================================================
                        // VALIDATION DU CONTENU
                        // ========================================================
                        // Le contenu ne doit pas être vide
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer le contenu de votre note";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  
                  // ==============================================================
                  // SÉLECTEUR DE COULEUR
                  // ==============================================================
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Défilement horizontal
                      child: Row(
                        // ========================================================
                        // CRÉER UN CERCLE POUR CHAQUE COULEUR
                        // ========================================================
                        // map() transforme chaque couleur en widget
                        children: _colors.map((color) {
                          // Vérifier si c'est la couleur actuellement sélectionnée
                          final isSelected = _selectedColor == color;
                          
                          return GestureDetector(
                            // Quand on clique sur le cercle
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
                                color: color, // La couleur du cercle
                                shape: BoxShape.circle, // Forme circulaire
                                // Bordure noire si cette couleur est sélectionnée
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
                                  : null, // Pas d'icône si non sélectionné
                            ),
                          );
                        }).toList(), // Convertir en liste de widgets
                      ),
                    ),
                  ),
                  
                  // ==============================================================
                  // BOUTON "ENREGISTRER"
                  // ==============================================================
                  InkWell(
                    // InkWell = rend le container cliquable
                    onTap: () async {
                      await _saveNote(); // Sauvegarder la note
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(118, 189, 255, 100), // Bleu
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

      // ======================================================================
      // BARRE DE NAVIGATION EN BAS
      // ======================================================================
      // On utilise le widget BottomNavigation qu'on a créé
      // currentIndex: 0 car cette page fait partie de la section "Accueil"
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}