import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/claim_service.dart';
import '../../services/item_service.dart';
import 'knowledge_check_screen.dart';

class ClaimScreen extends StatefulWidget {
  const ClaimScreen({super.key});
  @override
  State<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends State<ClaimScreen> {
  final _codeCtrl = TextEditingController();
  bool _searched = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimService = context.watch<ClaimService>();
    final itemService = context.watch<ItemService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Claim Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Icon(Icons.verified_user_outlined, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text('Verify Your Claim', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Enter your claim code to verify ownership', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
            ]),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 32),
          Text('Enter Claim Code', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 4),
              decoration: const InputDecoration(hintText: 'XXXXXX', prefixIcon: Icon(Icons.vpn_key_outlined)),
            )),
            const SizedBox(width: 12),
            SizedBox(height: 52, child: ElevatedButton(onPressed: () => setState(() => _searched = true), child: const Text('Verify'))),
          ]),

          if (_searched) ...[
            const SizedBox(height: 24),
            Builder(builder: (_) {
              final code = _codeCtrl.text.trim();
              final claim = claimService.getByCode(code);
              
              final matchedItems = itemService.items.where((i) => i.claimCode?.toUpperCase() == code.toUpperCase());
              final matchedItem = matchedItems.isNotEmpty ? matchedItems.first : null;

              if (claim == null && matchedItem == null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                  child: const Row(children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: 12),
                    Expanded(child: Text('No claim or matched item found with this code. Please check and try again.', style: TextStyle(color: AppColors.error))),
                  ]),
                ).animate().fadeIn().shake();
              }

              if (claim == null && matchedItem != null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('Item Matched — ${matchedItem.status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                    ]),
                    const SizedBox(height: 16),
                    _infoRow('Item', matchedItem.title),
                    _infoRow('Category', matchedItem.category),
                    _infoRow('Status', matchedItem.status),
                    if (matchedItem.matchedAt != null) _infoRow('Matched On', Helpers.formatDateTime(matchedItem.matchedAt!)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KnowledgeCheckScreen(matchedItem: matchedItem),
                            ),
                          );
                        },
                        child: const Text('Proceed to Knowledge Check'),
                      )
                    )
                  ]),
                ).animate().fadeIn().slideY(begin: 0.1);
              }


              if (claim != null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('Claim Found — ${claim.status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                    ]),
                    const SizedBox(height: 16),
                    _infoRow('Claim ID', Helpers.truncate(claim.id, 12)),
                    _infoRow('Status', claim.status),
                    _infoRow('Created', Helpers.formatDateTime(claim.createdAt)),
                    if (claim.verifiedAt != null) _infoRow('Verified', Helpers.formatDateTime(claim.verifiedAt!)),
                  ]),
                ).animate().fadeIn().slideY(begin: 0.1);
              }
              
              return const SizedBox.shrink();
            }),
          ],

          const SizedBox(height: 32),
          // How it works
          Text('How Verification Works', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _step('1', 'Submit Claim', 'Enter the claim code from your matched item'),
          _step('2', 'Knowledge Check', 'Answer verification questions about the item'),
          _step('3', 'Officer Review', 'Station officer verifies your answers'),
          _step('4', 'Collect Item', 'Show verified claim to collect your item'),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _step(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Center(child: Text(num, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}
