// lib/features/prestataire/onboarding/steps/step_paiements.dart

import 'package:flutter/material.dart';

const _green    = Color(0xFF2D7A4F);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF8E8E93);

const _avantages = [
  {'title': 'Protection contre les absences',   'desc': 'Demandez un acompte de 20% pour sécuriser vos réservations et éviter les no-shows'},
  {'title': 'Paiements sécurisés',              'desc': 'Vos paiements sont protégés par Stripe, leader mondial des paiements en ligne'},
  {'title': 'Réception automatique',            'desc': 'Recevez vos gains directement sur votre compte bancaire, sans démarches supplémentaires'},
  {'title': 'Confiance client',                 'desc': 'Les clients sont plus confiants avec un système de paiement professionnel'},
];

class StepPaiements extends StatelessWidget {
  const StepPaiements({super.key, required this.onNext, required this.onClose});
  final VoidCallback onNext, onClose;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(alignment: Alignment.centerRight,
        child: GestureDetector(onTap: onClose, child: const Icon(Icons.close, color: _textGrey))),
      const SizedBox(height: 16),

      const Text('Protégez vos revenus',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textDark)),
      const SizedBox(height: 6),
      const Text('Acceptez les paiements en ligne',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _green, height: 1.3)),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 30, height: 3, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _green, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Container(width: 30, height: 3, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
        ]),
      ),

      const Center(child: Text('Configuration en 2 minutes, sécurisée par Stripe',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: _textGrey))),
      const SizedBox(height: 20),

      ..._avantages.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(color: Color(0xFFF2E8D9), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: _green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
            const SizedBox(height: 3),
            Text(a['desc']!, style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
          ])),
        ]),
      )),

      // Acompte card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.payment, color: _green, size: 22),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Acompte de 20% pour tous',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 6),
            Text('L\'acompte est automatiquement de 20% du montant total. Le client paie le reste sur place.',
              style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
          ])),
        ]),
      ),
      const SizedBox(height: 16),

      // Sans abonnement Pro
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.warning_amber_rounded, color: _green, size: 18),
            SizedBox(width: 8),
            Text('Sans Abonnement Pro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
          ]),
          const SizedBox(height: 10),
          _LockedItem(label: 'Abonnement requis pour accepter des RDV'),
          _LockedItem(label: 'Pas de paiement intégral en ligne'),
          const SizedBox(height: 6),
          const Text('Abonnez-vous pour des RDV illimités et les paiements intégraux en ligne.',
            style: TextStyle(fontSize: 12, color: _textGrey)),
        ]),
      ),
      const SizedBox(height: 16),

      // Témoignage
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('"Depuis que je demande un acompte, je n\'ai plus aucun no-show. Les clients prennent leurs RDV au sérieux et moi je suis tranquille."',
            style: TextStyle(fontSize: 14, color: _textDark, height: 1.5, fontStyle: FontStyle.italic)),
          SizedBox(height: 8),
          Text('— Fatou M., coiffeuse à Marseille',
            style: TextStyle(fontSize: 13, color: _textGrey)),
        ]),
      ),
      const SizedBox(height: 16),

      // Badges
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shield_outlined, color: _green, size: 16),
        SizedBox(width: 4),
        Text('Sécurisé par Stripe', style: TextStyle(fontSize: 12, color: _textGrey)),
        SizedBox(width: 16),
        Icon(Icons.access_time, color: _green, size: 16),
        SizedBox(width: 4),
        Text('Configuration en 2 min', style: TextStyle(fontSize: 12, color: _textGrey)),
        SizedBox(width: 16),
        Icon(Icons.credit_card, color: _green, size: 16),
        SizedBox(width: 4),
        Text('Gratuit', style: TextStyle(fontSize: 12, color: _textGrey)),
      ]),
      const SizedBox(height: 20),

      SizedBox(width: double.infinity, height: 56,
        child: ElevatedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
          label: const Text('Configurer les paiements', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Center(child: Text('Paiement sécurisé par Stripe • Aucun frais d\'inscription',
        style: TextStyle(fontSize: 12, color: _textGrey))),
      const SizedBox(height: 24),
    ]);
  }
}

class _LockedItem extends StatelessWidget {
  const _LockedItem({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: Color(0xFFF2E8D9), shape: BoxShape.circle),
        child: const Icon(Icons.lock_outline, color: _green, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _textGrey))),
    ]),
  );
}