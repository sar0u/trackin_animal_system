class MovementModel {
  final int? id;
  final int animalId;
  final String animalRfidTag;
  final String movementType;
  final int? fromFarmId;
  final String? fromFarmName;
  final int? toFarmId;
  final String? toFarmName;
  final String movementDate;
  final double? price;
  final String? counterpartyName;
  final String? counterpartyPhone;
  final String? documentReference;
  final double? latitude;
  final double? longitude;
  final String? performedByUsername;
  final String? notes;

  MovementModel({
    this.id,
    required this.animalId,
    required this.animalRfidTag,
    required this.movementType,
    this.fromFarmId,
    this.fromFarmName,
    this.toFarmId,
    this.toFarmName,
    required this.movementDate,
    this.price,
    this.counterpartyName,
    this.counterpartyPhone,
    this.documentReference,
    this.latitude,
    this.longitude,
    this.performedByUsername,
    this.notes,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      id: _toInt(json['id']),
      animalId: _toInt(json['animalId']),
      animalRfidTag: json['animalRfidTag']?.toString() ?? '',
      movementType: json['movementType']?.toString() ?? '',
      fromFarmId: _nullableInt(json['fromFarmId']),
      fromFarmName: json['fromFarmName']?.toString(),
      toFarmId: _nullableInt(json['toFarmId']),
      toFarmName: json['toFarmName']?.toString(),
      movementDate: json['movementDate']?.toString() ?? '',
      price: _nullableDouble(json['price']),
      counterpartyName: json['counterpartyName']?.toString(),
      counterpartyPhone: json['counterpartyPhone']?.toString(),
      documentReference: json['documentReference']?.toString(),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      performedByUsername: json['performedByUsername']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _nullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}