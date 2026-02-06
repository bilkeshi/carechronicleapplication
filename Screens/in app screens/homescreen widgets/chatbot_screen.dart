import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String _apiKey = 'AIzaSyBP1qZNAKQFYRlcEsarOncZPDozVyrbt84';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  late GenerativeModel _model;

  bool _isLoading = false;

  final List<String> options = [
    'Importance of wound care',
    'How to prevent infections',
    'When to consult a doctor',
    'Tips for dressing wounds',
    'Wound care myths',
    'What to avoid during wound care',
  ];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
    _addIntroMessage();
  }

  void _addIntroMessage() {
    setState(() {
      messages.add({
        'sender': 'bot',
        'text': 'Hi! I\'m ChronicleBot. How can I help with wound care?'
      });
    });
  }

  Future<void> _handleOptionClick(String option) async {
    setState(() {
      messages.add({'sender': 'user', 'text': option});
      _isLoading = true;
    });

    try {
      final prompt = '''
Provide detailed information on the following topic: $option
''';
      final response = await _model.generateContent([Content.text(prompt)]);
      final botReply = response.text?.trim() ??
          'I apologize, I couldn\'t provide information at this moment.';
      setState(() {
        messages.add({'sender': 'bot', 'text': botReply});
      });
    } catch (error) {
      setState(() {
        messages.add({
          'sender': 'bot',
          'text': 'Sorry, I couldn\'t provide a response at this time.'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final prompt = '''
Answer briefly and concisely in 1-2 sentences:

Question: $text
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final botReply = response.text?.trim() ??
          'Sorry, I didn\'t catch that. Could you rephrase?';

      setState(() {
        messages.add({'sender': 'bot', 'text': botReply});
      });
    } catch (error) {
      setState(() {
        messages
            .add({'sender': 'bot', 'text': 'Sorry, please try again later.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChronicleBot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[400],
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUserMessage = message['sender'] == 'user';
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isUserMessage ? Colors.blue[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _handleOptionClick(option),
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me about wound care...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.teal[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.teal[500]!),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.teal[500],
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
