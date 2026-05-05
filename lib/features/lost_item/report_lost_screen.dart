import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../services/auth_service.dart';
import '../../services/item_service.dart';

class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({super.key});
  @override
  State<ReportLostScreen> createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _contentsCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  
  String _category = AppConstants.itemCategories[0];
  String _color = AppConstants.itemColors[0];
  String _transport = AppConstants.transportTypes[0];
  
  int _step = 0;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _brandCtrl.dispose();
    _contentsCtrl.dispose();
    _routeCtrl.dispose();
    _stationCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to pick image: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Lost Item'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
      ),
      body: _isUploading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading image & submitting report...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _step ? AppColors.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 0 ? _buildStep1() : _step == 1 ? _buildStep2() : _buildStep3(),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What did you lose?', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
        const SizedBox(height: 8),
        Text('Provide details about the item', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Item Name *', hintText: 'e.g., Black Leather Wallet', prefixIcon: Icon(Icons.inventory_2_outlined)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *', hintText: 'Describe the item in detail...', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        _buildDropdown('Category *', _category, AppConstants.itemCategories, (v) => setState(() => _category = v!)),
        const SizedBox(height: 16),
        _buildDropdown('Color *', _color, AppConstants.itemColors, (v) => setState(() => _color = v!)),
      ]),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('More Details & Photo', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
        const SizedBox(height: 8),
        Text('Help us identify your item better with a photo', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        
        // Image Picker Area
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 42, color: AppColors.primary),
                        SizedBox(height: 8),
                        Text('Add a photo of your item', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                        SizedBox(height: 4),
                        Text('Tap to browse gallery', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand (optional)', prefixIcon: Icon(Icons.branding_watermark_outlined))),
        const SizedBox(height: 16),
        TextFormField(controller: _contentsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Contents (optional)', hintText: 'e.g., SBI card, license', prefixIcon: Icon(Icons.list_alt_outlined), alignLabelWithHint: true)),
      ]),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Where did you lose it?', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(),
        const SizedBox(height: 8),
        Text('Location details help us match faster', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        _buildDropdown('Transport Type *', _transport, AppConstants.transportTypes, (v) => setState(() => _transport = v!)),
        const SizedBox(height: 16),
        TextFormField(controller: _routeCtrl, decoration: const InputDecoration(labelText: 'Route / Line (optional)', prefixIcon: Icon(Icons.route_outlined))),
        const SizedBox(height: 16),
        TextFormField(controller: _stationCtrl, decoration: const InputDecoration(labelText: 'Station / Stop Name', prefixIcon: Icon(Icons.location_on_outlined))),
        const SizedBox(height: 16),
        TextFormField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Exact Location (optional)', hintText: 'e.g., Seat 14, near exit', prefixIcon: Icon(Icons.my_location_outlined))),
      ]),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        if (_step > 0)
          Expanded(child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back'))),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: _step < 2 ? () { if (_step == 0 && !_formKey.currentState!.validate()) return; setState(() => _step++); } : _submit, child: Text(_step < 2 ? 'Next' : 'Submit Report'))),
      ]),
    );
  }

  void _submit() async {
    final auth = context.read<AuthService>();
    final items = context.read<ItemService>();
    if (auth.currentUser == null) return;

    setState(() {
      _isUploading = true;
    });

    List<String> imageUrls = [];

    // 1. Upload photo to Storage first if picked
    if (_imageFile != null) {
      final downloadUrl = await items.uploadItemImage(_imageFile!);
      if (downloadUrl != null) {
        imageUrls.add(downloadUrl);
      }
    }

    // 2. Report lost item with image URL
    final item = await items.reportLostItem(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      color: _color,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      contents: _contentsCtrl.text.trim().isEmpty ? null : _contentsCtrl.text.trim(),
      transportType: _transport,
      routeNumber: _routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim(),
      stationName: _stationCtrl.text.trim().isEmpty ? null : _stationCtrl.text.trim(),
      locationDetails: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      userId: auth.currentUser!.id,
      imageUrls: imageUrls,
    );

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      Helpers.showSnackBar(context, 'Lost item reported successfully!', isSuccess: true);
      Navigator.pop(context, item);
    }
  }
}
