
import 'package:flutter/material.dart';

const _bgCream   = Color(0xFFF5EFE6);
const _gold      = Color(0xFFD4A96A);
const _goldLight = Color(0xFFF0E6D3);
const _green     = Color(0xFF4CAF50);
const _textDark  = Color(0xFF2C1810);
const _textMed   = Color(0xFF6B4C35);
const _textGrey  = Color(0xFF9E8878);

class _Rdv {
  final String service, prestataire, date, heure, paiement, duree;
  final int prix;
  String statut;
  _Rdv({required this.service, required this.prestataire, required this.date,
    required this.heure, required this.paiement, required this.duree,
    required this.prix, required this.statut});
}

// Vraies icônes vectorielles Material
const _prestations = [
  {'label': 'Coiffure',   'icon': Icons.content_cut},
  {'label': 'Maquillage', 'icon': Icons.face_retouching_natural},
  {'label': 'Manucure',   'icon': Icons.back_hand_outlined},
  {'label': 'Pédicure',   'icon': Icons.airline_seat_legroom_extra_outlined},
  {'label': 'Tatouage',   'icon': Icons.draw_outlined},
];

const _actionsRapides = [
  {'label': 'Ajouter\nun RDV',          'icon': Icons.add_circle_outline},
  {'label': 'Mes\nfavoris',             'icon': Icons.favorite_border},
  {'label': 'Salons\nproches',          'icon': Icons.near_me_outlined},
  {'label': 'Aide &\nSupport',          'icon': Icons.headset_mic_outlined},
];

class ClientRdvTab extends StatefulWidget {
  final VoidCallback? onGoToRecherche;
  const ClientRdvTab({super.key, this.onGoToRecherche});

  @override
  State<ClientRdvTab> createState() => _ClientRdvTabState();
}

class _ClientRdvTabState extends State<ClientRdvTab> {
  int _tab = 0;
  bool _showCancelledSnack = false;

  final List<_Rdv> _rdvAVenir = [];

