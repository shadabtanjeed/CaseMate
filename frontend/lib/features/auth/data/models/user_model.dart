import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.isActive,
    required super.isVerified,
    required super.isApproved,
    required super.createdAt,
    super.phone,
    super.location,
    super.licenseId,
    super.specialization,
    super.yearsOfExperience,
    super.bio,
    super.education,
    super.achievements,
    super.rating,
    super.totalCases,
    super.profileImageUrl,  // ADDED
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      isApproved: json['is_approved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      licenseId: json['license_id'] as String?,
      specialization: json['specialization'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      bio: json['bio'] as String?,
      education: json['education'] as String?,
      achievements: json['achievements'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalCases: json['total_cases'] as int?,
      profileImageUrl: json['profile_image_url'] as String?,  // ADDED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'phone': phone,
      'location': location,
      'license_id': licenseId,
      'specialization': specialization,
      'years_of_experience': yearsOfExperience,
      'bio': bio,
      'education': education,
      'achievements': achievements,
      'rating': rating,
      'total_cases': totalCases,
      'profile_image_url': profileImageUrl,  // ADDED
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      isActive: isActive,
      isVerified: isVerified,
      isApproved: isApproved,
      createdAt: createdAt,
      phone: phone,
      location: location,
      licenseId: licenseId,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      education: education,
      achievements: achievements,
      rating: rating,
      totalCases: totalCases,
      profileImageUrl: profileImageUrl,  // ADDED
    );
  }
}