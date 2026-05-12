class FarmModel {
  final int id;
  final String name;
  final String? location;
  final String? wilaya;
  final String? commune;

  FarmModel({
    required this.id,
    required this.name,
    this.location,
    this.wilaya,
    this.commune,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString(),
      wilaya: json['wilaya']?.toString(),
      commune: json['commune']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}