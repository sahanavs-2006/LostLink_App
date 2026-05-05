import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/item_model.dart';
import '../../widgets/common_widgets.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemModel item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.statusColor(item.status);
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        child: Column(children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
            child: Column(children: [
              StatusBadge(label: Helpers.statusLabel(item.status), color: Colors.white, icon: Helpers.statusIcon(item.status)),
              const SizedBox(height: 12),
              Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('${item.category} • ${item.color}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
            ]).animate().fadeIn(duration: 500.ms),
          ),
          
          if (item.imageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: item.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item.imageUrls[index].startsWith('http')
                          ? Image.network(
                              item.imageUrls[index],
                              height: 250,
                              width: MediaQuery.of(context).size.width * 0.8,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                              ),
                            )
                          : Image.file(
                              File(item.imageUrls[index]),
                              height: 250,
                              width: MediaQuery.of(context).size.width * 0.8,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section(context, 'Description', item.description),
              if (item.brand != null) _section(context, 'Brand', item.brand!),
              if (item.contents != null) _section(context, 'Contents', item.contents!),
              const Divider(height: 32),
              _section(context, 'Transport', item.transportType),
              if (item.routeNumber != null) _section(context, 'Route', item.routeNumber!),
              if (item.stationName != null) _section(context, 'Station', item.stationName!),
              if (item.locationDetails != null) _section(context, 'Location', item.locationDetails!),
              const Divider(height: 32),
              _section(context, 'Reported', Helpers.formatDateTime(item.reportedAt)),
              _section(context, 'Type', item.isLostReport ? 'Lost Report' : 'Found Report'),
              if (item.claimCode != null) ...[
                const Divider(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                  child: Column(children: [
                    const Icon(Icons.qr_code_2, size: 32, color: AppColors.success),
                    const SizedBox(height: 8),
                    const Text('Claim Code', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(item.claimCode!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4, color: AppColors.success)),
                  ]),
                ),
              ],
              if (item.matchConfidence != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Match Confidence', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('${(item.matchConfidence! * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.info)),
                    ])),
                    SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: item.matchConfidence!, backgroundColor: Colors.grey.shade200, color: statusColor, strokeWidth: 5)),
                  ]),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _section(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}
