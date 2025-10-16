import '../../domain/entities/lawyer_entity.dart';

class LawyerModel extends LawyerEntity {
  LawyerModel({
    required String id,
    required String name,
    required String specialization,
    String? email,
    required double rating,
    required int reviews,
    required int experience,
    required String location,
    required int fee,
    required String image,
    bool verified = false,
    required String bio,
    List<String> education = const [],
    List<String> achievements = const [],
    List<String> languages = const [],
    List<String> barAdmissions = const [],
  }) : super(
          id: id,
          name: name,
          specialization: specialization,
          email: email,
          rating: rating,
          reviews: reviews,
          experience: experience,
          location: location,
          fee: fee,
          image: image,
          verified: verified,
          bio: bio,
          education: education,
          achievements: achievements,
          languages: languages,
          barAdmissions: barAdmissions,
        );

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