  final List<_Rdv> _historique = [
    _Rdv(service: 'Twists – Départ Locks Twist',     prestataire: '19thSignature',
      date: 'mar. 19 mai', heure: '14:00', paiement: 'Sur place', duree: '3h',   prix: 100, statut: 'Annulé'),
    _Rdv(service: 'Vanilles – Vanilles Épaisses',     prestataire: 'Emilie',
      date: 'lun. 18 mai', heure: '23:30', paiement: 'Sur place', duree: '3h30', prix: 50,  statut: 'Annulé'),
    _Rdv(service: 'Coupes & Contours – Contours',     prestataire: '19thSignature',
      date: 'lun. 18 mai', heure: '11:30', paiement: 'Sur place', duree: '1h',   prix: 10,  statut: 'Annulé'),
    _Rdv(service: 'Tresses / Braids – Stitch Braids', prestataire: '19thSignature',
      date: 'mer. 6 mai',  heure: '12:00', paiement: 'Sur place', duree: '1h',   prix: 35,  statut: 'Annulé'),
    _Rdv(service: 'Maquillage – Soirée',              prestataire: 'GlamFace',
      date: 'sam. 3 mai',  heure: '18:00', paiement: 'Sur place', duree: '1h',   prix: 60,  statut: 'Confirmé'),
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
                const TextSpan(text: 'Êtes-vous sûr de vouloir annuler\nvotre rendez-vous du '),
                TextSpan(text: rdv.date,  style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
                const TextSpan(text: ' à '),
                TextSpan(text: rdv.heure, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
                const TextSpan(text: ' ?'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Cette action ne peut pas être annulée.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textGrey)),
        ]),
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
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Annuler le rendez-vous',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Garder',
                  style: TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
              )),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final h   = MediaQuery.of(context).size.height;
    final rem = w / 100;

    return Stack(children: [
      Container(
        color: _bgCream,
        child: Column(children: [

          // ── Header ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(rem * 4, rem * 4, rem * 4, rem * 3.5),
            child: Row(children: [
              Text('Rendez-vous', style: TextStyle(
                fontSize: rem * 5.5,
                fontWeight: FontWeight.w800,
                color: _textDark)),
              const Spacer(),

              // Thème
              PopupMenuButton<String>(
                icon: Icon(Icons.wb_sunny_outlined, size: rem * 5.5, color: _textDark),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
                  const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
                  const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
                ],
              ),

              // Notifications
              Stack(children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined,
                    size: rem * 5.5, color: _textDark)),
                Positioned(top: rem * 1, right: rem * 1,
                  child: Container(
                    width: rem * 2, height: rem * 2,
                    decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle))),
              ]),

              // Support
              PopupMenuButton<String>(
                icon: Icon(Icons.help_outline, size: rem * 5.5, color: _textDark),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
                  const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
                ],
              ),

              // Déconnexion
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.logout_rounded, size: rem * 5.5, color: _textDark)),
            ]),
          ),

          // ── Contenu scrollable ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: rem * 3.5),

                // ── Carte profil ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rem * 4),
                  child: Container(
                    padding: EdgeInsets.all(rem * 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rem * 4),
                      boxShadow: [BoxShadow(
                        color: _textDark.withOpacity(0.06),
                        blurRadius: 10, offset: const Offset(0, 3))]),
                    child: Row(children: [
                      Container(
                        width: rem * 13, height: rem * 13,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _goldLight),
                        child: Icon(Icons.person_rounded,
                          color: _gold, size: rem * 7)),
                      SizedBox(width: rem * 3),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Bonjour William !', style: TextStyle(
                          fontSize: rem * 4,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                        SizedBox(height: rem * 0.5),
                        Text('Prêt(e) pour une nouvelle expérience beauté ?',
                          style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                      ])),
                      Icon(Icons.chevron_right_rounded,
                        color: _textGrey, size: rem * 5),
                    ]),
                  ),
                ),
                SizedBox(height: rem * 4),

                // ── Toggle À venir / Historique ───────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rem * 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE0CC),
                      borderRadius: BorderRadius.circular(rem * 10)),
                    child: Row(children: [
                      _TabBtn(
                        label: 'À venir (${_rdvAVenir.length})',
                        icon: Icons.upcoming_outlined,
                        active: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                        rem: rem),
                      _TabBtn(
                        label: 'Historique (${_historique.length})',
                        icon: Icons.history_rounded,
                        active: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                        rem: rem),
                    ]),
                  ),
                ),
                SizedBox(height: rem * 4),

                // ── Contenu selon onglet ──────────────────────────────
                if (_tab == 0) ...[
                  if (_rdvAVenir.isEmpty)
                    _EmptyRdv(onTrouver: widget.onGoToRecherche, rem: rem, h: h)
                  else
                    ...(_rdvAVenir.map((rdv) => Padding(
                      padding: EdgeInsets.fromLTRB(rem * 4, 0, rem * 4, rem * 3.5),
                      child: _RdvCard(rdv: rdv, onAnnuler: () => _annulerRdv(rdv), rem: rem)))),
                ] else ...[
                  ...(_historique.map((rdv) => Padding(
                    padding: EdgeInsets.fromLTRB(rem * 4, 0, rem * 4, rem * 3.5),
                    child: _RdvCard(rdv: rdv, isHistorique: true, rem: rem)))),
                ],

                // ── Section prestations (onglet À venir uniquement) ───
                if (_tab == 0) ...[
                  SizedBox(height: rem * 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rem * 4),
                    child: Text('',
                      style: TextStyle(
                        fontSize: rem * 4.2,
                        fontWeight: FontWeight.w800,
                        color: _textDark)),
                  ),
                  SizedBox(height: rem * 3),

                  // Prestations
                  // SizedBox(
                  //   height: rem * 24,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     physics: const BouncingScrollPhysics(),
                  //     padding: EdgeInsets.symmetric(horizontal: rem * 4),
                  //     itemCount: _prestations.length,
                  //     itemBuilder: (_, i) {
                  //       final cat = _prestations[i];
                  //       return Container(
                  //         width: rem * 20,
                  //         margin: EdgeInsets.only(right: rem * 3),
                  //         padding: EdgeInsets.all(rem * 2.5),
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(rem * 4),
                  //           border: Border.all(color: const Color(0xFFEDE8E0)),
                  //           boxShadow: [BoxShadow(
                  //             color: _textDark.withOpacity(0.05),
                  //             blurRadius: 6, offset: const Offset(0, 2))]),
                  //         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  //           Container(
                  //             width: rem * 12, height: rem * 12,
                  //             decoration: BoxDecoration(
                  //               color: _goldLight, shape: BoxShape.circle),
                  //             child: Icon(cat['icon'] as IconData,
                  //               color: _gold, size: rem * 6)),
                  //           SizedBox(height: rem * 1.5),
                  //           Text(cat['label'] as String,
                  //             style: TextStyle(
                  //               fontSize: rem * 2.8,
                  //               fontWeight: FontWeight.w600,
                  //               color: _textDark),
                  //             textAlign: TextAlign.center),
                  //         ]),
                  //       );
                  //     },
                  //   ),
                  // ),
                  // SizedBox(height: rem * 5),

                  // ── Actions rapides ────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rem * 4),
                    child: Text('Actions rapides',
                      style: TextStyle(
                        fontSize: rem * 4.2,
                        fontWeight: FontWeight.w800,
                        color: _textDark)),
                  ),
                  SizedBox(height: rem * 3),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rem * 4),
                    child: Row(children: _actionsRapides.map((a) {
                      final isLast = a == _actionsRapides.last;
                      return Expanded(
                        child: Container(
                          margin: isLast ? null : EdgeInsets.only(right: rem * 2.5),
                          padding: EdgeInsets.symmetric(
                            vertical: rem * 3.5,
                            horizontal: rem),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(rem * 4),
                            border: Border.all(color: const Color(0xFFEDE8E0)),
                            boxShadow: [BoxShadow(
                              color: _textDark.withOpacity(0.04),
                              blurRadius: 6, offset: const Offset(0, 2))]),
                          child: Column(children: [
                            Container(
                              width: rem * 10, height: rem * 10,
                              decoration: BoxDecoration(
                                color: _goldLight, shape: BoxShape.circle),
                              child: Icon(a['icon'] as IconData,
                                color: _gold, size: rem * 5)),
                            SizedBox(height: rem * 1.5),
                            Text(a['label'] as String,
                              style: TextStyle(
                                fontSize: rem * 2.4,
                                color: _textDark,
                                fontWeight: FontWeight.w500,
                                height: 1.3),
                              textAlign: TextAlign.center,
                              maxLines: 2),
                          ]),
                        ),
                      );
                    }).toList()),
                  ),
                  SizedBox(height: rem * 5),

                  // ── Bannière rappel ────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rem * 4),
                    child: Container(
                      padding: EdgeInsets.all(rem * 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F0),
                        borderRadius: BorderRadius.circular(rem * 4),
                        border: Border.all(color: _gold.withOpacity(0.3))),
                      child: Row(children: [
                        Container(
                          width: rem * 11, height: rem * 11,
                          decoration: BoxDecoration(
                            color: _goldLight, shape: BoxShape.circle),
                          child: Icon(Icons.notifications_active_outlined,
                            color: _gold, size: rem * 5.5)),
                        SizedBox(width: rem * 3),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text('Rappel', style: TextStyle(
                            fontSize: rem * 3.6,
                            fontWeight: FontWeight.w700,
                            color: _textDark)),
                          SizedBox(height: rem),
                          Text(
                            'Nous vous enverrons une notification\npour ne rien manquer de vos rendez-vous.',
                            style: TextStyle(
                              fontSize: rem * 2.8,
                              color: _textGrey,
                              height: 1.4)),
                        ])),
                        Icon(Icons.chevron_right_rounded,
                          color: _textGrey, size: rem * 5),
                      ]),
                    ),
                  ),
                ],
                SizedBox(height: rem * 8),
              ]),
            ),
          ),
        ]),
      ),

      // ── Snackbar annulation ──────────────────────────────────────────
      if (_showCancelledSnack)
        Positioned(top: 0, left: 0, right: 0,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: const [BoxShadow(
                color: Color(0x20000000), blurRadius: 8)]),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
              const SizedBox(width: 10),
              const Text('Rendez-vous annulé',
                style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: _textDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showCancelledSnack = false),
                child: const Icon(Icons.close_rounded, size: 18, color: _textGrey)),
            ]),
          )),
    ]);
  }
}

