

import 'package:flutter/material.dart';
import 'reservation/reservation_screen.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

const _servicesByType = {
  'coiffeur': [
    {'categorie': 'Tresses / Braids', 'count': 3, 'prestations': [
      {'nom': 'Stitch Braids', 'prix': 35, 'duree': '1h'},
      {'nom': 'Fulani Braids', 'prix': 40, 'duree': '1h'},
      {'nom': 'Cornrows',      'prix': 30, 'duree': '1h'},
    ]},
    {'categorie': 'Twists', 'count': 5, 'prestations': [
      {'nom': 'Flat Twists',        'prix': 40,  'duree': '1h'},
      {'nom': 'Départ Locks Twist', 'prix': 100, 'duree': '3h'},
      {'nom': 'Barrel Twists',      'prix': 50,  'duree': '1h'},
      {'nom': 'Reprise Twist',      'prix': 60,  'duree': '1h'},
      {'nom': 'Two Strand Twists',  'prix': 50,  'duree': '1h'},
    ]},
    {'categorie': 'Vanilles', 'count': 6, 'prestations': [
      {'nom': 'Vanilles Fines',       'prix': 60, 'duree': '1h'},
      {'nom': 'Vanilles Épaisses',    'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Courtes',     'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Sans Mèches', 'prix': 40, 'duree': '1h'},
      {'nom': 'Vanilles Avec Mèches', 'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Simples',     'prix': 40, 'duree': '1h'},
    ]},
    {'categorie': 'Locks / Dreadlocks', 'count': 2, 'prestations': [
      {'nom': 'Retwist',      'prix': 50,  'duree': '1h'},
      {'nom': 'Départ Locks', 'prix': 100, 'duree': '1h'},
    ]},
    {'categorie': 'Barbe & Soins Visage', 'count': 3, 'prestations': [
      {'nom': 'Contours Barbe', 'prix': 10, 'duree': '30min'},
      {'nom': 'Dégradé Barbe',  'prix': 10, 'duree': '30min'},
      {'nom': 'Taille Barbe',   'prix': 10, 'duree': '30min'},
    ]},
    {'categorie': 'Coupes & Contours', 'count': 8, 'prestations': [
      {'nom': 'Twisty Cut',        'prix': 20, 'duree': '1h'},
      {'nom': 'Burst Fade',        'prix': 20, 'duree': '1h'},
      {'nom': 'Dégradé Haut',      'prix': 10, 'duree': '45min'},
      {'nom': 'Dégradé Américain', 'prix': 15, 'duree': '45min'},
      {'nom': 'Contours',          'prix': 10, 'duree': '30min'},
      {'nom': 'Coupe Enfant',      'prix': 10, 'duree': '30min'},
      {'nom': 'Coupe Femme',       'prix': 25, 'duree': '1h'},
      {'nom': 'Brushing',          'prix': 20, 'duree': '45min'},
    ]},
  ],
  'maquillage': [
    {'categorie': 'Maquillage Jour', 'count': 3, 'prestations': [
      {'nom': 'Maquillage naturel',  'prix': 40, 'duree': '45min'},
      {'nom': 'Maquillage bureau',   'prix': 45, 'duree': '45min'},
      {'nom': 'Maquillage étudiant', 'prix': 35, 'duree': '30min'},
    ]},
    {'categorie': 'Maquillage Soirée', 'count': 4, 'prestations': [
      {'nom': 'Maquillage soirée',  'prix': 60, 'duree': '1h'},
      {'nom': 'Maquillage glamour', 'prix': 70, 'duree': '1h'},
      {'nom': 'Maquillage smoky',   'prix': 65, 'duree': '1h'},
      {'nom': 'Maquillage scène',   'prix': 80, 'duree': '1h30'},
    ]},
    {'categorie': 'Maquillage Événement', 'count': 4, 'prestations': [
      {'nom': 'Maquillage mariée',    'prix': 120, 'duree': '2h'},
      {'nom': 'Maquillage cérémonie', 'prix': 80,  'duree': '1h30'},
      {'nom': 'Maquillage EVJF',      'prix': 60,  'duree': '1h'},
      {'nom': 'Maquillage shooting',  'prix': 90,  'duree': '1h30'},
    ]},
    {'categorie': 'Soins Visage', 'count': 3, 'prestations': [
      {'nom': 'Soin hydratant',    'prix': 45, 'duree': '45min'},
      {'nom': 'Nettoyage de peau', 'prix': 50, 'duree': '1h'},
      {'nom': 'Soin anti-taches',  'prix': 55, 'duree': '1h'},
    ]},
    {'categorie': 'Sourcils & Cils', 'count': 4, 'prestations': [
      {'nom': 'Épilation sourcils',       'prix': 15, 'duree': '20min'},
      {'nom': 'Restructuration sourcils', 'prix': 25, 'duree': '30min'},
      {'nom': 'Pose cils classiques',     'prix': 60, 'duree': '1h30'},
      {'nom': 'Pose cils volume',         'prix': 80, 'duree': '2h'},
    ]},
  ],
  'manicure': [
    {'categorie': 'Manucure', 'count': 4, 'prestations': [
      {'nom': 'Manucure simple',         'prix': 25, 'duree': '45min'},
      {'nom': 'Manucure semi-permanent', 'prix': 35, 'duree': '1h'},
      {'nom': 'Manucure gel',            'prix': 40, 'duree': '1h'},
      {'nom': 'Manucure french',         'prix': 35, 'duree': '1h'},
    ]},
    {'categorie': 'Nail Art', 'count': 4, 'prestations': [
      {'nom': 'Nail art simple',       'prix': 45, 'duree': '1h'},
      {'nom': 'Nail art dégradé',      'prix': 55, 'duree': '1h30'},
      {'nom': 'Nail art 3D',           'prix': 70, 'duree': '2h'},
      {'nom': 'Nail art personnalisé', 'prix': 65, 'duree': '1h30'},
    ]},
    {'categorie': 'Extensions Ongles', 'count': 3, 'prestations': [
      {'nom': 'Pose capsules',          'prix': 50, 'duree': '1h30'},
      {'nom': 'Pose gel',               'prix': 55, 'duree': '1h30'},
      {'nom': 'Rallongement acrylique', 'prix': 60, 'duree': '2h'},
    ]},
    {'categorie': 'Pédicure', 'count': 3, 'prestations': [
      {'nom': 'Pédicure simple',         'prix': 30, 'duree': '45min'},
      {'nom': 'Pédicure semi-permanent', 'prix': 40, 'duree': '1h'},
      {'nom': 'Pédicure beauté',         'prix': 45, 'duree': '1h'},
    ]},
    {'categorie': 'Soins Mains & Pieds', 'count': 3, 'prestations': [
      {'nom': 'Soin hydratant mains', 'prix': 20, 'duree': '30min'},
      {'nom': 'Gommage mains',        'prix': 25, 'duree': '30min'},
      {'nom': 'Bain de pieds',        'prix': 20, 'duree': '30min'},
    ]},
  ],
};

