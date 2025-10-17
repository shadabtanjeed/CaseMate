import '../../../core/network/api_client.dart';

class ChatbotApiService {
  final ApiClient apiClient;
  ChatbotApiService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<String> getChatbotAnswer(
    String question, {
    String contextPrompt = '',
  }) async {
    // Adjust endpoint as per your backend route
    const endpoint = '/chatbot/chat';

    // Send context separately so backend uses only the question for retrieval
    final Map<String, dynamic> body = {
      'message': question,
    };

    if (contextPrompt.isNotEmpty) {
      body['context'] = contextPrompt;
    }

    final response = await apiClient.post(
      endpoint,
      body: body,
    );
    // Only return the 'answer' field
    return response['answer']?.toString() ?? '';
  }
}