// ── Carte RDV ─────────────────────────────────────────────────────────────────
class _RdvCard extends StatelessWidget {
  const _RdvCard({required this.rdv, this.onAnnuler,
    this.isHistorique = false, required this.rem});
  final _Rdv rdv;
  final VoidCallback? onAnnuler;
  final bool isHistorique;
  final double rem;

  @override
  Widget build(BuildContext context) {
    final isAnnule   = rdv.statut == 'Annulé';
    final isConfirme = rdv.statut == 'Confirmé';

    return Container(
      padding: EdgeInsets.all(rem * 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rem * 4.5),
        boxShadow: [BoxShadow(
          color: _textDark.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          // Icône service
          Container(
            width: rem * 11, height: rem * 11,
            decoration: BoxDecoration(
              color: _goldLight,
              borderRadius: BorderRadius.circular(rem * 3)),
            child: Icon(Icons.content_cut_rounded,
              color: _gold, size: rem * 5.5)),
          SizedBox(width: rem * 3),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rdv.service,
              style: TextStyle(fontSize: rem * 3.5,
                fontWeight: FontWeight.w700, color: _textDark),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: rem * 0.5),
            Text('Avec ${rdv.prestataire}',
              style: TextStyle(fontSize: rem * 3, color: _textGrey)),
          ])),

