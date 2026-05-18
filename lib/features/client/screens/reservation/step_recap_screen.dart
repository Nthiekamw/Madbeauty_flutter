

import 'package:flutter/material.dart';
import 'step_succes_screen.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

class StepRecapScreen extends StatelessWidget {
  final String nomPresta, service, duree, creneau;
  final int prix;
  const StepRecapScreen({super.key, required this.nomPresta,
    required this.service, required this.prix,
    required this.duree,   required this.creneau});

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // ── Header ────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 3.5),
          child: Column(children: [

            // Stepper
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _SD(rem: rem), _SL(rem: rem),
              _SD(rem: rem), _SL(rem: rem),
              _SD(rem: rem), _SL(rem: rem),
              _SA(num: 4, rem: rem),
            ]),
            SizedBox(height: rem * 2),
            Text('Récapitulatif',
              style: TextStyle(fontSize: rem * 3, color: _textGrey)),
            SizedBox(height: rem * 3),

            // Header nav
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: rem * 9, height: rem * 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFEDE0CC))),
                  child: Icon(Icons.arrow_back_rounded,
                    color: _textDark, size: rem * 5))),
              SizedBox(width: rem * 3),
              Container(
                width: rem * 10, height: rem * 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
                child: Icon(Icons.person_rounded, color: _gold, size: rem * 5.5)),
              SizedBox(width: rem * 3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Récapitulatif', style: TextStyle(
                  fontSize: rem * 4, fontWeight: FontWeight.w700, color: _textDark)),
                Text(nomPresta, style: TextStyle(
                  fontSize: rem * 3, color: _textGrey)),
              ])),
            ]),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(rem * 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Titre
              Text('Récapitulatif de votre réservation',
                style: TextStyle(
                  fontSize: rem * 5.5,
                  fontWeight: FontWeight.w900,
                  color: _textDark)),
              SizedBox(height: rem * 1.5),
              Text('Vérifiez les informations avant de confirmer',
                style: TextStyle(fontSize: rem * 3.2, color: _textGrey)),
              SizedBox(height: rem * 4),

              // ── Carte RDV ────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.06),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Titre section
                  Row(children: [
                    Container(
                      width: rem * 10, height: rem * 10,
                      decoration: BoxDecoration(
                        color: _goldLight, shape: BoxShape.circle),
                      child: Icon(Icons.calendar_month_rounded,
                        color: _gold, size: rem * 5.5)),
                    SizedBox(width: rem * 3),
                    Text('Rendez-vous', style: TextStyle(
                      fontSize: rem * 4.2,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
                  ]),
                  SizedBox(height: rem * 3),

                  _RR(label: 'Prestataire',  value: nomPresta,                          rem: rem),
                  _RR(label: 'Service',      value: service,                            rem: rem),
                  _RR(label: 'Prestation',   value: service.split('–').last.trim(),     rem: rem, isChip: true),
                  _RR(label: 'Durée',        value: duree,                              rem: rem),
                  _RR(label: 'Créneau',      value: creneau,                            rem: rem),
                  SizedBox(height: rem * 3),

                  // Prix total
                  Container(
                    padding: EdgeInsets.all(rem * 3.5),
                    decoration: BoxDecoration(
                      color: _goldLight,
                      borderRadius: BorderRadius.circular(rem * 3)),
                    child: Row(children: [
                      Icon(Icons.payments_outlined, color: _gold, size: rem * 5.5),
                      SizedBox(width: rem * 3),
                      Text('Prix total :',
                        style: TextStyle(fontSize: rem * 3.8, color: _textGrey)),
                      const Spacer(),
                      Text('${prix}€', style: TextStyle(
                        fontSize: rem * 6,
                        fontWeight: FontWeight.w900,
                        color: _goldDark)),
                    ]),
                  ),
                ]),
              ),
              SizedBox(height: rem * 3.5),

              // ── Vos informations ──────────────────────────────────────
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.06),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: rem * 10, height: rem * 10,
                      decoration: BoxDecoration(
                        color: _goldLight, shape: BoxShape.circle),
                      child: Icon(Icons.person_rounded,
                        color: _gold, size: rem * 5.5)),
                    SizedBox(width: rem * 3),
                    Text('Vos informations', style: TextStyle(
                      fontSize: rem * 4.2,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
                  ]),
                  SizedBox(height: rem * 3),
                  _RR(label: 'Nom',       value: 'William Nthiekam',    rem: rem),
                  _RR(label: 'Email',     value: 'william@gmail.com',    rem: rem),
                  _RR(label: 'Téléphone', value: '06 15 01 36 94',       rem: rem),
                ]),
              ),
              SizedBox(height: rem * 3.5),

              // ── Paiement ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(rem * 4),
                  border: Border.all(color: _gold.withOpacity(0.3))),
                child: Row(children: [
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.2),
                      shape: BoxShape.circle),
                    child: Icon(Icons.point_of_sale_outlined,
                      color: _goldDark, size: rem * 6)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Paiement sur place', style: TextStyle(
                      fontSize: rem * 3.8,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
                    SizedBox(height: rem),
                    Text('Réglez directement auprès du prestataire',
                      style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                  ])),
                ]),
              ),
              SizedBox(height: rem * 8),
            ]),
          ),
        ),

        // ── Bouton confirmer ──────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, rem * 5),
          color: Colors.white,
          child: GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => StepSuccesScreen(nomPresta: nomPresta)),
              (route) => route.isFirst),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rem * 4),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(rem * 8),
                boxShadow: [BoxShadow(
                  color: _gold.withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 5))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: rem * 5.5),
                SizedBox(width: rem * 2.5),
                Text('Confirmer la réservation', style: TextStyle(
                  color: Colors.white,
                  fontSize: rem * 4,
                  fontWeight: FontWeight.w700)),
              ])),
          ),
        ),
      ])),
    );
  }
}

