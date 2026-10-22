import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:star_phrases/screens/about_us.dart';
import 'package:star_phrases/screens/app_settings.dart';

class Phrases extends StatefulWidget {
  const Phrases({super.key});

  @override
  State<Phrases> createState() => _PhrasesState();
}

class _PhrasesState extends State<Phrases> {

  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Phrases", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUs()),
            ),
            icon: Icon(Icons.info),
          ),
          IconButton(onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppSettings())
          ), icon: Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder(
        stream: _fs.collection("dailyContent").doc("quoteOfTheDay").snapshots(), 
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text("Nenhuma citação ativa no momento."));
          }

          String frase = snapshot.data!.get("phrase");
          String autor = snapshot.data!.get("author");

          return Padding(
              padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      "Frase do Dia",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35
                      ),
                    ),
                    
                    SizedBox(height: 40),

                    Expanded(child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            frase,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                          ),
                          SizedBox(height: 8),
                          Text(
                            autor,
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
                          ),
                          SizedBox(height: 8),
                          Image.network("https://upload.wikimedia.org/wikipedia/commons/8/84/Martin_Luther_King_Jr_NYWTS.jpg?utm_source=pt.wikipedia.org&utm_campaign=index&utm_content=original")
                        ],
                      ),
                    ))
                  ],
                )
            );
        }
      ),
    );
  }
}