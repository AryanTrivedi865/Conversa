import 'dart:convert';

import 'package:conversa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  bool isClicked = true;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isClicked = prefs.getBool('aiChat') ?? false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> chatHistory = prefs.getStringList('chatHistory') ?? [];

    setState(() {
      _messages = chatHistory.map((jsonMessage) {
        Map<String, dynamic> messageData = jsonDecode(jsonMessage);
        return ChatMessage(
          text: messageData['text'],
          isUser: messageData['isUser'],
        );
      }).toList();
    });
  }

  void _saveChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonMessages = _messages.map((message) {
      return jsonEncode({
        'text': message.text,
        'isUser': message.isUser,
      });
    }).toList();
    prefs.setStringList('chatHistory', jsonMessages);
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });
    setState(() {
      _messages
          .add(ChatMessage(text: "<\"data\": \"loading\">", isUser: false));
    });
    getChatResponse(message).then((response) {
      final utf8Response = utf8.decode(response.runes.toList());
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(text: utf8Response, isUser: false));
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _saveChatHistory();
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return isClicked
        ? Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Lottie.asset(
                          'assets/lottie_animation/ai.json',
                        ))
                      : Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: message.isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65,
                                      ),
                                      decoration: BoxDecoration(
                                        color: message.isUser
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      child: (message.text ==
                                              "<\"data\": \"loading\">")
                                          ? Lottie.asset(
                                              'assets/lottie_animation/typing.json',
                                              height: 24,
                                              width: 48,
                                            )
                                          : Text(
                                              message.text,
                                              style: TextStyle(
                                                color: message.isUser
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Reset LunaAI',
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () async {
                                      setState(() {
                                        _messages.clear();
                                      });
                                      _saveChatHistory();
                                      _controller.clear();
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool('aiChat', false);
                                      setState(
                                        () {
                                          isClicked = false;
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Clear Chat',
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      clearChat();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ScreenUtils.screenHeightRatio(context, 0.04)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: ScreenUtils.screenWidthRatio(context, 0.04)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                                hintText: "Enter your message...",
                                border: InputBorder.none),
                            textInputAction: TextInputAction.send,
                            maxLines: 5,
                            minLines: 1,
                            onFieldSubmitted: (value) {
                              if (_controller.text.isNotEmpty) {
                                _sendMessage(_controller.text);
                              }
                              _controller.clear();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _sendMessage(_controller.text);
                            }
                            _controller.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie_animation/ai.json', height: 400),
                FilledButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('aiChat', true);
                    setState(() {
                      isClicked = true;
                    });
                  },
                  child: Text('Get Started'),
                ),
              ],
            ),
          );
  }

  void clearChat() {
    setState(() {
      _messages.clear();
    });
    _saveChatHistory();
    _controller.clear();
  }

  Future<String> getChatResponse(String message) async {
    final apiKey = 'YOUR_API_KEY';
    final endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a user'},
          {'role': 'user', 'content': message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final botResponse = responseData['choices'][0]['message']['content'];
      return botResponse;
    } else {
      print('API request failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to get response from API');
    }
  }
}