// ── Recap row ─────────────────────────────────────────────────────────────────
class _RR extends StatelessWidget {
  const _RR({required this.label, required this.value,
    required this.rem, this.isChip = false});
  final String label, value;
  final double rem;
  final bool isChip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 2),
    child: Row(children: [
      SizedBox(
        width: rem * 26,
        child: Text(label, style: TextStyle(
          fontSize: rem * 3.2, color: _textGrey))),
      Expanded(child: isChip
        ? Align(alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rem * 2.5, vertical: rem),
              decoration: BoxDecoration(
                color: _goldLight,
                borderRadius: BorderRadius.circular(rem * 4)),
              child: Text(value, style: TextStyle(
                fontSize: rem * 3,
                color: _goldDark,
                fontWeight: FontWeight.w600))))
        : Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: rem * 3.2,
              fontWeight: FontWeight.w600,
              color: _textDark))),
    ]));
}

// ── Stepper widgets ───────────────────────────────────────────────────────────
class _SD extends StatelessWidget {
  const _SD({required this.rem});
  final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 8, height: rem * 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold),
    child: Icon(Icons.check_rounded, color: Colors.white, size: rem * 4.5));
}

class _SA extends StatelessWidget {
  const _SA({required this.num, required this.rem});
  final int num; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 8, height: rem * 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold),
    child: Center(child: Text('$num', style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: rem * 3.5))));
}

class _SL extends StatelessWidget {
  const _SL({required this.rem});
  final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 7, height: 2, color: _gold);
}





















































// import 'package:flutter/material.dart';
// import 'step_succes_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// class StepRecapScreen extends StatelessWidget {
//   final String nomPresta, service, duree, creneau;
//   final int prix;
//   const StepRecapScreen({super.key, required this.nomPresta, required this.service,
//     required this.prix, required this.duree, required this.creneau});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(child: Column(children: [

//         // ── Header prestataire ────────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: Row(children: [
//             GestureDetector(onTap: () => Navigator.pop(context),
//               child: const Icon(Icons.arrow_back, color: _textDark)),
//             const SizedBox(width: 10),
//             Container(width: 36, height: 36,
//               decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
//               child: const Icon(Icons.person, color: _green, size: 20)),
//             const SizedBox(width: 10),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Réservation',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//               Text(nomPresta, style: const TextStyle(fontSize: 12, color: _textGrey)),
//             ]),
//           ]),
//         ),

//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: [

