import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class ConsentPage extends StatefulWidget {
  final VoidCallback onConsentAccepted;
  const ConsentPage({super.key, required this.onConsentAccepted});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  final ScrollController _controller = ScrollController();
  bool _scrolledToEnd = false;
  String _md = '';

  @override
  void initState() {
    super.initState();
    _loadMd();
    _controller.addListener(() {
      if (!_scrolledToEnd && _controller.hasClients && _controller.offset + 40 >= _controller.position.maxScrollExtent) {
        setState(() { _scrolledToEnd = true; });
      }
    });
  }

  Future<void> _loadMd() async {
    final txt = await rootBundle.loadString('assets/privacidade.md');
    setState(() { _md = txt; });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _md.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(controller: _controller, padding: const EdgeInsets.all(24), child: SelectableText(_md, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _scrolledToEnd ? widget.onConsentAccepted : null,
              icon: const Icon(Icons.check),
              label: const Text('Concordo com os termos'),
              style: FilledButton.styleFrom(backgroundColor: _scrolledToEnd ? purple : slate),
            ),
          ),
        ],
      ),
    );
  }
}