import '../../domain/entities/time_slot_entity.dart';

class TimeSlotModel extends TimeSlotEntity {
  TimeSlotModel({
    required super.date,
    required super.day,
    required super.times,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      date: json['date'],
      day: json['day'],
      times: List<String>.from(json['times'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'times': times,
    };
  }
}
