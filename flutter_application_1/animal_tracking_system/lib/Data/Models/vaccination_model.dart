class VaccinationModel {
  final String id;
  final String animalId;
  final String vaccineName;
  final String lotNumber;
  final DateTime date;
  final DateTime nextVaccination;
  final String vetId;
  final String vetName;
  final String notes;
  final bool isVerified;

  VaccinationModel({
    required this.id,
    required this.animalId,
    required this.vaccineName,
    required this.lotNumber,
    required this.date,
    required this.nextVaccination,
    required this.vetId,
    required this.vetName,
    required this.notes,
    required this.isVerified,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'],
      animalId: json['animal_id'],
      vaccineName: json['vaccine_name'],
      lotNumber: json['lot_number'],
      date: DateTime.parse(json['date']),
      nextVaccination: DateTime.parse(json['next_vaccination']),
      vetId: json['vet_id'],
      vetName: json['vet_name'],
      notes: json['notes'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'vaccine_name': vaccineName,
      'lot_number': lotNumber,
      'date': date.toIso8601String(),
      'next_vaccination': nextVaccination.toIso8601String(),
      'vet_id': vetId,
      'vet_name': vetName,
      'notes': notes,
      'is_verified': isVerified,
    };
  }
}