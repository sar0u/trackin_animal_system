class HealthSheetModel {
  final int animalId;
  final String rfidTag;
  final String species;
  final String? breed;
  final double? weight;
  final String status;
  final String farmName;
  final List<VaccinationDto> vaccinations;
  final List<HealthRecordDto> healthRecords;

  HealthSheetModel({
    required this.animalId,
    required this.rfidTag,
    required this.species,
    this.breed,
    this.weight,
    required this.status,
    required this.farmName,
    required this.vaccinations,
    required this.healthRecords,
  });

  factory HealthSheetModel.fromJson(Map<String, dynamic> json) {
    return HealthSheetModel(
      animalId: json['animalId'],
      rfidTag: json['rfidTag'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'],
      weight: json['weight'] != null ? double.parse(json['weight'].toString()) : null,
      status: json['status'] ?? '',
      farmName: json['farmName'] ?? '',
      vaccinations: (json['vaccinations'] as List? ?? [])
          .map((v) => VaccinationDto.fromJson(v))
          .toList(),
      healthRecords: (json['healthRecords'] as List? ?? [])
          .map((r) => HealthRecordDto.fromJson(r))
          .toList(),
    );
  }
}

class VaccinationDto {
  final int id;
  final String vaccineName;
  final String? vaccineType;
  final String? manufacturer;
  final String? batchNumber;
  final String? vaccinationDate;
  final String? expirationDate;

  VaccinationDto({
    required this.id,
    required this.vaccineName,
    this.vaccineType,
    this.manufacturer,
    this.batchNumber,
    this.vaccinationDate,
    this.expirationDate,
  });

  factory VaccinationDto.fromJson(Map<String, dynamic> json) {
    return VaccinationDto(
      id: json['id'],
      vaccineName: json['vaccineName'] ?? '',
      vaccineType: json['vaccineType'],
      manufacturer: json['manufacturer'],
      batchNumber: json['batchNumber'],
      vaccinationDate: json['vaccinationDate'],
      expirationDate: json['expirationDate'],
    );
  }
}

class HealthRecordDto {
  final int id;
  final String recordType;
  final String? diagnosis;
  final String? symptoms;
  final String? treatment;
  final String? visitDate;
  final String? nextVisitDate;
  final String? veterinarianName;

  HealthRecordDto({
    required this.id,
    required this.recordType,
    this.diagnosis,
    this.symptoms,
    this.treatment,
    this.visitDate,
    this.nextVisitDate,
    this.veterinarianName,
  });

  factory HealthRecordDto.fromJson(Map<String, dynamic> json) {
    return HealthRecordDto(
      id: json['id'],
      recordType: json['recordType'] ?? '',
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      visitDate: json['visitDate'],
      nextVisitDate: json['nextVisitDate'],
      veterinarianName: json['veterinarianName'],
    );
  }
}