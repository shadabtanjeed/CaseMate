import '../../domain/entities/lawyer_entity.dart';

class LawyerModel extends LawyerEntity {
  LawyerModel({
    required super.id,
    required super.name,
    required super.specialization,
    super.email,
    required super.rating,
    required super.reviews,
    required super.experience,
    required super.location,
    required super.fee,
    required super.image,
    super.verified,
    required super.bio,
    super.education,
    super.achievements,
    super.languages,
    super.barAdmissions,
  });

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic raw) {
      if (raw == null) return '';
      return raw.toString();
    }

    double parseRating(dynamic r) {
      if (r == null) return 0.0;
      if (r is double) return r;
      if (r is int) return r.toDouble();
      final s = r.toString();
      return double.tryParse(s) ?? 0.0;
    }

    return LawyerModel(
      id: parseId(json['id']),
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      email: json['email'],
      rating: parseRating(json['rating']),
      reviews: (json['reviews'] is int)
          ? json['reviews'] as int
          : (int.tryParse(json['reviews']?.toString() ?? '') ?? 0),
      experience: (json['experience'] is int)
          ? json['experience'] as int
          : (int.tryParse(json['experience']?.toString() ?? '') ?? 0),
      location: json['location'] ?? '',
      fee: (json['fee'] is int)
          ? json['fee'] as int
          : (int.tryParse(json['fee']?.toString() ?? '') ?? 0),
      image: json['image'] ?? '',
      verified: json['verified'] ?? false,
      bio: json['bio'] ?? '',
      education: List<String>.from(json['education'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      barAdmissions: List<String>.from(json['barAdmissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'reviews': reviews,
      'experience': experience,
      'location': location,
      'fee': fee,
      'image': image,
      'verified': verified,
      'bio': bio,
      'education': education,
      'achievements': achievements,
      'languages': languages,
      'barAdmissions': barAdmissions,
      'email': email,
    };
  }
}
