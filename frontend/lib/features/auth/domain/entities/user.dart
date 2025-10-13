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
    this.licenseId,
    this.specialization,
    this.yearsOfExperience,
    this.bio,
    this.rating,
    this.totalCases,
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
        licenseId,
        specialization,
        yearsOfExperience,
        bio,
        rating,
        totalCases,
      ];
}