//               // Carte prestataire
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Center(child: Container(width: 70, height: 70,
//                     decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight,
//                       border: Border.all(color: _green.withOpacity(0.4), width: 3)),
//                     child: const Icon(Icons.person, color: _green, size: 38))),
//                   const SizedBox(height: 12),
//                   Text(nomPresta,
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                   const SizedBox(height: 8),
//                   const _InfoRow(icon: Icons.location_on_outlined, text: 'Saint-Germain-en-Laye'),
//                   const _InfoRow(icon: Icons.lock_outline, text: 'Contact réservé aux clients'),
//                   const _InfoRow(icon: Icons.lock_outline, text: 'Email réservé aux clients'),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi',
//                     style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                 ]),
//               ),
//               const SizedBox(height: 20),

//               // Stepper — toutes les étapes cochées
//               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 _StepDone(), _StepLine(), _StepDone(), _StepLine(),
//                 _StepDone(), _StepLine(), _StepActive(num: 4),
//               ]),
//               const SizedBox(height: 8),
//               const Text('Récapitulatif', style: TextStyle(fontSize: 13, color: _textGrey)),
//               const SizedBox(height: 16),

//               // Bouton retour
//               Align(alignment: Alignment.centerLeft,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                     decoration: BoxDecoration(color: Colors.white,
//                       borderRadius: BorderRadius.circular(50),
//                       border: Border.all(color: const Color(0xFFE0E0E0))),
//                     child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(Icons.arrow_back, size: 16, color: _textDark),
//                       SizedBox(width: 4),
//                       Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
//                     ]),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Titre
//               const Text('Récapitulatif de votre réservation',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
//               const SizedBox(height: 4),
//               const Text('Vérifiez les informations avant de confirmer',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 13, color: _textGrey)),
//               const SizedBox(height: 20),

//               // Rendez-vous
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: _greenLight,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: _green.withOpacity(0.2))),
//                 child: Column(children: [
//                   const Align(alignment: Alignment.centerLeft,
//                     child: Text('Rendez-vous',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
//                   const SizedBox(height: 12),
//                   _RecapRow(label: 'Coiffeur',      value: nomPresta),
//                   _RecapRow(label: 'Service',       value: service),
//                   _RecapRow(label: 'Prestation',    value: service.split('–').last.trim(), isChip: true),
//                   _RecapRow(label: 'Durée',         value: duree),
//                   _RecapRow(label: 'Date et heure', value: creneau),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//                     child: Row(children: [
//                       const Text('Prix total:', style: TextStyle(fontSize: 14, color: _textGrey)),
//                       const Spacer(),
//                       Text('${prix}€',
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
//                     ]),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               // Vos informations
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Vos informations',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                   const SizedBox(height: 12),
//                   const _RecapRow(label: 'Nom',       value: 'william nth'),
//                   const _RecapRow(label: 'Email',     value: 'williamnthiekam392@gmail.com'),
//                   const _RecapRow(label: 'Téléphone', value: '0615013694'),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               // Paiement
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8F8F8),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: const Column(children: [
//                   Icon(Icons.payment, size: 32, color: _textGrey),
//                   SizedBox(height: 8),
//                   Text('Paiement sur place',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
//                   SizedBox(height: 4),
//                   Text('Réglez directement auprès du coiffeur',
//                     style: TextStyle(fontSize: 13, color: _textGrey)),
//                 ]),
//               ),
//               const SizedBox(height: 24),
//             ]),
//           ),
//         ),

//         // Bouton confirmer
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           decoration: const BoxDecoration(color: Colors.white,
//             border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: ElevatedButton(
//             onPressed: () => Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => StepSuccesScreen(nomPresta: nomPresta)),
//               (route) => route.isFirst,
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 52),
//             ),
//             child: const Text('Confirmer la réservation',
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ])),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({required this.icon, required this.text});
//   final IconData icon; final String text;
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 6),
//     child: Row(children: [
//       Icon(icon, size: 16, color: _textGrey),
//       const SizedBox(width: 8),
//       Text(text, style: const TextStyle(fontSize: 13, color: _textGrey)),
//     ]),
//   );
// }