const _confortItems = [
  'Adresse facile à trouver',
  'Boissons offertes (eau, jus, thé…)',
  'Canapé ou fauteuil confortable',
  'Chargeur de téléphone disponible',
];

const _dispos = [
  {'jour': 'Lundi',    'heures': ['11:30']},
  {'jour': 'Mardi',    'heures': ['14:00']},
  {'jour': 'Mercredi', 'heures': ['11:30', '12:00']},
];

IconData _iconForType(String type) {
  switch (type) {
    case 'maquillage': return Icons.face_retouching_natural;
    case 'manicure':   return Icons.back_hand_outlined;
    default:           return Icons.content_cut_rounded;
  }
}

String _labelForType(String type) {
  switch (type) {
    case 'maquillage': return 'Maquilleur(se)';
    case 'manicure':   return 'Manucure / Pédicure';
    default:           return 'Coiffeur(se)';
  }
}

String _bioForType(String type) {
  switch (type) {
    case 'maquillage': return 'Je suis une maquilleuse passionnée qui sublime chaque visage avec art et précision !';
    case 'manicure':   return 'Spécialiste de la beauté des mains et des pieds, je vous offre un soin impeccable.';
    default:           return 'Je suis une coiffeuse autodidacte qui aime sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi.';
  }
}

class ProfilPrestataireScreen extends StatefulWidget {
  final String nom, ville;
  final String typePresta;
  const ProfilPrestataireScreen({super.key, required this.nom,
    required this.ville, this.typePresta = 'coiffeur'});

  @override
  State<ProfilPrestataireScreen> createState() => _ProfilPrestataireScreenState();
}

class _ProfilPrestataireScreenState extends State<ProfilPrestataireScreen> {
  final Set<int> _expandedCats = {0};

  List<Map<String, dynamic>> get _services =>
    List<Map<String, dynamic>>.from(
      _servicesByType[widget.typePresta] ?? _servicesByType['coiffeur']!);

  @override
  Widget build(BuildContext context) {
    final w    = MediaQuery.of(context).size.width;
    final rem  = w / 100;
    final icon  = _iconForType(widget.typePresta);
    final label = _labelForType(widget.typePresta);
    final bio   = _bioForType(widget.typePresta);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        CustomScrollView(slivers: [

          // ── App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: rem * 45,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(rem * 2),
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
                child: Icon(Icons.arrow_back_rounded, color: _textDark, size: rem * 5))),
            actions: [
              Container(
                margin: EdgeInsets.all(rem * 2),
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
                child: IconButton(
                  icon: Icon(Icons.share_outlined, color: _textDark, size: rem * 5),
                  onPressed: () {})),
            ],
            title: Text('Profil', style: TextStyle(
              color: _textDark, fontWeight: FontWeight.w700, fontSize: rem * 4.2)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(children: [
                Container(color: _goldLight),
                Positioned(
                  bottom: rem * 5, left: rem * 4,
                  child: Stack(children: [
                    Container(
                      width: rem * 18, height: rem * 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _gold,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(
                          color: _gold.withOpacity(0.4),
                          blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Icon(icon, color: Colors.white, size: rem * 9)),
                    Positioned(bottom: rem, right: rem,
                      child: Container(
                        width: rem * 4, height: rem * 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)))),
                  ])),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, rem * 25),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Infos ────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(rem * 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rem * 4),
                    boxShadow: [BoxShadow(
                      color: _textDark.withOpacity(0.06),
                      blurRadius: 10, offset: const Offset(0, 3))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.nom, style: TextStyle(
                      fontSize: rem * 5.5, fontWeight: FontWeight.w900, color: _textDark)),
                    SizedBox(height: rem * 2),

                    // Badge type
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: rem * 2.5, vertical: rem),
                      decoration: BoxDecoration(
                        color: _goldLight, borderRadius: BorderRadius.circular(rem * 5)),
                      child: Text(label, style: TextStyle(
                        fontSize: rem * 3, color: _goldDark, fontWeight: FontWeight.w600))),
                    SizedBox(height: rem * 2.5),

                    _IR(icon: Icons.location_on_outlined, text: widget.ville, rem: rem),
                    _IR(icon: icon,                       text: 'Chez le prestataire', rem: rem),
                    _IR(icon: Icons.lock_outline,         text: 'Contact réservé aux clients', rem: rem),
                    _IR(icon: Icons.lock_outline,         text: 'Email réservé aux clients', rem: rem),
                    SizedBox(height: rem * 2.5),

                    Text(bio, style: TextStyle(
                      fontSize: rem * 3.5, color: _textDark, height: 1.5)),
                    SizedBox(height: rem * 3),

