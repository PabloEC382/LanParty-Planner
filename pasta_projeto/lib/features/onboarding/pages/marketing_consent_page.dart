import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';

class MarketingConsentPage extends StatefulWidget {
  final VoidCallback onSaved;
  const MarketingConsentPage({super.key, required this.onSaved});

  @override
  State<MarketingConsentPage> createState() => _MarketingConsentPageState();
}

class _MarketingConsentPageState extends State<MarketingConsentPage> {
  bool _marketing = false;
  bool _saving = false;

  Future<void> _saveConsent() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_accepted', _marketing);
    await prefs.setBool('onboarding_done', true);
    final info = '${_marketing ? "accepted" : "rejected"}|${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('consent_info', info);
    await prefs.setInt('consent_date', DateTime.now().millisecondsSinceEpoch);
    setState(() => _saving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, color: cyan, size: 90),
              const SizedBox(height: 28),
              Text(
                'Receber material de marketing',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Gostaria de receber novidades, promoções e materiais de marketing sobre eventos gamers?',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Receber material de marketing', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: _marketing,
                    onChanged: (v) => setState(() => _marketing = v),
                    activeThumbColor: purple,
                    activeTrackColor: cyan.withOpacity(0.4),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveConsent,
                  style: FilledButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Consentimento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}