          // Badge statut
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rem * 2.5, vertical: rem),
            decoration: BoxDecoration(
              color: isAnnule
                ? const Color(0xFFFFEEEE)
                : isConfirme
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(rem * 4)),
            child: Text(rdv.statut,
              style: TextStyle(
                fontSize: rem * 2.8,
                fontWeight: FontWeight.w600,
                color: isAnnule
                  ? Colors.red
                  : isConfirme ? _green : Colors.orange))),
        ]),
        SizedBox(height: rem * 2.5),

        // Infos date + paiement
        Container(
          padding: EdgeInsets.all(rem * 2.5),
          decoration: BoxDecoration(
            color: _bgCream,
            borderRadius: BorderRadius.circular(rem * 3)),
          child: Row(children: [
            Icon(Icons.calendar_today_outlined,
              size: rem * 3.5, color: _gold),
            SizedBox(width: rem * 1.5),
            Text('${rdv.date} à ${rdv.heure}',
              style: TextStyle(fontSize: rem * 3,
                color: _textDark, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.access_time_rounded,
              size: rem * 3.2, color: _textGrey),
            SizedBox(width: rem),
            Text(rdv.duree,
              style: TextStyle(fontSize: rem * 3, color: _textGrey)),
          ]),
        ),
        SizedBox(height: rem * 2),

        // Prix + paiement
        Row(children: [
          Icon(Icons.payments_outlined, size: rem * 3.5, color: _textGrey),
          SizedBox(width: rem * 1.5),
          Text(rdv.paiement,
            style: TextStyle(fontSize: rem * 3, color: _textGrey)),
          const Spacer(),
          Text('${rdv.prix}€',
            style: TextStyle(
              fontSize: rem * 4.5,
              fontWeight: FontWeight.w800,
              color: _gold)),
        ]),

        if (!isHistorique) ...[
          SizedBox(height: rem * 3),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.chat_bubble_rounded,
                size: rem * 4, color: Colors.white),
              label: Text('Chat', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: rem * 3.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rem * 4)),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: rem * 3)),
            )),
            SizedBox(width: rem * 2.5),
            Expanded(child: ElevatedButton.icon(
              onPressed: onAnnuler,
              icon: Icon(Icons.cancel_outlined,
                size: rem * 4, color: Colors.white),
              label: Text('Annuler', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: rem * 3.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rem * 4)),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: rem * 3)),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ── Vide ──────────────────────────────────────────────────────────────────────
class _EmptyRdv extends StatelessWidget {
  const _EmptyRdv({this.onTrouver, required this.rem, required this.h});
  final VoidCallback? onTrouver;
  final double rem, h;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: rem * 4),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(rem * 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rem * 5),
        boxShadow: [BoxShadow(
          color: const Color(0xFF2C1810).withOpacity(0.07),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [

        // Illustration
        Stack(alignment: Alignment.center, children: [
          Container(
            width: rem * 36, height: rem * 36,
            decoration: BoxDecoration(
              color: _goldLight, shape: BoxShape.circle)),
          Icon(Icons.calendar_month_rounded,
            size: rem * 18, color: _gold),
          Positioned(bottom: rem * 3, right: rem * 3,
            child: Container(
              width: rem * 10, height: rem * 10,
              decoration: const BoxDecoration(
                color: _green, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded,
                color: Colors.white, size: rem * 6))),
        ]),
        SizedBox(height: rem * 5),

        Text('Aucun rendez-vous à venir',
          style: TextStyle(
            fontSize: rem * 4.8,
            fontWeight: FontWeight.w800,
            color: _textDark),
          textAlign: TextAlign.center),
        SizedBox(height: rem * 2),

        Text('Réservez votre prochain rendez-vous\ndès maintenant et prenez soin de vous.',
          style: TextStyle(
            fontSize: rem * 3.2,
            color: _textGrey,
            height: 1.5),
          textAlign: TextAlign.center),
        SizedBox(height: rem * 2),

        // Ligne déco
        Container(
          width: rem * 12, height: 2,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2))),
        SizedBox(height: rem * 5),

        // Bouton
        GestureDetector(
          onTap: onTrouver,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: rem * 7, vertical: rem * 3.5),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(rem * 8),
              boxShadow: [BoxShadow(
                color: _gold.withOpacity(0.4),
                blurRadius: 12, offset: const Offset(0, 5))]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_rounded,
                color: Colors.white, size: rem * 5),
              SizedBox(width: rem * 2.5),
              Text('Trouver un professionnel',
                style: TextStyle(
                  fontSize: rem * 3.8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
            ])),
        ),
        SizedBox(height: rem * 2),
      ]),
    ),
  );
}

// ── Tab bouton ────────────────────────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  const _TabBtn({required this.label, required this.icon,
    required this.active, required this.onTap, required this.rem});
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final double rem;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rem * 3.2),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(rem * 10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: rem * 4.2,
            color: active ? Colors.white : _textGrey),
          SizedBox(width: rem * 1.5),
          Text(label, style: TextStyle(
            fontSize: rem * 3.2,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : _textGrey)),
        ]),
      ),
    ),
  );
}









































// import 'package:flutter/material.dart';