                    Text('Confort client', style: TextStyle(
                      fontSize: rem * 3.2, color: _textGrey, fontWeight: FontWeight.w600)),
                    SizedBox(height: rem * 2),
                    Wrap(spacing: rem * 2, runSpacing: rem * 2, children: [
                      ..._confortItems.map((c) => Container(
                        padding: EdgeInsets.symmetric(horizontal: rem * 2.5, vertical: rem * 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F0),
                          borderRadius: BorderRadius.circular(rem * 5),
                          border: Border.all(color: const Color(0xFFEDE0CC))),
                        child: Text(c, style: TextStyle(fontSize: rem * 2.8, color: _textDark)))),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: rem * 2.5, vertical: rem * 1.5),
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(rem * 5),
                          border: Border.all(color: _gold.withOpacity(0.3))),
                        child: Text('+14 autres', style: TextStyle(
                          fontSize: rem * 2.8, color: _goldDark, fontWeight: FontWeight.w600))),
                    ]),
                  ]),
                ),
                SizedBox(height: rem * 3.5),

                // ── Services & Tarifs ─────────────────────────────────
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
                        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
                        child: Icon(icon, color: _gold, size: rem * 5.5)),
                      SizedBox(width: rem * 3),
                      Expanded(child: Text('Services & Tarifs', style: TextStyle(
                        fontSize: rem * 4.2, fontWeight: FontWeight.w800, color: _textDark))),
                      TextButton(onPressed: () {},
                        child: Text('Voir tout →', style: TextStyle(color: _gold, fontSize: rem * 3.2))),
                    ]),
                    SizedBox(height: rem * 2),

                    ..._services.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      final expanded    = _expandedCats.contains(i);
                      final prestations = s['prestations'] as List;

                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            if (expanded) _expandedCats.remove(i);
                            else _expandedCats.add(i);
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: rem * 3),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFEDE0CC)))),
                            child: Row(children: [
                              Container(
                                width: rem * 9, height: rem * 9,
                                decoration: BoxDecoration(
                                  color: _goldLight, borderRadius: BorderRadius.circular(rem * 2.5)),
                                child: Icon(icon, color: _gold, size: rem * 4.5)),
                              SizedBox(width: rem * 2.5),
                              Expanded(child: Text(s['categorie'] as String, style: TextStyle(
                                fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark))),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: rem * 2, vertical: rem),
                                decoration: BoxDecoration(
                                  color: _goldLight, borderRadius: BorderRadius.circular(rem * 4)),
                                child: Text('${s['count']} prestations', style: TextStyle(
                                  fontSize: rem * 2.6, color: _goldDark))),
                              SizedBox(width: rem * 2),
                              Icon(
                                expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: _textGrey, size: rem * 5),
                            ]),
                          ),
                        ),

                        if (expanded)
                          ...prestations.map((p) => GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ReservationScreen(
                                nomPresta: widget.nom,
                                service: '${s['categorie']} – ${p['nom']}',
                                prix: p['prix'] as int,
                                duree: p['duree'] as String,
                                typePresta: widget.typePresta))),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: rem * 3.5, horizontal: rem),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFF8F5F0)))),
                              child: Row(children: [
                                SizedBox(width: rem * 11.5),
                                Expanded(child: Text(p['nom'] as String, style: TextStyle(
                                  fontSize: rem * 3.5, color: _textDark))),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text('${p['prix']}€', style: TextStyle(
                                    fontSize: rem * 4,
                                    fontWeight: FontWeight.w800,
                                    color: _gold)),
                                  Row(children: [
                                    Icon(Icons.access_time_rounded, size: rem * 3, color: _textGrey),
                                    SizedBox(width: rem),
                                    Text(p['duree'] as String, style: TextStyle(
                                      fontSize: rem * 2.8, color: _textGrey)),
                                  ]),
                                ]),
                              ]),
                            ),
                          )),
                      ]);
                    }),

                    SizedBox(height: rem * 2),
                    Center(child: TextButton(onPressed: () {},
                      child: Text('Voir les 2 autres services', style: TextStyle(
                        color: _gold, fontSize: rem * 3.2, fontWeight: FontWeight.w600)))),
                  ]),
                ),
                SizedBox(height: rem * 3.5),

                // ── Disponibilités ────────────────────────────────────
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
                        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
                        child: Icon(Icons.calendar_month_rounded, color: _gold, size: rem * 5.5)),
                      SizedBox(width: rem * 3),
                      Expanded(child: Text('Disponibilités', style: TextStyle(
                        fontSize: rem * 4.2, fontWeight: FontWeight.w800, color: _textDark))),
                      TextButton(onPressed: () {},
                        child: Text('Réserver →', style: TextStyle(
                          color: _gold, fontSize: rem * 3.2))),
                    ]),
                    SizedBox(height: rem * 3),

                    ..._dispos.map((d) => Padding(
                      padding: EdgeInsets.only(bottom: rem * 3),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d['jour'] as String, style: TextStyle(
                          fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)),
                        SizedBox(height: rem * 1.5),
                        Wrap(spacing: rem * 2, children: (d['heures'] as List<String>).map((h) =>
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 2),
                            decoration: BoxDecoration(
                              color: _goldLight,
                              borderRadius: BorderRadius.circular(rem * 5),
                              border: Border.all(color: _gold.withOpacity(0.3))),
                            child: Text(h, style: TextStyle(
                              fontSize: rem * 3.2, color: _goldDark, fontWeight: FontWeight.w600)))).toList()),
                      ]))),
                  ]),
                ),
                SizedBox(height: rem * 3.5),

                // ── Réalisations ──────────────────────────────────────
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
                        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
                        child: Icon(Icons.photo_camera_outlined, color: _gold, size: rem * 5.5)),
                      SizedBox(width: rem * 3),
                      Text('Réalisations (8)', style: TextStyle(
                        fontSize: rem * 4.2, fontWeight: FontWeight.w800, color: _textDark)),
                    ]),
                    SizedBox(height: rem * 3),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: rem * 2,
                      mainAxisSpacing: rem * 2,
                      children: List.generate(6, (_) => Container(
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(rem * 3)),
                        child: Icon(icon, color: _gold, size: rem * 10)))),
                    SizedBox(height: rem * 3),
                    Center(child: TextButton(onPressed: () {},
                      child: Text('Voir les 2 autres réalisations', style: TextStyle(
                        color: _gold, fontSize: rem * 3.2, fontWeight: FontWeight.w600)))),
                  ]),
                ),
                SizedBox(height: rem * 3.5),

                // ── Contact ───────────────────────────────────────────
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
                        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
                        child: Icon(Icons.phone_outlined, color: _gold, size: rem * 5.5)),
                      SizedBox(width: rem * 3),
                      Text('Contact', style: TextStyle(
                        fontSize: rem * 4.2, fontWeight: FontWeight.w800, color: _textDark)),
                    ]),
                    SizedBox(height: rem * 3),
                    Row(children: [
                      Container(width: rem * 2.5, height: rem * 2.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                      SizedBox(width: rem * 2),
                      Text('0783684557', style: TextStyle(
                        fontSize: rem * 3.5, color: _textDark, fontWeight: FontWeight.w500)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ]),

        // ── Bouton flottant Réserver ──────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, rem * 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEDE0CC)))),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ReservationScreen(
                  nomPresta: widget.nom,
                  service: 'Choisir un service',
                  prix: 0, duree: '',
                  typePresta: widget.typePresta))),
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
                  Icon(Icons.calendar_month_rounded, color: Colors.white, size: rem * 5.5),
                  SizedBox(width: rem * 2.5),
                  Text('Réserver maintenant', style: TextStyle(
                    color: Colors.white, fontSize: rem * 4, fontWeight: FontWeight.w700)),
                ])),
            ),
          ),
        ),
      ]),
    );
  }
}

class _IR extends StatelessWidget {
  const _IR({required this.icon, required this.text, required this.rem});
  final IconData icon; final String text; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 1.5),
    child: Row(children: [
      Icon(icon, size: rem * 4, color: _textGrey),
      SizedBox(width: rem * 2),
      Expanded(child: Text(text, style: TextStyle(fontSize: rem * 3.5, color: _textGrey))),
    ]));
}


































































































