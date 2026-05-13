// lib/features/prestataire/onboarding/steps/step_conditions_service.dart

import 'package:flutter/material.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _conditionsCourantes = [
  'Annulation 24h à l\'avance minimum',
  'Cheveux propres exigés',
  'Pas de retard accepté (plus de 15min = annulation)',
  'Produits chimiques interdits dans les 48h précédentes',
  'Consultation obligatoire pour les transformations importantes',
  'Supplément pour cheveux très longs ou très épais',
  'Matériel personnel requis (serviettes, peignes)',
  'Enfants accompagnés d\'un adulte uniquement',
  'Port du masque obligatoire',
  'Allergies à signaler impérativement',
  'Pas de modifications après confirmation du RDV',
  'Respect des horaires des RDV',
];

class StepConditionsService extends StatefulWidget {
  const StepConditionsService({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepConditionsService> createState() => _StepConditionsServiceState();
}

class _StepConditionsServiceState extends State<StepConditionsService> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.description, color: _green, size: 22),
        SizedBox(width: 8),
        Text('Conditions de service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      const SizedBox(height: 20),

      // Ajouter condition personnalisée
      const Text('Ajouter une condition personnalisée',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark)),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: _green),
          label: const Text('Ajouter une condition', style: TextStyle(color: _green)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE0E0E0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(height: 20),

      // Conditions courantes
      const Text('Conditions courantes',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark)),
      const SizedBox(height: 10),

      ..._conditionsCourantes.map((c) {
        final sel = _selected.contains(c);
        return GestureDetector(
          onTap: () => setState(() => sel ? _selected.remove(c) : _selected.add(c)),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? _greenLight : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: sel ? _green : const Color(0xFFE8E8E8), width: sel ? 2 : 1),
            ),
            child: Text(c, style: TextStyle(fontSize: 14, color: sel ? _green : _textDark,
              fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
          ),
        );
      }),

      const SizedBox(height: 16),

      // À savoir
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 18),
          SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('À savoir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue)),
            SizedBox(height: 4),
            Text('Ces conditions seront affichées sur votre profil public et devront être acceptées par vos clients lors de la réservation.',
              style: TextStyle(fontSize: 13, color: Colors.blue, height: 1.4)),
          ])),
        ]),
      ),

      const SizedBox(height: 24),
      Row(children: [
        Expanded(
          child: SizedBox(height: 52,
            child: ElevatedButton(
              onPressed: widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              child: const Text('Sauvegarder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
      ]),
      const SizedBox(height: 24),
    ]);
  }
}