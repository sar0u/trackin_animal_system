class HealthRecordModel {
  final String id;
  final String animalId;
  final String type;
  final String description;
  final DateTime date;
  final String vetId;
  final String vetName;
  final String notes;
  final bool isVerified;

  HealthRecordModel({
    required this.id,
    required this.animalId,
    required this.type,
    required this.description,
    required this.date,
    required this.vetId,
    required this.vetName,
    required this.notes,
    required this.isVerified,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] ?? '',
      animalId: json['animal_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      vetId: json['vet_id'] ?? '',
      vetName: json['vet_name'] ?? '',
      notes: json['notes'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'vet_id': vetId,
      'vet_name': vetName,
      'notes': notes,
      'is_verified': isVerified,
    };
  }
}