// import 'package:flutter/material.dart';
// import 'reservation/reservation_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// // Services statiques — à brancher Supabase selon le type
// const _servicesByType = {
//   'coiffeur': [
//     {'categorie': 'Tresses / Braids', 'count': 3, 'prestations': [
//       {'nom': 'Stitch Braids', 'prix': 35, 'duree': '1h'},
//       {'nom': 'Fulani Braids', 'prix': 40, 'duree': '1h'},
//       {'nom': 'Cornrows',      'prix': 30, 'duree': '1h'},
//     ]},
//     {'categorie': 'Twists', 'count': 5, 'prestations': [
//       {'nom': 'Flat Twists',        'prix': 40,  'duree': '1h'},
//       {'nom': 'Départ Locks Twist', 'prix': 100, 'duree': '3h'},
//       {'nom': 'Barrel Twists',      'prix': 50,  'duree': '1h'},
//       {'nom': 'Reprise Twist',      'prix': 60,  'duree': '1h'},
//       {'nom': 'Two Strand Twists',  'prix': 50,  'duree': '1h'},
//     ]},
//     {'categorie': 'Vanilles', 'count': 6, 'prestations': [
//       {'nom': 'Vanilles Fines',        'prix': 60, 'duree': '1h'},
//       {'nom': 'Vanilles Épaisses',     'prix': 50, 'duree': '1h'},
//       {'nom': 'Vanilles Courtes',      'prix': 50, 'duree': '1h'},
//       {'nom': 'Vanilles Sans Mèches',  'prix': 40, 'duree': '1h'},
//       {'nom': 'Vanilles Avec Mèches',  'prix': 50, 'duree': '1h'},
//       {'nom': 'Vanilles Simples',      'prix': 40, 'duree': '1h'},
//     ]},
//     {'categorie': 'Locks / Dreadlocks', 'count': 2, 'prestations': [
//       {'nom': 'Retwist',      'prix': 50,  'duree': '1h'},
//       {'nom': 'Départ Locks', 'prix': 100, 'duree': '1h'},
//     ]},
//     {'categorie': 'Barbe & Soins Visage', 'count': 3, 'prestations': [
//       {'nom': 'Contours Barbe', 'prix': 10, 'duree': '30min'},
//       {'nom': 'Dégradé Barbe',  'prix': 10, 'duree': '30min'},
//       {'nom': 'Taille Barbe',   'prix': 10, 'duree': '30min'},
//     ]},
//     {'categorie': 'Coupes & Contours', 'count': 8, 'prestations': [
//       {'nom': 'Twisty Cut',        'prix': 20, 'duree': '1h'},
//       {'nom': 'Burst Fade',        'prix': 20, 'duree': '1h'},
//       {'nom': 'Dégradé Haut',      'prix': 10, 'duree': '45min'},
//       {'nom': 'Dégradé Américain', 'prix': 15, 'duree': '45min'},
//       {'nom': 'Contours',          'prix': 10, 'duree': '30min'},
//       {'nom': 'Coupe Enfant',      'prix': 10, 'duree': '30min'},
//       {'nom': 'Coupe Femme',       'prix': 25, 'duree': '1h'},
//       {'nom': 'Brushing',          'prix': 20, 'duree': '45min'},
//     ]},
//   ],
//   'maquillage': [
//     {'categorie': 'Maquillage Jour', 'count': 3, 'prestations': [
//       {'nom': 'Maquillage naturel',  'prix': 40, 'duree': '45min'},
//       {'nom': 'Maquillage bureau',   'prix': 45, 'duree': '45min'},
//       {'nom': 'Maquillage étudiant', 'prix': 35, 'duree': '30min'},
//     ]},
//     {'categorie': 'Maquillage Soirée', 'count': 4, 'prestations': [
//       {'nom': 'Maquillage soirée',  'prix': 60, 'duree': '1h'},
//       {'nom': 'Maquillage glamour', 'prix': 70, 'duree': '1h'},
//       {'nom': 'Maquillage smoky',   'prix': 65, 'duree': '1h'},
//       {'nom': 'Maquillage scène',   'prix': 80, 'duree': '1h30'},
//     ]},
//     {'categorie': 'Maquillage Événement', 'count': 4, 'prestations': [
//       {'nom': 'Maquillage mariée',    'prix': 120, 'duree': '2h'},
//       {'nom': 'Maquillage cérémonie', 'prix': 80,  'duree': '1h30'},
//       {'nom': 'Maquillage EVJF',      'prix': 60,  'duree': '1h'},
//       {'nom': 'Maquillage shooting',  'prix': 90,  'duree': '1h30'},
//     ]},
//     {'categorie': 'Soins Visage', 'count': 3, 'prestations': [
//       {'nom': 'Soin hydratant',    'prix': 45, 'duree': '45min'},
//       {'nom': 'Nettoyage de peau', 'prix': 50, 'duree': '1h'},
//       {'nom': 'Soin anti-taches',  'prix': 55, 'duree': '1h'},
//     ]},
//     {'categorie': 'Sourcils & Cils', 'count': 4, 'prestations': [
//       {'nom': 'Épilation sourcils',       'prix': 15, 'duree': '20min'},
//       {'nom': 'Restructuration sourcils', 'prix': 25, 'duree': '30min'},
//       {'nom': 'Pose cils classiques',     'prix': 60, 'duree': '1h30'},
//       {'nom': 'Pose cils volume',         'prix': 80, 'duree': '2h'},
//     ]},
//   ],
//   'manicure': [
//     {'categorie': 'Manucure', 'count': 4, 'prestations': [
//       {'nom': 'Manucure simple',         'prix': 25, 'duree': '45min'},
//       {'nom': 'Manucure semi-permanent', 'prix': 35, 'duree': '1h'},
//       {'nom': 'Manucure gel',            'prix': 40, 'duree': '1h'},
//       {'nom': 'Manucure french',         'prix': 35, 'duree': '1h'},
//     ]},
//     {'categorie': 'Nail Art', 'count': 4, 'prestations': [
//       {'nom': 'Nail art simple',       'prix': 45, 'duree': '1h'},
//       {'nom': 'Nail art dégradé',      'prix': 55, 'duree': '1h30'},
//       {'nom': 'Nail art 3D',           'prix': 70, 'duree': '2h'},
//       {'nom': 'Nail art personnalisé', 'prix': 65, 'duree': '1h30'},
//     ]},
//     {'categorie': 'Extensions Ongles', 'count': 3, 'prestations': [
//       {'nom': 'Pose capsules',          'prix': 50, 'duree': '1h30'},
//       {'nom': 'Pose gel',               'prix': 55, 'duree': '1h30'},
//       {'nom': 'Rallongement acrylique', 'prix': 60, 'duree': '2h'},
//     ]},
//     {'categorie': 'Pédicure', 'count': 3, 'prestations': [
//       {'nom': 'Pédicure simple',         'prix': 30, 'duree': '45min'},
//       {'nom': 'Pédicure semi-permanent', 'prix': 40, 'duree': '1h'},
//       {'nom': 'Pédicure beauté',         'prix': 45, 'duree': '1h'},
//     ]},
//     {'categorie': 'Soins Mains & Pieds', 'count': 3, 'prestations': [
//       {'nom': 'Soin hydratant mains', 'prix': 20, 'duree': '30min'},
//       {'nom': 'Gommage mains',        'prix': 25, 'duree': '30min'},
//       {'nom': 'Bain de pieds',        'prix': 20, 'duree': '30min'},
//     ]},
//   ],
// };

