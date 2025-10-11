class LawyerEntity {
  final int id;
  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final int experience;
  final String location;
  final int fee;
  final String image;
  final bool verified;
  final String bio;
  final List<String> education;
  final List<String> achievements;
  final List<String> languages;
  final List<String> barAdmissions;

  LawyerEntity({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.location,
    required this.fee,
    required this.image,
    this.verified = false,
    required this.bio,
    this.education = const [],
    this.achievements = const [],
    this.languages = const [],
    this.barAdmissions = const [],
  });
}
