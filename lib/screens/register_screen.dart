import 'package:flutter/material.dart';
import 'package:projetfinal/model/users_model.dart';
import 'package:projetfinal/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Contrôleurs pour les champs
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // --- Fonction d'enregistrement
  Future<void> _creerCompte() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _motDePasseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs."
          ),
        ),
      );
      return;
    }

    final user = User(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      motDePasse: _motDePasseController.text,
    );

    //await DatabaseManager.instance.insertRedacteur(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Compte créé avec succès !"
        ),
      ),
    );

    // Efface les champs après enregistrement
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _motDePasseController.clear();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Container(
        margin: EdgeInsets.all(30),

        child: Form(
          child: Column(
            children: [
              Text("Inscription", 
              style: TextStyle(
                fontSize: 80, 
                fontWeight: FontWeight.w900),),

              SizedBox(height: 5),

              SizedBox(
                height: 115,
                child: Image.asset("assets/images/logo.png"),),

              SizedBox(height: 30),

              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  hintText: "Ecrivez votre nom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 211, 137, 100),// Bordure violette au focus
                      width: 2.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  hintText: "Ecrivez votre prénom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 211, 137, 100),// Bordure violette au focus
                      width: 2.0,
                    ),
                  ),
                ),
              ),


              SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Ecrivez votre adressse email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 211, 137, 100),// Bordure violette au focus
                      width: 2.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: _motDePasseController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Ecrivez votre mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(0, 211, 137, 100),// Bordure violette au focus
                      width: 2.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 50),

              SizedBox(width: 350,
              child: ElevatedButton(
                onPressed: _creerCompte, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical:17),
                  backgroundColor: const Color.fromRGBO(0, 211, 137, 100),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ), 
                  side: BorderSide(
                    width: 2,
                    color: Colors.black)
                ),
                child: Text("Créer un compte",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900),
                ),
              ),
            ),
              
              SizedBox(height: 10),

              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: (){
                     Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => LoginScreen(),)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical:17),
                    backgroundColor: const Color.fromRGBO(118, 189, 255, 100),
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    side: BorderSide(
                      width: 2,
                      color: Colors.black),
                  ),
               
                  child: Text("Se connecter",
                    style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w900),
                  ),
                ),
              ),
             ],
            ),
           ),
         ),
        ],
      ),
    );
  }
}