// const _confortItems = [
//   'Adresse facile à trouver',
//   'Boissons offertes (eau, jus, thé…)',
//   'Canapé ou fauteuil confortable',
//   'Chargeur de téléphone disponible',
// ];

// const _dispos = [
//   {'jour': 'Lundi',    'heures': ['11:30']},
//   {'jour': 'Mardi',    'heures': ['14:00']},
//   {'jour': 'Mercredi', 'heures': ['11:30', '12:00']},
// ];

// // Icône selon le type
// IconData _iconForType(String type) {
//   switch (type) {
//     case 'maquillage': return Icons.brush;
//     case 'manicure':   return Icons.back_hand_outlined;
//     default:           return Icons.content_cut;
//   }
// }

// // Label selon le type
// String _labelForType(String type) {
//   switch (type) {
//     case 'maquillage': return 'Maquilleur(se)';
//     case 'manicure':   return 'Manucure / Pédicure';
//     default:           return 'Coiffeur(se)';
//   }
// }

// // Bio selon le type
// String _bioForType(String type) {
//   switch (type) {
//     case 'maquillage': return 'Je suis une maquilleuse passionnée qui sublime chaque visage avec art et précision !';
//     case 'manicure':   return 'Spécialiste de la beauté des mains et des pieds, je vous offre un soin impeccable.';
//     default:           return 'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi';
//   }
// }

// class ProfilPrestataireScreen extends StatefulWidget {
//   final String nom;
//   final String ville;
//   final String typePresta; // 'coiffeur', 'maquillage', 'manicure'

//   const ProfilPrestataireScreen({
//     super.key,
//     required this.nom,
//     required this.ville,
//     this.typePresta = 'coiffeur',
//   });

//   @override
//   State<ProfilPrestataireScreen> createState() => _ProfilPrestataireScreenState();
// }

// class _ProfilPrestataireScreenState extends State<ProfilPrestataireScreen> {
//   final Set<int> _expandedCats = {0};

//   List<Map<String, dynamic>> get _services =>
//     List<Map<String, dynamic>>.from(
//       _servicesByType[widget.typePresta] ?? _servicesByType['coiffeur']!);

//   @override
//   Widget build(BuildContext context) {
//     final icon = _iconForType(widget.typePresta);
//     final label = _labelForType(widget.typePresta);
//     final bio = _bioForType(widget.typePresta);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(children: [
//         CustomScrollView(slivers: [

//           // ── App Bar ────────────────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 180,
//             pinned: true,
//             backgroundColor: Colors.white,
//             leading: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 margin: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white, shape: BoxShape.circle,
//                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
//                 child: const Icon(Icons.arrow_back, color: _textDark, size: 20),
//               ),
//             ),
//             actions: [
//               Container(
//                 margin: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white, shape: BoxShape.circle,
//                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
//                 child: IconButton(
//                   icon: const Icon(Icons.share_outlined, color: _textDark, size: 20),
//                   onPressed: () {},
//                 ),
//               ),
//             ],
//             title: const Text('Profil',
//               style: TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Stack(children: [
//                 Container(color: _greenLight),
//                 Positioned(
//                   bottom: 20, left: 16,
//                   child: Stack(children: [
//                     Container(
//                       width: 70, height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle, color: _green,
//                         border: Border.all(color: Colors.white, width: 3)),
//                       child: Icon(icon, color: Colors.white, size: 36)),
//                     Positioned(
//                       bottom: 4, right: 4,
//                       child: Container(
//                         width: 16, height: 16,
//                         decoration: BoxDecoration(
//                           color: _green, shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2)))),
//                   ]),
//                 ),
//               ]),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//                 // ── Infos ──────────────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text(widget.nom,
//                       style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
//                     const SizedBox(height: 8),

//                     // Badge type
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: _greenLight, borderRadius: BorderRadius.circular(50)),
//                       child: Text(label,
//                         style: const TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.w600))),
//                     const SizedBox(height: 10),

//                     _InfoRow(icon: Icons.location_on_outlined, text: widget.ville),
//                     _InfoRow(icon: icon,                       text: 'Chez le prestataire'),
//                     const _InfoRow(icon: Icons.lock_outline,   text: 'Contact réservé aux clients'),
//                     const _InfoRow(icon: Icons.lock_outline,   text: 'Email réservé aux clients'),
//                     const SizedBox(height: 10),
//                     Text(bio, style: const TextStyle(fontSize: 14, color: _textDark, height: 1.5)),
//                     const SizedBox(height: 12),
//                     const Text('Confort client',
//                       style: TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     Wrap(spacing: 8, runSpacing: 8, children: [
//                       ..._confortItems.map((c) => Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8F8F8),
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(color: const Color(0xFFE0E0E0))),
//                         child: Text(c, style: const TextStyle(fontSize: 12, color: _textDark)))),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8F8F8),
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(color: const Color(0xFFE0E0E0))),
//                         child: const Text('+14 autres',
//                           style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.w600))),
//                     ]),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Services & Tarifs ──────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       Icon(icon, size: 18, color: _green),
//                       const SizedBox(width: 8),
//                       const Expanded(child: Text('Services & Tarifs',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
//                       TextButton(onPressed: () {},
//                         child: const Text('Voir tout →',
//                           style: TextStyle(color: _green, fontSize: 13))),
//                     ]),
//                     const SizedBox(height: 8),

//                     ..._services.asMap().entries.map((e) {
//                       final i = e.key;
//                       final s = e.value;
//                       final expanded = _expandedCats.contains(i);
//                       final prestations = s['prestations'] as List;

