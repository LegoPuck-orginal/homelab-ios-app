import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/service_item.dart';
import '../providers/services_provider.dart';
import '../theme/adobe_colors.dart';
import '../widgets/add_service_dialog.dart';
import '../widgets/adobe_card.dart';
import '../widgets/live_status_indicator.dart';
import 'webview_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, ServicesProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AddServiceDialog(
        onAdd: (newService) => prov.addCustomService(newService),
      ),
    );
  }

  IconData _getServiceIcon(String iconName, String category) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      case 'layers':
        return Icons.layers_outlined;
      case 'cpu':
        return Icons.memory;
      case 'brain':
        return Icons.psychology_outlined;
      case 'gamepad':
        return Icons.sports_esports_outlined;
      case 'play':
        return Icons.play_circle_outline;
      case 'shield':
        return Icons.shield_outlined;
      case 'crosshair':
        return Icons.filter_tilt_shift;
      case 'folder':
        return Icons.folder_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'mic':
        return Icons.mic_none;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'router':
        return Icons.router_outlined;
      case 'terminal':
        return Icons.terminal;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.dns_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ServicesProvider>();
    final services = prov.filteredServices;
    final categories = prov.categories;

    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      appBar: AppBar(
        title: const Text(
          'DIENSTE // HOMELAB HUB',
          style: TextStyle(
            color: AdobeColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          IconButton(
            icon: prov.isCheckingHealth
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AdobeColors.orangeAccent),
                    ),
                  )
                : const Icon(Icons.refresh, size: 20, color: AdobeColors.textSecondary),
            tooltip: 'Latenz & Status aktualisieren',
            onPressed: prov.isCheckingHealth ? null : () => prov.checkAllHealth(),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 22, color: AdobeColors.orangeAccent),
            tooltip: 'Dienst hinzufügen',
            onPressed: () => _showAddDialog(context, prov),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. SUCHLEISTE
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => prov.setSearchQuery(val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Dienst oder IP suchen...',
                prefixIcon: const Icon(Icons.search, size: 18, color: AdobeColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: AdobeColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          prov.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // 2. KATEGORIE-FILTER PILLS
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == prov.selectedCategory;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AdobeColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AdobeColors.orangeAccent,
                  backgroundColor: AdobeColors.surfaceElevated,
                  side: BorderSide(
                    color: isSelected ? AdobeColors.orangeAccent : AdobeColors.borderCard,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => prov.setCategory(cat),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. DIENSTE-LISTE
          Expanded(
            child: services.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 40, color: AdobeColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Keine passenden Dienste gefunden',
                          style: TextStyle(color: AdobeColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            prov.setSearchQuery('');
                            prov.setCategory('Alle');
                          },
                          child: const Text('Filter zurücksetzen', style: TextStyle(color: AdobeColors.orangeAccent)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: services.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return _buildServiceTile(context, s, prov);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, ServiceItem s, ServicesProvider prov) {
    final iconData = _getServiceIcon(s.iconName, s.category);

    return AdobeCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              title: s.name,
              url: s.url,
            ),
          ),
        );
      },
      onLongPress: () {
        _showServiceOptions(context, s, prov);
      },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AdobeColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AdobeColors.borderCard, width: 1),
            ),
            child: Icon(iconData, size: 18, color: AdobeColors.orangeAccent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AdobeColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (s.port != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AdobeColors.surfaceBase,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: AdobeColors.borderSubtle, width: 1),
                        ),
                        child: Text(
                          ':${s.port}',
                          style: const TextStyle(
                            color: AdobeColors.textMuted,
                            fontSize: 9,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  s.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdobeColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          LiveStatusIndicator(
            isOnline: s.isOnline,
            latencyMs: s.latencyMs,
            showLabel: true,
          ),
        ],
      ),
    );
  }

  void _showServiceOptions(BuildContext context, ServiceItem s, ServicesProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AdobeColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        side: BorderSide(color: AdobeColors.borderCard, width: 1),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.copy, color: AdobeColors.textSecondary),
                  title: const Text('URL kopieren', style: TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: s.url));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL in die Zwischenablage kopiert'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                if (s.isCustom)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AdobeColors.statusOffline),
                    title: const Text('Dienst entfernen', style: TextStyle(color: AdobeColors.statusOffline, fontSize: 13)),
                    onTap: () {
                      prov.removeCustomService(s.id);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
