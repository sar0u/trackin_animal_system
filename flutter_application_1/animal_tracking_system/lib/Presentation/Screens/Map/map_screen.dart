import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../Widgets/Common/glass_chip.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _map;
  Position? _pos;

  bool chipFraud = true;
  bool chipEpidemic = false;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getLocation();
    _loadMockOverlays();
    // Show region overview by default (like screenshot)
    WidgetsBinding.instance.addPostFrameCallback((_) => _showRegionOverview());
  }

  Future<void> _getLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) return;

    final p = await Geolocator.getCurrentPosition();
    setState(() => _pos = p);
  }

  void _loadMockOverlays() {
    // Mock region: Djelfa area
    const center = LatLng(34.6728, 3.2630);

    _markers.addAll({
      const Marker(
        markerId: MarkerId('alert'),
        position: LatLng(34.6755, 3.2810),
        infoWindow: InfoWindow(title: 'Alert', snippet: 'Fraud hotspot'),
      ),
      const Marker(
        markerId: MarkerId('hospital'),
        position: LatLng(34.6680, 3.2400),
        infoWindow: InfoWindow(title: 'Vet checkpoint'),
      ),
    });

    _circles.add(
      Circle(
        circleId: const CircleId('zone'),
        center: center,
        radius: 1800,
        fillColor: AppColors.dangerRed.withOpacity(.18),
        strokeColor: AppColors.dangerRed.withOpacity(.35),
        strokeWidth: 2,
      ),
    );
  }

  void _showRegionOverview() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Djelfa Province Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withOpacity(.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.dangerRed.withOpacity(.22)),
                  ),
                  child: const Text('ALERT', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.dangerRed)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStat(title: 'FARMS', value: '1,248', color: AppColors.successGreen)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(title: 'FRAUD', value: '12', color: AppColors.dangerRed)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(title: 'QUARANT.', value: '3', color: AppColors.warningOrange)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_rounded),
                label: const Text('View Detailed Regional Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final camera = CameraPosition(
      target: _pos == null ? const LatLng(36.7525, 3.04197) : LatLng(_pos!.latitude, _pos!.longitude),
      zoom: 11.5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geographic Intelligence'),
        actions: [
          IconButton(onPressed: _showRegionOverview, icon: const Icon(Icons.layers_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: camera,
            onMapCreated: (c) => _map = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            circles: chipFraud ? _circles : {},
            zoomControlsEnabled: false,
          ),

          // Top search bar (UI only)
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search Wilaya or Commune (e.g. Djelfa)',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.mic_rounded, color: cs.primary),
                  ],
                ),
              ),
            ),
          ),

          // chips row
          Positioned(
            left: 16,
            right: 16,
            top: 74,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GlassChip(
                    icon: Icons.satellite_alt_rounded,
                    label: 'Satellite Fraud',
                    selected: chipFraud,
                    onTap: () => setState(() {
                      chipFraud = true;
                      chipEpidemic = false;
                    }),
                  ),
                  const SizedBox(width: 10),
                  GlassChip(
                    icon: Icons.coronavirus_rounded,
                    label: 'Epidemic History',
                    selected: chipEpidemic,
                    onTap: () => setState(() {
                      chipEpidemic = true;
                      chipFraud = false;
                    }),
                  ),
                  const SizedBox(width: 10),
                  GlassChip(
                    icon: Icons.analytics_rounded,
                    label: 'Overview',
                    selected: false,
                    onTap: _showRegionOverview,
                  ),
                ],
              ),
            ),
          ),

          // Legend
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _LegendRow(color: AppColors.dangerRed, label: 'Fraud hotspot'),
                    SizedBox(height: 6),
                    _LegendRow(color: AppColors.warningOrange, label: 'Quarantine zone'),
                    SizedBox(height: 6),
                    _LegendRow(color: AppColors.successGreen, label: 'Verified market'),
                  ],
                ),
              ),
            ),
          ),

          // Floating controls
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'loc',
                  onPressed: () async {
                    await _getLocation();
                    if (_pos != null && _map != null) {
                      _map!.animateCamera(CameraUpdate.newLatLng(LatLng(_pos!.latitude, _pos!.longitude)));
                    }
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'plus',
                  onPressed: () => _map?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'minus',
                  onPressed: () => _map?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniStat({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }
}