//                       return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         GestureDetector(
//                           onTap: () => setState(() {
//                             if (expanded) _expandedCats.remove(i);
//                             else _expandedCats.add(i);
//                           }),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             decoration: const BoxDecoration(
//                               border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
//                             child: Row(children: [
//                               Container(width: 36, height: 36,
//                                 decoration: BoxDecoration(
//                                   color: _greenLight, borderRadius: BorderRadius.circular(8)),
//                                 child: Icon(icon, color: _green, size: 18)),
//                               const SizedBox(width: 10),
//                               Expanded(child: Text(s['categorie'] as String,
//                                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark))),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFF2F2F7),
//                                   borderRadius: BorderRadius.circular(50)),
//                                 child: Text('${s['count']} prestations',
//                                   style: const TextStyle(fontSize: 11, color: _textGrey))),
//                               const SizedBox(width: 8),
//                               Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                                 color: _textGrey, size: 20),
//                             ]),
//                           ),
//                         ),

//                         if (expanded)
//                           ...prestations.map((p) => GestureDetector(
//                             onTap: () => Navigator.push(context, MaterialPageRoute(
//                               builder: (_) => ReservationScreen(
//                                 nomPresta: widget.nom,
//                                 service: '${s['categorie']} – ${p['nom']}',
//                                 prix: p['prix'] as int,
//                                 duree: p['duree'] as String,
//                                 typePresta: widget.typePresta,
//                               ),
//                             )),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
//                               decoration: const BoxDecoration(
//                                 border: Border(bottom: BorderSide(color: Color(0xFFF8F8F8)))),
//                               child: Row(children: [
//                                 const SizedBox(width: 46),
//                                 Expanded(child: Text(p['nom'] as String,
//                                   style: const TextStyle(fontSize: 14, color: _textDark))),
//                                 Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                                   Text('${p['prix']}€',
//                                     style: const TextStyle(fontSize: 15,
//                                       fontWeight: FontWeight.w700, color: _green)),
//                                   Row(children: [
//                                     const Icon(Icons.access_time, size: 12, color: _textGrey),
//                                     const SizedBox(width: 2),
//                                     Text(p['duree'] as String,
//                                       style: const TextStyle(fontSize: 12, color: _textGrey)),
//                                   ]),
//                                 ]),
//                               ]),
//                             ),
//                           )),
//                       ]);
//                     }),

//                     const SizedBox(height: 8),
//                     Center(child: TextButton(onPressed: () {},
//                       child: const Text('Voir les 2 autres services',
//                         style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)))),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Disponibilités ────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       const Icon(Icons.access_time, size: 18, color: _green),
//                       const SizedBox(width: 8),
//                       const Expanded(child: Text('Disponibilités',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
//                       TextButton(onPressed: () {},
//                         child: const Text('Réserver →',
//                           style: TextStyle(color: _green, fontSize: 13))),
//                     ]),
//                     const SizedBox(height: 12),
//                     ..._dispos.map((d) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text(d['jour'] as String,
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                         const SizedBox(height: 6),
//                         Wrap(spacing: 8,
//                           children: (d['heures'] as List<String>).map((h) => Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(50),
//                               border: Border.all(color: const Color(0xFFE0E0E0))),
//                             child: Text(h, style: const TextStyle(fontSize: 13, color: _textDark)),
//                           )).toList()),
//                       ]),
//                     )),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Réalisations ──────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       const Icon(Icons.photo_camera_outlined, size: 18, color: _textDark),
//                       const SizedBox(width: 8),
//                       const Text('Réalisations (8)',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                     ]),
//                     const SizedBox(height: 12),
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                       childAspectRatio: 1,
//                       children: List.generate(6, (_) => Container(
//                         decoration: BoxDecoration(
//                           color: _greenLight, borderRadius: BorderRadius.circular(12)),
//                         child: Icon(icon, color: _green, size: 40))),
//                     ),
//                     const SizedBox(height: 12),
//                     Center(child: TextButton(onPressed: () {},
//                       child: const Text('Voir les 2 autres réalisations',
//                         style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)))),
//                   ]),
//                 ),
//                 const SizedBox(height: 16),

//                 // ── Contact ───────────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     const Row(children: [
//                       Icon(Icons.phone_outlined, size: 18, color: _green),
//                       SizedBox(width: 8),
//                       Text('Contact',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                     ]),
//                     const SizedBox(height: 10),
//                     Row(children: [
//                       Container(width: 8, height: 8,
//                         decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
//                       const SizedBox(width: 8),
//                       const Text('0783684557',
//                         style: TextStyle(fontSize: 14, color: _textDark)),
//                     ]),
//                   ]),
//                 ),
//               ]),
//             ),
//           ),
//         ]),

//         // ── Bouton flottant Réserver ──────────────────────────────────
//         Positioned(
//           bottom: 0, left: 0, right: 0,
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//             child: ElevatedButton.icon(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(
//                 builder: (_) => ReservationScreen(
//                   nomPresta: widget.nom,
//                   service: 'Choisir un service',
//                   prix: 0,
//                   duree: '',
//                   typePresta: widget.typePresta,
//                 ),
//               )),
//               icon: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
//               label: const Text('Réserver maintenant',
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _green,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 minimumSize: const Size(double.infinity, 52),
//               ),
//             ),
//           ),
//         ),
//       ]),
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
//       Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: _textGrey))),
//     ]),
//   );
// }








































// // import 'package:flutter/material.dart';
// // import 'reservation/reservation_screen.dart';

// // const _green      = Color(0xFF2D7A4F);
// // const _greenLight = Color(0xFFE8F5EE);
// // const _textDark   = Color(0xFF1A1A1A);
// // const _textGrey   = Color(0xFF8E8E93);

