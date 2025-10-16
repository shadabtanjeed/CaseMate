
//user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final bool isVerified;
  final bool isApproved;
  final DateTime createdAt;
  // Common user fields
  final String? phone;
  final String? location;
  // Lawyer extra fields
  final String? education;
  final String? achievements;
  
  // Lawyer-specific fields
  final String? licenseId;
  final String? specialization;
  final int? yearsOfExperience;
  final String? bio;
  final double? rating;
  final int? totalCases;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.isVerified,
    required this.isApproved,
    required this.createdAt,
    // Common user fields
    this.phone,
    this.location,
    this.licenseId,
    this.specialization,
    this.yearsOfExperience,
    this.bio,
    this.rating,
    this.totalCases,
    this.education,
    this.achievements,
  });

  bool get isLawyer => role == 'lawyer';
  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        isActive,
        isVerified,
        isApproved,
        createdAt,
        phone,
        location,
        licenseId,
        specialization,
        yearsOfExperience,
        bio,
        education,
        achievements,
        rating,
        totalCases,
      ];
}