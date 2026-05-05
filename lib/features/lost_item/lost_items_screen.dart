import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/item_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/item_card.dart';
import '../../widgets/common_widgets.dart';
import 'report_lost_screen.dart';
import '../lost_item/item_detail_screen.dart';

class LostItemsScreen extends StatelessWidget {
  const LostItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ItemService>();
    final auth = context.watch<AuthService>();
    final myLostItems = items.lostItems
        .where((i) => i.reportedBy == auth.currentUser?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Lost Items')),
      body: myLostItems.isEmpty
          ? EmptyState(
              icon: Icons.search_off,
              title: 'No Lost Items',
              subtitle: 'You haven\'t reported any lost items yet.',
              action: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Report Lost Item'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myLostItems.length,
              itemBuilder: (_, i) => ItemCard(
                item: myLostItems[i],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: myLostItems[i]))),
              ),
            ),
      floatingActionButton: myLostItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportLostScreen())),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
