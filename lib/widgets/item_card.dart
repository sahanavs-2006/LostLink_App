import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../models/item_model.dart';

/// A polished card widget for displaying lost/found items
class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onTap;
  final bool showMatchBadge;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.showMatchBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.statusColor(item.status);
    final isMatched = item.status == AppConstants.statusMatched;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isMatched && showMatchBadge
              ? Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 2)
              : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon or uploaded photo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.imageUrls.first.startsWith('http')
                                ? Image.network(
                                    item.imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(_categoryIcon, color: _categoryColor, size: 24),
                                  )
                                : Image.file(
                                    File(item.imageUrls.first),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(_categoryIcon, color: _categoryColor, size: 24),
                                  ),
                          )
                        : Icon(_categoryIcon, color: _categoryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Title & category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} • ${item.transportType}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Helpers.statusIcon(item.status),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Helpers.statusLabel(item.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer — location & time
              Row(
                children: [
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isLostReport
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.isLostReport ? 'LOST' : 'FOUND',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: item.isLostReport
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.stationName != null) ...[
                    Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        item.stationName!,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 2),
                  Text(
                    Helpers.timeAgo(item.reportedAt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),

              // Match confidence badge
              if (isMatched &&
                  showMatchBadge &&
                  item.matchConfidence != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.1),
                        AppColors.info.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'Match found — ${(item.matchConfidence! * 100).toInt()}% confidence',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color get _categoryColor {
    final index =
        AppConstants.itemCategories.indexOf(item.category);
    if (index >= 0 && index < AppColors.categoryColors.length) {
      return AppColors.categoryColors[index];
    }
    return AppColors.primary;
  }

  IconData get _categoryIcon {
    switch (item.category) {
      case 'Wallet':
        return Icons.account_balance_wallet_outlined;
      case 'Phone':
        return Icons.phone_android;
      case 'ID Card':
        return Icons.badge_outlined;
      case 'Bag':
        return Icons.backpack_outlined;
      case 'Keys':
        return Icons.key_outlined;
      case 'Laptop':
        return Icons.laptop_mac_outlined;
      case 'Documents':
        return Icons.description_outlined;
      case 'Jewelry':
        return Icons.diamond_outlined;
      case 'Glasses':
        return Icons.visibility_outlined;
      case 'Umbrella':
        return Icons.umbrella_outlined;
      case 'Clothing':
        return Icons.checkroom_outlined;
      case 'Electronics':
        return Icons.devices_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
