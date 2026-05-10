import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/item_card.dart';
import '../features/lost_item/report_lost_screen.dart';
import '../features/found_item/log_found_screen.dart';
import '../features/lost_item/lost_items_screen.dart';
import '../features/lost_item/item_detail_screen.dart';
import '../features/claim/claim_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/about_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final isAdmin = user?.role == AppConstants.roleAdmin || user?.role == AppConstants.roleOfficer;

    final pages = [
      const _DashboardTab(),
      const _ExploreTab(),
      if (isAdmin) const AdminDashboard(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          if (isAdmin) const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Admin'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ──────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final items = context.watch<ItemService>();
    final user = auth.currentUser;
    final myItems = items.getByUser(user?.id ?? '');

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Gradient App Bar
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
            child: SafeArea(
              bottom: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(user?.name.isNotEmpty == true ? user!.name[0] : 'U', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hello, ${user?.name.split(' ').first ?? 'User'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(_roleLabel(user?.role ?? ''), style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                  ])),
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                ]),
                const SizedBox(height: 20),
                // Quick actions
                Row(children: [
                  _quickAction(context, Icons.report_outlined, 'Report\nLost', AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostScreen()))),
                  const SizedBox(width: 12),
                  _quickAction(context, Icons.add_location_alt_outlined, 'Log\nFound', AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogFoundScreen()))),
                  const SizedBox(width: 12),
                  _quickAction(context, Icons.verified_outlined, 'Claim\nVerify', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimScreen()))),
                ]),
              ]),
            ),
          ).animate().fadeIn(duration: 400.ms),
        ),

        // My Items section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(children: [
              Text('My Reports', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LostItemsScreen())), child: const Text('See All')),
            ]),
          ),
        ),
        if (myItems.isEmpty)
          const SliverToBoxAdapter(child: EmptyState(icon: Icons.inventory_2_outlined, title: 'No Reports Yet', subtitle: 'Report a lost item or log a found item to get started.'))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ItemCard(item: myItems[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: myItems[i])))),
              ),
              childCount: myItems.length.clamp(0, 3),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2)),
          ]),
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppConstants.roleCommuter: return '🚌 Commuter';
      case AppConstants.roleFinder: return '🔍 Finder';
      case AppConstants.roleOfficer: return '👮 Station Officer';
      case AppConstants.roleAdmin: return '⚙️ Administrator';
      default: return 'User';
    }
  }
}

// ─── Explore Tab ────────────────────────────────────────
class _ExploreTab extends StatefulWidget {
  const _ExploreTab();
  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';
  String _selectedStation = 'All Stations';
  String _selectedCategory = 'All Categories';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final items = context.watch<ItemService>();
    final user = auth.currentUser;

    // Get unique stations and categories from current items
    final stations = ['All Stations', ...items.items.map((e) => e.stationName).where((e) => e != null && e.isNotEmpty).cast<String>().toSet().toList()];
    final categories = ['All Categories', ...AppConstants.itemCategories];

    // Filter items based on search, station, and category
    final allItems = items.items.where((i) {
      // Hide matched/claimed items from public feed unless user is the reporter or the finder
      if (i.status == 'matched' || i.status == 'claiming' || i.status == 'recovered' || i.status == 'returned') {
        if (user == null) return false;
        
        bool isMyReport = i.reportedBy == user.id;
        bool isMatchedToMe = false;
        
        if (i.matchedItemId != null) {
          final matchedItemsList = items.items.where((other) => other.id == i.matchedItemId);
          if (matchedItemsList.isNotEmpty && matchedItemsList.first.reportedBy == user.id) {
            isMatchedToMe = true;
          }
        }
        
        if (!isMyReport && !isMatchedToMe) {
          return false;
        }
      }

      final matchesSearch = _searchQuery.isEmpty || i.title.toLowerCase().contains(_searchQuery.toLowerCase()) || i.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStation = _selectedStation == 'All Stations' || i.stationName == _selectedStation;
      final matchesCategory = _selectedCategory == 'All Categories' || i.category == _selectedCategory;
      return matchesSearch && matchesStation && matchesCategory;
    }).toList();
    
    final lost = allItems.where((i) => i.isLostReport).toList();
    final found = allItems.where((i) => i.isFoundReport).toList();
    final returned = allItems.where((i) => i.status == AppConstants.statusReturned).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Explorer'),
        bottom: TabBar(controller: _tabCtrl, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70, tabs: [
          Tab(text: 'All (${allItems.length})'),
          Tab(text: 'Lost (${lost.length})'),
          Tab(text: 'Found (${found.length})'),
        ]),
      ),
      body: Column(children: [
        // Public Analytics Dashboard
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          color: Theme.of(context).cardTheme.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Network Analytics', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _miniStat('Total Lost', lost.length.toString(), Icons.report_outlined, AppColors.error)),
                  const SizedBox(width: 8),
                  Expanded(child: _miniStat('Total Found', found.length.toString(), Icons.inventory_2_outlined, AppColors.info)),
                  const SizedBox(width: 8),
                  Expanded(child: _miniStat('Recovered', returned.toString(), Icons.verified, AppColors.success)),
                ],
              ),
              const SizedBox(height: 12),
              // Filters
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedStation,
                          icon: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          onChanged: (v) => setState(() => _selectedStation = v!),
                          items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          icon: const Icon(Icons.category, size: 16, color: AppColors.primary),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Search
              SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = '')) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // Item List
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            _itemList(allItems),
            _itemList(lost),
            _itemList(found),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _itemList(List items) {
    if (items.isEmpty) return const EmptyState(icon: Icons.search_off, title: 'No Items', subtitle: 'No items match your criteria.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => ItemCard(item: items[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: items[i])))),
    );
  }
}

// ─── Profile Tab ────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: user?.profileImageUrl != null
                ? (user!.profileImageUrl!.startsWith('http')
                    ? NetworkImage(user.profileImageUrl!)
                    : FileImage(File(user.profileImageUrl!)) as ImageProvider)
                : null,
            child: user?.profileImageUrl == null
                ? Text(user?.name.isNotEmpty == true ? user!.name[0] : 'U', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary))
                : null,
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'User', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(user?.role.toUpperCase() ?? 'USER', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
          ),
          const SizedBox(height: 32),
          _menuItem(context, Icons.edit_outlined, 'Edit Profile', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),
          _menuItem(context, Icons.notifications_outlined, 'Notifications', () {
            Helpers.showSnackBar(context, 'Notification settings coming soon!');
          }),
          _menuItem(context, Icons.security_outlined, 'Privacy & Security', () {
            Helpers.showSnackBar(context, 'Privacy settings coming soon!');
          }),
          _menuItem(context, Icons.help_outline, 'Help & Support', () {
            Helpers.showSnackBar(context, 'Support center coming soon!');
          }),
          _menuItem(context, Icons.info_outline, 'About LostLink', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
