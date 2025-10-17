import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatHistoryService {
  static const String _chatHistoryKey = 'chat_history_general';
  static const String _caseAnalysisChatKey = 'chat_history_case';
  static const int _maxMessages = 20; // Store last 20 messages total

  Future<void> saveChatMessage({
    required String message,
    required bool isBot,
    required String mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = mode == 'case' ? _caseAnalysisChatKey : _chatHistoryKey;

    final history = await getChatHistory(mode);

    history.add({
      'message': message,
      'isBot': isBot,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only the last _maxMessages messages
    if (history.length > _maxMessages) {
      history.removeRange(0, history.length - _maxMessages);
    }

    await prefs.setString(key, jsonEncode(history));
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = mode == 'case' ? _caseAnalysisChatKey : _chatHistoryKey;

    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Get the last N messages as context (excludes the current message being replied to)
  /// Uses intelligent filtering to avoid context overload
  Future<String> getContextPrompt(String mode, int lastNMessages) async {
    final history = await getChatHistory(mode);

    if (history.isEmpty) {
      return '';
    }

    // Get last N messages (or all if less than N)
    final contextMessages = history.length > lastNMessages
        ? history.sublist(history.length - lastNMessages)
        : history;

    // Filter: Only include meaningful exchanges (user message + bot response)
    final meaningfulExchanges = <Map<String, dynamic>>[];
    for (int i = 0; i < contextMessages.length; i++) {
      final msg = contextMessages[i];

      // Skip very short messages (likely incomplete or typos)
      if ((msg['message'] as String).length < 5) {
        continue;
      }

      // Skip "I do not know" responses to avoid confusing the model
      if (msg['isBot'] == true &&
          (msg['message'] as String).toLowerCase().contains('do not know')) {
        continue;
      }

      meaningfulExchanges.add(msg);
    }

    if (meaningfulExchanges.isEmpty) {
      return '';
    }

    // Build context with better formatting and relevance hints
    final buffer = StringBuffer();
    buffer.writeln('CONVERSATION CONTEXT (for reference only):');
    buffer.writeln('===========================================');

    int exchangeNum = 1;
    for (var msg in meaningfulExchanges) {
      final role = msg['isBot'] == true ? 'Assistant' : 'User';
      final message = msg['message'] as String;

      // Truncate very long messages to avoid token bloat
      final truncatedMessage =
          message.length > 200 ? message.substring(0, 200) + '...' : message;

      buffer.writeln('[$exchangeNum] $role: $truncatedMessage');

      if (msg['isBot'] == true) {
        exchangeNum++;
      }
    }

    buffer.writeln('===========================================');
    buffer.writeln(
        'NOTE: Use the context above only if it helps answer the new question.');
    buffer.writeln(
        'If the new question is on a different topic, focus on answering it directly.');
    buffer.writeln('');

    return buffer.toString();
  }

  /// Intelligent context that detects topic shifts and avoids confusion
  /// Returns empty context if topic seems completely different
  Future<String> getSmartContextPrompt(
      String mode, String currentQuestion) async {
    final history = await getChatHistory(mode);

    if (history.isEmpty) {
      return '';
    }

    // Get only the last 5 exchanges (10 messages) to keep it focused
    final recentMessages =
        history.length > 10 ? history.sublist(history.length - 10) : history;

    // Extract user's last question for comparison
    String lastUserQuestion = '';
    for (var msg in recentMessages.reversed) {
      if (msg['isBot'] != true) {
        lastUserQuestion = msg['message'] as String;
        break;
      }
    }

    // Simple topic similarity check - if questions are too different, don't include context
    if (lastUserQuestion.isNotEmpty &&
        !_isRelatedTopic(lastUserQuestion, currentQuestion)) {
      return 'NOTE: New topic detected. Please answer the current question directly.\n\n';
    }

    // Build selective context
    final buffer = StringBuffer();
    buffer.writeln('RECENT CONTEXT (last few exchanges):');
    buffer.writeln('---');

    for (var msg in recentMessages) {
      final role = msg['isBot'] == true ? 'Assistant' : 'User';
      final message = msg['message'] as String;

      // Skip very short or "I don't know" messages
      if (message.length < 5 ||
          (msg['isBot'] == true &&
              message.toLowerCase().contains('do not know'))) {
        continue;
      }

      // Truncate long messages
      final displayMessage =
          message.length > 150 ? message.substring(0, 150) + '...' : message;

      buffer.writeln('$role: $displayMessage');
    }

    buffer.writeln('---');
    buffer.writeln('');

    return buffer.toString();
  }

  /// Simple topic relevance checker
  bool _isRelatedTopic(String previousQuestion, String currentQuestion) {
    // Convert to lowercase for comparison
    final prev = previousQuestion.toLowerCase();
    final curr = currentQuestion.toLowerCase();

    // Legal topic keywords
    const legalKeywords = [
      'law',
      'legal',
      'court',
      'judge',
      'attorney',
      'lawyer',
      'contract',
      'property',
      'crime',
      'criminal',
      'civil',
      'family',
      'divorce',
      'copyright',
      'patent',
      'trademark',
      'business',
      'tax',
      'estate',
      'will',
      'inheritance',
      'tenant',
      'landlord',
      'employment',
      'rights'
    ];

    // Count matching keywords
    int matchingKeywords = 0;
    for (var keyword in legalKeywords) {
      if (prev.contains(keyword) && curr.contains(keyword)) {
        matchingKeywords++;
      }
    }

    // If at least 2 common legal keywords, consider it related
    // Or if questions share more than 30% of words, consider them related
    if (matchingKeywords >= 2) {
      return true;
    }

    // Check word overlap
    final prevWords = prev.split(' ').toSet();
    final currWords = curr.split(' ').toSet();
    final commonWords = prevWords.intersection(currWords);

    final overlapRatio =
        commonWords.length / ((prevWords.length + currWords.length) / 2);
    return overlapRatio > 0.3;
  }

  /// Clear chat history for a specific mode
  Future<void> clearChatHistory(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = mode == 'case' ? _caseAnalysisChatKey : _chatHistoryKey;

    await prefs.remove(key);
  }

  /// Clear all chat histories
  Future<void> clearAllChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
    await prefs.remove(_caseAnalysisChatKey);
  }
}
