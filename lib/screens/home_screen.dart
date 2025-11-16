import 'package:flutter/material.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:projetfinal/screens/add_edit_screen.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/screens/view_note_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

// ==============================================================================
// PAGE D'ACCUEIL DE L'APPLICATION
// ==============================================================================
// Cette page affiche toutes les notes de l'utilisateur connecté
// C'est la page principale où on voit la liste de toutes nos notes !
// Elle permet aussi d'ajouter de nouvelles notes via le bouton +
// ==============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ==============================================================================
// ÉTAT DE LA PAGE D'ACCUEIL
// ==============================================================================
// Cette classe gère les données et les actions de la page
// (liste des notes, chargement, etc.)
// ==============================================================================
class _HomeScreenState extends State<HomeScreen> {
  // ==========================================================================
  // SERVICES NÉCESSAIRES
  // ==========================================================================
  // DatabaseHelper = pour récupérer les notes depuis la base de données
  // AuthService = pour vérifier qui est connecté
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService = AuthService();

  // ==========================================================================
  // LISTE DES NOTES
  // ==========================================================================
  // Cette liste contiendra toutes les notes de l'utilisateur
  // Au départ, elle est vide []
  List<Note> _notes = [];

  // ==========================================================================
  // VARIABLE DE CHARGEMENT
  // ==========================================================================
  // _isLoading = true quand on est en train de charger les notes
  // Permet d'afficher un spinner pendant le chargement
  bool _isLoading = true;

