import '../../domain/entities/lawyer_entity.dart';

class LawyerModel extends LawyerEntity {
  LawyerModel({
    required super.id,
    required super.name,
    required super.specialization,
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
    return LawyerModel(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      rating: json['rating'].toDouble(),
      reviews: json['reviews'],
      experience: json['experience'],
      location: json['location'],
      fee: json['fee'],
      image: json['image'],
      verified: json['verified'] ?? false,
      bio: json['bio'],
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
    };
  }
}
