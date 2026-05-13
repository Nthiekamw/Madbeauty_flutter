import 'package:flutter/material.dart';
import 'step_cheveux_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _creneaux = [
  {'jour': 'Lundi 18 Mai',    'heures': ['11:30']},
  {'jour': 'Mardi 19 Mai',    'heures': ['14:00']},
  {'jour': 'Mercredi 20 Mai', 'heures': ['11:30', '12:00']},
  {'jour': 'Lundi 25 Mai',    'heures': ['11:30']},
  {'jour': 'Mardi 26 Mai',    'heures': ['14:00']},
  {'jour': 'Mercredi 27 Mai', 'heures': ['11:30', '12:00']},
];

class StepDateScreen extends StatefulWidget {
  final String nomPresta, service, duree;
  final int prix;
  const StepDateScreen({super.key, required this.nomPresta, required this.service, required this.prix, required this.duree});

  @override
  State<StepDateScreen> createState() => _StepDateScreenState();
}

class _StepDateScreenState extends State<StepDateScreen> {
  String? _selectedCreneau;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8),
            child: const Text('← Retour', style: TextStyle(color: _textDark, fontSize: 14))),
        ),
        leadingWidth: 100,
        title: const Text('Sélectionnez un créneau',
          style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        // Résumé service sélectionné
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(child: Text(widget.service,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _green))),
              Text('${widget.prix}€',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
            ]),
          ),
        ),

        // Liste des créneaux
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: _creneaux.map((c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(c['jour'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                  ),
                  Wrap(spacing: 10, children: (c['heures'] as List<String>).map((h) {
                    final key = '${c['jour']}_$h';
                    final sel = _selectedCreneau == key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCreneau = key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: sel ? _green : const Color(0xFFE0E0E0))),
                        child: Text(h, style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textDark)),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 8),
                ],
              )).toList(),
            ),
          ),
        ),

        // Bouton continuer
        if (_selectedCreneau != null)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => StepCheveuxScreen(
                  nomPresta: widget.nomPresta,
                  service: widget.service,
                  prix: widget.prix,
                  duree: widget.duree,
                  creneau: _selectedCreneau!.replaceAll('_', ' '),
                ),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Continuer',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
      ]),
    );
  }
}