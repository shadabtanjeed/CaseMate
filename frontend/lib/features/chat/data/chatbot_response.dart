class ChatbotResponse {
  final String answer;
  ChatbotResponse({required this.answer});

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(answer: json['answer'] ?? '');
  }
}