// class _RecapRow extends StatelessWidget {
//   const _RecapRow({required this.label, required this.value, this.isChip = false});
//   final String label, value; final bool isChip;
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(children: [
//       SizedBox(width: 110,
//         child: Text(label, style: const TextStyle(fontSize: 13, color: _textGrey))),
//       Expanded(child: isChip
//         ? Align(alignment: Alignment.centerLeft,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
//               child: Text(value, style: const TextStyle(fontSize: 12, color: _textDark, fontWeight: FontWeight.w600))))
//         : Text(value, textAlign: TextAlign.right,
//             style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600))),
//     ]),
//   );
// }

// class _StepDone extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: const Icon(Icons.check, color: Colors.white, size: 18));
// }
// class _StepActive extends StatelessWidget {
//   const _StepActive({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: Center(child: Text('$num',
//       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepLine extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
// }






































// import 'package:flutter/material.dart';
// import 'step_succes_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// class StepRecapScreen extends StatelessWidget {
//   final String nomPresta, service, duree, creneau;
//   final int prix;
//   const StepRecapScreen({super.key, required this.nomPresta, required this.service,
//     required this.prix, required this.duree, required this.creneau});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(child: Column(children: [

//         // ── Header prestataire ────────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: Row(children: [
//             GestureDetector(onTap: () => Navigator.pop(context),
//               child: const Icon(Icons.arrow_back, color: _textDark)),
//             const SizedBox(width: 10),
//             Container(width: 36, height: 36,
//               decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
//               child: const Icon(Icons.person, color: _green, size: 20)),
//             const SizedBox(width: 10),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Réservation',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//               Text(nomPresta, style: const TextStyle(fontSize: 12, color: _textGrey)),
//             ]),
//           ]),
//         ),

//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: [

//               // Carte prestataire
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Center(child: Container(width: 70, height: 70,
//                     decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight,
//                       border: Border.all(color: _green.withOpacity(0.4), width: 3)),
//                     child: const Icon(Icons.person, color: _green, size: 38))),
//                   const SizedBox(height: 12),
//                   Text(nomPresta,
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                   const SizedBox(height: 8),
//                   const _InfoRow(icon: Icons.location_on_outlined, text: 'Saint-Germain-en-Laye'),
//                   const _InfoRow(icon: Icons.lock_outline, text: 'Contact réservé aux clients'),
//                   const _InfoRow(icon: Icons.lock_outline, text: 'Email réservé aux clients'),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi',
//                     style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                 ]),
//               ),
//               const SizedBox(height: 20),

//               // Stepper — toutes les étapes cochées
//               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 _StepDone(), _StepLine(), _StepDone(), _StepLine(),
//                 _StepDone(), _StepLine(), _StepActive(num: 4),
//               ]),
//               const SizedBox(height: 8),
//               const Text('Récapitulatif', style: TextStyle(fontSize: 13, color: _textGrey)),
//               const SizedBox(height: 16),

//               // Bouton retour
//               Align(alignment: Alignment.centerLeft,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                     decoration: BoxDecoration(color: Colors.white,
//                       borderRadius: BorderRadius.circular(50),
//                       border: Border.all(color: const Color(0xFFE0E0E0))),
//                     child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(Icons.arrow_back, size: 16, color: _textDark),
//                       SizedBox(width: 4),
//                       Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
//                     ]),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Titre
//               const Text('Récapitulatif de votre réservation',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
//               const SizedBox(height: 4),
//               const Text('Vérifiez les informations avant de confirmer',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 13, color: _textGrey)),
//               const SizedBox(height: 20),

//               // Rendez-vous
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: _greenLight,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: _green.withOpacity(0.2))),
//                 child: Column(children: [
//                   const Align(alignment: Alignment.centerLeft,
//                     child: Text('Rendez-vous',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
//                   const SizedBox(height: 12),
//                   _RecapRow(label: 'Coiffeur',      value: nomPresta),
//                   _RecapRow(label: 'Service',       value: service),
//                   _RecapRow(label: 'Prestation',    value: service.split('–').last.trim(), isChip: true),
//                   _RecapRow(label: 'Durée',         value: duree),
//                   _RecapRow(label: 'Date et heure', value: creneau),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//                     child: Row(children: [
//                       const Text('Prix total:', style: TextStyle(fontSize: 14, color: _textGrey)),
//                       const Spacer(),
//                       Text('${prix}€',
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
//                     ]),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               // Vos informations
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('Vos informations',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                   const SizedBox(height: 12),
//                   const _RecapRow(label: 'Nom',       value: 'william nth'),
//                   const _RecapRow(label: 'Email',     value: 'williamnthiekam392@gmail.com'),
//                   const _RecapRow(label: 'Téléphone', value: '0615013694'),
//                 ]),
//               ),
//               const SizedBox(height: 16),

//               // Paiement
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8F8F8),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFF0F0F0))),
//                 child: const Column(children: [
//                   Icon(Icons.payment, size: 32, color: _textGrey),
//                   SizedBox(height: 8),
//                   Text('Paiement sur place',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
//                   SizedBox(height: 4),
//                   Text('Réglez directement auprès du coiffeur',
//                     style: TextStyle(fontSize: 13, color: _textGrey)),
//                 ]),
//               ),
//               const SizedBox(height: 24),
//             ]),
//           ),
//         ),

//         // Bouton confirmer
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           decoration: const BoxDecoration(color: Colors.white,
//             border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: ElevatedButton(
//             onPressed: () => Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => StepSuccesScreen(nomPresta: nomPresta)),
//               (route) => route.isFirst,
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 52),
//             ),
//             child: const Text('Confirmer la réservation',
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ])),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow({required this.icon, required this.text});
//   final IconData icon; final String text;
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 6),
//     child: Row(children: [
//       Icon(icon, size: 16, color: _textGrey),
//       const SizedBox(width: 8),
//       Text(text, style: const TextStyle(fontSize: 13, color: _textGrey)),
//     ]),
//   );
// }

// class _RecapRow extends StatelessWidget {
//   const _RecapRow({required this.label, required this.value, this.isChip = false});
//   final String label, value; final bool isChip;
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(children: [
//       SizedBox(width: 110,
//         child: Text(label, style: const TextStyle(fontSize: 13, color: _textGrey))),
//       Expanded(child: isChip
//         ? Align(alignment: Alignment.centerLeft,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
//               child: Text(value, style: const TextStyle(fontSize: 12, color: _textDark, fontWeight: FontWeight.w600))))
//         : Text(value, textAlign: TextAlign.right,
//             style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600))),
//     ]),
//   );
// }

// class _StepDone extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: const Icon(Icons.check, color: Colors.white, size: 18));
// }
// class _StepActive extends StatelessWidget {
//   const _StepActive({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: Center(child: Text('$num',
//       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepLine extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
// }