// const _bgCream   = Color(0xFFF5EFE6);
// const _gold      = Color(0xFFD4A96A);
// const _goldLight = Color(0xFFF0E6D3);
// const _green     = Color(0xFF4CAF50);  // garde vert uniquement pour badge dispo
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// class _Rdv {
//   final String service, prestataire, date, heure, paiement, duree;
//   final int prix;
//   String statut;
//   _Rdv({required this.service, required this.prestataire, required this.date,
//     required this.heure, required this.paiement, required this.duree,
//     required this.prix, required this.statut});
// }

// const _prestations = [
//   {'label': 'Coiffure',   'emoji': '👩‍🦱'},
//   {'label': 'Maquillage', 'emoji': '👁'},
//   {'label': 'Manucure',   'emoji': '💅'},
//   {'label': 'Pédicure',   'emoji': '🦶'},
//   {'label': 'Tatouage',   'emoji': '🖊'},
// ];

// const _actionsRapides = [
//   {'label': 'Ajouter\nun rendez-vous',         'icon': Icons.calendar_today_outlined},
//   {'label': 'Mes favoris\nprofessionnels',      'icon': Icons.favorite_border},
//   {'label': 'Salons à\nproximité',              'icon': Icons.location_on_outlined},
//   {'label': 'Besoin d\'aide ?\nContactez-nous', 'icon': Icons.headset_mic_outlined},
// ];

// class ClientRdvTab extends StatefulWidget {
//   final VoidCallback? onGoToRecherche;
//   const ClientRdvTab({super.key, this.onGoToRecherche});

//   @override
//   State<ClientRdvTab> createState() => _ClientRdvTabState();
// }

// class _ClientRdvTabState extends State<ClientRdvTab> {
//   int _tab = 0;
//   bool _showCancelledSnack = false;

//   final List<_Rdv> _rdvAVenir = [];

//   final List<_Rdv> _historique = [
//     _Rdv(service: 'Twists – Départ Locks Twist',      prestataire: '19thSignature',
//       date: 'mar. 19 mai', heure: '14:00', paiement: 'Sur place', duree: '3h',   prix: 100, statut: 'Annulé'),
//     _Rdv(service: 'Vanilles – Vanilles Épaisses',      prestataire: 'Emilie',
//       date: 'lun. 18 mai', heure: '23:30', paiement: 'Sur place', duree: '3h30', prix: 50,  statut: 'Annulé'),
//     _Rdv(service: 'Coupes & Contours – Contours',      prestataire: '19thSignature',
//       date: 'lun. 18 mai', heure: '11:30', paiement: 'Sur place', duree: '1h',   prix: 10,  statut: 'Annulé'),
//     _Rdv(service: 'Tresses / Braids – Stitch Braids',  prestataire: '19thSignature',
//       date: 'mer. 6 mai',  heure: '12:00', paiement: 'Sur place', duree: '1h',   prix: 35,  statut: 'Annulé'),
//     _Rdv(service: 'Maquillage – Soirée',               prestataire: 'GlamFace',
//       date: 'sam. 3 mai',  heure: '18:00', paiement: 'Sur place', duree: '1h',   prix: 60,  statut: 'Confirmé'),
//   ];

//   void _annulerRdv(_Rdv rdv) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Confirmer l\'annulation',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           RichText(
//             textAlign: TextAlign.center,
//             text: TextSpan(
//               style: const TextStyle(fontSize: 14, color: _textGrey, height: 1.5),
//               children: [
//                 const TextSpan(text: 'Êtes-vous sûr de vouloir annuler\nvotre rendez-vous du '),
//                 TextSpan(text: rdv.date, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
//                 const TextSpan(text: ' à '),
//                 TextSpan(text: rdv.heure, style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
//                 const TextSpan(text: ' ?'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text('Cette action ne peut pas être annulée.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 13, color: _textGrey)),
//         ]),
//         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         actions: [
//           Column(children: [
//             SizedBox(width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     _rdvAVenir.remove(rdv);
//                     rdv.statut = 'Annulé';
//                     _historique.insert(0, rdv);
//                     _showCancelledSnack = true;
//                   });
//                   Future.delayed(const Duration(seconds: 3), () {
//                     if (mounted) setState(() => _showCancelledSnack = false);
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                   elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
//                 child: const Text('Annuler le rendez-vous',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
//               )),
//             const SizedBox(height: 8),
//             SizedBox(width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Color(0xFFE0E0E0)),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                   padding: const EdgeInsets.symmetric(vertical: 14)),
//                 child: const Text('Garder',
//                   style: TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
//               )),
//           ]),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//     final p = w * 0.045;

//     return Stack(children: [
//       Container(
//         color: _bgCream,
//         child: Column(children: [

