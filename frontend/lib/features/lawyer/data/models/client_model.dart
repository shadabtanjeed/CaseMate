class ClientModel {
  final String userEmail;
  final String fullName;
  final String? phone;
  final String? location;
  final String? profileImageUrl;
  final bool isActive;
  final int activeCases;
  final int completedCases;
  final int totalCases;
  final String recentCaseTitle;
  final String recentCaseType;
  final String recentCaseStatus;
  final DateTime? lastCaseDate;

  ClientModel({
    required this.userEmail,
    required this.fullName,
    this.phone,
    this.location,
    this.profileImageUrl,
    required this.isActive,
    required this.activeCases,
    required this.completedCases,
    required this.totalCases,
    required this.recentCaseTitle,
    required this.recentCaseType,
    required this.recentCaseStatus,
    this.lastCaseDate,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      userEmail: json['user_email'] ?? '',
      fullName: json['full_name'] ?? 'Unknown',
      phone: json['phone'],
      location: json['location'],
      profileImageUrl: json['profile_image_url'],
      isActive: json['is_active'] ?? false,
      activeCases: json['active_cases'] ?? 0,
      completedCases: json['completed_cases'] ?? 0,
      totalCases: json['total_cases'] ?? 0,
      recentCaseTitle: json['recent_case_title'] ?? '',
      recentCaseType: json['recent_case_type'] ?? 'Unknown',
      recentCaseStatus: json['recent_case_status'] ?? '',
      lastCaseDate: json['last_case_date'] != null
          ? DateTime.parse(json['last_case_date'])
          : null,
    );
  }

  String get displayName => fullName;
  
  String get sessionCount => '$totalCases session${totalCases != 1 ? 's' : ''}';
  
  String get statusText => isActive ? 'Active' : 'Completed';
  
  String get lastDateText {
    if (lastCaseDate == null) return 'No date';
    
    final date = lastCaseDate!;
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (isActive) {
      if (difference.inDays == 0) {
        return 'Last: Today';
      } else if (difference.inDays == 1) {
        return 'Last: Yesterday';
      } else if (difference.inDays < 7) {
        return 'Last: ${difference.inDays} days ago';
      } else {
        return 'Last: ${date.month}/${date.day}/${date.year}';
      }
    } else {
      return 'Ended: ${date.month}/${date.day}/${date.year}';
    }
  }
}