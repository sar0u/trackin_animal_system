class ControlCheckResponse {
  final int sessionId;
  final int farmId;
  final String farmName;
  final int expectedCount;
  final int detectedCount;
  final int missingCount;
  final int unknownCount;
  final List<String> missingTags;
  final List<String> unknownTags;
  final String result;

  ControlCheckResponse({
    required this.sessionId,
    required this.farmId,
    required this.farmName,
    required this.expectedCount,
    required this.detectedCount,
    required this.missingCount,
    required this.unknownCount,
    required this.missingTags,
    required this.unknownTags,
    required this.result,
  });

  factory ControlCheckResponse.fromJson(Map<String, dynamic> json) {
    return ControlCheckResponse(
      sessionId: _safeInt(json['sessionId']),
      farmId: _safeInt(json['farmId']),
      farmName: json['farmName']?.toString() ?? '',
      expectedCount: _safeInt(json['expectedCount']),
      detectedCount: _safeInt(json['detectedCount']),
      missingCount: _safeInt(json['missingCount']),
      unknownCount: _safeInt(json['unknownCount']),
      missingTags: _safeList(json['missingTags']),
      unknownTags: _safeList(json['unknownTags']),
      result: json['result']?.toString() ?? 'EN_COURS',
    );
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static List<String> _safeList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}