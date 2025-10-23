import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class PolicyViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;
  final VoidCallback onAgree;
  const PolicyViewerPage({super.key, required this.title, required this.assetPath, required this.onAgree});

  @override
  State<PolicyViewerPage> createState() => _PolicyViewerPageState();
}

class _PolicyViewerPageState extends State<PolicyViewerPage> {
  String _text = '';
  final ScrollController _controller = ScrollController();
  bool _read = false;

  @override
  void initState() {
    super.initState();
    _load();
    _controller.addListener(_onScroll);
  }

  Future<void> _load() async {
    final txt = await rootBundle.loadString(widget.assetPath);
    setState(() { _text = txt; });
  }

  void _onScroll() {
    if (!_read && _controller.hasClients && _controller.offset + 40 >= _controller.position.maxScrollExtent) {
      setState(() { _read = true; });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _agreeAndClose() {
    widget.onAgree();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate,
      appBar: AppBar(backgroundColor: purple, title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(child: _text.isEmpty ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(controller: _controller, padding: const EdgeInsets.all(24), child: SelectableText(_text, style: const TextStyle(color: Colors.white, fontSize: 16)))),
          SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: _read ? _agreeAndClose : null, icon: const Icon(Icons.check), label: const Text('Concordo com os termos')))),
        ],
      ),
    );
  }
}