import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/screens/add_edit_screen.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/screens/view_note_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

/// Page d'accueil de l'application
/// Affiche toutes les notes de l'utilisateur connecté
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services nécessaires
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  // Liste qui contiendra toutes les notes de l'utilisateur
  List<Note> _notes = [];

  // Variable pour afficher un indicateur de chargement
  bool _isLoading = true;

  /// Fonction appelée quand la page est créée
  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadNotes();
  }

  /// Vérifier l'authentification et charger les notes
  Future<void> _checkAuthAndLoadNotes() async {
    // Vérifier si un utilisateur est connecté
    if (!_authService.isLoggedIn) {
      // Si personne n'est connecté, rediriger vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    // Charger les notes de l'utilisateur
    await _loadNotes();
  }

  /// Charger toutes les notes de l'utilisateur depuis la base de données
  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    // Récupérer l'ID de l'utilisateur connecté
    final userId = _authService.getCurrentUserId();

    if (userId != null) {
      // Récupérer les notes de cet utilisateur
      final notes = await _databaseHelper.getNotes(userId);

      // Mettre à jour l'interface avec les notes
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  /// Formatter une date pour l'affichage
  /// Affiche "Aujourd'hui" si c'est aujourd'hui, sinon la date complète
  String _formatDateTime(String dateTime) {
    final DateTime dt = DateTime.parse(dateTime);
    final now = DateTime.now();

    // Si la date est aujourd'hui
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Aujourd\'hui, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    // Sinon, afficher la date complète
    return '${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer l'utilisateur connecté
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section d'en-tête avec le message de bienvenue
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message "Bonjour, [Prénom]"
                      Row(
                        children: [
                          Text(
                            "Bonjour, ",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            user?.prenom ?? 'Utilisateur',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(0, 211, 137, 100),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // Nombre de notes
                      Text(
                        "Vous avez ${_notes.length} note${_notes.length > 1 ? 's' : ''} enregistrée(s)",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                // Grille de notes ou message si vide
                Expanded(
                  child: _notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune note',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Appuyez sur + pour créer une note',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 colonnes
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            final note = _notes[index];
                            final color = Color(int.parse(note.color));

                            // Carte de note cliquable
                            return GestureDetector(
                              onTap: () async {
                                // Ouvrir la page de détails de la note
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewNoteScreen(note: note),
                                  ),
                                );
                                // Recharger les notes au retour
                                _loadNotes();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Titre de la note
                                    Text(
                                      note.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    // Contenu de la note (aperçu)
                                    Text(
                                      note.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Spacer(),
                                    // Date de la note
                                    Text(
                                      _formatDateTime(note.dateTime),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      // Bouton flottant pour ajouter une note
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Ouvrir la page d'ajout de note
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditNoteScreen()),
          );
          // Recharger les notes au retour
          _loadNotes();
        },
        backgroundColor: Color.fromRGBO(118, 189, 255, 100),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),

      // ⭐ AJOUT DE LA BARRE DE NAVIGATION EN BAS ⭐
      // On utilise le widget BottomNavigation qu'on a créé
      // currentIndex: 0 car on est sur la page d'accueil (première page)
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}
