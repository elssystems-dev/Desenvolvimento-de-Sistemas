import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:star_phrases/screens/about_us.dart';
import 'package:star_phrases/screens/app_settings.dart';
import 'package:star_phrases/services/quote_simulation_service.dart';

class Phrases extends StatefulWidget {
  const Phrases({super.key});

  @override
  State<Phrases> createState() => _PhrasesState();
}

class _PhrasesState extends State<Phrases> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    QuoteSimulationService.checkAndInitializeDailyQuote();
  }

  Future<void> _handleSimulateCloudFunction() async {
    if (_isSimulating) return;

    setState(() {
      _isSimulating = true;
    });

    await QuoteSimulationService.simulateDailyCloudFunction();

    if (!mounted) return;

    setState(() {
      _isSimulating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Star Phrases",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Simular Cloud Function (Atualizar Citação)",
            onPressed: _isSimulating ? null : _handleSimulateCloudFunction,
            icon: _isSimulating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black87,
                    ),
                  )
                : const Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUs()),
            ),
            icon: const Icon(Icons.info),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppSettings()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _fs.collection("dailyContent").doc("quoteOfTheDay").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      "Erro ao carregar do Firestore: ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleSimulateCloudFunction,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Tentar Novamente"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists || snapshot.data!.data() == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_quote, size: 56, color: Color(0xFFE5B800)),
                    const SizedBox(height: 16),
                    const Text(
                      "Nenhuma citação ativa no momento.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Clique abaixo para simular a execução da Cloud Function e gerar a Frase do Dia no Firestore.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8D830),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _handleSimulateCloudFunction,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Gerar Citação Inicial"),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final String frase = data["phrase"] ?? data["quote"] ?? "Sem frase disponível";
          final String autor = data["author"] ?? "Autor Desconhecido";
          final String? source = data["source"];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome, color: Color(0xFFE5B800), size: 30),
                      SizedBox(width: 8),
                      Text(
                        "Frase do Dia",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            size: 44,
                            color: Color(0xFFE5B800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "“$frase”",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "— $autor",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              fontSize: 19,
                              color: isDark
                                  ? const Color(0xFFF8D830)
                                  : Colors.amber[900],
                            ),
                          ),
                          if (source != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              "Fonte: $source",
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFF8D830).withAlpha(20)
                          : const Color(0xFFF8D830).withAlpha(45),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF8D830).withAlpha(isDark ? 25 : 60),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/star_phrases.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}