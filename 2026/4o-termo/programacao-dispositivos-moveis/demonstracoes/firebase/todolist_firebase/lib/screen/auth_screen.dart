import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist_firebase/screen/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Vai verificar o estado da autenticação e redirecionar 
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TarefaScreen();
        }
        return LoginScreen();
      }
    );
  }
}