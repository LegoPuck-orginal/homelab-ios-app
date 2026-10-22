import 'package:flutter/material.dart';
import '../models/service_item.dart';
import '../theme/adobe_colors.dart';
import 'adobe_button.dart';

class AddServiceDialog extends StatefulWidget {
  final Function(ServiceItem) onAdd;
  final String? initialIp;
  final int? initialPort;
  final String? initialName;
  final String? initialCategory;

  const AddServiceDialog({
    super.key,
    required this.onAdd,
    this.initialIp,
    this.initialPort,
    this.initialName,
    this.initialCategory,
  });

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  String _selectedCategory = 'Server';

  final List<String> _categories = [
    'Virtualisierung',
    'Smart Home',
    'KI & Medien',
    'Gaming & Server',
    'Security & Auth',
    'Netzwerk',
    'Dateien & Cloud',
    'Kommunikation',
    'Server',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');

    String initialUrl = '';
    if (widget.initialIp != null) {
      final portSuffix = (widget.initialPort != null && widget.initialPort != 80 && widget.initialPort != 443)
          ? ':${widget.initialPort}'
          : '';
      final proto = (widget.initialPort == 443 || widget.initialPort == 8006) ? 'https' : 'http';
      initialUrl = '$proto://${widget.initialIp}$portSuffix';
    }
    _urlController = TextEditingController(text: initialUrl);

    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (name.isEmpty || url.isEmpty) {
      return;
    }

    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final service = ServiceItem(
      id: id,
      name: name,
      url: url,
      category: _selectedCategory,
      iconName: 'server',
      isCustom: true,
      port: widget.initialPort,
    );

    widget.onAdd(service);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdobeColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AdobeColors.borderCard, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEUEN DIENST HINZUFÜGEN',
              style: TextStyle(
                color: AdobeColors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Dienst-Name (z.B. TrueNAS, Grafana)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'URL (z.B. http://192.168.188.50:8080)',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AdobeColors.surfaceBase,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdobeColors.borderCard, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AdobeColors.surfaceElevated,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(color: AdobeColors.textMuted, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                AdobeButton(
                  text: 'Hinzufügen',
                  onPressed: _submit,
                  style: AdobeButtonStyle.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
