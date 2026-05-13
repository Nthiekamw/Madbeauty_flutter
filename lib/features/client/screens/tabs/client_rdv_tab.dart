

import 'package:flutter/material.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

class _Rdv {
  final String service, prestataire, date, heure, paiement, duree;
  final int prix;
  String statut; // 'En attente', 'Annulé', 'Confirmé'
  _Rdv({required this.service, required this.prestataire, required this.date,
    required this.heure, required this.paiement, required this.duree,
    required this.prix, required this.statut});
}

class ClientRdvTab extends StatefulWidget {
  final VoidCallback? onGoToRecherche;
  const ClientRdvTab({super.key, this.onGoToRecherche});

  @override
  State<ClientRdvTab> createState() => _ClientRdvTabState();
}

class _ClientRdvTabState extends State<ClientRdvTab> {
  int _tab = 0;
  bool _showCancelledSnack = false;

  final List<_Rdv> _rdvAVenir = [
    _Rdv(service: 'Coupes & Contours – Contours', prestataire: '19thSignature',
      date: 'lun. 18 mai', heure: '11:30', paiement: 'Sur place',
      duree: '1h', prix: 10, statut: 'En attente'),
  ];

  final List<_Rdv> _historique = [
    _Rdv(service: 'Twists – Départ Locks Twist',   prestataire: '19thSignature',
      date: 'mar. 19 mai', heure: '14:00', paiement: 'Sur place',
      duree: '3h',   prix: 100, statut: 'Annulé'),
    _Rdv(service: 'Vanilles – Vanilles Épaisses',  prestataire: 'Emilie',
      date: 'lun. 18 mai', heure: '23:30', paiement: 'Sur place',
      duree: '3h30', prix: 50,  statut: 'Annulé'),
    _Rdv(service: 'Coupes & Contours – Contours',  prestataire: '19thSignature',
      date: 'lun. 18 mai', heure: '11:30', paiement: 'Sur place',
      duree: '1h',   prix: 10,  statut: 'Annulé'),
    _Rdv(service: 'Tresses / Braids – Stitch Braids', prestataire: '19thSignature',
      date: 'mer. 6 mai',  heure: '12:00', paiement: 'Sur place',
      duree: '1h',   prix: 35,  statut: 'Annulé'),
  ];

  void _annulerRdv(_Rdv rdv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer l\'annulation',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: _textGrey, height: 1.5),
              children: [
                const TextSpan(text: 'Êtes-vous sûr de vouloir annuler votre rendez-vous\ndu '),
                TextSpan(text: '18/05/2026', style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
                const TextSpan(text: ' à '),
                TextSpan(text: '11:30', style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
                const TextSpan(text: ' ?'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Cette action ne peut pas être annulée.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textGrey)),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Column(children: [
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _rdvAVenir.remove(rdv);
                    rdv.statut = 'Annulé';
                    _historique.insert(0, rdv);
                    _showCancelledSnack = true;
                  });
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) setState(() => _showCancelledSnack = false);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Annuler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Garder', style: TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [

        // Carte profil
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0))),
            child: Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
                child: const Icon(Icons.person, color: _green, size: 28)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour william !',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                Text('Espace client', style: TextStyle(fontSize: 13, color: _textGrey)),
              ])),
              Container(width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))),
                child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
            ]),
          ),
        ),

        // Toggle À venir / Historique
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
            child: Row(children: [
              _TabBtn(
                label: 'À venir (${_rdvAVenir.length})',
                active: _tab == 0,
                onTap: () => setState(() => _tab = 0),
                badge: _rdvAVenir.isNotEmpty ? _rdvAVenir.length : null,
              ),
              _TabBtn(
                label: 'Historique (${_historique.length})',
                active: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // Contenu
        Expanded(
          child: _tab == 0
            ? (_rdvAVenir.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EmptyRdv(onTrouver: widget.onGoToRecherche))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _rdvAVenir.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _RdvCard(rdv: _rdvAVenir[i], onAnnuler: () => _annulerRdv(_rdvAVenir[i])),
                  ))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _historique.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _RdvCard(rdv: _historique[i], isHistorique: true),
              ),
        ),
      ]),

      // Snackbar annulation
      if (_showCancelledSnack)
        Positioned(top: 0, left: 0, right: 0,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)]),
            child: Row(children: [
              const Icon(Icons.check_circle, color: _green, size: 20),
              const SizedBox(width: 10),
              const Text('Rendez-vous annulé', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _showCancelledSnack = false),
                child: const Icon(Icons.close, size: 18, color: _textGrey)),
            ]),
          ),
        ),
    ]);
  }
}

class _RdvCard extends StatelessWidget {
  const _RdvCard({required this.rdv, this.onAnnuler, this.isHistorique = false});
  final _Rdv rdv;
  final VoidCallback? onAnnuler;
  final bool isHistorique;

