import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/item_model.dart';
import '../../services/claim_service.dart';
import '../../services/item_service.dart';
import '../../core/theme/app_colors.dart';

class KnowledgeCheckScreen extends StatefulWidget {
  final ItemModel matchedItem;

  const KnowledgeCheckScreen({super.key, required this.matchedItem});

  @override
  State<KnowledgeCheckScreen> createState() => _KnowledgeCheckScreenState();
}

class _KnowledgeCheckScreenState extends State<KnowledgeCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _contentsCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _colorCtrl.dispose();
    _contentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final claimService = context.read<ClaimService>();
      final itemService = context.read<ItemService>();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      String otherItemId = widget.matchedItem.matchedItemId ?? '';
      
      // Fallback for old items that were matched before we added matchedItemId to the DB
      if (otherItemId.isEmpty) {
        final others = itemService.items.where((i) => 
            i.id != widget.matchedItem.id && 
            i.claimCode == widget.matchedItem.claimCode);
        if (others.isNotEmpty) {
          otherItemId = others.first.id;
        }
      }

      final lostItemId = widget.matchedItem.isLostReport 
          ? widget.matchedItem.id 
          : otherItemId;
          
      final foundItemId = widget.matchedItem.isFoundReport 
          ? widget.matchedItem.id 
          : otherItemId;
          
      if (lostItemId.isEmpty || foundItemId.isEmpty) {
        throw Exception('Could not find the other matched item. Data might be missing for this old report.');
      }

      final answers = {
        'brand': _brandCtrl.text.trim(),
        'color': _colorCtrl.text.trim(),
        'contents': _contentsCtrl.text.trim(),
      };

      await claimService.submitClaim(
        lostItemId: lostItemId,
        foundItemId: foundItemId,
        claimantId: userId,
        verificationAnswers: answers,
      );

      if (mounted) {
        // Show success and pop back twice (to home or claim screen)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim submitted successfully! Awaiting officer review.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting claim: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Ownership',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please answer the following questions to prove ownership of the item. These will be reviewed by the station officer.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              _buildField('What is the brand of the item?', _brandCtrl, 'e.g., Apple, Nike, etc.', true),
              const SizedBox(height: 20),
              
              _buildField('What is the exact color?', _colorCtrl, 'e.g., Space Gray, Navy Blue', true),
              const SizedBox(height: 20),
              
              _buildField('Any specific contents or identifying marks?', _contentsCtrl, 'e.g., A scratch on the back, ID card inside', false),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Claim', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: label.contains('contents') ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: isRequired 
              ? (val) => val == null || val.trim().isEmpty ? 'This field is required' : null
              : null,
        ),
      ],
    );
  }
}
