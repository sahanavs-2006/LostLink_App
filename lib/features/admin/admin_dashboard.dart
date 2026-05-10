import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/item_service.dart';
import '../../services/claim_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/item_card.dart';
import '../lost_item/item_detail_screen.dart';
import 'admin_claims_screen.dart';

import '../shared/qr_scanner_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemService>();
    final claims = context.watch<ClaimService>();

    final reported = items.getByStatus(AppConstants.statusReported).length;
    final found = items.getByStatus(AppConstants.statusFound).length;
    final matched = items.getByStatus(AppConstants.statusMatched).length;
    final returned = items.getByStatus(AppConstants.statusReturned).length;
    final pending = claims.pendingClaims.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { items.loadDemoData(); },
            tooltip: 'Reload Demo Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(
                title: 'Verify Claim QR',
                description: 'Scan the user\'s Claim Code QR to verify',
              ),
            ),
          );

          if (result != null && context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Claim Verified!'),
                  ],
                ),
                content: Text('Claim Code: $result\nThis item is now marked as Returned.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Verify Claim',
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              StatCard(title: 'Reported', value: '$reported', icon: Icons.report_outlined, color: AppColors.warning),
              StatCard(title: 'Found', value: '$found', icon: Icons.location_on_outlined, color: AppColors.info),
              StatCard(title: 'Matched', value: '$matched', icon: Icons.link, color: const Color(0xFF7C4DFF)),
              StatCard(title: 'Returned', value: '$returned', icon: Icons.check_circle_outline, color: AppColors.success),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),

          // Pending claims banner
          if (pending > 0)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminClaimsScreen()));
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.pending_actions, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$pending Pending Claims', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Require officer verification', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                  ])),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ]),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
            ),

          const SizedBox(height: 16),

          // Recovery rate
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recovery Rate', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: items.items.isEmpty ? 0 : returned / items.items.length,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.success,
                  ),
                )),
                const SizedBox(width: 12),
                Text('${items.items.isEmpty ? 0 : (returned / items.items.length * 100).toInt()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success)),
              ]),
              const SizedBox(height: 8),
              Text('$returned of ${items.items.length} items recovered', style: Theme.of(context).textTheme.bodySmall),
            ]),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // Recent activity
          Text('Recent Activity', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (items.items.isEmpty)
            const EmptyState(icon: Icons.inbox_outlined, title: 'No Items Yet', subtitle: 'Tap refresh to load demo data.')
          else
            ...items.items.take(5).map((item) => ItemCard(
              item: item,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item))),
            )),
        ]),
      ),
    );
  }
}
