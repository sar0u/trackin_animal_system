class AnimalModel {
  final int id;
  final String rfidTag;
  final String species;
  final String? breed;
  final String? gender;
  final double? weight;
  final String status;
  final String? color;
  final String? birthDate;
  final int farmId;
  final String farmName;

  AnimalModel({
    required this.id,
    required this.rfidTag,
    required this.species,
    this.breed,
    this.gender,
    this.weight,
    required this.status,
    this.color,
    this.birthDate,
    required this.farmId,
    required this.farmName,
  });

  static String _normalizeStatus(String? raw) {
    switch (raw) {
      case 'Active':      return 'ACTIF';
      case 'Sold':        return 'VENDU';
      case 'Lost':        return 'PERDU';
      case 'Dead':        return 'MORT';
      case 'Slaughtered': return 'ABATTU';
      default:            return raw ?? '';
    }
  }

  static String? _normalizeGender(String? raw) {
    if (raw == null) return null;
    return raw.toUpperCase();
  }

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'],
      rfidTag: json['rfidTag'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'],
      gender: _normalizeGender(json['gender']),
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      status: _normalizeStatus(json['status']?.toString()),
      color: json['color'],
      birthDate: json['birthDate'],
      farmId: json['farmId'],
      farmName: json['farmName'] ?? '',
    );
  }
}