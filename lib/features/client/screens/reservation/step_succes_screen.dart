import 'package:flutter/material.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

class StepSuccesScreen extends StatelessWidget {
  final String nomPresta;
  const StepSuccesScreen({super.key, required this.nomPresta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Carte prestataire
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 70, height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight,
                  border: Border.all(color: _green.withOpacity(0.4), width: 3)),
                child: const Icon(Icons.person, color: _green, size: 38))),
              const SizedBox(height: 12),
              Text(nomPresta,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
              const SizedBox(height: 8),
              const _InfoRow(icon: Icons.location_on_outlined, text: 'Saint-Germain-en-Laye'),
              const _InfoRow(icon: Icons.lock_outline, text: 'Contact réservé aux clients'),
              const _InfoRow(icon: Icons.lock_outline, text: 'Email réservé aux clients'),
              const SizedBox(height: 8),
              const Text(
                'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi',
                style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 20),

          // Stepper — tout coché
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _StepDone(), _StepLine(), _StepDone(), _StepLine(),
            _StepDone(), _StepLine(), _StepDone(),
          ]),
          const SizedBox(height: 16),

          // Bouton retour
          Align(alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFFE0E0E0))),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.arrow_back, size: 16, color: _textDark),
                  SizedBox(width: 4),
                  Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Succès
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0F0F0))),
            child: Column(children: [

              // Cercle vert avec check
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40)),
              const SizedBox(height: 20),

              const Text('Réservation confirmée !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
              const SizedBox(height: 8),
              Text('Votre demande a été envoyée à $nomPresta',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: _textGrey)),
              const SizedBox(height: 20),

              // Notification
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12)),
                child: const Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_outlined, size: 18, color: _textDark),
                    SizedBox(width: 8),
                    Text('Une notification a été envoyée',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                  ]),
                  SizedBox(height: 4),
                  Text('Le coiffeur vous contactera pour confirmer le RDV',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
                ]),
              ),
              const SizedBox(height: 20),

              // Bouton nouveau RDV
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Nouveau rendez-vous',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton mes RDV
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Mes rendez-vous',
                    style: TextStyle(color: _textDark, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
        ]),
      )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: _textGrey),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 13, color: _textGrey)),
    ]),
  );
}

class _StepDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 36, height: 36,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
    child: const Icon(Icons.check, color: Colors.white, size: 18));
}
class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
}