// // const _services = [
// //   {'categorie': 'Tresses / Braids', 'count': 3, 'prestations': [
// //     {'nom': 'Stitch Braids', 'prix': 35, 'duree': '1h'},
// //     {'nom': 'Fulani Braids', 'prix': 40, 'duree': '1h'},
// //     {'nom': 'Cornrows',      'prix': 30, 'duree': '1h'},
// //   ]},
// //   {'categorie': 'Twists', 'count': 5, 'prestations': [
// //     {'nom': 'Flat Twists',       'prix': 40,  'duree': '1h'},
// //     {'nom': 'Départ Locks Twist','prix': 100, 'duree': '3h'},
// //     {'nom': 'Barrel Twists',     'prix': 50,  'duree': '1h'},
// //     {'nom': 'Reprise Twist',     'prix': 60,  'duree': '1h'},
// //     {'nom': 'Two Strand Twists', 'prix': 50,  'duree': '1h'},
// //   ]},
// //   {'categorie': 'Vanilles', 'count': 6, 'prestations': [
// //     {'nom': 'Vanilles Fines',       'prix': 60, 'duree': '1h'},
// //     {'nom': 'Vanilles Épaisses',    'prix': 50, 'duree': '1h'},
// //     {'nom': 'Vanilles Courtes',     'prix': 50, 'duree': '1h'},
// //     {'nom': 'Vanilles Sans Mèches', 'prix': 40, 'duree': '1h'},
// //     {'nom': 'Vanilles Avec Mèches', 'prix': 50, 'duree': '1h'},
// //     {'nom': 'Vanilles Simples',     'prix': 40, 'duree': '1h'},
// //   ]},
// //   {'categorie': 'Locks / Dreadlocks', 'count': 2, 'prestations': [
// //     {'nom': 'Retwist',       'prix': 50,  'duree': '1h'},
// //     {'nom': 'Départ Locks',  'prix': 100, 'duree': '1h'},
// //   ]},
// //   {'categorie': 'Barbe & Soins Visage', 'count': 3, 'prestations': [
// //     {'nom': 'Contours Barbe', 'prix': 10, 'duree': '1h'},
// //     {'nom': 'Dégradé Barbe',  'prix': 10, 'duree': '1h'},
// //     {'nom': 'Taille Barbe',   'prix': 10, 'duree': '1h'},
// //   ]},
// //   {'categorie': 'Coupes & Contours', 'count': 8, 'prestations': [
// //     {'nom': 'Twisty Cut',    'prix': 20, 'duree': '1h'},
// //     {'nom': 'Burst Fade',    'prix': 20, 'duree': '1h'},
// //     {'nom': 'Dégradé Haut',  'prix': 10, 'duree': '1h'},
// //   ]},
// // ];

// // const _confortItems = [
// //   'Adresse facile à trouver', 'Boissons offertes (eau, jus, thé…)',
// //   'Canapé ou fauteuil confortable', 'Chargeur de téléphone disponible',
// // ];

// // const _dispos = [
// //   {'jour': 'Lundi',    'heures': ['11:30']},
// //   {'jour': 'Mardi',    'heures': ['14:00']},
// //   {'jour': 'Mercredi', 'heures': ['11:30', '12:00']},
// // ];

// // class ProfilPrestataireScreen extends StatefulWidget {
// //   final String nom;
// //   final String ville;
// //   const ProfilPrestataireScreen({super.key, required this.nom, required this.ville});

// //   @override
// //   State<ProfilPrestataireScreen> createState() => _ProfilPrestataireScreenState();
// // }

