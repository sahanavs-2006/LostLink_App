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
import '../shared/qr_scanner_screen.dart';

class LogFoundScreen extends StatefulWidget {
  const LogFoundScreen({super.key});
  @override
  State<LogFoundScreen> createState() => _LogFoundScreenState();
}

class _LogFoundScreenState extends State<LogFoundScreen> {
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
      appBar: AppBar(title: const Text('Log Found Item')),
      body: _isUploading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading image & logging item...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // QR scan banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.qr_code_scanner, size: 36, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('QR Station Logging', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Scan station QR to auto-fill location', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                    ])),
                    OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(
                              title: 'Scan Station QR',
                              description: 'Find the QR code on the wall or train window',
                            ),
                          ),
                        );
                        
                        if (result != null && mounted) {
                          setState(() {
                            // If the user scanned a generic URL QR code for the demo
                            if (result.startsWith('http://') || result.startsWith('https://')) {
                              _stationCtrl.text = 'Kengeri Metro Station';
                              if (AppConstants.transportTypes.contains('Metro')) {
                                _transport = 'Metro';
                              }
                            } else {
                              // Use the exact text from the QR
                              _stationCtrl.text = result;
                              
                              // Smartly detect transport type from text!
                              final lowerResult = result.toLowerCase();
                              if (lowerResult.contains('bus')) {
                                _transport = AppConstants.transportTypes.firstWhere((e) => e.toLowerCase() == 'bus', orElse: () => AppConstants.transportTypes[0]);
                              } else if (lowerResult.contains('metro')) {
                                _transport = AppConstants.transportTypes.firstWhere((e) => e.toLowerCase() == 'metro', orElse: () => AppConstants.transportTypes[0]);
                              } else if (lowerResult.contains('train') || lowerResult.contains('railway')) {
                                _transport = AppConstants.transportTypes.firstWhere((e) => e.toLowerCase() == 'train', orElse: () => AppConstants.transportTypes[0]);
                              }
                            }
                          });
                          Helpers.showSnackBar(context, 'Location auto-filled from QR!', isSuccess: true);
                        }
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                      child: const Text('Scan'),
                    ),
                  ]),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                const SizedBox(height: 24),

                Text('Photo (Recommended)', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                GestureDetector(
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
                              Icon(Icons.add_a_photo_outlined, size: 42, color: AppColors.secondary),
                              SizedBox(height: 8),
                              Text('Add a photo of the item', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary)),
                              SizedBox(height: 4),
                              Text('Helps owners identify matches faster', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('Item Details', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Item Name *', prefixIcon: Icon(Icons.inventory_2_outlined)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                _buildDropdown('Category', _category, AppConstants.itemCategories, (v) => setState(() => _category = v!)),
                const SizedBox(height: 16),
                _buildDropdown('Color', _color, AppConstants.itemColors, (v) => setState(() => _color = v!)),
                const SizedBox(height: 16),
                TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand (optional)', prefixIcon: Icon(Icons.branding_watermark_outlined))),
                const SizedBox(height: 16),
                TextFormField(controller: _contentsCtrl, decoration: const InputDecoration(labelText: 'Contents (optional)', prefixIcon: Icon(Icons.list_alt_outlined))),
                const SizedBox(height: 24),

                Text('Location', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildDropdown('Transport Type', _transport, AppConstants.transportTypes, (v) => setState(() => _transport = v!)),
                const SizedBox(height: 16),
                TextFormField(controller: _routeCtrl, decoration: const InputDecoration(labelText: 'Route / Line', prefixIcon: Icon(Icons.route_outlined))),
                const SizedBox(height: 16),
                TextFormField(controller: _stationCtrl, decoration: const InputDecoration(labelText: 'Station / Stop *', prefixIcon: Icon(Icons.location_on_outlined)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Exact Location', prefixIcon: Icon(Icons.my_location_outlined))),
                const SizedBox(height: 32),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.check_circle_outline), label: const Text('Log Found Item'))),
                const SizedBox(height: 24),
              ]),
            ),
          ),
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
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

    // 2. Log found item with image URL
    final item = await items.logFoundItem(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category, 
      color: _color,
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      contents: _contentsCtrl.text.trim().isEmpty ? null : _contentsCtrl.text.trim(),
      transportType: _transport,
      routeNumber: _routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim(),
      stationName: _stationCtrl.text.trim(),
      locationDetails: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      userId: auth.currentUser!.id,
      imageUrls: imageUrls,
    );

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
      Helpers.showSnackBar(context, 'Found item logged! Thank you.', isSuccess: true);
      Navigator.pop(context, item);
    }
  }
}
