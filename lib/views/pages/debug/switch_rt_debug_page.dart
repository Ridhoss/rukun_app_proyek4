import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

class SwitchRTDebugPage extends StatefulWidget {
  const SwitchRTDebugPage({super.key});

  @override
  State<SwitchRTDebugPage> createState() => _SwitchRTDebugPageState();
}

class _SwitchRTDebugPageState extends State<SwitchRTDebugPage> {
  final TextEditingController _rtController = TextEditingController();
  String? _currentLabel;
  int? _currentRtId;

  @override
  void initState() {
    super.initState();
    _loadCurrentContext();
  }

  @override
  void dispose() {
    _rtController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentContext() async {
    final service = WargaService();
    await service.warmUpRTContext();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentRtId = service.currentRtId;
      _currentLabel = service.currentRtLabel;
      _rtController.text = service.currentRtId.toString();
    });
  }

  Future<void> _setContextFromInput() async {
    final value = int.tryParse(_rtController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan RT ID yang valid (angka > 0).')),
      );
      return;
    }

    await WargaService().setCurrentRTContext(rtId: value);
    await _loadCurrentContext();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RT context aktif: ${WargaService().currentRtLabel}'),
      ),
    );
  }

  Future<void> _setPreset(int rtId) async {
    await WargaService().setCurrentRTContext(rtId: rtId);
    await _loadCurrentContext();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RT context aktif: ${WargaService().currentRtLabel}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Switch RT Context')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RT aktif: ${_currentLabel ?? '-'} (${_currentRtId ?? '-'})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rtController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'RT ID',
                hintText: 'Contoh: 1, 2, 3',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _setContextFromInput,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Apply RT Context'),
            ),
            const SizedBox(height: 20),
            const Text('Preset cepat untuk QA:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in [1, 2, 3, 4, 5])
                  OutlinedButton(
                    onPressed: () => _setPreset(id),
                    child: Text('RT ${id.toString().padLeft(3, '0')}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
