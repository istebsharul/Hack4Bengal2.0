import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({super.key});

  @override
  _MakePaymentPageState createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage> {
  stt.SpeechToText? _speechToText;
  String? _recognizedText;

  final TextEditingController _payerController = TextEditingController();
  final TextEditingController _payeeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _recognizedText = null;
  }

  void _startListening() async {
    print("startListeningCalled");
    if (!(_speechToText?.isListening ?? false)) {
      final available = await _speechToText?.initialize();
      if (available ?? false) {
        _speechToText?.listen(
          onResult: (result) {
            print('+++++++++++++$result');
            if (result.finalResult) {
              setState(() {
                _recognizedText = result.recognizedWords;
                parseSpeech(result.recognizedWords);
                print("startListeningCalled");
              });
            }
          },
          listenFor: const Duration(
              seconds: 6), // Maximum duration of speech recording
        );
      }
    }
  }

  void parseSpeech(String speech) {
    // Split the recognized speech into words
    List<String> words = speech.toLowerCase().split(' ');

    // Check if the speech contains the required keywords
    if (words.contains('from') && words.contains('to')) {
      // Get the indices of 'from' and 'to' keywords
      int fromIndex = words.indexOf('from');
      int toIndex = words.indexOf('to');

      // Extract the payer, payee, and amount
      String payer = words.getRange(fromIndex + 1, toIndex).join(' ');
      String payee = words.getRange(toIndex + 1, words.length).join(' ');
      String amount = words.elementAt(fromIndex - 1);

      // Update the text fields
      _payerController.text = payer;
      _payeeController.text = payee;
      _amountController.text = amount;
    }
  }

  void createPayment() async {
    final payer = _payerController.text;
    final payee = _payeeController.text;
    final amount = double.parse(_amountController.text);

    // Replace this with your actual logic for checking existing payee
    final existingPayee = true;

    if (existingPayee) {
      final response = await http.post(
        Uri.parse('http://localhost:5000/payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payer': payer,
          'payee': payee,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        _payerController.clear();
        _payeeController.clear();
        _amountController.clear();
      }
      // ignore: dead_code
    } else {
      final response = await http.post(
        Uri.parse('http://localhost:5000/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': payee,
          'available_amount': 0,
        }),
      );

      if (response.statusCode == 200) {
        createPayment();
      }
    }
  }

  @override
  void dispose() {
    _payerController.dispose();
    _payeeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Recognition Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recognized Text:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              _recognizedText ?? 'No speech recorded',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _payerController,
              decoration: const InputDecoration(
                labelText: 'Payer',
              ),
            ),
            TextField(
              controller: _payeeController,
              decoration: const InputDecoration(
                labelText: 'Payee',
              ),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text('Record Speech'),
            ),
            ElevatedButton(
              onPressed: createPayment,
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechInputExample extends StatefulWidget {
//   const SpeechInputExample({super.key});

//   @override
//   _SpeechInputExampleState createState() => _SpeechInputExampleState();
// }

// class _SpeechInputExampleState extends State<SpeechInputExample> {
//   final stt.SpeechToText _speechToText = stt.SpeechToText();
//   String payer = '';
//   String payee = '';
//   String amount = '';
//   bool isListening = false;

//   @override
//   void initState() {
//     super.initState();
//     initializeSpeechToText();
//   }

//   void initializeSpeechToText() async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       setState(() {
//         isListening = true;
//       });
//     }
//   }

//   void startListening() {
//     if (!isListening) {
//       _speechToText.listen(
//         onResult: (result) {
//           setState(() {
//             switch (result.recognizedWords.toLowerCase()) {
//               case 'payer':
//                 payer = result.recognizedWords;
//                 break;
//               case 'payee':
//                 payee = result.recognizedWords;
//                 break;
//               case 'amount':
//                 amount = result.recognizedWords;
//                 break;
//             }
//           });
//         },
//       );
//       setState(() {
//         isListening = true;
//       });
//     }
//   }

//   void stopListening() {
//     if (isListening) {
//       _speechToText.stop();
//       setState(() {
//         isListening = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Speech Input Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Payer: $payer'),
//             Text('Payee: $payee'),
//             Text('Amount: $amount'),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: isListening ? stopListening : startListening,
//               child: Text(isListening ? 'Stop Listening' : 'Start Listening'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
