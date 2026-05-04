import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/remote/api_client.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _loading = true;
  List<dynamic> _campaigns = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _apiClient.dio.get('/veterinaire/campaigns');
      setState(() {
        _campaigns = res.data ?? [];
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message'] ?? 'Erreur chargement campagnes';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markDone(int campaignId, int animalId) async {
    try {
      await _apiClient.dio.put(
        '/veterinaire/campaigns/$campaignId/participate/$animalId',
        data: {
          'vaccinationDate': DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participation enregistrée'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadCampaigns();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data?['message'] ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campagnes Sanitaires'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _error != null
          ? Center(child: Text(_error!))
          : _campaigns.isEmpty
          ? const Center(child: Text('Aucune campagne active'))
          : RefreshIndicator(
        onRefresh: _loadCampaigns,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _campaigns.length,
          itemBuilder: (context, index) {
            final c = _campaigns[index];
            return _buildCampaignCard(c);
          },
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> c) {
    final pending = c['enAttente'] ?? 0;
    final done = c['vaccinés'] ?? 0;
    final total = pending + done;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c['status'] == 'ACTIVE' ? 'En cours' : c['status'] ?? '',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$done/$total vaccinés',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (c['vaccineName'] != null)
                  Text(
                    'Vaccin : ${c['vaccineName']}',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.primaryGreen,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% complété',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}