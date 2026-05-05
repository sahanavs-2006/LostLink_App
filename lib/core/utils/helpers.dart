import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// General utility functions
class Helpers {
  Helpers._();

  /// Generate a random claim code (uppercase alphanumeric)
  static String generateClaimCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      AppConstants.claimCodeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Format a DateTime to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format a DateTime to include time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  /// Format relative time (e.g., "2 hours ago")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatDate(dateTime);
  }

  /// Get a status-appropriate color
  static Color statusColor(String status) {
    switch (status) {
      case AppConstants.statusReported:
        return const Color(0xFFFF6F00);
      case AppConstants.statusFound:
        return const Color(0xFF2196F3);
      case AppConstants.statusMatched:
        return const Color(0xFF7C4DFF);
      case AppConstants.statusClaimPending:
        return const Color(0xFFFFAB00);
      case AppConstants.statusVerified:
        return const Color(0xFF00BFA5);
      case AppConstants.statusReturned:
        return const Color(0xFF00C853);
      case AppConstants.statusClosed:
        return const Color(0xFF9E9E9E);
      case AppConstants.statusExpired:
        return const Color(0xFFD50000);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Get human-readable status label
  static String statusLabel(String status) {
    switch (status) {
      case AppConstants.statusReported:
        return 'Reported';
      case AppConstants.statusFound:
        return 'Found';
      case AppConstants.statusMatched:
        return 'Matched';
      case AppConstants.statusClaimPending:
        return 'Claim Pending';
      case AppConstants.statusVerified:
        return 'Verified';
      case AppConstants.statusReturned:
        return 'Returned';
      case AppConstants.statusClosed:
        return 'Closed';
      case AppConstants.statusExpired:
        return 'Expired';
      default:
        return status;
    }
  }

  /// Get status icon
  static IconData statusIcon(String status) {
    switch (status) {
      case AppConstants.statusReported:
        return Icons.report_outlined;
      case AppConstants.statusFound:
        return Icons.location_on_outlined;
      case AppConstants.statusMatched:
        return Icons.link;
      case AppConstants.statusClaimPending:
        return Icons.pending_actions;
      case AppConstants.statusVerified:
        return Icons.verified_outlined;
      case AppConstants.statusReturned:
        return Icons.check_circle_outline;
      case AppConstants.statusClosed:
        return Icons.archive_outlined;
      case AppConstants.statusExpired:
        return Icons.timer_off_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Simple fuzzy match score between two strings (0.0 - 1.0)
  static double fuzzyMatchScore(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final wordsA = a.toLowerCase().split(RegExp(r'\s+'));
    final wordsB = b.toLowerCase().split(RegExp(r'\s+'));
    int matches = 0;
    for (final word in wordsA) {
      if (wordsB.any((w) => w.contains(word) || word.contains(w))) {
        matches++;
      }
    }
    return matches / max(wordsA.length, wordsB.length);
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Show a snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? const Color(0xFFD50000)
        : isSuccess
            ? const Color(0xFF00C853)
            : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Calculate match confidence between a lost item and a found item
  static double calculateMatchConfidence(dynamic lost, dynamic found) {
    double score = 0;
    int criteria = 0;

    // 1. Category match (Critical)
    if (lost.category == found.category) {
      score += 0.4;
    } else {
      return 0.0; // Different category = no match
    }
    criteria++;

    // 2. Color match
    if (lost.color == found.color) {
      score += 0.2;
    }
    criteria++;

    // 3. Title/Description fuzzy match
    double textMatch = fuzzyMatchScore(
      '${lost.title} ${lost.description}',
      '${found.title} ${found.description}',
    );
    score += textMatch * 0.3;
    criteria++;

    // 4. Station/Transport match
    if (lost.transportType == found.transportType) {
      score += 0.1;
    }
    criteria++;

    return score;
  }
}