  // ==========================================================================
  // INITIALISATION DE LA PAGE
  // ==========================================================================
  // Cette fonction est appelée automatiquement quand la page est créée
  // C'est le moment parfait pour charger les notes !
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadNotes(); // Vérifier la connexion et charger les notes
  }

  // ==========================================================================
  // VÉRIFIER L'AUTHENTIFICATION ET CHARGER LES NOTES
  // ==========================================================================
  // Cette fonction vérifie d'abord si quelqu'un est connecté
  // Si oui, elle charge les notes
  // Si non, elle redirige vers la page de connexion
  // ==========================================================================
  Future<void> _checkAuthAndLoadNotes() async {
    // ========================================================================
    // VÉRIFIER SI UN UTILISATEUR EST CONNECTÉ
    // ========================================================================
    if (!_authService.isLoggedIn) {
      // Personne n'est connecté !
      // On redirige vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return; // Arrêter la fonction ici
    }

    // ========================================================================
    // CHARGER LES NOTES
    // ========================================================================
    // Si on arrive ici, c'est qu'un utilisateur est connecté
    await _loadNotes();
  }

  // ==========================================================================
  // CHARGER TOUTES LES NOTES DE L'UTILISATEUR
  // ==========================================================================
  // Cette fonction récupère toutes les notes depuis la base de données
  // et les affiche à l'écran
  // ==========================================================================
  Future<void> _loadNotes() async {
    // Afficher l'indicateur de chargement
    setState(() => _isLoading = true);

    // ========================================================================
    // RÉCUPÉRER L'ID DE L'UTILISATEUR CONNECTÉ
    // ========================================================================
    final userId = _authService.getCurrentUserId();

    if (userId != null) {
      // ======================================================================
      // RÉCUPÉRER LES NOTES DEPUIS LA BASE DE DONNÉES
      // ======================================================================
      // getNotes() retourne toutes les notes de cet utilisateur
      final notes = await _databaseHelper.getNotes(userId);

      // ======================================================================
      // METTRE À JOUR L'INTERFACE
      // ======================================================================
      // setState() dit à Flutter de redessiner la page avec les nouvelles données
      setState(() {
        _notes = notes; // Mettre à jour la liste des notes
        _isLoading = false; // Cacher l'indicateur de chargement
      });
    }
  }

  // ==========================================================================
  // FORMATER UNE DATE POUR L'AFFICHAGE
  // ==========================================================================
  // Cette fonction transforme une date en texte lisible
  // Affiche "Aujourd'hui" si c'est aujourd'hui, sinon la date complète
  // Par exemple : "2024-03-15 14:30:00" devient "Aujourd'hui, 14:30"
  // ou "15/03/2024, 14:30" selon la date
  // ==========================================================================
  String _formatDateTime(String dateTime) {
    // ========================================================================
    // CONVERTIR LE TEXTE EN OBJET DATE
    // ========================================================================
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
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée tout ce qu'on voit à l'écran
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    // Récupérer l'utilisateur connecté
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // ======================================================================
      // APPBAR (BARRE DU HAUT)
      // ======================================================================
      appBar: AppBar(
        elevation: 0, // Pas d'ombre
        backgroundColor: Colors.white,
      ),
      
      // ======================================================================
      // CORPS DE LA PAGE
      // ======================================================================
      body: _isLoading
          // Si on est en train de charger, afficher un spinner
          ? Center(child: CircularProgressIndicator())
          // Sinon, afficher le contenu
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================================================
                // SECTION D'EN-TÊTE AVEC MESSAGE DE BIENVENUE
                // ==============================================================
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========================================================
                      // MESSAGE "BONJOUR, [PRÉNOM]"
                      // ========================================================
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
                            // ?? 'Utilisateur' = si user.prenom est null, afficher "Utilisateur"
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(0, 211, 137, 100), // Vert
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      
                      // ========================================================
                      // NOMBRE DE NOTES
                      // ========================================================
                      Text(
                        "Vous avez ${_notes.length} note${_notes.length > 1 ? 's' : ''} enregistrée(s)",
                        // Si plus d'une note, afficher "notes", sinon "note"
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                
                // ==============================================================
                // GRILLE DE NOTES OU MESSAGE SI VIDE
                // ==============================================================
                // Expanded = prendre tout l'espace restant
                Expanded(
                  child: _notes.isEmpty
                      // ========================================================
                      // SI AUCUNE NOTE : AFFICHER UN MESSAGE
                      // ========================================================
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
                      // ========================================================
                      // SINON : AFFICHER LA GRILLE DE NOTES
                      // ========================================================
                      : GridView.builder(
                          // GridView = grille de cartes (comme un tableau)
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 colonnes
                            crossAxisSpacing: 16, // Espace horizontal entre les cartes
                            mainAxisSpacing: 16, // Espace vertical entre les cartes
                          ),
                          itemCount: _notes.length, // Nombre de notes à afficher
                          
                          // ====================================================
                          // CONSTRUIRE CHAQUE CARTE DE NOTE
                          // ====================================================
                          // Cette fonction est appelée pour chaque note
                          itemBuilder: (context, index) {
                            final note = _notes[index]; // La note à afficher
                            final color = Color(int.parse(note.color)); // Sa couleur

                            // ==================================================
                            // CARTE DE NOTE CLIQUABLE
                            // ==================================================
                            // GestureDetector = détecte les clics
                            return GestureDetector(
                              onTap: () async {
                                // ==============================================
                                // OUVRIR LA PAGE DE DÉTAILS DE LA NOTE
                                // ==============================================
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewNoteScreen(note: note),
                                  ),
                                );
                                // Recharger les notes au retour
                                // (au cas où la note aurait été modifiée ou supprimée)
                                _loadNotes();
                              },
                              
                              // ==============================================
                              // CONTENU DE LA CARTE
                              // ==============================================
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color, // Couleur de fond de la note
                                  borderRadius: BorderRadius.circular(16), // Coins arrondis
                                  // Ombre pour effet de profondeur
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
                                    // ==========================================
                                    // TITRE DE LA NOTE
                                    // ==========================================
                                    Text(
                                      note.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1, // Maximum 1 ligne
                                      overflow: TextOverflow.ellipsis, // ... si trop long
                                    ),
                                    SizedBox(height: 8),
                                    
                                    // ==========================================
                                    // CONTENU DE LA NOTE (APERÇU)
                                    // ==========================================
                                    Text(
                                      note.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70, // Blanc transparent
                                      ),
                                      maxLines: 4, // Maximum 4 lignes
                                      overflow: TextOverflow.ellipsis, // ... si trop long
                                    ),
                                    
                                    Spacer(), // Prendre tout l'espace restant
                                    
                                    // ==========================================
                                    // DATE DE LA NOTE
                                    // ==========================================
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
      
      // ======================================================================
      // BOUTON FLOTTANT POUR AJOUTER UNE NOTE
      // ======================================================================
      // Le bouton + rond en bas à droite de l'écran
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ==================================================================
          // OUVRIR LA PAGE D'AJOUT DE NOTE
          // ==================================================================
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditNoteScreen()),
          );
          // Recharger les notes au retour pour afficher la nouvelle note
          _loadNotes();
        },
        backgroundColor: Color.fromRGBO(118, 189, 255, 100), // Bleu
        foregroundColor: Colors.white, // Couleur de l'icône
        child: Icon(Icons.add), // Icône +
      ),

      // ======================================================================
      // BARRE DE NAVIGATION EN BAS
      // ======================================================================
      // On utilise le widget BottomNavigation qu'on a créé
      // currentIndex: 0 car on est sur la page d'accueil (première page)
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}