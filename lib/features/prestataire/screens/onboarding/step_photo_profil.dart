// lib/features/prestataire/onboarding/steps/step_photo_profil.dart

import 'package:flutter/material.dart';

const _green    = Color(0xFF2D7A4F);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF8E8E93);

class StepPhotoProfil extends StatefulWidget {
  const StepPhotoProfil({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepPhotoProfil> createState() => _StepPhotoProfilState();
}

class _StepPhotoProfilState extends State<StepPhotoProfil> {
  final _prenomCtrl      = TextEditingController();
  final _nomCtrl         = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _telCtrl         = TextEditingController();
  final _villeCtrl       = TextEditingController();
  final _codePostalCtrl  = TextEditingController();
  final _adresseCtrl     = TextEditingController();
  final _nomAffCtrl      = TextEditingController();
  final _expCtrl         = TextEditingController();
  final _descCtrl        = TextEditingController();

  @override
  void dispose() {
    for (final c in [_prenomCtrl, _nomCtrl, _emailCtrl, _telCtrl,
      _villeCtrl, _codePostalCtrl, _adresseCtrl, _nomAffCtrl, _expCtrl, _descCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Center(child: Text('Modifier le profil',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark))),
      const SizedBox(height: 20),

      // Photo
      Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: const Color(0xFFF2E8D9), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Color(0xFFD4A878), size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload, color: _textDark, size: 18),
            label: const Text('Changer la photo', style: TextStyle(color: _textDark)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 20),

      // Prénom / Nom
      Row(children: [
        Expanded(child: _Field(label: 'Prénom *', ctrl: _prenomCtrl, placeholder: 'Votre prénom', required: true)),
        const SizedBox(width: 12),
        Expanded(child: _Field(label: 'Nom *', ctrl: _nomCtrl, placeholder: 'Votre nom', required: true)),
      ]),

      _Field(label: 'Email *', ctrl: _emailCtrl, placeholder: 'votre@email.com', required: true, type: TextInputType.emailAddress),
      _Field(label: 'Téléphone *', ctrl: _telCtrl, placeholder: '0600000000', required: true, type: TextInputType.phone),

      // Ville / Code postal
      Row(children: [
        Expanded(child: _FieldWithIcon(label: 'Ville *', ctrl: _villeCtrl, placeholder: 'Paris', required: true)),
        const SizedBox(width: 12),
        Expanded(child: _Field(label: 'Code postal *', ctrl: _codePostalCtrl, placeholder: '75000', required: true, type: TextInputType.number)),
      ]),

      _FieldWithIcon(label: 'Adresse', ctrl: _adresseCtrl, placeholder: '12 rue des Lilas'),
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Optionnel – Utile si vous recevez des clients à votre domicile/salon',
          style: TextStyle(fontSize: 12, color: _textGrey)),
      ),

      _Field(label: 'Nom affiché *', ctrl: _nomAffCtrl, placeholder: 'Nom visible par les clients', required: true),

      // Expérience
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Expérience professionnelle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
          const SizedBox(width: 6),
          ValueListenableBuilder(valueListenable: _expCtrl,
            builder: (_, v, __) => Text('(${v.text.length}/150 caractères)',
              style: const TextStyle(fontSize: 12, color: _textGrey))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: _expCtrl, maxLines: 3,
          decoration: _inputDeco('Décrivez votre expérience…')),
      ]),
      const SizedBox(height: 16),

      // Description
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
          const SizedBox(width: 6),
          ValueListenableBuilder(valueListenable: _descCtrl,
            builder: (_, v, __) => Text('(${v.text.length}/200 caractères)',
              style: const TextStyle(fontSize: 12, color: _textGrey))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: _descCtrl, maxLines: 4,
          decoration: _inputDeco('Présentez-vous à vos clients…')),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
          ),
          child: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Interdit : réseaux sociaux, téléphone, email, liens externes',
              style: TextStyle(fontSize: 12, color: Color(0xFF7A5800)))),
          ]),
        ),
      ]),
      const SizedBox(height: 24),

      // Boutons
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
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
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
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 52,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          label: const Text('Supprimer mon compte', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.ctrl, required this.placeholder,
    this.required = false, this.type = TextInputType.text});
  final String label, placeholder;
  final TextEditingController ctrl;
  final bool required;
  final TextInputType type;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ]),
      const SizedBox(height: 8),
      TextField(controller: ctrl, keyboardType: type, decoration: _inputDeco(placeholder)),
      const SizedBox(height: 14),
    ],
  );
}

class _FieldWithIcon extends StatelessWidget {
  const _FieldWithIcon({required this.label, required this.ctrl, required this.placeholder, this.required = false});
  final String label, placeholder;
  final TextEditingController ctrl;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ]),
      const SizedBox(height: 8),
      TextField(controller: ctrl,
        decoration: _inputDeco(placeholder).copyWith(
          suffixIcon: const Icon(Icons.location_on_outlined, color: _textGrey),
        )),
      const SizedBox(height: 14),
    ],
  );
}

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint, hintStyle: const TextStyle(color: _textGrey),
  filled: true, fillColor: const Color(0xFFF8F8F8),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: _green, width: 2)),
);