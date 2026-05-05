/// Application-wide constants for LostLink
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LostLink';
  static const String appTagline = 'Smart Lost & Found Recovery';
  static const String appVersion = '1.0.0';

  // Item Categories
  static const List<String> itemCategories = [
    'Wallet',
    'Phone',
    'ID Card',
    'Bag',
    'Keys',
    'Laptop',
    'Documents',
    'Jewelry',
    'Glasses',
    'Umbrella',
    'Clothing',
    'Electronics',
    'Other',
  ];

  // Item Colors
  static const List<String> itemColors = [
    'Black',
    'White',
    'Brown',
    'Blue',
    'Red',
    'Green',
    'Gray',
    'Silver',
    'Gold',
    'Pink',
    'Purple',
    'Orange',
    'Yellow',
    'Multicolor',
    'Other',
  ];

  // Transport Types
  static const List<String> transportTypes = [
    'Bus',
    'Metro',
    'Train',
    'Tram',
    'Ferry',
    'Auto Rickshaw',
    'Taxi',
    'Station',
    'Bus Stop',
    'Other',
  ];

  // Claim Status
  static const String statusReported = 'reported';
  static const String statusFound = 'found';
  static const String statusMatched = 'matched';
  static const String statusClaimPending = 'claim_pending';
  static const String statusVerified = 'verified';
  static const String statusReturned = 'returned';
  static const String statusClosed = 'closed';
  static const String statusExpired = 'expired';

  // User Roles
  static const String roleCommuter = 'commuter';
  static const String roleFinder = 'finder';
  static const String roleOfficer = 'officer';
  static const String roleAdmin = 'admin';

  // Storage / Escalation
  static const int escalationDays = 30;
  static const int claimCodeLength = 6;

  // Matching thresholds
  static const double matchConfidenceHigh = 0.8;
  static const double matchConfidenceMedium = 0.5;
  static const double matchConfidenceLow = 0.3;
}
