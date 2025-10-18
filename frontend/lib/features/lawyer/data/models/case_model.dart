import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CaseModel {
  final String id;
  final String caseId;
  final String appointmentId;
  final DateTime creationDate;
  final String lawyerEmail;
  final String userEmail;
  final String status;
  final DateTime lastUpdated;
  final String caseType;
  final String caseTitle;
  final String description;

  CaseModel({
    required this.id,
    required this.caseId,
    required this.appointmentId,
    required this.creationDate,
    required this.lawyerEmail,
    required this.userEmail,
    required this.status,
    required this.lastUpdated,
    required this.caseType,
    required this.caseTitle,
    required this.description,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['_id']?['\$oid'] ?? '',
      caseId: json['case_id'] ?? '',
      appointmentId: json['appointment_id'] ?? '',
      creationDate: json['creation_date']?['\$date'] != null
          ? DateTime.parse(json['creation_date']['\$date'])
          : DateTime.now(),
      lawyerEmail: json['lawyer_email'] ?? '',
      userEmail: json['user_email'] ?? '',
      status: json['status'] ?? 'pending',
      lastUpdated: json['last_updated']?['\$date'] != null
          ? DateTime.parse(json['last_updated']['\$date'])
          : DateTime.now(),
      caseType: json['case_type'] ?? 'Unknown',
      caseTitle: json['case_title'] ?? 'Untitled Case',
      description: json['description'] ?? 'No description',
    );
  }

  String get clientName => userEmail.split('@')[0];
  
  String get priorityLevel {
    if (status == 'ongoing' && caseType == 'Criminal') return 'High';
    if (status == 'pending') return 'Medium';
    return 'Low';
  }
  
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return AppTheme.primaryBlue;
      case 'pending':
        return Colors.orange;
      case 'closed':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }
  
  double get progressValue {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.3;
      case 'active':
      case 'ongoing':
        return 0.6;
      case 'closed':
        return 1.0;
      default:
        return 0.0;
    }
  }
}