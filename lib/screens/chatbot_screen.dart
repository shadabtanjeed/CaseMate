import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  final List<ChatMessage> _messages = [
    ChatMessage(
      isBot: true,
      message:
          "Hello! I'm LegalBot, your AI legal assistant. How can I help you today?",
      timestamp: DateTime.now(),
    ),
  ];
  String _mode = 'general';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          isBot: false,
          message: _messageController.text,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // Simulate bot response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            isBot: true,
            message:
                'Based on your query, this seems to be a legal matter that would benefit from professional consultation. I can provide general information, but for specific legal advice, I recommend speaking with a qualified lawyer.',
            timestamp: DateTime.now(),
            showLawyerButton: true,
          ),
        );
      });
    });
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
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
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppTheme.primaryBlue
            : AppTheme.background,
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
        mainAxisAlignment: message.isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
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
                  child: Text(
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
              onPressed: () {},
              color: AppTheme.textSecondary,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
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
