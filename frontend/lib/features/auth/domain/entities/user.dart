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
  
  // Profile Image - ADDED
  final String? profileImageUrl;
  
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
    this.profileImageUrl, // ADDED
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

  // ADDED copyWith method
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
    bool? isVerified,
    bool? isApproved,
    DateTime? createdAt,
    String? profileImageUrl,
    String? phone,
    String? location,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
    double? rating,
    int? totalCases,
    String? education,
    String? achievements,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      licenseId: licenseId ?? this.licenseId,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalCases: totalCases ?? this.totalCases,
      education: education ?? this.education,
      achievements: achievements ?? this.achievements,
    );
  }

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
        profileImageUrl, // ADDED
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