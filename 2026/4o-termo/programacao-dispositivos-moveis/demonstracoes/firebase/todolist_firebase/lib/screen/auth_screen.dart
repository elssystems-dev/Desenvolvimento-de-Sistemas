import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist_firebase/screen/task_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist_firebase/screen/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Vai verificar o estado da autenticação e redirecionar 
      // Para tarefas se já estiver loado ou login se não estiver
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se existir algum dado de conexão estabelecida
        if (snapshot.hasData) {
          // Redireciona para a tela de tarefas
          return TaskScreen();
        }
        // Se não -> Redireciona para tela de login
        return LoginScreen();
      }
    );
  }
}