// // class _ProfilPrestataireScreenState extends State<ProfilPrestataireScreen> {
// //   final Set<int> _expandedCats = {0};

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Stack(children: [
// //         CustomScrollView(slivers: [

// //           // ── App Bar ───────────────────────────────────────────────
// //           SliverAppBar(
// //             expandedHeight: 180,
// //             pinned: true,
// //             backgroundColor: Colors.white,
// //             leading: GestureDetector(
// //               onTap: () => Navigator.pop(context),
// //               child: Container(
// //                 margin: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
// //                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
// //                 child: const Icon(Icons.arrow_back, color: _textDark, size: 20),
// //               ),
// //             ),
// //             actions: [
// //               Container(
// //                 margin: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
// //                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 6)]),
// //                 child: IconButton(
// //                   icon: const Icon(Icons.share_outlined, color: _textDark, size: 20),
// //                   onPressed: () {},
// //                 ),
// //               ),
// //             ],
// //             title: const Text('Profil', style: TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
// //             flexibleSpace: FlexibleSpaceBar(
// //               background: Stack(children: [
// //                 Container(color: _greenLight),
// //                 Positioned(bottom: 20, left: 16,
// //                   child: Stack(children: [
// //                     Container(
// //                       width: 70, height: 70,
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle, color: _green,
// //                         border: Border.all(color: Colors.white, width: 3)),
// //                       child: const Icon(Icons.person, color: Colors.white, size: 38)),
// //                     Positioned(bottom: 4, right: 4,
// //                       child: Container(width: 16, height: 16,
// //                         decoration: BoxDecoration(color: _green, shape: BoxShape.circle,
// //                           border: Border.all(color: Colors.white, width: 2)))),
// //                   ]),
// //                 ),
// //               ]),
// //             ),
// //           ),

// //           SliverToBoxAdapter(child: Padding(
// //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
// //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// //               // ── Infos ───────────────────────────────────────────────
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: const Color(0xFFF0F0F0)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Text(widget.nom,
// //                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
// //                   const SizedBox(height: 10),
// //                   _InfoRow(icon: Icons.location_on_outlined, text: widget.ville),
// //                   _InfoRow(icon: Icons.content_cut,          text: 'Chez le coiffeur'),
// //                   _InfoRow(icon: Icons.lock_outline,         text: 'Contact réservé aux clients'),
// //                   _InfoRow(icon: Icons.lock_outline,         text: 'Email réservé aux clients'),
// //                   const SizedBox(height: 10),
// //                   const Text(
// //                     'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi',
// //                     style: TextStyle(fontSize: 14, color: _textDark, height: 1.5)),
// //                   const SizedBox(height: 12),
// //                   const Text('Confort client',
// //                     style: TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w600)),
// //                   const SizedBox(height: 8),
// //                   Wrap(spacing: 8, runSpacing: 8, children: [
// //                     ..._confortItems.map((c) => Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFF8F8F8),
// //                         borderRadius: BorderRadius.circular(50),
// //                         border: Border.all(color: const Color(0xFFE0E0E0))),
// //                       child: Text(c, style: const TextStyle(fontSize: 12, color: _textDark)))),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFF8F8F8),
// //                         borderRadius: BorderRadius.circular(50),
// //                         border: Border.all(color: const Color(0xFFE0E0E0))),
// //                       child: const Text('+14 autres', style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.w600))),
// //                   ]),
// //                 ]),
// //               ),
// //               const SizedBox(height: 16),

// //               // ── Services & Tarifs ────────────────────────────────────
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: const Color(0xFFF0F0F0)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Row(children: [
// //                     const Icon(Icons.content_cut, size: 18, color: _green),
// //                     const SizedBox(width: 8),
// //                     const Expanded(child: Text('Services & Tarifs',
// //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
// //                     TextButton(onPressed: () {},
// //                       child: const Text('Voir tout →', style: TextStyle(color: _green, fontSize: 13))),
// //                   ]),
// //                   const SizedBox(height: 8),
// //                   ..._services.asMap().entries.map((e) {
// //                     final i = e.key;
// //                     final s = e.value;
// //                     final expanded = _expandedCats.contains(i);
// //                     final prestations = s['prestations'] as List;
// //                     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                       GestureDetector(
// //                         onTap: () => setState(() {
// //                           if (expanded) _expandedCats.remove(i);
// //                           else _expandedCats.add(i);
// //                         }),
// //                         child: Container(
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                           decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
// //                           child: Row(children: [
// //                             Container(width: 36, height: 36,
// //                               decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
// //                               child: const Icon(Icons.content_cut, color: _green, size: 18)),
// //                             const SizedBox(width: 10),
// //                             Expanded(child: Text(s['categorie'] as String,
// //                               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark))),
// //                             Container(
// //                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                               decoration: BoxDecoration(
// //                                 color: const Color(0xFFF2F2F7),
// //                                 borderRadius: BorderRadius.circular(50)),
// //                               child: Text('${s['count']} prestations',
// //                                 style: const TextStyle(fontSize: 11, color: _textGrey))),
// //                             const SizedBox(width: 8),
// //                             Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
// //                               color: _textGrey, size: 20),
// //                           ]),
// //                         ),
// //                       ),
// //                       if (expanded)
// //                         ...prestations.map((p) => GestureDetector(
// //                           onTap: () => Navigator.push(context, MaterialPageRoute(
// //                             builder: (_) => ReservationScreen(
// //                               nomPresta: widget.nom,
// //                               service: '${s['categorie']} – ${p['nom']}',
// //                               prix: p['prix'] as int,
// //                               duree: p['duree'] as String,
// //                             ),
// //                           )),
// //                           child: Container(
// //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
// //                             decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF8F8F8)))),
// //                             child: Row(children: [
// //                               const SizedBox(width: 46),
// //                               Expanded(child: Text(p['nom'] as String,
// //                                 style: const TextStyle(fontSize: 14, color: _textDark))),
// //                               Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
// //                                 Text('${p['prix']}€',
// //                                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _green)),
// //                                 Row(children: [
// //                                   const Icon(Icons.access_time, size: 12, color: _textGrey),
// //                                   const SizedBox(width: 2),
// //                                   Text(p['duree'] as String,
// //                                     style: const TextStyle(fontSize: 12, color: _textGrey)),
// //                                 ]),
// //                               ]),
// //                             ]),
// //                           ),
// //                         )),
// //                     ]);
// //                   }),
// //                   const SizedBox(height: 8),
// //                   Center(child: TextButton(onPressed: () {},
// //                     child: const Text('Voir les 2 autres services',
// //                       style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)))),
// //                 ]),
// //               ),
// //               const SizedBox(height: 16),

// //               // ── Disponibilités ────────────────────────────────────────
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: const Color(0xFFF0F0F0)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Row(children: [
// //                     const Icon(Icons.access_time, size: 18, color: _green),
// //                     const SizedBox(width: 8),
// //                     const Expanded(child: Text('Disponibilités',
// //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark))),
// //                     TextButton(onPressed: () {},
// //                       child: const Text('Réserver →', style: TextStyle(color: _green, fontSize: 13))),
// //                   ]),
// //                   const SizedBox(height: 12),
// //                   ..._dispos.map((d) => Padding(
// //                     padding: const EdgeInsets.only(bottom: 12),
// //                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                       Text(d['jour'] as String,
// //                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
// //                       const SizedBox(height: 6),
// //                       Wrap(spacing: 8, children: (d['heures'] as List<String>).map((h) =>
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(50),
// //                             border: Border.all(color: const Color(0xFFE0E0E0))),
// //                           child: Text(h, style: const TextStyle(fontSize: 13, color: _textDark)),
// //                         )).toList()),
// //                     ]),
// //                   )),
// //                 ]),
// //               ),
// //               const SizedBox(height: 16),

// //               // ── Réalisations ──────────────────────────────────────────
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: const Color(0xFFF0F0F0)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Row(children: [
// //                     const Icon(Icons.photo_camera_outlined, size: 18, color: _textDark),
// //                     const SizedBox(width: 8),
// //                     const Text('Réalisations (8)',
// //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //                   ]),
// //                   const SizedBox(height: 12),
// //                   GridView.count(
// //                     shrinkWrap: true,
// //                     physics: const NeverScrollableScrollPhysics(),
// //                     crossAxisCount: 2,
// //                     crossAxisSpacing: 8,
// //                     mainAxisSpacing: 8,
// //                     childAspectRatio: 1,
// //                     children: List.generate(6, (i) => Container(
// //                       decoration: BoxDecoration(
// //                         color: _greenLight,
// //                         borderRadius: BorderRadius.circular(12)),
// //                       child: const Icon(Icons.person, color: _green, size: 40),
// //                     )),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Center(child: TextButton(onPressed: () {},
// //                     child: const Text('Voir les 2 autres réalisations',
// //                       style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)))),
// //                 ]),
// //               ),
// //               const SizedBox(height: 16),

// //               // ── Contact ───────────────────────────────────────────────
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: const Color(0xFFF0F0F0)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   const Row(children: [
// //                     Icon(Icons.phone_outlined, size: 18, color: _green),
// //                     SizedBox(width: 8),
// //                     Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //                   ]),
// //                   const SizedBox(height: 10),
// //                   Row(children: [
// //                     Container(width: 8, height: 8, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
// //                     const SizedBox(width: 8),
// //                     const Text('0783684557', style: TextStyle(fontSize: 14, color: _textDark)),
// //                   ]),
// //                 ]),
// //               ),
// //             ]),
// //           )),
// //         ]),

// //         // ── Bouton flottant Réserver ──────────────────────────────────
// //         Positioned(
// //           bottom: 0, left: 0, right: 0,
// //           child: Container(
// //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
// //             decoration: const BoxDecoration(
// //               color: Colors.white,
// //               border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
// //             child: ElevatedButton.icon(
// //               onPressed: () => Navigator.push(context, MaterialPageRoute(
// //                 builder: (_) => ReservationScreen(
// //                   nomPresta: widget.nom,
// //                   service: 'Choisir un service',
// //                   prix: 0,
// //                   duree: '',
// //                 ),
// //               )),
// //               icon: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
// //               label: const Text('Réserver maintenant',
// //                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: _green,
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //                 elevation: 0,
// //                 padding: const EdgeInsets.symmetric(vertical: 16),
// //                 minimumSize: const Size(double.infinity, 52),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ]),
// //     );
// //   }
// // }

// // class _InfoRow extends StatelessWidget {
// //   const _InfoRow({required this.icon, required this.text});
// //   final IconData icon; final String text;

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: const EdgeInsets.only(bottom: 6),
// //     child: Row(children: [
// //       Icon(icon, size: 16, color: _textGrey),
// //       const SizedBox(width: 8),
// //       Text(text, style: const TextStyle(fontSize: 14, color: _textGrey)),
// //     ]),
// //   );
// // }