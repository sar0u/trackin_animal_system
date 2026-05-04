class FarmStatsModel {
  final int totalAnimaux;
  final int animauxActifs;
  final int animauxVendus;
  final int animauxMorts;
  final String farmName;
  final int farmId;

  FarmStatsModel({
    required this.totalAnimaux,
    required this.animauxActifs,
    required this.animauxVendus,
    required this.animauxMorts,
    required this.farmName,
    required this.farmId,
  });

  factory FarmStatsModel.fromJson(Map<String, dynamic> json) {
    return FarmStatsModel(
      totalAnimaux: _safeInt(json['totalAnimaux']),
      animauxActifs: _safeInt(json['animauxActifs']),
      animauxVendus: _safeInt(json['animauxVendus']),
      animauxMorts: _safeInt(json['animauxMorts']),
      farmName: json['farmName']?.toString() ?? '',
      farmId: _safeInt(json['farmId']),
    );
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}