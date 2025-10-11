import 'package:flutter/material.dart';

class Lawyer {
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

  Lawyer({
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

class Review {
  final int id;
  final String name;
  final int rating;
  final String date;
  final String comment;

  Review({
    required this.id,
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class TimeSlot {
  final String date;
  final String day;
  final List<String> times;

  TimeSlot({
    required this.date,
    required this.day,
    required this.times,
  });
}

class Consultation {
  final String lawyer;
  final String specialization;
  final String date;
  final String time;
  final String type;

  Consultation({
    required this.lawyer,
    required this.specialization,
    required this.date,
    required this.time,
    required this.type,
  });
}

class LegalCategory {
  final String label;
  final IconData icon;
  final Color color;

  LegalCategory({
    required this.label,
    required this.icon,
    required this.color,
  });
}