//           // ── Header ────────────────────────────────────────────────────
//           Container(
//             color: Colors.white,
//             padding: EdgeInsets.fromLTRB(p, h * 0.02, p, h * 0.015),
//             child: Row(children: [
//               Text('Rendez-vous', style: TextStyle(
//                 fontSize: w * 0.055, fontWeight: FontWeight.w800, color: _textDark)),
//               const Spacer(),
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.wb_sunny_outlined, size: w * 0.055, color: _textDark),
//                 onSelected: (v) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
//                   const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
//                   const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
//                 ],
//               ),
//               Stack(children: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.notifications_outlined, size: w * 0.055, color: _textDark)),
//                 Positioned(top: 8, right: 8,
//                   child: Container(width: w * 0.02, height: w * 0.02,
//                     decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
//               ]),
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.help_outline, size: w * 0.055, color: _textDark),
//                 onSelected: (v) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
//                   const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
//                 ],
//               ),
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(Icons.logout, size: w * 0.055, color: _textDark)),
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(Icons.settings_outlined, size: w * 0.055, color: _textDark)),
//             ]),
//           ),

//           // ── Contenu scrollable ────────────────────────────────────────
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 SizedBox(height: h * 0.015),

//                 // ── Carte profil ────────────────────────────────────────
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: p),
//                   child: Container(
//                     padding: EdgeInsets.all(p * 0.8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(w * 0.04),
//                       boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
//                     child: Row(children: [
//                       Container(
//                         width: w * 0.13, height: w * 0.13,
//                         decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
//                         child: Icon(Icons.person, color: _gold, size: w * 0.07)),
//                       SizedBox(width: w * 0.03),
//                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text('Bonjour William !', style: TextStyle(
//                           fontSize: w * 0.04, fontWeight: FontWeight.w700, color: _textDark)),
//                         Text('Prêt(e) pour une nouvelle expérience beauté ?',
//                           style: TextStyle(fontSize: w * 0.03, color: _textGrey)),
//                       ])),
//                       Icon(Icons.chevron_right, color: _textGrey, size: w * 0.05),
//                     ]),
//                   ),
//                 ),
//                 SizedBox(height: h * 0.02),

//                 // ── Toggle À venir / Historique ─────────────────────────
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: p),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF0EAE0),
//                       borderRadius: BorderRadius.circular(w * 0.1)),
//                     child: Row(children: [
//                       _TabBtn(
//                         label: 'À venir (${_rdvAVenir.length})',
//                         icon: Icons.calendar_today_outlined,
//                         active: _tab == 0,
//                         onTap: () => setState(() => _tab = 0)),
//                       _TabBtn(
//                         label: 'Historique (${_historique.length})',
//                         icon: Icons.history,
//                         active: _tab == 1,
//                         onTap: () => setState(() => _tab = 1)),
//                     ]),
//                   ),
//                 ),
//                 SizedBox(height: h * 0.02),

//                 // ── Contenu selon onglet ────────────────────────────────
//                 if (_tab == 0) ...[
//                   if (_rdvAVenir.isEmpty)
//                     _EmptyRdv(onTrouver: widget.onGoToRecherche, w: w, h: h, p: p)
//                   else
//                     ...(_rdvAVenir.map((rdv) => Padding(
//                       padding: EdgeInsets.fromLTRB(p, 0, p, h * 0.016),
//                       child: _RdvCard(rdv: rdv, onAnnuler: () => _annulerRdv(rdv), w: w, h: h),
//                     ))),
//                 ] else ...[
//                   ...(_historique.map((rdv) => Padding(
//                     padding: EdgeInsets.fromLTRB(p, 0, p, h * 0.016),
//                     child: _RdvCard(rdv: rdv, isHistorique: true, w: w, h: h),
//                   ))),
//                 ],

//                 // ── Choisissez votre prestation ─────────────────────────
//                 if (_tab == 0) ...[
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: p),
//                     child: Text('Choisissez votre prestation', style: TextStyle(
//                       fontSize: w * 0.042, fontWeight: FontWeight.w800, color: _textDark)),
//                   ),
//                   SizedBox(height: h * 0.015),
//                   SizedBox(
//                     height: h * 0.115,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: EdgeInsets.symmetric(horizontal: p),
//                       itemCount: _prestations.length,
//                       itemBuilder: (_, i) {
//                         final cat = _prestations[i];
//                         return Container(
//                           width: w * 0.2,
//                           margin: EdgeInsets.only(right: w * 0.03),
//                           padding: EdgeInsets.all(w * 0.025),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(w * 0.04),
//                             border: Border.all(color: const Color(0xFFEDE8E0)),
//                             boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))]),
//                           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                             Text(cat['emoji'] as String, style: TextStyle(fontSize: w * 0.07)),
//                             SizedBox(height: h * 0.006),
//                             Text(cat['label'] as String, style: TextStyle(
//                               fontSize: w * 0.028, fontWeight: FontWeight.w600, color: _textDark),
//                               textAlign: TextAlign.center),
//                           ]),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: h * 0.022),

