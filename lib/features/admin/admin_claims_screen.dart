import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../models/claim_model.dart';
import '../../services/claim_service.dart';
import '../../services/item_service.dart';

class AdminClaimsScreen extends StatelessWidget {
  const AdminClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final claimsService = context.watch<ClaimService>();
    final pendingClaims = claimsService.pendingClaims;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Claims')),
      body: pendingClaims.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                  SizedBox(height: 16),
                  Text('All caught up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('There are no pending claims to review.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingClaims.length,
              itemBuilder: (context, index) {
                final claim = pendingClaims[index];
                return _ClaimReviewCard(claim: claim);
              },
            ),
    );
  }
}

class _ClaimReviewCard extends StatelessWidget {
  final ClaimModel claim;

  const _ClaimReviewCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final itemService = context.watch<ItemService>();
    
    // Look up the items related to this claim
    final lostItem = itemService.items.where((i) => i.id == claim.lostItemId).firstOrNull;
    final foundItem = itemService.items.where((i) => i.id == claim.foundItemId).firstOrNull;
    
    final itemName = lostItem?.title ?? foundItem?.title ?? 'Unknown Item';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pending_actions, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Claim for: $itemName',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            const Text('Knowledge Check Answers:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            
            _buildAnswerRow('Brand', claim.verificationAnswers['brand']),
            _buildAnswerRow('Color', claim.verificationAnswers['color']),
            _buildAnswerRow('Marks/Contents', claim.verificationAnswers['contents']),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    onPressed: () => _updateClaimStatus(context, claim.id, 'rejected'),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    onPressed: () => _updateClaimStatus(context, claim.id, 'approved'),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(String label, String? answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(answer?.isEmpty ?? true ? 'Not provided' : answer!, style: const TextStyle(fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }

  void _updateClaimStatus(BuildContext context, String claimId, String newStatus) async {
    try {
      final claimService = context.read<ClaimService>();
      final officerId = FirebaseAuth.instance.currentUser?.uid ?? 'officer';
      
      if (newStatus == 'approved') {
        await claimService.verifyClaim(claimId, officerId);
      } else {
        await claimService.rejectClaim(claimId, officerId, 'Rejected by Station Officer');
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claim $newStatus successfully!'),
            backgroundColor: newStatus == 'approved' ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
