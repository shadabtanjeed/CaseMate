import '../../domain/entities/consultation_entity.dart';

class ConsultationModel extends ConsultationEntity {
  ConsultationModel({
    required super.lawyer,
    required super.specialization,
    required super.date,
    required super.time,
    required super.type,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      lawyer: json['lawyer'],
      specialization: json['specialization'],
      date: json['date'],
      time: json['time'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lawyer': lawyer,
      'specialization': specialization,
      'date': date,
      'time': time,
      'type': type,
    };
  }
}