//                   // ── Actions rapides ─────────────────────────────────────
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: p),
//                     child: Text('Actions rapides', style: TextStyle(
//                       fontSize: w * 0.042, fontWeight: FontWeight.w800, color: _textDark)),
//                   ),
//                   SizedBox(height: h * 0.015),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: p),
//                     child: Row(children: _actionsRapides.map((a) => Expanded(
//                       child: Container(
//                         margin: EdgeInsets.only(right: a == _actionsRapides.last ? 0 : w * 0.025),
//                         padding: EdgeInsets.symmetric(vertical: h * 0.018, horizontal: w * 0.01),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(w * 0.04),
//                           border: Border.all(color: const Color(0xFFEDE8E0))),
//                         child: Column(children: [
//                           Container(
//                             width: w * 0.1, height: w * 0.1,
//                             decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
//                             child: Icon(a['icon'] as IconData, color: _gold, size: w * 0.05)),
//                           SizedBox(height: h * 0.008),
//                           Text(a['label'] as String,
//                             style: TextStyle(fontSize: w * 0.024, color: _textDark,
//                               fontWeight: FontWeight.w500, height: 1.3),
//                             textAlign: TextAlign.center, maxLines: 2),
//                         ]),
//                       ),
//                     )).toList()),
//                   ),
//                   SizedBox(height: h * 0.022),

//                   // ── Bannière rappel ─────────────────────────────────────
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: p),
//                     child: Container(
//                       padding: EdgeInsets.all(p * 0.8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF8F0),
//                         borderRadius: BorderRadius.circular(w * 0.04),
//                         border: Border.all(color: _gold.withOpacity(0.3))),
//                       child: Row(children: [
//                         Container(
//                           width: w * 0.1, height: w * 0.1,
//                           decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
//                           child: Icon(Icons.notifications_outlined, color: _gold, size: w * 0.05)),
//                         SizedBox(width: w * 0.03),
//                         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                           Text('Rappel', style: TextStyle(
//                             fontSize: w * 0.036, fontWeight: FontWeight.w700, color: _textDark)),
//                           SizedBox(height: h * 0.004),
//                           Text('Nous vous enverrons une notification\npour ne rien manquer de vos rendez-vous.',
//                             style: TextStyle(fontSize: w * 0.028, color: _textGrey, height: 1.4)),
//                         ])),
//                         Icon(Icons.chevron_right, color: _textGrey, size: w * 0.05),
//                       ]),
//                     ),
//                   ),
//                 ],
//                 SizedBox(height: h * 0.03),
//               ]),
//             ),
//           ),
//         ]),
//       ),

//       // ── Snackbar annulation ──────────────────────────────────────────
//       if (_showCancelledSnack)
//         Positioned(top: 0, left: 0, right: 0,
//           child: Container(
//             margin: const EdgeInsets.all(12),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE0E0E0)),
//               boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)]),
//             child: Row(children: [
//               const Icon(Icons.check_circle, color: _green, size: 20),
//               const SizedBox(width: 10),
//               const Text('Rendez-vous annulé',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => setState(() => _showCancelledSnack = false),
//                 child: const Icon(Icons.close, size: 18, color: _textGrey)),
//             ]),
//           )),
//     ]);
//   }
// }

// // ── Carte RDV ─────────────────────────────────────────────────────────────────
// class _RdvCard extends StatelessWidget {
//   const _RdvCard({required this.rdv, this.onAnnuler, this.isHistorique = false,
//     required this.w, required this.h});
//   final _Rdv rdv; final VoidCallback? onAnnuler;
//   final bool isHistorique; final double w, h;

//   @override
//   Widget build(BuildContext context) {
//     final isAnnule   = rdv.statut == 'Annulé';
//     final isConfirme = rdv.statut == 'Confirmé';

