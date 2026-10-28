import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sobre Nós",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF8D830).withAlpha(45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF8D830),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 46,
                color: Color(0xFFE5B800),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Star Phrases",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Inspiração diária e frases impactantes",
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 28),

            _buildPlaceholderSection(
              context: context,
              title: "Quem Somos",
              icon: Icons.groups_outlined,
              placeholderText:
                "Uma equipe de um único estudante apaixonado pelo conhecimento. - ELS Systems"
            ),
            const SizedBox(height: 16),

            _buildPlaceholderSection(
              context: context,
              title: "Missão",
              icon: Icons.lightbulb_outline,
              placeholderText:
                  "Espalhar a vontade pelo saber para as pessoas, através da iniciativa Star Phrases"
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFFE5B800)),
                        SizedBox(width: 8),
                        Text(
                          "Informações do Projeto",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow("Projeto", "Star Phrases (QuoteGenius)"),
                    _buildInfoRow("Cenário", "Situação de Aprendizagem 5"),
                    _buildInfoRow("Backend", "Firebase Cloud Firestore"),
                    _buildInfoRow("Simulação", "Cloud Function Agendada (Local)"),
                    _buildInfoRow("Versão", "1.0.0"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String placeholderText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE5B800)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(12)
                    : const Color(0xFFF8D830).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white24
                      : const Color(0xFFF8D830).withAlpha(120),
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                placeholderText,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(210),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}