
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/constat_provider.dart';

class ConstatScreen extends StatefulWidget {
  final int farmId;
  final int? controlSessionId;

  const ConstatScreen({
    super.key,
    required this.farmId,
    this.controlSessionId,
  });

  @override
  State<ConstatScreen> createState() => _ConstatScreenState();
}

class _ConstatScreenState extends State<ConstatScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConstatProvider>(context, listen: false);
      provider.reset();
      provider.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConstatProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Déclaration de Constat"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session info
              _buildSessionCard(),
              const SizedBox(height: 20),

              // Type
              _buildTypeSection(provider),
              const SizedBox(height: 20),

              // GPS
              _buildLocationSection(provider),
              const SizedBox(height: 20),

              // Description
              _buildDescriptionSection(provider),
              const SizedBox(height: 20),

              // Pièces jointes
              _buildAttachmentSection(provider),
              const SizedBox(height: 20),

              // Aperçu photos
              if (provider.attachments.isNotEmpty)
                _buildAttachmentPreview(provider),

              const SizedBox(height: 28),

              // Bouton soumettre
              _buildSubmitButton(context, provider),

              if (provider.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(provider.error!),
              ],

              if (provider.success != null) ...[
                const SizedBox(height: 16),
                _buildSuccessCard(provider.success!),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Session de contrôle active",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.controlSessionId != null
                    ? "Session #${widget.controlSessionId}"
                    : "Ferme #${widget.farmId}",
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSection(ConstatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TYPE D'ANOMALIE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.3,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          _typeOption(provider, "FRAUDE", "Fraude", Icons.warning_amber, AppColors.danger),
          const SizedBox(height: 8),
          _typeOption(provider, "MANQUANT", "Animal manquant", Icons.inventory_2, Colors.blueGrey),
          const SizedBox(height: 8),
          _typeOption(provider, "AUTRE", "Autre anomalie", Icons.help_outline, AppColors.textGrey),
        ],
      ),
    );
  }

  Widget _typeOption(
      ConstatProvider provider,
      String value,
      String label,
      IconData icon,
      Color color,
      ) {
    final selected = provider.type == value;

    return InkWell(
      onTap: () => provider.setType(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(ConstatProvider provider) {
    final hasLocation = provider.latitude != null && provider.longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasLocation
                  ? "${provider.latitude!.toStringAsFixed(5)}, ${provider.longitude!.toStringAsFixed(5)}"
                  : "Récupération GPS...",
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (!hasLocation)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ConstatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DESCRIPTION",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.3,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            onChanged: provider.setDescription,
            decoration: InputDecoration(
              hintText: "Décrivez l'anomalie observée...",
              filled: true,
              fillColor: const Color(0xFFF3F6F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection(ConstatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "PIÈCES JOINTES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.3,
                  color: AppColors.textGrey,
                ),
              ),
              const Spacer(),
              Text(
                "${provider.attachmentCount}/2 minimum",
                style: TextStyle(
                  color: provider.hasEnoughAttachments
                      ? AppColors.primaryGreen
                      : AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.pickPhoto(),
                  icon: const Icon(Icons.camera_alt, size: 17),
                  label: const Text("Photo", style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.pickPhotoFromGallery(),
                  icon: const Icon(Icons.photo_library, size: 17),
                  label: const Text("Galerie", style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.pickFile(),
                  icon: const Icon(Icons.attach_file, size: 17),
                  label: const Text("Fichier", style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(ConstatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pièces jointes (${provider.attachmentCount})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.attachments.length,
              itemBuilder: (context, index) {
                final file = provider.attachments[index];
                final isImage = file.path.toLowerCase().endsWith('.jpg') ||
                    file.path.toLowerCase().endsWith('.jpeg') ||
                    file.path.toLowerCase().endsWith('.png');

                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isImage
                            ? Image.file(
                          file,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.insert_drive_file,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => provider.removeAttachment(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ConstatProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading
            ? null
            : () async {
          if (_descriptionController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Veuillez ajouter une description"),
              ),
            );
            return;
          }

          provider.setDescription(_descriptionController.text.trim());

          final success = await provider.submitConstat(
            widget.farmId,
            controlSessionId: widget.controlSessionId,
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.success ?? "Constat envoyé"),
                backgroundColor: Colors.green,
              ),
            );

            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
        icon: provider.isLoading
            ? const SizedBox.shrink()
            : const Icon(Icons.send, color: Colors.white),
        label: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Soumettre le Constat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}