//     return Container(
//       padding: EdgeInsets.all(w * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(w * 0.045),
//         boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(rdv.service, style: TextStyle(
//               fontSize: w * 0.038, fontWeight: FontWeight.w700, color: _textDark)),
//             SizedBox(height: h * 0.003),
//             Text('Avec ${rdv.prestataire}',
//               style: TextStyle(fontSize: w * 0.032, color: _textGrey)),
//           ])),
//           Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.004),
//               decoration: BoxDecoration(
//                 color: isAnnule
//                   ? const Color(0xFFFFEEEE)
//                   : isConfirme
//                     ? const Color(0xFFE8F5E9)
//                     : const Color(0xFFFFF8E7),
//                 borderRadius: BorderRadius.circular(50)),
//               child: Text(rdv.statut, style: TextStyle(
//                 fontSize: w * 0.028, fontWeight: FontWeight.w600,
//                 color: isAnnule ? Colors.red : isConfirme ? _green : Colors.orange))),
//             SizedBox(height: h * 0.005),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.004),
//               decoration: BoxDecoration(
//                 color: _goldLight, borderRadius: BorderRadius.circular(50)),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.payment, size: w * 0.03, color: _gold),
//                 SizedBox(width: w * 0.01),
//                 Text(rdv.paiement, style: TextStyle(fontSize: w * 0.026, color: _gold)),
//               ])),
//           ]),
//         ]),
//         SizedBox(height: h * 0.01),
//         Row(children: [
//           Icon(Icons.access_time, size: w * 0.035, color: _textGrey),
//           SizedBox(width: w * 0.01),
//           Text('${rdv.date} à ${rdv.heure}',
//             style: TextStyle(fontSize: w * 0.032, color: _textGrey)),
//           const Spacer(),
//           Text('${rdv.prix}€ · ${rdv.duree}',
//             style: TextStyle(fontSize: w * 0.032, color: _textGrey, fontWeight: FontWeight.w600)),
//         ]),
//         if (!isHistorique) ...[
//           SizedBox(height: h * 0.012),
//           Row(children: [
//             Expanded(child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: Icon(Icons.chat_bubble_outline, size: w * 0.04, color: Colors.white),
//               label: Text('Chat', style: TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.w600, fontSize: w * 0.035)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _gold,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 elevation: 0, padding: EdgeInsets.symmetric(vertical: h * 0.014)),
//             )),
//             SizedBox(width: w * 0.025),
//             Expanded(child: ElevatedButton(
//               onPressed: onAnnuler,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 elevation: 0, padding: EdgeInsets.symmetric(vertical: h * 0.014)),
//               child: Text('Annuler', style: TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.w600, fontSize: w * 0.035)),
//             )),
//           ]),
//         ],
//       ]),
//     );
//   }
// }

// // ── Vide ─────────────────────────────────────────────────────────────────────
// class _EmptyRdv extends StatelessWidget {
//   const _EmptyRdv({this.onTrouver, required this.w, required this.h, required this.p});
//   final VoidCallback? onTrouver; final double w, h, p;

//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: EdgeInsets.symmetric(horizontal: p),
//     child: Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(p),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(w * 0.05),
//         boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))]),
//       child: Column(children: [
//         SizedBox(height: h * 0.01),
//         // Illustration calendrier
//         Container(
//           width: w * 0.35, height: w * 0.35,
//           decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
//           child: Stack(alignment: Alignment.center, children: [
//             Icon(Icons.calendar_today_outlined, size: w * 0.18, color: _gold),
//             Positioned(bottom: w * 0.05, right: w * 0.05,
//               child: Container(
//                 width: w * 0.1, height: w * 0.1,
//                 decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
//                 child: Icon(Icons.check, color: Colors.white, size: w * 0.06))),
//           ])),
//         SizedBox(height: h * 0.025),
//         Text('Aucun rendez-vous à venir', style: TextStyle(
//           fontSize: w * 0.048, fontWeight: FontWeight.w800, color: _textDark),
//           textAlign: TextAlign.center),
//         SizedBox(height: h * 0.008),
//         Text('Réservez votre prochain rendez-vous dès maintenant\net prenez soin de vous.',
//           style: TextStyle(fontSize: w * 0.032, color: _textGrey, height: 1.5),
//           textAlign: TextAlign.center),
//         SizedBox(height: h * 0.008),
//         Container(width: w * 0.12, height: 2,
//           decoration: BoxDecoration(color: _gold.withOpacity(0.4),
//             borderRadius: BorderRadius.circular(2))),
//         SizedBox(height: h * 0.025),
//         GestureDetector(
//           onTap: onTrouver,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.018),
//             decoration: BoxDecoration(
//               color: _gold,
//               borderRadius: BorderRadius.circular(w * 0.1),
//               boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 5))]),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(Icons.search, color: Colors.white, size: w * 0.05),
//               SizedBox(width: w * 0.025),
//               Text('Trouver un professionnel', style: TextStyle(
//                 fontSize: w * 0.038, fontWeight: FontWeight.w700, color: Colors.white)),
//             ])),
//         ),
//         SizedBox(height: h * 0.01),
//       ]),
//     ),
//   );
// }

// // ── Tab bouton ────────────────────────────────────────────────────────────────
// class _TabBtn extends StatelessWidget {
//   const _TabBtn({required this.label, required this.icon, required this.active, required this.onTap});
//   final String label; final IconData icon; final bool active; final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: w * 0.034),
//           decoration: BoxDecoration(
//             color: active ? _gold : Colors.transparent,
//             borderRadius: BorderRadius.circular(w * 0.1)),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(icon, size: w * 0.042,
//               color: active ? Colors.white : _textGrey),
//             SizedBox(width: w * 0.015),
//             Text(label, style: TextStyle(
//               fontSize: w * 0.032, fontWeight: FontWeight.w600,
//               color: active ? Colors.white : _textGrey)),
//           ]),
//         ),
//       ),
//     );
//   }
// }























