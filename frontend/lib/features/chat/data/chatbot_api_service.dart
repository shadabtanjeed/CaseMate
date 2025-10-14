import '../../../core/network/api_client.dart';

class ChatbotApiService {
  final ApiClient apiClient;
  ChatbotApiService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<String> getChatbotAnswer(String question) async {
    // Adjust endpoint as per your backend route
    const endpoint = '/chatbot/chat';
    final response = await apiClient.post(
      endpoint,
      body: {'message': question},
    );
    // Only return the 'answer' field
    return response['answer']?.toString() ?? '';
  }
}
