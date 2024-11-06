import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Replace with your actual OpenAI API key
  final String _apiKey = 'YOUR_API_KEY_HERE';

  // Map of common questions and answers about Samsung TVs
  final Map<String, String> _predefinedAnswers = {
    "hi": "Hello, how may I help you?",
    "hii": "Hello, how may I help you?",
    "hello": "Hello, how may I help you?",
    "hey": "Hello, how may I help you?",
    "good morning": "Hello, how may I help you?",
    "what is the latest samsung tv model": "The latest Samsung TV model is the Samsung QN900A Neo QLED 8K.",
    "how to connect my samsung tv to wifi": "Go to Settings > Network > Network Settings and select your Wi-Fi network.",
    "what is samsung smart hub": "Samsung Smart Hub is an intuitive interface that allows you to access apps, streaming services, and more.",
    "how to reset my samsung tv": "Press and hold the power button on the remote for 10 seconds to reset your TV.",
    "can i mirror my phone to my samsung tv": "Yes, you can use Smart View or the screen mirroring feature on your phone to cast to your Samsung TV.",
    "what to do if my samsung tv won't turn on": "Unplug the TV for a minute, then plug it back in. If it still doesn't turn on, try a factory reset.",
    "what apps are available on samsung smart tv": "Popular apps include Netflix, YouTube, Hulu, and many more. You can download more from the Samsung App Store.",
    "how can i control my samsung tv with my phone": "Download the SmartThings app on your phone to control your TV remotely.",
    "what is game mode on samsung tv": "Game Mode reduces input lag and optimizes picture settings for gaming.",
    "how to enable voice control on my samsung tv": "Go to Settings > General > Voice > Voice Wake-Up and enable it.",
    "how can i watch youtube on my samsung tv": "You can download the YouTube app from the Samsung App Store or access it through the Smart Hub."
  };

  // Function to send request to OpenAI's API and get a response
  Future<String> _getResponseFromOpenAI(String prompt) async {
    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');
    int retries = 3; // Number of retry attempts
    int delay = 2; // Initial delay in seconds

    while (retries > 0) {
      try {
        final response = await http.post(
          apiUrl,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            "model": "gpt-3.5-turbo", // Use the appropriate model
            "messages": [
              {"role": "user", "content": prompt}
            ],
            "max_tokens": 100,
            "temperature": 0.7,
          }),
        );

        // Log status code and response body for debugging
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          return responseData['choices'][0]['message']['content'].trim();
        } else if (response.statusCode == 429) {
          // Too Many Requests
          await Future.delayed(Duration(seconds: delay));
          delay *= 2; // Exponential backoff
        } else {
          return 'Error ${response.statusCode}: ${response.reasonPhrase}';
        }
      } catch (e) {
        print('Exception caught: $e');
        return 'Failed to connect to OpenAI. Please try again later.';
      }
      retries--;
    }

    return 'Failed due to rate limit. Please wait and try again.';
  }

  // Function to handle sending a message and receiving a response
  void _sendMessage() async {
    final String message = _controller.text.toLowerCase(); // Convert to lowercase for matching
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': message});
      _controller.clear();
      _isLoading = true;
    });

    // Check for predefined answers first
    if (_predefinedAnswers.containsKey(message)) {
      // Add a delay for the predefined answer
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _messages.add({'role': 'bot', 'message': _predefinedAnswers[message]!});
        _isLoading = false;
      });
      return;
    }

    // If the question is not predefined, return the Samsung official site link
    setState(() {
      _messages.add({
        'role': 'bot',
        'message': 'For more information, please visit https://www.samsung.com.'
      });
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot', style: TextStyle(color: Colors.white)), // Set text color to white
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // This is also important for the icon color
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['role'] == 'user'
                            ? Colors.black
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message['message']!,
                        style: TextStyle(
                          color: message['role'] == 'user'
                              ? Colors.white
                              : Colors.black,
                          // Remove boldness from chat messages
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
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
