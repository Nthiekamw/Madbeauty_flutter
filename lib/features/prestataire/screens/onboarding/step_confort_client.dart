// lib/features/prestataire/onboarding/steps/step_confort_client.dart

import 'package:flutter/material.dart';

const _brown      = Color(0xFF8B6340);
const _brownLight = Color(0xFFF2E8D9);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _conforts = [
  'Accessibilité PMR (personnes à mobilité réduite)',
  'Adresse facile à trouver',
  'Ascenseur',
  'Boissons offertes (eau, jus, thé…)',
  'Canapé ou fauteuil confortable',
  'Chargeur de téléphone disponible',
  'Climatisation ou chauffage',
  'Coiffure possible avec hijab',
  'Espace d\'attente pour cliente en avance',
  'Espace privé ou pièce isolée disponible',
  'Jeux ou coin enfants',
  'Lieu calme',
  'Magazines ou livres à disposition',
  'Miroir à disposition',
  'Musique d\'ambiance',
  'Outils désinfectés entre chaque cliente',
  'Parking gratuit à proximité',
  'Place de parking privée',
  'Propreté irréprochable',
  'Snacks ou friandises disponibles',
  'Station de métro ou bus proche',
  'Table ou support pour poser ses affaires',
  'Temps de coiffure respecté (ponctualité)',
  'Toilettes accessibles',
  'TV ou Netflix disponible pendant la coiffure',
  'Wifi gratuit',
];

class StepConfortClient extends StatefulWidget {
  const StepConfortClient({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepConfortClient> createState() => _StepConfortClientState();
}

class _StepConfortClientState extends State<StepConfortClient> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.favorite_outline, color: _brown, size: 22),
        SizedBox(width: 8),
        Text('Confort client',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      const SizedBox(height: 16),

      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Services de confort client',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 6),
          const Text('Sélectionnez les services de confort que vous proposez à vos clients',
            style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
          const SizedBox(height: 14),

          ..._conforts.map((c) {
            final sel = _selected.contains(c);
            return GestureDetector(
              onTap: () => setState(() => sel ? _selected.remove(c) : _selected.add(c)),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? _brownLight : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: sel ? _brown : const Color(0xFFE8E8E8), width: sel ? 2 : 1),
                ),
                child: Text(c, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14,
                    color: sel ? _brown : _textGrey,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
              ),
            );
          }),
        ]),
      ),

      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _brownLight,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: _brown.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.favorite_outline, color: _brown, size: 18),
          const SizedBox(width: 8),
          Text('${_selected.length} services de confort sélectionnés',
            style: const TextStyle(color: _brown, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),

      const SizedBox(height: 24),
      Row(children: [
        Expanded(
          child: SizedBox(height: 52,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: const Text('Annuler', style: TextStyle(color: _textDark)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(height: 52,
            child: ElevatedButton(
              onPressed: widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              child: const Text('Sauvegarder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ]);
  }
}