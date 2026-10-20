import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  //atributos
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser; //pegando dados do usuário atual autenticado
  final TextEditingController _taskController = TextEditingController();

  // Adicionar Tasks
  Future<void>_addTask() async {
    if(_taskController.text.isNotEmpty && _user != null){
      await _db.collection("users")
        .doc(_user.uid)
        .collection("tarefas")
        .add({
          "titulo": _taskController.text,
          "concluida":false,
          "criadaEm":Timestamp.now()
        });
        _taskController.clear();
        Navigator.pop(context);//fechar a tela de Dialogo
    }
  }

  // Atualizar Task
  Future<void> _updateTask(String taskId, bool currentState) async {
    if (_user != null) {
      await _db.collection("users").doc(_user.uid).collection("tarefas").doc(taskId).update({
        "concluida": currentState,
      });
    }
  }

  // Deletar Task
  Future<void> _removeTask(String taskId) async {
    if (_user != null) {
      await _db
      .collection("users").doc(_user.uid)
      .collection("tarefas").doc(taskId).delete();
    }
  }

  // Método View: Exibir caixa de diálogo de criação da tarefa
  void _showAddTaskDialog() {
    showDialog(context: context, 
      builder: (context){
        return AlertDialog(
          title: Text("Nova tarefa"),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: InputDecoration(labelText: "Nome da tarefa"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Cancelar")
            ),
            ElevatedButton(
              onPressed: _addTask, 
              child: Text("Adicionar")
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas tarefas"),
        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
          }, icon: Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection("users").doc(_user?.uid).collection("tarefas")
        .orderBy("criadaEm", descending: true).snapshots(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Nenhuma tarefa encontrada"),
            );
          }

          var tarefas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              var tarefa = tarefas[index];
              //Mapeamento das Informações de Cada Tarefa
              var tarefaData = tarefa.data() as Map<String,dynamic>;
              bool concluida = tarefaData["concluida"] ?? false; //validação de nulidade
              return ListTile(
                title: Text(tarefaData["titulo"],style: TextStyle(
                  decoration: concluida ? 
                    TextDecoration.lineThrough : 
                    TextDecoration.none),),
                leading: Checkbox(
                  value: concluida, 
                  onChanged: (bool? value){
                    _updateTask(tarefa.id, concluida);
                  }),
                trailing: IconButton(
                  onPressed: ()=> _removeTask(tarefa.id), 
                  icon: Icon(Icons.delete, color: Colors.red,),)
              );
            }
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: Icon(Icons.add),),
    );
  }
}