  @override
  Widget build(BuildContext context) {
    final isAnnule = rdv.statut == 'Annulé';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rdv.service,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 2),
            Text('Avec ${rdv.prestataire}',
              style: const TextStyle(fontSize: 13, color: _textGrey)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAnnule ? const Color(0xFFFFEEEE) : const Color(0xFFFFFBE6),
                borderRadius: BorderRadius.circular(50)),
              child: Text(rdv.statut,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: isAnnule ? Colors.red : Colors.orange)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.payment, size: 12, color: _textGrey),
                const SizedBox(width: 4),
                Text(rdv.paiement, style: const TextStyle(fontSize: 11, color: _textGrey)),
              ]),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: _textGrey),
          const SizedBox(width: 4),
          Text('${rdv.date} à ${rdv.heure}',
            style: const TextStyle(fontSize: 13, color: _textGrey)),
          const Spacer(),
          Text('${rdv.prix}€ · ${rdv.duree}',
            style: const TextStyle(fontSize: 13, color: _textGrey)),
        ]),

        if (!isHistorique) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                label: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onAnnuler,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Annuler',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _EmptyRdv extends StatelessWidget {
  const _EmptyRdv({this.onTrouver});
  final VoidCallback? onTrouver;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF0F0F0))),
    child: Column(children: [
      const Icon(Icons.calendar_today_outlined, size: 52, color: _green),
      const SizedBox(height: 14),
      const Text('Aucun rendez-vous à venir',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 8),
      const Text('Réservez votre prochain rendez-vous dès maintenant',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: onTrouver,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        ),
        child: const Text('Trouver un coiffeur',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({required this.label, required this.active, required this.onTap, this.badge});
  final String label; final bool active; final VoidCallback onTap; final int? badge;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(50)),
        alignment: Alignment.center,
        child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
          Text(label, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: active ? Colors.white : _textGrey)),
          if (badge != null && badge! > 0)
            Positioned(top: -8, right: -18,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              )),
        ]),
      ),
    ),
  );
}
























































// import 'package:flutter/material.dart';

// const _rose      = Color(0xFF2D7A4F);
// const _roseLight = Color(0xFFE8F5EE);
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// class ClientRdvTab extends StatefulWidget {
//   const ClientRdvTab({super.key});

//   @override
//   State<ClientRdvTab> createState() => _ClientRdvTabState();
// }

// class _ClientRdvTabState extends State<ClientRdvTab> {
//   int _tab = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [

//       // Carte profil
//       Padding(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFF0F0F0)),
//           ),
//           child: Row(children: [
//             Container(width: 48, height: 48,
//               decoration: const BoxDecoration(shape: BoxShape.circle, color: _roseLight),
//               child: const Icon(Icons.person, color: _rose, size: 28)),
//             const SizedBox(width: 12),
//             const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text('Bonjour william !', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//               Text('Espace client',     style: TextStyle(fontSize: 13, color: _textGrey)),
//             ])),
//             Container(width: 36, height: 36,
//               decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))),
//               child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
//           ]),
//         ),
//       ),

//       // Toggle
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Container(
//           decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
//           child: Row(children: [
//             _TabBtn(label: 'À venir (0)',    active: _tab == 0, onTap: () => setState(() => _tab = 0)),
//             _TabBtn(label: 'Historique (1)', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
//           ]),
//         ),
//       ),
//       const SizedBox(height: 16),

//       // Contenu
//       Expanded(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: _tab == 0
//             ? _EmptyRdv()
//             : _EmptyRdv(title: 'Historique vide', subtitle: 'Vos rendez-vous passés apparaîtront ici'),
//         ),
//       ),
//     ]);
//   }
// }

// class _EmptyRdv extends StatelessWidget {
//   const _EmptyRdv({
//     this.title = 'Aucun rendez-vous à venir',
//     this.subtitle = 'Réservez votre prochain rendez-vous dès maintenant',
//   });
//   final String title, subtitle;

//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(32),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: const Color(0xFFF0F0F0)),
//     ),
//     child: Column(children: [
//       const Icon(Icons.calendar_today_outlined, size: 52, color: _rose),
//       const SizedBox(height: 14),
//       Text(title, textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//       const SizedBox(height: 8),
//       Text(subtitle, textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//       const SizedBox(height: 20),
//       ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _rose,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
//         ),
//         child: const Text('Trouver un Prestataire',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//       ),
//     ]),
//   );
// }

// class _TabBtn extends StatelessWidget {
//   const _TabBtn({required this.label, required this.active, required this.onTap});
//   final String label; final bool active; final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => Expanded(
//     child: GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: active ? _rose : Colors.transparent,
//           borderRadius: BorderRadius.circular(50),
//         ),
//         alignment: Alignment.center,
//         child: Text(label, style: TextStyle(
//           fontSize: 14, fontWeight: FontWeight.w600,
//           color: active ? Colors.white : _textGrey)),
//       ),
//     ),
//   );
// }