import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QuoteSimulationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultAuthorImage =
      'https://upload.wikimedia.org/wikipedia/commons/8/84/Martin_Luther_King_Jr_NYWTS.jpg?utm_source=pt.wikipedia.org&utm_campaign=index&utm_content=original';

  static const List<Map<String, String>> _fallbackQuotes = [
    {
      'phrase':
          'O que não provoca minha morte faz com que eu fique mais forte.',
      'author': 'Friedrich Nietzsche',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Nietzsche187a.jpg',
    },
    {
      'phrase':
          'Eu tenho um sonho de que meus quatro filhos viverão um dia em uma nação onde não serão julgados pela cor de sua pele, mas pelo conteúdo de seu caráter.',
      'author': 'Martin Luther King Jr.',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/8/84/Martin_Luther_King_Jr_NYWTS.jpg',
    },
    {
      'phrase':
          'No meio da dificuldade encontra-se a oportunidade.',
      'author': 'Albert Einstein',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/d/d3/Albert_Einstein_Head.jpg',
    },
    {
      'phrase':
          'A educação é a arma mais poderosa que você pode usar para mudar o mundo.',
      'author': 'Nelson Mandela',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/0/02/Nelson_Mandela_1994.jpg',
    },
    {
      'phrase':
          'A simplicidade é o último grau de sofisticação.',
      'author': 'Leonardo da Vinci',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/b/ba/Leonardo_self.jpg',
    },
    {
      'phrase':
          'Seja a mudança que você quer ver no mundo.',
      'author': 'Mahatma Gandhi',
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/d/d1/Portrait_Gandhi.jpg',
    },
  ];

  static Future<Map<String, String>> fetchQuoteFromApi() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://favqs.com/api/qotd'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['quote'] != null) {
          final body = data['quote']['body']?.toString().trim() ?? '';
          final author = data['quote']['author']?.toString().trim() ?? 'Desconhecido';
          if (body.isNotEmpty) {
            return {
              'phrase': body,
              'author': author,
              'source': 'API Externa FavQs',
              'imageUrl': defaultAuthorImage,
            };
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('FavQs API falhou ou tempo esgotado: $e. Tentando alternativa...');
      }
    }

    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0]['q'] != null) {
          final phrase = data[0]['q']?.toString().trim() ?? '';
          final author = data[0]['a']?.toString().trim() ?? 'Desconhecido';
          if (phrase.isNotEmpty) {
            return {
              'phrase': phrase,
              'author': author,
              'source': 'API Externa ZenQuotes',
              'imageUrl': defaultAuthorImage,
            };
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ZenQuotes API falhou: $e. Usando citação local de fallback.');
      }
    }

    final random = Random();
    final item = _fallbackQuotes[random.nextInt(_fallbackQuotes.length)];
    return {
      'phrase': item['phrase']!,
      'author': item['author']!,
      'source': 'Banco Curado (Modo Simulação Local)',
      'imageUrl': item['imageUrl'] ?? defaultAuthorImage,
    };
  }

  static Future<bool> simulateDailyCloudFunction() async {
    try {
      final quoteData = await fetchQuoteFromApi();

      await _firestore.collection('dailyContent').doc('quoteOfTheDay').set({
        'phrase': quoteData['phrase'],
        'quote': quoteData['phrase'], // compatibilidade
        'author': quoteData['author'],
        'imageUrl': quoteData['imageUrl'] ?? defaultAuthorImage,
        'source': quoteData['source'] ?? 'Simulação Local - Cloud Function',
        'updatedAt': FieldValue.serverTimestamp(),
        'simulatedSchedule': '00:01 Diário (Cloud Function Agendada)',
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('Cloud Function (Simulada): Documento atualizado no Firestore com sucesso!');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao simular Cloud Function no Firestore: $e');
      }
      return false;
    }
  }

  static Future<void> checkAndInitializeDailyQuote() async {
    try {
      final doc = await _firestore
          .collection('dailyContent')
          .doc('quoteOfTheDay')
          .get();

      if (!doc.exists || doc.data() == null || doc.data()!['phrase'] == null) {
        await simulateDailyCloudFunction();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar inicialização do Firestore: $e');
      }
    }
  }
}
