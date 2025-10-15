import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/chatbot_api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuggestLawyers;

  const ChatbotScreen({
    super.key,
    required this.onBack,
    required this.onSuggestLawyers,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  final List<ChatMessage> _messages = [
    ChatMessage(
      isBot: true,
      message: '''
Hello! I'm CaseMateBot, your AI legal assistant. How can I help you today?

**Please be aware that my responses are for informational purposes only and do not constitute legal advice. The app will not be liable for any actions taken based on my responses.**
''',
      timestamp: DateTime.now(),
    ),
  ];
  String _mode = 'general';
  final ChatbotApiService _apiService = ChatbotApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        isBot: false,
        message: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _messageController.clear();

    try {
      final String answer = await _apiService.getChatbotAnswer(text);
      setState(() {
        _messages.add(ChatMessage(
          isBot: true,
          message: (answer.isNotEmpty) ? answer : 'I do not know',
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          isBot: true,
          message: 'Sorry, failed to get a response from the server.',
          timestamp: DateTime.now(),
        ));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: AppTheme.primaryBlue),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LegalBot', style: TextStyle(fontSize: 18)),
                Text(
                  'AI Legal Assistant',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildModeSelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.accentBlue,
                            child: Icon(Icons.smart_toy,
                                size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text('...'),
                        ],
                      ),
                    ),
                  );
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildModeButton('General Advice', 'general')),
          const SizedBox(width: 8),
          Expanded(child: _buildModeButton('Case Analysis', 'case')),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = _mode == mode;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _mode = mode;
          // When entering case analysis, show a coming-soon message and disable input
          if (_mode == 'case') {
            _messages.clear();
            _messages.add(ChatMessage(
              isBot: true,
              message:
                  'Case analysis is coming soon. This feature will be available in a future release.',
              timestamp: DateTime.now(),
            ));
          } else {
            // On switching back to general, ensure the friendly welcome message exists
            if (_messages.isEmpty ||
                (_messages.length == 1 &&
                    _messages[0].message.contains('coming soon'))) {
              _messages.clear();
              _messages.add(ChatMessage(
                isBot: true,
                message: '''
Hello! I'm CaseMateBot, your AI legal assistant. How can I help you today?

**Please be aware that my responses are for informational purposes only and do not constitute legal advice. The app will not be liable for any actions taken based on my responses.**
''',
                timestamp: DateTime.now(),
              ));
            }
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppTheme.primaryBlue : AppTheme.background,
        foregroundColor: isSelected ? Colors.white : AppTheme.textSecondary,
        elevation: 0,
      ),
      child: Text(label),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentBlue,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isBot
                        ? AppTheme.accentBlue.withOpacity(0.2)
                        : AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // render markdown for bot messages, plain text for user messages
                  child: message.isBot
                      ? MarkdownBody(
                          data: message.message,
                          selectable: false,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(Theme.of(context))
                                  .copyWith(
                            p: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        )
                      : Text(
                          message.message,
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (message.showLawyerButton) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: widget.onSuggestLawyers,
                    child: const Text('Find Lawyers'),
                  ),
                ],
              ],
            ),
          ),
          if (!message.isBot) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.borderColor,
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Attachment feature coming soon')),
                );
              },
              color: AppTheme.textSecondary,
            ),
            Expanded(
              child: RawKeyboardListener(
                focusNode: _textFocusNode,
                onKey: (event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    // if shift is pressed, allow newline
                    if (event.isShiftPressed) {
                      final newText = _messageController.text + '\n';
                      _messageController.text = newText;
                      _messageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: newText.length));
                    } else {
                      // prevent send in case mode
                      if (_mode != 'case') {
                        _sendMessage();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Case analysis coming soon')));
                      }
                    }
                  }
                },
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _mode == 'case'
                        ? 'Case analysis coming soon'
                        : 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  enabled: _mode != 'case',
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {},
              color: AppTheme.textSecondary,
            ),
            CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final bool isBot;
  final String message;
  final DateTime timestamp;
  final bool showLawyerButton;

  ChatMessage({
    required this.isBot,
    required this.message,
    required this.timestamp,
    this.showLawyerButton = false,
  });
}
