import 'package:flutter/material.dart';
import 'chatgpt_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  bool _isDiseasePredictionMode = false;
  bool _isMedicalAdviceMode = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hello! 👋 I am PHMS!😄 How can I assist you today?");
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'text': text, 'isUser': false});
    });
  }

  void _addBotImage(Uint8List imageBytes) {
    setState(() {
      _messages.add({'image': imageBytes, 'isUser': false});
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final userMessage = _controller.text.trim();
    _addUserMessage(userMessage);
    _controller.clear();

    String botReply;

    if (_isDiseasePredictionMode) {
      botReply = await DiseasePredictionService.sendSymptoms(userMessage);
      _addBotMessage(botReply);

      // Only show the chart if it's available and valid
      if (DiseasePredictionService.shouldShowChart() && DiseasePredictionService.getChart() != null) {
        _addBotImage(DiseasePredictionService.getChart()!);
      } else {
        // Remove any old chart image when no chart is returned
        if (_messages.isNotEmpty && _messages.last.containsKey('image')) {
          setState(() {
            _messages.removeLast();  // Remove the previous chart if any
          });
        }
      }
    }
    else if (_isMedicalAdviceMode) {
      botReply = await MedicalAdviceService.sendSymptoms(userMessage);
      _addBotMessage(botReply);
    }
    else {
      botReply = await ChatGptService.sendMessage(userMessage);
      _addBotMessage(botReply);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classic Chatbot  🏥️',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                setState(() {
                  _messages.clear();
                  _addBotMessage("Hello! 👋 I am PHMS!😄 How can I assist you today?");
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete All Messages'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                final hasImage = message.containsKey('image');
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: hasImage
                        ? InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 4.0,
                      child: Image.memory(
                        message['image'],
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    )
                        : Text(message['text']),
                  ),
                );
              },
            ),
          ),

          // Bottom typing area with buttons and text field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[200],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isMedicalAdviceMode ? null : () {
                        setState(() {
                          _isDiseasePredictionMode = !_isDiseasePredictionMode;
                          if (_isDiseasePredictionMode) {
                            _isMedicalAdviceMode = false; // Disable medical advice mode
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDiseasePredictionMode ? Colors.blue[800] : Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Text(
                        _isDiseasePredictionMode ? 'Exit Mode' : 'Disease Prediction',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isDiseasePredictionMode ? null : () {
                        setState(() {
                          _isMedicalAdviceMode = !_isMedicalAdviceMode;
                          if (_isMedicalAdviceMode) {
                            _isDiseasePredictionMode = false; // Disable disease prediction mode
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMedicalAdviceMode ? Colors.blue[800] : Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Text(
                        _isMedicalAdviceMode ? 'Exit Mode' : 'Advanced Medical Advice',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // space between buttons and textfield

                // Typing and send area
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiseasePredictionService {
  static Future<String> sendSymptoms(String symptoms) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.62:5000/predict_disease'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': symptoms}),
      ).timeout(const Duration(seconds: 30));

      // Reset chart when no chart is returned
      _chartBytes = null;
      _showChart = false;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        String message = "Prediction Made 📝\nSymptoms : ${decoded['symptoms_detected']}\n"
            "Disease : ${decoded['disease_name']}❗";

        if (decoded['symptom_chart_base64'] != null) {
          Uint8List chartBytes = base64Decode(decoded['symptom_chart_base64']);
          _chartBytes = chartBytes;  // Store it in a global or state variable
          _showChart = true;
        }
        else {
        _showChart = false;
        }

        return message;
      } else {
        final decoded = json.decode(response.body);
        return decoded['error'] ?? "Failed to get prediction.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  static Uint8List? _chartBytes;
  static bool _showChart = false;

  static Uint8List? getChart() => _chartBytes;
  static bool shouldShowChart() => _showChart;
}

class MedicalAdviceService {
  static Future<String> sendSymptoms(String symptoms) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.62:5001/predict_advice'), // Flask API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': symptoms}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['response'] ?? "No response from the server.";
      } else {
        final decoded = json.decode(response.body);
        if (decoded['error'] != null) {
          return "⚠️ ${decoded['error']}";
        }
        return "Failed to get prediction.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}

