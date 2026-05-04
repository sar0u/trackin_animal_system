class UhfService {
  final List<String> _farm1Tags = [
    'ID-0001',
    'ID-0002',
    'ID-0003',
  ];

  final List<String> _farm2Tags = [
    'ID-0004',
    'ID-0005',
  ];

  Future<List<String>> performUhfScan({int farmId = 1}) async {
    await Future.delayed(const Duration(seconds: 2));

    if (farmId == 1) return List.from(_farm1Tags);
    if (farmId == 2) return List.from(_farm2Tags);
    return [];
  }

  Future<String> scanSingleTag() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final id = DateTime.now().millisecondsSinceEpoch % 9999 + 1;
    return 'ID-${id.toString().padLeft(4, '0')}';
  }
}