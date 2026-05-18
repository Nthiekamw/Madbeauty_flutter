
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../profil_prestataire_screen.dart';

const _bg       = Color(0xFFF2EBE0);
const _gold     = Color(0xFFC4956A);
const _goldBg   = Color(0xFFEDE0CC);
const _goldDark = Color(0xFF8B6340);
const _textDark = Color(0xFF2C1810);
const _textMed  = Color(0xFF6B4C35);
const _textGrey = Color(0xFF9E8878);
const _green    = Color(0xFF4CAF50);

const _prestataires = [
  {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'km': '2.4 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'specialite': 'Tresses & Locks',        'type': 'coiffeur',   'image': 'assets/images/cf.jpg'},
  {'nom': 'Black Ink',     'ville': 'Créteil',          'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Tatouages personnalisés', 'type': 'coiffeur',   'image': 'assets/images/ta.jpg'},
  {'nom': 'Hairstylebymm', 'ville': 'Villepinte',       'km': '5.2 km', 'note': 4.8, 'avis': 64,  'dispo': true,  'specialite': 'Coiffure afro & Braids', 'type': 'coiffeur',   'image': 'assets/images/cf1.jpg'},
  {'nom': 'BarberKing',    'ville': 'Paris 18e',        'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Coupe homme & Barbe',    'type': 'coiffeur',   'image': 'assets/images/ch.jpg'},
  {'nom': 'TwistMaster',   'ville': 'Montreuil',        'km': '4.5 km', 'note': 4.6, 'avis': 52,  'dispo': false, 'specialite': 'Twists & Locks homme',   'type': 'coiffeur',   'image': 'assets/images/ch1.jpg'},
  {'nom': 'GlamFace',      'ville': 'Paris 11e',        'km': '6.0 km', 'note': 4.9, 'avis': 143, 'dispo': true,  'specialite': 'Maquillage artistique',  'type': 'maquillage', 'image': 'assets/images/m.jpg'},
  {'nom': 'BeautyByMia',   'ville': 'Versailles',       'km': '12 km',  'note': 4.8, 'avis': 97,  'dispo': true,  'specialite': 'Maquillage & Beauté',    'type': 'maquillage', 'image': 'assets/images/mmm.webp'},
  {'nom': 'NailArtStudio', 'ville': 'Créteil',          'km': '7.2 km', 'note': 4.7, 'avis': 78,  'dispo': true,  'specialite': 'Nail Art africain',      'type': 'manicure',   'image': 'assets/images/pe.jpg'},
  {'nom': 'PreciousNails', 'ville': 'Bobigny',          'km': '5.8 km', 'note': 4.5, 'avis': 41,  'dispo': true,  'specialite': 'Nail Art & Extensions',  'type': 'manicure',   'image': 'assets/images/pi.jpg'},
  {'nom': 'PediBySophie',  'ville': 'Saint-Denis',      'km': '9.3 km', 'note': 4.6, 'avis': 33,  'dispo': false, 'specialite': 'Pédicure & Soins pieds', 'type': 'manicure',   'image': 'assets/images/pe.avif'},
];

// Chips filtres avec icônes vectorielles
const _filtres = [
  {'label': 'Toutes',    'icon': Icons.grid_view_rounded,              'value': 'tous'},
  {'label': 'Coiffure',  'icon': Icons.content_cut,                   'value': 'coiffeur'},
  {'label': 'Manucure',  'icon': Icons.back_hand_outlined,            'value': 'manicure'},
  {'label': 'Pédicure',  'icon': Icons.airline_seat_legroom_extra_outlined, 'value': 'pedicure'},
  {'label': 'Maquillage','icon': Icons.face_retouching_natural,        'value': 'maquillage'},
];

class ClientAccueilTab extends StatefulWidget {
  final VoidCallback? onGoToRecherche;
  const ClientAccueilTab({super.key, this.onGoToRecherche});

  @override
  State<ClientAccueilTab> createState() => _ClientAccueilTabState();
}

class _ClientAccueilTabState extends State<ClientAccueilTab> {
  int _filtreIndex = 0;

  List<Map<String, dynamic>> get _filtered {
    if (_filtreIndex == 0) return List.from(_prestataires);
    final val = _filtres[_filtreIndex]['value'];
    return _prestataires.where((p) => p['type'] == val).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final h   = MediaQuery.of(context).size.height;
    final rem = w / 100;

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header compact : paramètres | avatar | cloche ─────────────
          Padding(
            padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Paramètres
                _HBtn(icon: Icons.settings_outlined, rem: rem, onTap: () {}),

                // Avatar centré + titre compact
                Column(children: [
                  Container(
                    width: rem * 13, height: rem * 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold, width: 2.5),
                      boxShadow: [BoxShadow(
                        color: _gold.withOpacity(0.3),
                        blurRadius: 10, offset: const Offset(0, 3))]),
                    child: ClipOval(
                      child: Image.asset('assets/images/cf.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: _goldBg,
                          child: Icon(Icons.person, color: _gold, size: rem * 7))))),
                ]),

                // Cloche
                Stack(children: [
                  _HBtn(icon: Icons.notifications_outlined, rem: rem, onTap: () {}),
                  Positioned(top: rem * 0.5, right: rem * 0.5,
                    child: Container(
                      width: rem * 2, height: rem * 2,
                      decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle))),
                ]),
              ],
            ),
          ),
          SizedBox(height: rem * 2.5),

          // ── Titre réduit ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: Text(
              'Salut William, envie de vous sublimer de la tête aux pieds ? 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: rem * 5.2,
                fontWeight: FontWeight.w900,
                color: _textDark,
                height: 1.25,
                letterSpacing: -0.3)),
          ),
          SizedBox(height: rem * 4),

          // ── Barre recherche ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: GestureDetector(
              onTap: widget.onGoToRecherche,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rem * 4, vertical: rem * 3.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 8),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.07),
                    blurRadius: 12, offset: const Offset(0, 4))]),
                child: Row(children: [
                  Icon(Icons.search_rounded,
                    color: _textGrey, size: rem * 5),
                  SizedBox(width: rem * 2.5),
                  Expanded(child: Text(
                    'Rechercher un service (Coiffure, Manu...)',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: rem * 3.4,
                      fontWeight: FontWeight.w400))),
                  Container(
                    padding: EdgeInsets.all(rem * 1.5),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(rem * 2)),
                    child: Icon(Icons.tune_rounded,
                      color: _textMed, size: rem * 4.2)),
                ]),
              ),
            ),
          ),
          SizedBox(height: rem * 3.5),

          // ── Chips filtres avec icônes + fond marron clair ─────────────
          SizedBox(
            height: rem * 9.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: rem * 4),
              itemCount: _filtres.length,
              itemBuilder: (_, i) {
                final active = i == _filtreIndex;
                final f = _filtres[i];
                return GestureDetector(
                  onTap: () => setState(() => _filtreIndex = i),
                  child: Container(
                    margin: EdgeInsets.only(right: rem * 2),
                    padding: EdgeInsets.symmetric(
                      horizontal: rem * 3.5, vertical: rem * 1.8),
                    decoration: BoxDecoration(
                      // Fond marron clair pour tous, plus foncé si actif
                      color: active ? _gold : _goldBg,
                      borderRadius: BorderRadius.circular(rem * 6),
                      border: Border.all(
                        color: active ? _gold : _goldBg.withOpacity(0.5),
                        width: 1.2),
                      boxShadow: active ? [BoxShadow(
                        color: _gold.withOpacity(0.35),
                        blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Row(children: [
                      Icon(
                        f['icon'] as IconData,
                        size: rem * 3.8,
                        color: active ? Colors.white : _goldDark),
                      SizedBox(width: rem * 1.5),
                      Text(f['label'] as String,
                        style: TextStyle(
                          fontSize: rem * 3,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _goldDark)),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: rem * 5),

          // ── Titre section ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: Text('Découvrez vos experts beauté & art',
              style: TextStyle(
                fontSize: rem * 5.5,
                fontWeight: FontWeight.w900,
                color: _textDark,
                letterSpacing: -0.3)),
          ),
          SizedBox(height: rem * 3.5),

          // ── Cartes scroll horizontal ──────────────────────────────────
          SizedBox(
            height: h * 0.38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: rem * 4, right: rem * 2, top: rem, bottom: rem * 1.5),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c     = _filtered[i];
                final dispo = c['dispo'] as bool;
                final type  = c['type'] as String;
                final note  = c['note'] as double;
                final avis  = c['avis'] as int;

                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfilPrestataireScreen(
                      nom: c['nom'] as String,
                      ville: c['ville'] as String,
                      typePresta: type))),
                  child: Container(
                    width: w * 0.48,
                    margin: EdgeInsets.only(right: rem * 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rem * 5),
                      boxShadow: [BoxShadow(
                        color: _textDark.withOpacity(0.10),
                        blurRadius: 18, offset: const Offset(0, 8))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      // Photo
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(rem * 5)),
                          child: Stack(fit: StackFit.expand, children: [
                            Image.asset(c['image'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF3D2B1F),
                                child: Icon(Icons.person,
                                  color: Colors.white, size: rem * 15))),

                            // Gradient
                            Container(decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xDD000000)],
                                stops: [0.45, 1.0]))),

                            // Badge dispo
                            Positioned(top: rem * 2.5, right: rem * 2.5,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rem * 2, vertical: rem * 0.8),
                                decoration: BoxDecoration(
                                  color: dispo ? _green : Colors.black54,
                                  borderRadius: BorderRadius.circular(rem * 4)),
                                child: Row(mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Container(width: rem * 1.5, height: rem * 1.5,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle)),
                                  SizedBox(width: rem),
                                  Text(dispo ? 'Dispo' : 'Indispo',
                                    style: TextStyle(
                                      fontSize: rem * 2.6,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                                ]))),
                          ]),
                        ),
                      ),

                      // Infos
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            rem * 3, rem * 2.5, rem * 3, rem * 2.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(c['nom'] as String,
                                  style: TextStyle(
                                    fontSize: rem * 4,
                                    fontWeight: FontWeight.w800,
                                    color: _textDark),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: rem * 0.5),
                                Text(c['specialite'] as String,
                                  style: TextStyle(
                                    fontSize: rem * 2.9,
                                    color: _textGrey),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              ]),
                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Row(children: [
                                  Icon(Icons.star_rounded,
                                    size: rem * 3.8,
                                    color: const Color(0xFFE8A838)),
                                  SizedBox(width: rem),
                                  Text('$note ($avis avis)',
                                    style: TextStyle(
                                      fontSize: rem * 2.9,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark)),
                                ]),
                                SizedBox(height: rem),
                                Row(children: [
                                  Icon(Icons.location_on_outlined,
                                    size: rem * 3.2, color: _textGrey),
                                  SizedBox(width: rem),
                                  Flexible(child: Text(
                                    '${c['ville']} · ${c['km']}',
                                    style: TextStyle(
                                      fontSize: rem * 2.9, color: _textGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                                ]),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: rem * 6),

          // ── Vos prochains rendez-vous ─────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Vos prochains rendez-vous',
                style: TextStyle(
                  fontSize: rem * 5.5,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  letterSpacing: -0.3)),
              SizedBox(height: rem * 3.5),

              // Carte RDV
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4.5),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.07),
                    blurRadius: 14, offset: const Offset(0, 5))]),
                child: Row(children: [
                  Container(
                    width: rem * 13, height: rem * 13,
                    decoration: BoxDecoration(
                      color: _goldBg,
                      borderRadius: BorderRadius.circular(rem * 3.5)),
                    child: Icon(Icons.calendar_month_rounded,
                      color: _gold, size: rem * 7)),
                  SizedBox(width: rem * 3.5),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mardi 15 Juin • 10:00',
                      style: TextStyle(
                        fontSize: rem * 3.8,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                    SizedBox(height: rem),
                    Text('chez NiniLocks',
                      style: TextStyle(fontSize: rem * 3.2, color: _textGrey)),
                  ])),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _gold.withOpacity(0.6), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rem * 6)),
                      padding: EdgeInsets.symmetric(
                        horizontal: rem * 3, vertical: rem * 2)),
                    child: Text('Voir détails',
                      style: TextStyle(
                        fontSize: rem * 3,
                        fontWeight: FontWeight.w600,
                        color: _goldDark))),
                ]),
              ),
              SizedBox(height: rem * 3),

              // Carte prendre RDV
              GestureDetector(
                onTap: widget.onGoToRecherche,
                child: Container(
                  padding: EdgeInsets.all(rem * 4),
                  decoration: BoxDecoration(
                    color: _goldBg,
                    borderRadius: BorderRadius.circular(rem * 4.5),
                    border: Border.all(
                      color: _gold.withOpacity(0.3), width: 1.2)),
                  child: Row(children: [
                    Container(
                      width: rem * 11, height: rem * 11,
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(rem * 3)),
                      child: Icon(Icons.add_rounded,
                        color: _goldDark, size: rem * 6.5)),
                    SizedBox(width: rem * 3.5),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Prendre un rendez-vous',
                        style: TextStyle(
                          fontSize: rem * 3.8,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                      SizedBox(height: rem),
                      Text('Trouvez votre expert beauté',
                        style: TextStyle(fontSize: rem * 3, color: _textMed)),
                    ])),
                    Icon(Icons.arrow_forward_ios_rounded,
                      size: rem * 4, color: _goldDark),
                  ]),
                ),
              ),
            ]),
          ),
          SizedBox(height: rem * 8),
        ]),
      ),
    );
  }
}

// ── Bouton header rond ────────────────────────────────────────────────────────
class _HBtn extends StatelessWidget {
  const _HBtn({required this.icon, required this.rem, required this.onTap});
  final IconData icon; final double rem; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: rem * 10, height: rem * 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(
          color: _textDark.withOpacity(0.08),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Icon(icon, size: rem * 5.5, color: _textMed)),
  );
}





























































// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../profil_prestataire_screen.dart';

// // ── Couleurs exactes du design ────────────────────────────────────────────────
// const _bg       = Color(0xFFF2EBE0);  // fond crème chaud exact
// const _gold     = Color(0xFFC4956A);  // doré brun exact
// const _goldBg   = Color(0xFFEDE0CC);  // fond doré clair
// const _goldDark = Color(0xFF8B6340);  // doré foncé pour textes
// const _textDark = Color(0xFF2C1810);  // brun très foncé
// const _textMed  = Color(0xFF6B4C35);  // brun moyen
// const _textGrey = Color(0xFF9E8878);  // gris chaud
// const _white    = Colors.white;
// const _green    = Color(0xFF4CAF50);  // vert badge dispo uniquement

// const _prestataires = [
//   {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'km': '2.4 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'specialite': 'Tresses & Locks',        'type': 'coiffeur',   'image': 'assets/images/cf.jpg'},
//   {'nom': 'Black Ink',     'ville': 'Créteil',          'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Tatouages personnalisés', 'type': 'coiffeur',   'image': 'assets/images/ta.jpg'},
//   {'nom': 'Hairstylebymm', 'ville': 'Villepinte',       'km': '5.2 km', 'note': 4.8, 'avis': 64,  'dispo': true,  'specialite': 'Coiffure afro & Braids', 'type': 'coiffeur',   'image': 'assets/images/cf1.jpg'},
//   {'nom': 'BarberKing',    'ville': 'Paris 18e',        'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Coupe homme & Barbe',    'type': 'coiffeur',   'image': 'assets/images/ch.jpg'},
//   {'nom': 'TwistMaster',   'ville': 'Montreuil',        'km': '4.5 km', 'note': 4.6, 'avis': 52,  'dispo': false, 'specialite': 'Twists & Locks homme',   'type': 'coiffeur',   'image': 'assets/images/ch1.jpg'},
//   {'nom': 'GlamFace',      'ville': 'Paris 11e',        'km': '6.0 km', 'note': 4.9, 'avis': 143, 'dispo': true,  'specialite': 'Maquillage artistique',  'type': 'maquillage', 'image': 'assets/images/m.jpg'},
//   {'nom': 'BeautyByMia',   'ville': 'Versailles',       'km': '12 km',  'note': 4.8, 'avis': 97,  'dispo': true,  'specialite': 'Maquillage & Beauté',    'type': 'maquillage', 'image': 'assets/images/mmm.webp'},
//   {'nom': 'NailArtStudio', 'ville': 'Créteil',          'km': '7.2 km', 'note': 4.7, 'avis': 78,  'dispo': true,  'specialite': 'Nail Art africain',      'type': 'manicure',   'image': 'assets/images/pe.jpg'},
//   {'nom': 'PreciousNails', 'ville': 'Bobigny',          'km': '5.8 km', 'note': 4.5, 'avis': 41,  'dispo': true,  'specialite': 'Nail Art & Extensions',  'type': 'manicure',   'image': 'assets/images/pi.jpg'},
//   {'nom': 'PediBySophie',  'ville': 'Saint-Denis',      'km': '9.3 km', 'note': 4.6, 'avis': 33,  'dispo': false, 'specialite': 'Pédicure & Soins pieds', 'type': 'manicure',   'image': 'assets/images/pe.avif'},
// ];

// const _filtres = [
//   {'label': '🎨 Toutes',    'value': 'tous'},
//   {'label': '✂️ Coiffure',  'value': 'coiffeur'},
//   {'label': '💅 Manucure',  'value': 'manicure'},
//   {'label': '👣 Pédicure',  'value': 'manicure'},
//   {'label': '💄 Maquillage','value': 'maquillage'},
// ];

// class ClientAccueilTab extends StatefulWidget {
//   final VoidCallback? onGoToRecherche;
//   const ClientAccueilTab({super.key, this.onGoToRecherche});

//   @override
//   State<ClientAccueilTab> createState() => _ClientAccueilTabState();
// }

// class _ClientAccueilTabState extends State<ClientAccueilTab> {
//   int _filtreIndex = 0;

//   List<Map<String, dynamic>> get _filtered {
//     if (_filtreIndex == 0) return List.from(_prestataires);
//     final val = _filtres[_filtreIndex]['value'];
//     return _prestataires.where((p) => p['type'] == val).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final w = size.width;
//     final h = size.height;

//     // Unité de base responsive — 1 rem = 1% de la largeur
//     final rem = w / 100;

//     return Container(
//       color: _bg,
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // ── Header : paramètres | avatar centré | cloche ─────────────
//           Padding(
//             padding: EdgeInsets.fromLTRB(rem * 4, rem * 4, rem * 4, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [

//                 // Paramètres (gauche)
//                 _HeaderBtn(icon: Icons.settings_outlined, size: rem * 6.5,
//                   onTap: () {}),

//                 // Avatar centré
//                 Container(
//                   width: rem * 16, height: rem * 16,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: _gold, width: 2.5),
//                     boxShadow: [BoxShadow(
//                       color: _gold.withOpacity(0.3),
//                       blurRadius: 12, offset: const Offset(0, 4))],
//                     image: const DecorationImage(
//                       image: AssetImage('assets/images/cf.jpg'),
//                       fit: BoxFit.cover,
//                       onError: null),
//                   ),
//                   child: ClipOval(
//                     child: Image.asset('assets/images/cf.jpg',
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => Container(
//                         color: _goldBg,
//                         child: Icon(Icons.person, color: _gold, size: rem * 9)))),
//                 ),

//                 // Cloche (droite) avec badge
//                 Stack(children: [
//                   _HeaderBtn(icon: Icons.notifications_outlined,
//                     size: rem * 6.5, onTap: () {}),
//                   Positioned(top: rem * 0.5, right: rem * 0.5,
//                     child: Container(
//                       width: rem * 2.2, height: rem * 2.2,
//                       decoration: const BoxDecoration(
//                         color: Colors.red, shape: BoxShape.circle))),
//                 ]),
//               ],
//             ),
//           ),
//           SizedBox(height: rem * 4),

//           // ── Titre bienvenue ───────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: rem * 5),
//             child: Text(
//               'Salut William, envie de vous sublimer\nde la tête aux pieds ? 👋',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: rem * 6.8,
//                 fontWeight: FontWeight.w900,
//                 color: _textDark,
//                 height: 1.25,
//                 letterSpacing: -0.5),
//             ),
//           ),
//           SizedBox(height: rem * 5),

//           // ── Barre recherche ───────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: rem * 4),
//             child: GestureDetector(
//               onTap: widget.onGoToRecherche,
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: rem * 4, vertical: rem * 3.8),
//                 decoration: BoxDecoration(
//                   color: _white,
//                   borderRadius: BorderRadius.circular(rem * 8),
//                   boxShadow: [BoxShadow(
//                     color: _textDark.withOpacity(0.06),
//                     blurRadius: 16, offset: const Offset(0, 4))],
//                 ),
//                 child: Row(children: [
//                   Icon(Icons.search, color: _textGrey, size: rem * 5.5),
//                   SizedBox(width: rem * 3),
//                   Expanded(child: Text(
//                     'Rechercher un service (Coiffure, Manu...)',
//                     style: TextStyle(color: _textGrey, fontSize: rem * 3.5,
//                       fontWeight: FontWeight.w400))),
//                   Container(
//                     padding: EdgeInsets.all(rem * 1.5),
//                     decoration: BoxDecoration(
//                       color: _bg, borderRadius: BorderRadius.circular(rem * 2)),
//                     child: Icon(Icons.tune, color: _textMed, size: rem * 4.5)),
//                 ]),
//               ),
//             ),
//           ),
//           SizedBox(height: rem * 4),

//           // ── Chips filtres ─────────────────────────────────────────────
//           SizedBox(
//             height: rem * 10,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: rem * 4),
//               itemCount: _filtres.length,
//               itemBuilder: (_, i) {
//                 final active = i == _filtreIndex;
//                 return GestureDetector(
//                   onTap: () => setState(() => _filtreIndex = i),
//                   child: Container(
//                     margin: EdgeInsets.only(right: rem * 2.5),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: rem * 4, vertical: rem * 2),
//                     decoration: BoxDecoration(
//                       color: active ? _gold : _white,
//                       borderRadius: BorderRadius.circular(rem * 6),
//                       border: Border.all(
//                         color: active ? _gold : const Color(0xFFDDD0C0),
//                         width: 1.2),
//                       boxShadow: active ? [BoxShadow(
//                         color: _gold.withOpacity(0.35),
//                         blurRadius: 10, offset: const Offset(0, 4))] : [
//                         BoxShadow(
//                           color: _textDark.withOpacity(0.05),
//                           blurRadius: 4, offset: const Offset(0, 2))],
//                     ),
//                     child: Text(_filtres[i]['label']!,
//                       style: TextStyle(
//                         fontSize: rem * 3.2,
//                         fontWeight: FontWeight.w600,
//                         color: active ? _white : _textMed)),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: rem * 6),

//           // ── Titre section ─────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: rem * 4),
//             child: Text('Découvrez vos experts beauté & art',
//               style: TextStyle(
//                 fontSize: rem * 6,
//                 fontWeight: FontWeight.w900,
//                 color: _textDark,
//                 letterSpacing: -0.3)),
//           ),
//           SizedBox(height: rem * 4),

//           // ── Cartes scroll horizontal ──────────────────────────────────
//           SizedBox(
//             height: h * 0.38,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               padding: EdgeInsets.only(
//                 left: rem * 4, right: rem * 2, top: rem, bottom: rem * 1.5),
//               itemCount: _filtered.length,
//               itemBuilder: (_, i) {
//                 final c    = _filtered[i];
//                 final dispo = c['dispo'] as bool;
//                 final type  = c['type'] as String;
//                 final note  = c['note'] as double;
//                 final avis  = c['avis'] as int;

//                 return GestureDetector(
//                   onTap: () => Navigator.of(context).push(
//                     MaterialPageRoute(builder: (_) => ProfilPrestataireScreen(
//                       nom: c['nom'] as String,
//                       ville: c['ville'] as String,
//                       typePresta: type))),
//                   child: Container(
//                     width: w * 0.48,
//                     margin: EdgeInsets.only(right: rem * 3.5),
//                     decoration: BoxDecoration(
//                       color: _white,
//                       borderRadius: BorderRadius.circular(rem * 5),
//                       boxShadow: [BoxShadow(
//                         color: _textDark.withOpacity(0.10),
//                         blurRadius: 20, offset: const Offset(0, 8))],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [

//                         // Photo
//                         Expanded(
//                           flex: 6,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(rem * 5)),
//                             child: Stack(fit: StackFit.expand, children: [
//                               Image.asset(c['image'] as String,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) => Container(
//                                   color: const Color(0xFF3D2B1F),
//                                   child: Icon(Icons.person,
//                                     color: _white, size: rem * 15))),

//                               // Gradient
//                               Container(decoration: const BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [Colors.transparent, Color(0xDD000000)],
//                                   stops: [0.45, 1.0]))),

//                               // Badge dispo
//                               Positioned(top: rem * 2.5, right: rem * 2.5,
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: rem * 2.2, vertical: rem * 1),
//                                   decoration: BoxDecoration(
//                                     color: dispo ? _green : Colors.black54,
//                                     borderRadius: BorderRadius.circular(rem * 4)),
//                                   child: Row(mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Container(width: rem * 1.5, height: rem * 1.5,
//                                         decoration: const BoxDecoration(
//                                           color: _white, shape: BoxShape.circle)),
//                                       SizedBox(width: rem * 1),
//                                       Text(dispo ? 'Dispo' : 'Indispo',
//                                         style: TextStyle(
//                                           fontSize: rem * 2.6,
//                                           fontWeight: FontWeight.w700,
//                                           color: _white)),
//                                     ]))),
//                             ]),
//                           ),
//                         ),

//                         // Infos
//                         Expanded(
//                           flex: 4,
//                           child: Padding(
//                             padding: EdgeInsets.fromLTRB(
//                               rem * 3, rem * 2.5, rem * 3, rem * 2.5),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(c['nom'] as String,
//                                       style: TextStyle(
//                                         fontSize: rem * 4,
//                                         fontWeight: FontWeight.w800,
//                                         color: _textDark,
//                                         letterSpacing: -0.2),
//                                       maxLines: 1, overflow: TextOverflow.ellipsis),
//                                     SizedBox(height: rem * 0.5),
//                                     Text(c['specialite'] as String,
//                                       style: TextStyle(
//                                         fontSize: rem * 2.9,
//                                         color: _textGrey,
//                                         fontWeight: FontWeight.w400),
//                                       maxLines: 1, overflow: TextOverflow.ellipsis),
//                                   ]),
//                                 Column(crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(children: [
//                                       Icon(Icons.star_rounded,
//                                         size: rem * 3.8,
//                                         color: const Color(0xFFE8A838)),
//                                       SizedBox(width: rem),
//                                       Text('$note ($avis avis)',
//                                         style: TextStyle(
//                                           fontSize: rem * 2.9,
//                                           fontWeight: FontWeight.w600,
//                                           color: _textDark)),
//                                     ]),
//                                     SizedBox(height: rem),
//                                     Row(children: [
//                                       Icon(Icons.location_on_outlined,
//                                         size: rem * 3.2, color: _textGrey),
//                                       SizedBox(width: rem),
//                                       Flexible(child: Text(
//                                         '${c['ville']} · ${c['km']}',
//                                         style: TextStyle(
//                                           fontSize: rem * 2.9, color: _textGrey),
//                                         maxLines: 1, overflow: TextOverflow.ellipsis)),
//                                     ]),
//                                   ]),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: rem * 7),

//           // ── Vos prochains rendez-vous ─────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: rem * 4),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text('Vos prochains rendez-vous',
//                 style: TextStyle(
//                   fontSize: rem * 6,
//                   fontWeight: FontWeight.w900,
//                   color: _textDark,
//                   letterSpacing: -0.3)),
//               SizedBox(height: rem * 4),

//               // Carte RDV existant
//               Container(
//                 padding: EdgeInsets.all(rem * 4),
//                 decoration: BoxDecoration(
//                   color: _white,
//                   borderRadius: BorderRadius.circular(rem * 4.5),
//                   boxShadow: [BoxShadow(
//                     color: _textDark.withOpacity(0.07),
//                     blurRadius: 16, offset: const Offset(0, 6))]),
//                 child: Row(children: [
//                   Container(
//                     width: rem * 13, height: rem * 13,
//                     decoration: BoxDecoration(
//                       color: _goldBg,
//                       borderRadius: BorderRadius.circular(rem * 3.5)),
//                     child: Icon(Icons.calendar_today_outlined,
//                       color: _gold, size: rem * 6.5)),
//                   SizedBox(width: rem * 4),
//                   Expanded(child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('Mardi 15 Juin • 10:00',
//                       style: TextStyle(
//                         fontSize: rem * 4,
//                         fontWeight: FontWeight.w700,
//                         color: _textDark)),
//                     SizedBox(height: rem),
//                     Text('chez NiniLocks',
//                       style: TextStyle(fontSize: rem * 3.2, color: _textGrey)),
//                   ])),
//                   OutlinedButton(
//                     onPressed: () {},
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: _gold.withOpacity(0.6), width: 1.5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(rem * 6)),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: rem * 3.5, vertical: rem * 2)),
//                     child: Text('Voir détails',
//                       style: TextStyle(
//                         fontSize: rem * 3.2,
//                         fontWeight: FontWeight.w600,
//                         color: _goldDark))),
//                 ]),
//               ),
//               SizedBox(height: rem * 3),

//               // Carte prendre RDV
//               GestureDetector(
//                 onTap: widget.onGoToRecherche,
//                 child: Container(
//                   padding: EdgeInsets.all(rem * 4),
//                   decoration: BoxDecoration(
//                     color: _goldBg,
//                     borderRadius: BorderRadius.circular(rem * 4.5),
//                     border: Border.all(
//                       color: _gold.withOpacity(0.3), width: 1.2)),
//                   child: Row(children: [
//                     Container(
//                       width: rem * 11, height: rem * 11,
//                       decoration: BoxDecoration(
//                         color: _gold.withOpacity(0.25),
//                         borderRadius: BorderRadius.circular(rem * 3)),
//                       child: Icon(Icons.add_rounded,
//                         color: _goldDark, size: rem * 6.5)),
//                     SizedBox(width: rem * 4),
//                     Expanded(child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text('Prendre un rendez-vous',
//                         style: TextStyle(
//                           fontSize: rem * 3.8,
//                           fontWeight: FontWeight.w700,
//                           color: _textDark)),
//                       SizedBox(height: rem),
//                       Text('Trouvez votre expert beauté',
//                         style: TextStyle(
//                           fontSize: rem * 3, color: _textMed)),
//                     ])),
//                     Icon(Icons.arrow_forward_ios_rounded,
//                       size: rem * 4, color: _goldDark),
//                   ]),
//                 ),
//               ),
//             ]),
//           ),
//           SizedBox(height: rem * 8),
//         ]),
//       ),
//     );
//   }
// }

// // ── Bouton header ─────────────────────────────────────────────────────────────
// class _HeaderBtn extends StatelessWidget {
//   const _HeaderBtn({required this.icon, required this.size, required this.onTap});
//   final IconData icon; final double size; final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       width: size * 1.6, height: size * 1.6,
//       decoration: BoxDecoration(
//         color: _white,
//         shape: BoxShape.circle,
//         boxShadow: [BoxShadow(
//           color: const Color(0xFF2C1810).withOpacity(0.08),
//           blurRadius: 8, offset: const Offset(0, 2))]),
//       child: Icon(icon, size: size, color: const Color(0xFF6B4C35))),
//   );
// }




























































// // // client_accueil_tab.dart
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import '../profil_prestataire_screen.dart';

// // const _bgCream  = Color(0xFFF5EFE6);
// // const _gold     = Color(0xFFD4A96A);
// // const _goldLight= Color(0xFFF0E6D3);
// // const _green    = Color(0xFF2D7A4F);
// // const _textDark = Color(0xFF1A1A1A);
// // const _textGrey = Color(0xFF8E8E93);

// // const _prestataires = [
// //   {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'km': '2.4 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'specialite': 'Tresses & Locks',         'type': 'coiffeur',   'image': 'assets/images/cf.jpg'},
// //   {'nom': 'Hairstylebymm', 'ville': 'Villepinte',       'km': '5.2 km', 'note': 4.8, 'avis': 64,  'dispo': true,  'specialite': 'Coiffure afro & Braids',  'type': 'coiffeur',   'image': 'assets/images/cf1.jpg'},
// //   {'nom': 'BarberKing',    'ville': 'Paris 18e',        'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Coupe homme & Barbe',     'type': 'coiffeur',   'image': 'assets/images/ch.jpg'},
// //   {'nom': 'TwistMaster',   'ville': 'Montreuil',        'km': '4.5 km', 'note': 4.6, 'avis': 52,  'dispo': false, 'specialite': 'Twists & Locks homme',    'type': 'coiffeur',   'image': 'assets/images/ch1.jpg'},
// //   {'nom': 'GlamFace',      'ville': 'Paris 11e',        'km': '6.0 km', 'note': 4.9, 'avis': 143, 'dispo': true,  'specialite': 'Maquillage artistique',   'type': 'maquillage', 'image': 'assets/images/m.jpg'},
// //   {'nom': 'BeautyByMia',   'ville': 'Versailles',       'km': '12 km',  'note': 4.8, 'avis': 97,  'dispo': true,  'specialite': 'Maquillage & Beauté',     'type': 'maquillage', 'image': 'assets/images/mmm.webp'},
// //   {'nom': 'NailArtStudio', 'ville': 'Créteil',          'km': '7.2 km', 'note': 4.7, 'avis': 78,  'dispo': true,  'specialite': 'Nail Art africain',       'type': 'manicure',   'image': 'assets/images/pe.jpg'},
// //   {'nom': 'PreciousNails', 'ville': 'Bobigny',          'km': '5.8 km', 'note': 4.5, 'avis': 41,  'dispo': true,  'specialite': 'Nail Art & Extensions',   'type': 'manicure',   'image': 'assets/images/pi.jpg'},
// //   {'nom': 'BlackInk',      'ville': 'Vincennes',        'km': '8.1 km', 'note': 4.9, 'avis': 210, 'dispo': true,  'specialite': 'Tatouages personnalisés', 'type': 'coiffeur',   'image': 'assets/images/ta.jpg'},
// //   {'nom': 'PediBySophie',  'ville': 'Saint-Denis',      'km': '9.3 km', 'note': 4.6, 'avis': 33,  'dispo': false, 'specialite': 'Pédicure & Soins pieds', 'type': 'manicure',   'image': 'assets/images/pe.avif'},
// // ];

// // const _filtres = [
// //   {'label': '🎨 Toutes',    'value': 'tous'},
// //   {'label': '✂️ Coiffure',  'value': 'coiffeur'},
// //   {'label': '💅 Manucure',  'value': 'manicure'},
// //   {'label': '💄 Maquillage','value': 'maquillage'},
// // ];

// // class ClientAccueilTab extends StatefulWidget {
// //   final VoidCallback? onGoToRecherche;
// //   const ClientAccueilTab({super.key, this.onGoToRecherche});
// //   @override
// //   State<ClientAccueilTab> createState() => _ClientAccueilTabState();
// // }

// // class _ClientAccueilTabState extends State<ClientAccueilTab> {
// //   int _filtreIndex = 0;

// //   List<Map<String, dynamic>> get _filtered {
// //     if (_filtreIndex == 0) return List.from(_prestataires);
// //     final val = _filtres[_filtreIndex]['value'];
// //     return _prestataires.where((p) => p['type'] == val).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final w = MediaQuery.of(context).size.width;
// //     final h = MediaQuery.of(context).size.height;
// //     final p = w * 0.05; // padding de base = 5% de la largeur

// //     return Container(
// //       color: _bgCream,
// //       child: SingleChildScrollView(
// //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// //           // ── Header ────────────────────────────────────────────────────
// //           Padding(
// //             padding: EdgeInsets.fromLTRB(p, p * 0.8, p * 0.5, 0),
// //             child: Row(children: [

// //               // Avatar
// //               Container(
// //                 width: w * 0.13, height: w * 0.13,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: _goldLight,
// //                   border: Border.all(color: _gold.withOpacity(0.6), width: 2.5),
// //                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)]),
// //                 child: Icon(Icons.person, color: _gold, size: w * 0.07)),
// //               const Spacer(),

// //               // Thème
// //               PopupMenuButton<String>(
// //                 icon: Icon(Icons.wb_sunny_outlined, size: w * 0.058, color: _textDark),
// //                 onSelected: (v) {},
// //                 itemBuilder: (_) => [
// //                   const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
// //                   const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
// //                   const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
// //                 ],
// //               ),

// //               // Support
// //               PopupMenuButton<String>(
// //                 icon: Icon(Icons.help_outline, size: w * 0.058, color: _textDark),
// //                 onSelected: (v) {},
// //                 itemBuilder: (_) => [
// //                   const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
// //                   const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
// //                 ],
// //               ),

// //               // Notifications
// //               Stack(children: [
// //                 IconButton(
// //                   onPressed: () => showDialog(
// //                     context: context,
// //                     builder: (_) => AlertDialog(
// //                       title: const Text('Notifications'),
// //                       content: const Text('Aucune notification'),
// //                       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
// //                     ),
// //                   ),
// //                   icon: Icon(Icons.notifications_outlined, size: w * 0.062, color: _textDark)),
// //                 Positioned(top: 8, right: 8,
// //                   child: Container(width: w * 0.022, height: w * 0.022,
// //                     decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
// //               ]),

// //               // Déconnexion
// //               IconButton(
// //                 onPressed: () => context.go('/'),
// //                 icon: Icon(Icons.logout, size: w * 0.056, color: _textDark),
// //                 padding: EdgeInsets.all(p * 0.3),
// //                 constraints: const BoxConstraints()),
// //             ]),
// //           ),

// //           // ── Message bienvenue ─────────────────────────────────────────
// //           Padding(
// //             padding: EdgeInsets.fromLTRB(p, p * 0.8, p, p),
// //             child: Text(
// //               'Salut William, envie de vous\nsublimer de la tête aux pieds ? 👋',
// //               style: TextStyle(
// //                 fontSize: w * 0.065,
// //                 fontWeight: FontWeight.w800,
// //                 color: _textDark,
// //                 height: 1.3)),
// //           ),

// //           // ── Barre de recherche ────────────────────────────────────────
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: p),
// //             child: GestureDetector(
// //               onTap: widget.onGoToRecherche,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: p * 0.8, vertical: h * 0.018),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(w * 0.1),
// //                   boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
// //                 ),
// //                 child: Row(children: [
// //                   Icon(Icons.search, color: _textGrey, size: w * 0.056),
// //                   SizedBox(width: w * 0.025),
// //                   Expanded(child: Text(
// //                     'Rechercher un service (Coiffure, Manu...)',
// //                     style: TextStyle(color: _textGrey.withOpacity(0.8), fontSize: w * 0.035))),
// //                   Container(
// //                     padding: EdgeInsets.all(w * 0.015),
// //                     decoration: BoxDecoration(color: _bgCream, borderRadius: BorderRadius.circular(8)),
// //                     child: Icon(Icons.tune, color: _textDark, size: w * 0.045)),
// //                 ]),
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: h * 0.018),

// //           // ── Chips filtres ─────────────────────────────────────────────
// //           SizedBox(
// //             height: h * 0.048,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               padding: EdgeInsets.symmetric(horizontal: p),
// //               itemCount: _filtres.length,
// //               itemBuilder: (_, i) {
// //                 final active = i == _filtreIndex;
// //                 return GestureDetector(
// //                   onTap: () => setState(() => _filtreIndex = i),
// //                   child: Container(
// //                     margin: EdgeInsets.only(right: w * 0.02),
// //                     padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.008),
// //                     decoration: BoxDecoration(
// //                       color: active ? _gold : Colors.white,
// //                       borderRadius: BorderRadius.circular(w * 0.1),
// //                       border: Border.all(color: active ? _gold : const Color(0xFFE0E0E0)),
// //                       boxShadow: active ? [BoxShadow(color: _gold.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3))] : null,
// //                     ),
// //                     child: Text(_filtres[i]['label']!,
// //                       style: TextStyle(
// //                         fontSize: w * 0.033,
// //                         fontWeight: FontWeight.w600,
// //                         color: active ? Colors.white : _textGrey)),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           SizedBox(height: h * 0.025),

// //           // ── Titre section ─────────────────────────────────────────────
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: p),
// //             child: Text('Découvrez vos experts beauté & art',
// //               style: TextStyle(fontSize: w * 0.056, fontWeight: FontWeight.w800, color: _textDark)),
// //           ),
// //           SizedBox(height: h * 0.016),

// //           // ── Grandes cartes ────────────────────────────────────────────
// //           SizedBox(
// //             height: h * 0.36,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               padding: EdgeInsets.only(left: p, right: w * 0.02, bottom: 4, top: 4),
// //               itemCount: _filtered.length,
// //               itemBuilder: (_, i) {
// //                 final c     = _filtered[i];
// //                 final dispo = c['dispo'] as bool;
// //                 final type  = c['type'] as String;
// //                 final note  = c['note'] as double;
// //                 final avis  = c['avis'] as int;

// //                 return GestureDetector(
// //                   onTap: () => Navigator.of(context).push(MaterialPageRoute(
// //                     builder: (_) => ProfilPrestataireScreen(
// //                       nom: c['nom'] as String,
// //                       ville: c['ville'] as String,
// //                       typePresta: type,
// //                     ),
// //                   )),
// //                   child: Container(
// //                     width: w * 0.5,
// //                     margin: EdgeInsets.only(right: w * 0.035),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(w * 0.06),
// //                       boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
// //                     ),
// //                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// //                       // Photo
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.06)),
// //                         child: SizedBox(
// //                           height: h * 0.225,
// //                           width: double.infinity,
// //                           child: Stack(fit: StackFit.expand, children: [
// //                             Image.asset(c['image'] as String,
// //                               fit: BoxFit.cover,
// //                               errorBuilder: (_, __, ___) => Container(
// //                                 color: const Color(0xFF3D2B1F),
// //                                 child: Icon(Icons.person, color: Colors.white, size: w * 0.15))),
// //                             Container(
// //                               decoration: const BoxDecoration(
// //                                 gradient: LinearGradient(
// //                                   begin: Alignment.topCenter,
// //                                   end: Alignment.bottomCenter,
// //                                   colors: [Colors.transparent, Color(0xCC000000)],
// //                                   stops: [0.5, 1.0]))),
// //                             Positioned(
// //                               top: h * 0.015, right: w * 0.03,
// //                               child: Container(
// //                                 padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.005),
// //                                 decoration: BoxDecoration(
// //                                   color: dispo ? _green : Colors.black54,
// //                                   borderRadius: BorderRadius.circular(w * 0.1)),
// //                                 child: Row(mainAxisSize: MainAxisSize.min, children: [
// //                                   Container(width: w * 0.015, height: w * 0.015,
// //                                     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
// //                                   SizedBox(width: w * 0.01),
// //                                   Text(dispo ? 'Dispo' : 'Indispo',
// //                                     style: TextStyle(fontSize: w * 0.026, fontWeight: FontWeight.w700, color: Colors.white)),
// //                                 ]))),
// //                           ]),
// //                         ),
// //                       ),

// //                       // Infos
// //                       Padding(
// //                         padding: EdgeInsets.fromLTRB(w * 0.03, h * 0.012, w * 0.03, h * 0.014),
// //                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                           Text(c['nom'] as String,
// //                             style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w800, color: _textDark),
// //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// //                           SizedBox(height: h * 0.003),
// //                           Text(c['specialite'] as String,
// //                             style: TextStyle(fontSize: w * 0.028, color: _textGrey.withOpacity(0.9)),
// //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// //                           SizedBox(height: h * 0.008),
// //                           Row(children: [
// //                             Icon(Icons.star_rounded, size: w * 0.036, color: const Color(0xFFFFB800)),
// //                             SizedBox(width: w * 0.008),
// //                             Text('$note ($avis avis)',
// //                               style: TextStyle(fontSize: w * 0.028, fontWeight: FontWeight.w600, color: _textDark)),
// //                           ]),
// //                           SizedBox(height: h * 0.004),
// //                           Row(children: [
// //                             Icon(Icons.location_on_outlined, size: w * 0.03, color: _textGrey),
// //                             SizedBox(width: w * 0.008),
// //                             Flexible(child: Text('${c['ville']} · ${c['km']}',
// //                               style: TextStyle(fontSize: w * 0.028, color: _textGrey),
// //                               maxLines: 1, overflow: TextOverflow.ellipsis)),
// //                           ]),
// //                         ]),
// //                       ),
// //                     ]),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           SizedBox(height: h * 0.028),

// //           // ── Vos prochains RDV ─────────────────────────────────────────
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: p),
// //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //               Text('Vos prochains rendez-vous',
// //                 style: TextStyle(fontSize: w * 0.056, fontWeight: FontWeight.w800, color: _textDark)),
// //               SizedBox(height: h * 0.016),

// //               // Carte RDV
// //               Container(
// //                 padding: EdgeInsets.all(p * 0.8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(w * 0.05),
// //                   boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))]),
// //                 child: Row(children: [
// //                   Container(
// //                     width: w * 0.13, height: w * 0.13,
// //                     decoration: BoxDecoration(color: _goldLight, borderRadius: BorderRadius.circular(w * 0.035)),
// //                     child: Icon(Icons.calendar_today_outlined, color: _gold, size: w * 0.06)),
// //                   SizedBox(width: w * 0.035),
// //                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                     Text('Mardi 15 Juin • 10:00',
// //                       style: TextStyle(fontSize: w * 0.038, fontWeight: FontWeight.w700, color: _textDark)),
// //                     SizedBox(height: h * 0.004),
// //                     Text('chez NiniLocks',
// //                       style: TextStyle(fontSize: w * 0.033, color: _textGrey)),
// //                   ])),
// //                   OutlinedButton(
// //                     onPressed: () {},
// //                     style: OutlinedButton.styleFrom(
// //                       side: BorderSide(color: _gold.withOpacity(0.5)),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.1)),
// //                       padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.008)),
// //                     child: Text('Voir détails',
// //                       style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.w600, color: _gold)),
// //                   ),
// //                 ]),
// //               ),
// //               SizedBox(height: h * 0.014),

// //               // Carte prendre RDV
// //               GestureDetector(
// //                 onTap: widget.onGoToRecherche,
// //                 child: Container(
// //                   padding: EdgeInsets.all(p * 0.8),
// //                   decoration: BoxDecoration(
// //                     color: _goldLight,
// //                     borderRadius: BorderRadius.circular(w * 0.05),
// //                     border: Border.all(color: _gold.withOpacity(0.25))),
// //                   child: Row(children: [
// //                     Container(
// //                       width: w * 0.11, height: w * 0.11,
// //                       decoration: BoxDecoration(
// //                         color: _gold.withOpacity(0.2),
// //                         borderRadius: BorderRadius.circular(w * 0.03)),
// //                       child: Icon(Icons.add_rounded, color: _gold, size: w * 0.06)),
// //                     SizedBox(width: w * 0.035),
// //                     Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                       Text('Prendre un rendez-vous',
// //                         style: TextStyle(fontSize: w * 0.036, fontWeight: FontWeight.w700, color: _textDark)),
// //                       SizedBox(height: h * 0.003),
// //                       Text('Trouvez votre expert beauté',
// //                         style: TextStyle(fontSize: w * 0.03, color: _textGrey)),
// //                     ])),
// //                     Icon(Icons.arrow_forward_ios_rounded, size: w * 0.04, color: _gold),
// //                   ]),
// //                 ),
// //               ),
// //             ]),
// //           ),
// //           SizedBox(height: h * 0.04),
// //         ]),
// //       ),
// //     );
// //   }
// // }




















































































// // // import 'package:flutter/material.dart';
// // // import 'package:go_router/go_router.dart';
// // // import '../profil_prestataire_screen.dart';

// // // const _bgCream  = Color(0xFFF5EFE6);
// // // const _gold     = Color(0xFFD4A96A);
// // // const _goldLight= Color(0xFFF0E6D3);
// // // const _green    = Color(0xFF2D7A4F);
// // // const _textDark = Color(0xFF1A1A1A);
// // // const _textGrey = Color(0xFF8E8E93);

// // // const _prestataires = [
// // //   {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'km': '2.4 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'specialite': 'Tresses & Locks',         'type': 'coiffeur',   'image': 'assets/images/cf.jpg'},
// // //   {'nom': 'Hairstylebymm', 'ville': 'Villepinte',       'km': '5.2 km', 'note': 4.8, 'avis': 64,  'dispo': true,  'specialite': 'Coiffure afro & Braids',  'type': 'coiffeur',   'image': 'assets/images/cf1.jpg'},
// // //   {'nom': 'BarberKing',    'ville': 'Paris 18e',        'km': '3.1 km', 'note': 4.7, 'avis': 88,  'dispo': true,  'specialite': 'Coupe homme & Barbe',     'type': 'coiffeur',   'image': 'assets/images/ch.jpg'},
// // //   {'nom': 'TwistMaster',   'ville': 'Montreuil',        'km': '4.5 km', 'note': 4.6, 'avis': 52,  'dispo': false, 'specialite': 'Twists & Locks homme',    'type': 'coiffeur',   'image': 'assets/images/ch1.jpg'},
// // //   {'nom': 'GlamFace',      'ville': 'Paris 11e',        'km': '6.0 km', 'note': 4.9, 'avis': 143, 'dispo': true,  'specialite': 'Maquillage artistique',   'type': 'maquillage', 'image': 'assets/images/m.jpg'},
// // //   {'nom': 'BeautyByMia',   'ville': 'Versailles',       'km': '12 km',  'note': 4.8, 'avis': 97,  'dispo': true,  'specialite': 'Maquillage & Beauté',     'type': 'maquillage', 'image': 'assets/images/mmm.webp'},
// // //   {'nom': 'NailArtStudio', 'ville': 'Créteil',          'km': '7.2 km', 'note': 4.7, 'avis': 78,  'dispo': true,  'specialite': 'Nail Art africain',       'type': 'manicure',   'image': 'assets/images/pe.jpg'},
// // //   {'nom': 'PreciousNails', 'ville': 'Bobigny',          'km': '5.8 km', 'note': 4.5, 'avis': 41,  'dispo': true,  'specialite': 'Nail Art & Extensions',   'type': 'manicure',   'image': 'assets/images/pi.jpg'},
// // //   {'nom': 'BlackInk',      'ville': 'Vincennes',        'km': '8.1 km', 'note': 4.9, 'avis': 210, 'dispo': true,  'specialite': 'Tatouages personnalisés', 'type': 'coiffeur',   'image': 'assets/images/ta.jpg'},
// // //   {'nom': 'PediBySophie',  'ville': 'Saint-Denis',      'km': '9.3 km', 'note': 4.6, 'avis': 33,  'dispo': false, 'specialite': 'Pédicure & Soins pieds', 'type': 'manicure',   'image': 'assets/images/pe.avif'},
// // // ];

// // // const _filtres = [
// // //   {'label': '🎨 Toutes',    'value': 'tous'},
// // //   {'label': '✂️ Coiffure',  'value': 'coiffeur'},
// // //   {'label': '💅 Manucure',  'value': 'manicure'},
// // //   {'label': '💄 Maquillage','value': 'maquillage'},
// // // ];

// // // class ClientAccueilTab extends StatefulWidget {
// // //   final VoidCallback? onGoToRecherche;
// // //   const ClientAccueilTab({super.key, this.onGoToRecherche});

// // //   @override
// // //   State<ClientAccueilTab> createState() => _ClientAccueilTabState();
// // // }

// // // class _ClientAccueilTabState extends State<ClientAccueilTab> {
// // //   int _filtreIndex = 0;

// // //   List<Map<String, dynamic>> get _filtered {
// // //     if (_filtreIndex == 0) return List.from(_prestataires);
// // //     final val = _filtres[_filtreIndex]['value'];
// // //     return _prestataires.where((p) => p['type'] == val).toList();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       color: _bgCream,
// // //       child: SingleChildScrollView(
// // //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// // //           // ── Header ────────────────────────────────────────────────────
// // //           Padding(
// // //             padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
// // //             child: Row(children: [

// // //               // Avatar
// // //               Container(
// // //                 width: 52, height: 52,
// // //                 decoration: BoxDecoration(
// // //                   shape: BoxShape.circle,
// // //                   color: _goldLight,
// // //                   border: Border.all(color: _gold.withOpacity(0.6), width: 2.5),
// // //                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)]),
// // //                 child: Icon(Icons.person, color: _gold, size: 28)),
// // //               const Spacer(),

// // //               // Thème
// // //               PopupMenuButton<String>(
// // //                 icon: const Icon(Icons.wb_sunny_outlined, size: 22, color: _textDark),
// // //                 onSelected: (v) {},
// // //                 itemBuilder: (_) => [
// // //                   const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
// // //                   const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
// // //                   const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
// // //                 ],
// // //               ),

// // //               // Support
// // //               PopupMenuButton<String>(
// // //                 icon: const Icon(Icons.help_outline, size: 22, color: _textDark),
// // //                 onSelected: (v) {},
// // //                 itemBuilder: (_) => [
// // //                   const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
// // //                   const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
// // //                 ],
// // //               ),

// // //               // Notifications
// // //               Stack(children: [
// // //                 IconButton(
// // //                   onPressed: () => showDialog(
// // //                     context: context,
// // //                     builder: (_) => AlertDialog(
// // //                       title: const Text('Notifications'),
// // //                       content: const Text('Aucune notification'),
// // //                       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
// // //                     ),
// // //                   ),
// // //                   icon: const Icon(Icons.notifications_outlined, size: 24, color: _textDark)),
// // //                 Positioned(top: 8, right: 8,
// // //                   child: Container(width: 8, height: 8,
// // //                     decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
// // //               ]),

// // //               // Déconnexion
// // //               IconButton(
// // //                 onPressed: () => context.go('/'),
// // //                 icon: const Icon(Icons.logout, size: 22, color: _textDark),
// // //                 padding: const EdgeInsets.all(6),
// // //                 constraints: const BoxConstraints()),
// // //             ]),
// // //           ),

// // //           // ── Message bienvenue ─────────────────────────────────────────
// // //           const Padding(
// // //             padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
// // //             child: Text(
// // //               'Salut William, envie de vous\nsublimer de la tête aux pieds ? 👋',
// // //               style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textDark, height: 1.3)),
// // //           ),

// // //           // ── Barre de recherche ────────────────────────────────────────
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20),
// // //             child: GestureDetector(
// // //               onTap: widget.onGoToRecherche,
// // //               child: Container(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(50),
// // //                   boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
// // //                 ),
// // //                 child: Row(children: [
// // //                   const Icon(Icons.search, color: _textGrey, size: 22),
// // //                   const SizedBox(width: 10),
// // //                   Expanded(child: Text(
// // //                     'Rechercher un service (Coiffure, Manu...)',
// // //                     style: TextStyle(color: _textGrey.withOpacity(0.8), fontSize: 14))),
// // //                   Container(
// // //                     padding: const EdgeInsets.all(6),
// // //                     decoration: BoxDecoration(color: _bgCream, borderRadius: BorderRadius.circular(8)),
// // //                     child: const Icon(Icons.tune, color: _textDark, size: 18)),
// // //                 ]),
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 16),

// // //           // ── Chips filtres ─────────────────────────────────────────────
// // //           SizedBox(
// // //             height: 40,
// // //             child: ListView.builder(
// // //               scrollDirection: Axis.horizontal,
// // //               padding: const EdgeInsets.symmetric(horizontal: 20),
// // //               itemCount: _filtres.length,
// // //               itemBuilder: (_, i) {
// // //                 final active = i == _filtreIndex;
// // //                 return GestureDetector(
// // //                   onTap: () => setState(() => _filtreIndex = i),
// // //                   child: Container(
// // //                     margin: const EdgeInsets.only(right: 8),
// // //                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: active ? _gold : Colors.white,
// // //                       borderRadius: BorderRadius.circular(50),
// // //                       border: Border.all(color: active ? _gold : const Color(0xFFE0E0E0)),
// // //                       boxShadow: active ? [BoxShadow(color: _gold.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3))] : null,
// // //                     ),
// // //                     child: Text(_filtres[i]['label']!,
// // //                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
// // //                         color: active ? Colors.white : _textGrey)),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           const SizedBox(height: 22),

// // //           // ── Titre section ─────────────────────────────────────────────
// // //           const Padding(
// // //             padding: EdgeInsets.symmetric(horizontal: 20),
// // //             child: Text('Découvrez vos experts beauté & art',
// // //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // ── Grandes cartes ────────────────────────────────────────────
// // //           SizedBox(
// // //             height: 290,
// // //             child: ListView.builder(
// // //               scrollDirection: Axis.horizontal,
// // //               padding: const EdgeInsets.only(left: 20, right: 8, bottom: 4, top: 4),
// // //               itemCount: _filtered.length,
// // //               itemBuilder: (_, i) {
// // //                 final c     = _filtered[i];
// // //                 final dispo = c['dispo'] as bool;
// // //                 final type  = c['type'] as String;
// // //                 final note  = c['note'] as double;
// // //                 final avis  = c['avis'] as int;

// // //                 return GestureDetector(
// // //                   onTap: () => Navigator.of(context).push(MaterialPageRoute(
// // //                     builder: (_) => ProfilPrestataireScreen(
// // //                       nom: c['nom'] as String,
// // //                       ville: c['ville'] as String,
// // //                       typePresta: type,
// // //                     ),
// // //                   )),
// // //                   child: Container(
// // //                     width: 195,
// // //                     margin: const EdgeInsets.only(right: 14),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white,
// // //                       borderRadius: BorderRadius.circular(24),
// // //                       boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
// // //                     ),
// // //                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// // //                       // Photo
// // //                       ClipRRect(
// // //                         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
// // //                         child: SizedBox(
// // //                           height: 180, width: double.infinity,
// // //                           child: Stack(fit: StackFit.expand, children: [
// // //                             Image.asset(c['image'] as String,
// // //                               fit: BoxFit.cover,
// // //                               errorBuilder: (_, __, ___) => Container(
// // //                                 color: const Color(0xFF3D2B1F),
// // //                                 child: const Icon(Icons.person, color: Colors.white, size: 60))),
// // //                             Container(
// // //                               decoration: const BoxDecoration(
// // //                                 gradient: LinearGradient(
// // //                                   begin: Alignment.topCenter,
// // //                                   end: Alignment.bottomCenter,
// // //                                   colors: [Colors.transparent, Color(0xCC000000)],
// // //                                   stops: [0.5, 1.0]))),
// // //                             Positioned(top: 12, right: 12,
// // //                               child: Container(
// // //                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // //                                 decoration: BoxDecoration(
// // //                                   color: dispo ? _green : Colors.black54,
// // //                                   borderRadius: BorderRadius.circular(50)),
// // //                                 child: Row(mainAxisSize: MainAxisSize.min, children: [
// // //                                   Container(width: 6, height: 6,
// // //                                     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
// // //                                   const SizedBox(width: 4),
// // //                                   Text(dispo ? 'Dispo' : 'Indispo',
// // //                                     style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
// // //                                 ]))),
// // //                           ]),
// // //                         ),
// // //                       ),

// // //                       // Infos
// // //                       Padding(
// // //                         padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
// // //                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                           Text(c['nom'] as String,
// // //                             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
// // //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// // //                           const SizedBox(height: 2),
// // //                           Text(c['specialite'] as String,
// // //                             style: TextStyle(fontSize: 11, color: _textGrey.withOpacity(0.9)),
// // //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// // //                           const SizedBox(height: 7),
// // //                           Row(children: [
// // //                             const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
// // //                             const SizedBox(width: 3),
// // //                             Text('$note ($avis avis)',
// // //                               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textDark)),
// // //                           ]),
// // //                           const SizedBox(height: 3),
// // //                           Row(children: [
// // //                             const Icon(Icons.location_on_outlined, size: 12, color: _textGrey),
// // //                             const SizedBox(width: 3),
// // //                             Flexible(child: Text('${c['ville']} · ${c['km']}',
// // //                               style: const TextStyle(fontSize: 11, color: _textGrey),
// // //                               maxLines: 1, overflow: TextOverflow.ellipsis)),
// // //                           ]),
// // //                         ]),
// // //                       ),
// // //                     ]),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           const SizedBox(height: 24),

// // //           // ── Vos prochains RDV ─────────────────────────────────────────
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20),
// // //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //               const Text('Vos prochains rendez-vous',
// // //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
// // //               const SizedBox(height: 14),

// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(20),
// // //                   boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))]),
// // //                 child: Row(children: [
// // //                   Container(width: 52, height: 52,
// // //                     decoration: BoxDecoration(color: _goldLight, borderRadius: BorderRadius.circular(14)),
// // //                     child: Icon(Icons.calendar_today_outlined, color: _gold, size: 24)),
// // //                   const SizedBox(width: 14),
// // //                   const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                     Text('Mardi 15 Juin • 10:00',
// // //                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
// // //                     SizedBox(height: 3),
// // //                     Text('chez NiniLocks', style: TextStyle(fontSize: 13, color: _textGrey)),
// // //                   ])),
// // //                   OutlinedButton(
// // //                     onPressed: () {},
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: BorderSide(color: _gold.withOpacity(0.5)),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// // //                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
// // //                     child: Text('Voir détails',
// // //                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _gold)),
// // //                   ),
// // //                 ]),
// // //               ),
// // //               const SizedBox(height: 12),

// // //               GestureDetector(
// // //                 onTap: widget.onGoToRecherche,
// // //                 child: Container(
// // //                   padding: const EdgeInsets.all(16),
// // //                   decoration: BoxDecoration(
// // //                     color: _goldLight,
// // //                     borderRadius: BorderRadius.circular(20),
// // //                     border: Border.all(color: _gold.withOpacity(0.25))),
// // //                   child: Row(children: [
// // //                     Container(width: 44, height: 44,
// // //                       decoration: BoxDecoration(
// // //                         color: _gold.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
// // //                       child: Icon(Icons.add_rounded, color: _gold, size: 24)),
// // //                     const SizedBox(width: 14),
// // //                     const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                       Text('Prendre un rendez-vous',
// // //                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
// // //                       SizedBox(height: 2),
// // //                       Text('Trouvez votre expert beauté',
// // //                         style: TextStyle(fontSize: 12, color: _textGrey)),
// // //                     ])),
// // //                     Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _gold),
// // //                   ]),
// // //                 ),
// // //               ),
// // //             ]),
// // //           ),
// // //           const SizedBox(height: 32),
// // //         ]),
// // //       ),
// // //     );
// // //   }
// // // }
















































































// // // import 'package:flutter/material.dart';
// // // import '../profil_prestataire_screen.dart';

// // // const _bgCream  = Color(0xFFF5EFE6);
// // // const _gold     = Color(0xFFD4A96A);
// // // const _goldLight= Color(0xFFF0E6D3);
// // // const _green    = Color(0xFF2D7A4F);
// // // const _textDark = Color(0xFF1A1A1A);
// // // const _textGrey = Color(0xFF8E8E93);

// // // const _prestataires = [
// // //   {
// // //     'nom': 'NiniLocks',
// // //     'ville': 'Corbeil-Essonnes',
// // //     'km': '2.4 km',
// // //     'note': 4.9,
// // //     'avis': 120,
// // //     'dispo': true,
// // //     'specialite': 'Tresses & Locks',
// // //     'type': 'coiffeur',
// // //     'image': 'assets/images/cf.jpg',
// // //   },
// // //   {
// // //     'nom': 'Hairstylebymm',
// // //     'ville': 'Villepinte',
// // //     'km': '5.2 km',
// // //     'note': 4.8,
// // //     'avis': 64,
// // //     'dispo': true,
// // //     'specialite': 'Coiffure afro & Braids',
// // //     'type': 'coiffeur',
// // //     'image': 'assets/images/cf1.jpg',
// // //   },
// // //   {
// // //     'nom': 'BarberKing',
// // //     'ville': 'Paris 18e',
// // //     'km': '3.1 km',
// // //     'note': 4.7,
// // //     'avis': 88,
// // //     'dispo': true,
// // //     'specialite': 'Coupe homme & Barbe',
// // //     'type': 'coiffeur',
// // //     'image': 'assets/images/ch.jpg',
// // //   },
// // //   {
// // //     'nom': 'TwistMaster',
// // //     'ville': 'Montreuil',
// // //     'km': '4.5 km',
// // //     'note': 4.6,
// // //     'avis': 52,
// // //     'dispo': false,
// // //     'specialite': 'Twists & Locks homme',
// // //     'type': 'coiffeur',
// // //     'image': 'assets/images/ch1.jpg',
// // //   },
// // //   {
// // //     'nom': 'GlamFace',
// // //     'ville': 'Paris 11e',
// // //     'km': '6.0 km',
// // //     'note': 4.9,
// // //     'avis': 143,
// // //     'dispo': true,
// // //     'specialite': 'Maquillage artistique',
// // //     'type': 'maquillage',
// // //     'image': 'assets/images/m.jpg',
// // //   },
// // //   {
// // //     'nom': 'BeautyByMia',
// // //     'ville': 'Versailles',
// // //     'km': '12 km',
// // //     'note': 4.8,
// // //     'avis': 97,
// // //     'dispo': true,
// // //     'specialite': 'Maquillage & Beauté',
// // //     'type': 'maquillage',
// // //     'image': 'assets/images/mmm.webp',
// // //   },
// // //   {
// // //     'nom': 'NailArtStudio',
// // //     'ville': 'Créteil',
// // //     'km': '7.2 km',
// // //     'note': 4.7,
// // //     'avis': 78,
// // //     'dispo': true,
// // //     'specialite': 'Nail Art africain',
// // //     'type': 'manicure',
// // //     'image': 'assets/images/pe.jpg',
// // //   },
// // //   {
// // //     'nom': 'PreciousNails',
// // //     'ville': 'Bobigny',
// // //     'km': '5.8 km',
// // //     'note': 4.5,
// // //     'avis': 41,
// // //     'dispo': true,
// // //     'specialite': 'Nail Art & Extensions',
// // //     'type': 'manicure',
// // //     'image': 'assets/images/pi.jpg',
// // //   },
// // //   {
// // //     'nom': 'BlackInk',
// // //     'ville': 'Vincennes',
// // //     'km': '8.1 km',
// // //     'note': 4.9,
// // //     'avis': 210,
// // //     'dispo': true,
// // //     'specialite': 'Tatouages personnalisés',
// // //     'type': 'coiffeur',
// // //     'image': 'assets/images/ta.jpg',
// // //   },
// // //   {
// // //     'nom': 'PediBySophie',
// // //     'ville': 'Saint-Denis',
// // //     'km': '9.3 km',
// // //     'note': 4.6,
// // //     'avis': 33,
// // //     'dispo': false,
// // //     'specialite': 'Pédicure & Soins pieds',
// // //     'type': 'manicure',
// // //     'image': 'assets/images/pe.avif',
// // //   },
// // // ];

// // // const _filtres = [
// // //   {'label': '🎨 Toutes',    'value': 'tous'},
// // //   {'label': '✂️ Coiffure',  'value': 'coiffeur'},
// // //   {'label': '💅 Manucure',  'value': 'manicure'},
// // //   {'label': '💄 Maquillage','value': 'maquillage'},
// // // ];

// // // class ClientAccueilTab extends StatefulWidget {
// // //   final VoidCallback? onGoToRecherche;
// // //   const ClientAccueilTab({super.key, this.onGoToRecherche});

// // //   @override
// // //   State<ClientAccueilTab> createState() => _ClientAccueilTabState();
// // // }

// // // class _ClientAccueilTabState extends State<ClientAccueilTab> {
// // //   int _filtreIndex = 0;

// // //   List<Map<String, dynamic>> get _filtered {
// // //     if (_filtreIndex == 0) return List.from(_prestataires);
// // //     final val = _filtres[_filtreIndex]['value'];
// // //     return _prestataires.where((p) => p['type'] == val).toList();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       color: _bgCream,
// // //       child: SingleChildScrollView(
// // //         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// // //           // ── Header ────────────────────────────────────────────────────
// // //           Container(
// // //             color: _bgCream,
// // //             padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
// // //             child: Row(children: [

// // //               // Avatar
// // //               Container(
// // //                 width: 52, height: 52,
// // //                 decoration: BoxDecoration(
// // //                   shape: BoxShape.circle,
// // //                   color: _goldLight,
// // //                   border: Border.all(color: _gold.withOpacity(0.6), width: 2.5),
// // //                   boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8)]),
// // //                 child: Icon(Icons.person, color: _gold, size: 28)),
// // //               const Spacer(),

// // //               // Thème
// // //               PopupMenuButton<String>(
// // //                 icon: const Icon(Icons.wb_sunny_outlined, size: 22, color: _textDark),
// // //                 onSelected: (v) {},
// // //                 itemBuilder: (_) => [
// // //                   const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
// // //                   const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
// // //                   const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
// // //                 ],
// // //               ),

// // //               // Support
// // //               PopupMenuButton<String>(
// // //                 icon: const Icon(Icons.help_outline, size: 22, color: _textDark),
// // //                 onSelected: (v) {},
// // //                 itemBuilder: (_) => [
// // //                   const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
// // //                   const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
// // //                 ],
// // //               ),

// // //               // Notifications
// // //               Stack(children: [
// // //                 IconButton(
// // //                   onPressed: () {},
// // //                   icon: const Icon(Icons.notifications_outlined, size: 24, color: _textDark)),
// // //                 Positioned(top: 8, right: 8,
// // //                   child: Container(width: 8, height: 8,
// // //                     decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
// // //               ]),
// // //             ]),
// // //           ),

// // //           // ── Message bienvenue ─────────────────────────────────────────
// // //           const Padding(
// // //             padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
// // //             child: Text(
// // //               'Salut William, envie de vous\nsublimer de la tête aux pieds ? 👋',
// // //               style: TextStyle(
// // //                 fontSize: 26, fontWeight: FontWeight.w800,
// // //                 color: _textDark, height: 1.3)),
// // //           ),

// // //           // ── Barre de recherche ────────────────────────────────────────
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20),
// // //             child: GestureDetector(
// // //               onTap: widget.onGoToRecherche,
// // //               child: Container(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(50),
// // //                   boxShadow: const [BoxShadow(
// // //                     color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
// // //                 ),
// // //                 child: Row(children: [
// // //                   const Icon(Icons.search, color: _textGrey, size: 22),
// // //                   const SizedBox(width: 10),
// // //                   Expanded(child: Text(
// // //                     'Rechercher un service (Coiffure, Manu...)',
// // //                     style: TextStyle(color: _textGrey.withOpacity(0.8), fontSize: 14))),
// // //                   Container(
// // //                     padding: const EdgeInsets.all(6),
// // //                     decoration: BoxDecoration(
// // //                       color: _bgCream,
// // //                       borderRadius: BorderRadius.circular(8)),
// // //                     child: const Icon(Icons.tune, color: _textDark, size: 18)),
// // //                 ]),
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 16),

// // //           // ── Chips filtres ─────────────────────────────────────────────
// // //           SizedBox(
// // //             height: 40,
// // //             child: ListView.builder(
// // //               scrollDirection: Axis.horizontal,
// // //               padding: const EdgeInsets.symmetric(horizontal: 20),
// // //               itemCount: _filtres.length,
// // //               itemBuilder: (_, i) {
// // //                 final active = i == _filtreIndex;
// // //                 return GestureDetector(
// // //                   onTap: () => setState(() => _filtreIndex = i),
// // //                   child: Container(
// // //                     margin: const EdgeInsets.only(right: 8),
// // //                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //                     decoration: BoxDecoration(
// // //                       color: active ? _gold : Colors.white,
// // //                       borderRadius: BorderRadius.circular(50),
// // //                       border: Border.all(
// // //                         color: active ? _gold : const Color(0xFFE0E0E0)),
// // //                       boxShadow: active ? [BoxShadow(
// // //                         color: _gold.withOpacity(0.30),
// // //                         blurRadius: 8, offset: const Offset(0, 3))] : null,
// // //                     ),
// // //                     child: Text(_filtres[i]['label']!,
// // //                       style: TextStyle(
// // //                         fontSize: 13, fontWeight: FontWeight.w600,
// // //                         color: active ? Colors.white : _textGrey)),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           const SizedBox(height: 22),

// // //           // ── Titre section ─────────────────────────────────────────────
// // //           const Padding(
// // //             padding: EdgeInsets.symmetric(horizontal: 20),
// // //             child: Text('Découvrez vos experts beauté & art',
// // //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
// // //           ),
// // //           const SizedBox(height: 14),

// // //           // ── Grandes cartes avec vraies photos ─────────────────────────
// // //           SizedBox(
// // //             height: 290,
// // //             child: ListView.builder(
// // //               scrollDirection: Axis.horizontal,
// // //               padding: const EdgeInsets.only(left: 20, right: 8, bottom: 4, top: 4),
// // //               itemCount: _filtered.length,
// // //               itemBuilder: (_, i) {
// // //                 final c    = _filtered[i];
// // //                 final dispo = c['dispo'] as bool;
// // //                 final type  = c['type'] as String;
// // //                 final note  = c['note'] as double;
// // //                 final avis  = c['avis'] as int;

// // //                 return GestureDetector(
// // //                   onTap: () => Navigator.of(context).push(MaterialPageRoute(
// // //                     builder: (_) => ProfilPrestataireScreen(
// // //                       nom: c['nom'] as String,
// // //                       ville: c['ville'] as String,
// // //                       typePresta: type,
// // //                     ),
// // //                   )),
// // //                   child: Container(
// // //                     width: 195,
// // //                     margin: const EdgeInsets.only(right: 14),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white,
// // //                       borderRadius: BorderRadius.circular(24),
// // //                       boxShadow: const [BoxShadow(
// // //                         color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
// // //                     ),
// // //                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// // //                       // ── Photo ───────────────────────────────────────
// // //                       ClipRRect(
// // //                         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
// // //                         child: SizedBox(
// // //                           height: 180, width: double.infinity,
// // //                           child: Stack(fit: StackFit.expand, children: [

// // //                             // Image réelle
// // //                             Image.asset(
// // //                               c['image'] as String,
// // //                               fit: BoxFit.cover,
// // //                               errorBuilder: (_, __, ___) => Container(
// // //                                 color: const Color(0xFF3D2B1F),
// // //                                 child: const Icon(Icons.person, color: Colors.white, size: 60)),
// // //                             ),

// // //                             // Gradient bas
// // //                             Container(
// // //                               decoration: const BoxDecoration(
// // //                                 gradient: LinearGradient(
// // //                                   begin: Alignment.topCenter,
// // //                                   end: Alignment.bottomCenter,
// // //                                   colors: [Colors.transparent, Color(0xCC000000)],
// // //                                   stops: [0.5, 1.0],
// // //                                 )),
// // //                             ),

// // //                             // Badge dispo
// // //                             Positioned(top: 12, right: 12,
// // //                               child: Container(
// // //                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // //                                 decoration: BoxDecoration(
// // //                                   color: dispo ? _green : Colors.black54,
// // //                                   borderRadius: BorderRadius.circular(50)),
// // //                                 child: Row(mainAxisSize: MainAxisSize.min, children: [
// // //                                   Container(width: 6, height: 6,
// // //                                     decoration: const BoxDecoration(
// // //                                       color: Colors.white, shape: BoxShape.circle)),
// // //                                   const SizedBox(width: 4),
// // //                                   Text(dispo ? 'Dispo' : 'Indispo',
// // //                                     style: const TextStyle(
// // //                                       fontSize: 10, fontWeight: FontWeight.w700,
// // //                                       color: Colors.white)),
// // //                                 ]),
// // //                               )),
// // //                           ]),
// // //                         ),
// // //                       ),

// // //                       // ── Infos ───────────────────────────────────────
// // //                       Padding(
// // //                         padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
// // //                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                           Text(c['nom'] as String,
// // //                             style: const TextStyle(
// // //                               fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
// // //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// // //                           const SizedBox(height: 2),
// // //                           Text(c['specialite'] as String,
// // //                             style: TextStyle(fontSize: 11, color: _textGrey.withOpacity(0.9)),
// // //                             maxLines: 1, overflow: TextOverflow.ellipsis),
// // //                           const SizedBox(height: 7),
// // //                           Row(children: [
// // //                             const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
// // //                             const SizedBox(width: 3),
// // //                             Text('$note ($avis avis)',
// // //                               style: const TextStyle(
// // //                                 fontSize: 11, fontWeight: FontWeight.w600, color: _textDark)),
// // //                           ]),
// // //                           const SizedBox(height: 3),
// // //                           Row(children: [
// // //                             const Icon(Icons.location_on_outlined, size: 12, color: _textGrey),
// // //                             const SizedBox(width: 3),
// // //                             Flexible(child: Text('${c['ville']} · ${c['km']}',
// // //                               style: const TextStyle(fontSize: 11, color: _textGrey),
// // //                               maxLines: 1, overflow: TextOverflow.ellipsis)),
// // //                           ]),
// // //                         ]),
// // //                       ),
// // //                     ]),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           const SizedBox(height: 24),

// // //           // ── Vos prochains RDV ─────────────────────────────────────────
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20),
// // //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //               const Text('Vos prochains rendez-vous',
// // //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
// // //               const SizedBox(height: 14),

// // //               // Carte RDV
// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(20),
// // //                   boxShadow: const [BoxShadow(
// // //                     color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))]),
// // //                 child: Row(children: [
// // //                   Container(
// // //                     width: 52, height: 52,
// // //                     decoration: BoxDecoration(
// // //                       color: _goldLight,
// // //                       borderRadius: BorderRadius.circular(14)),
// // //                     child: Icon(Icons.calendar_today_outlined, color: _gold, size: 24)),
// // //                   const SizedBox(width: 14),
// // //                   const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                     Text('Mardi 15 Juin • 10:00',
// // //                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
// // //                     SizedBox(height: 3),
// // //                     Text('chez NiniLocks',
// // //                       style: TextStyle(fontSize: 13, color: _textGrey)),
// // //                   ])),
// // //                   OutlinedButton(
// // //                     onPressed: () {},
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: BorderSide(color: _gold.withOpacity(0.5)),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// // //                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
// // //                     child: Text('Voir détails',
// // //                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _gold)),
// // //                   ),
// // //                 ]),
// // //               ),
// // //               const SizedBox(height: 12),

// // //               // Carte prendre RDV
// // //               GestureDetector(
// // //                 onTap: widget.onGoToRecherche,
// // //                 child: Container(
// // //                   padding: const EdgeInsets.all(16),
// // //                   decoration: BoxDecoration(
// // //                     color: _goldLight,
// // //                     borderRadius: BorderRadius.circular(20),
// // //                     border: Border.all(color: _gold.withOpacity(0.25))),
// // //                   child: Row(children: [
// // //                     Container(
// // //                       width: 44, height: 44,
// // //                       decoration: BoxDecoration(
// // //                         color: _gold.withOpacity(0.2),
// // //                         borderRadius: BorderRadius.circular(12)),
// // //                       child: Icon(Icons.add_rounded, color: _gold, size: 24)),
// // //                     const SizedBox(width: 14),
// // //                     const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // //                       Text('Prendre un rendez-vous',
// // //                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
// // //                       SizedBox(height: 2),
// // //                       Text('Trouvez votre expert beauté',
// // //                         style: TextStyle(fontSize: 12, color: _textGrey)),
// // //                     ])),
// // //                     Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _gold),
// // //                   ]),
// // //                 ),
// // //               ),
// // //             ]),
// // //           ),
// // //           const SizedBox(height: 32),
// // //         ]),
// // //       ),
// // //     );
// // //   }
// // // }














































// // // // import 'package:flutter/material.dart';
// // // // import '../profil_prestataire_screen.dart';

// // // // const _green      = Color(0xFF2D7A4F);
// // // // const _greenLight = Color(0xFFE8F5EE);
// // // // const _textDark   = Color(0xFF1A1A1A);
// // // // const _textGrey   = Color(0xFF8E8E93);

// // // // const _coiffeursRecommandes = [
// // // //   {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'dispo': true,  'specialite': 'Tresses & Locks',         'type': 'coiffeur',   'initiales': 'NL'},
// // // //   {'nom': 'Hairstylebymm', 'ville': 'Villepinte',        'dispo': true,  'specialite': 'Coiffure afro',           'type': 'coiffeur',   'initiales': 'M'},
// // // //   {'nom': 'Ashy.hair',     'ville': 'Cergy',             'dispo': true,  'specialite': 'Twists & Vanilles',       'type': 'coiffeur',   'initiales': 'AH'},
// // // //   {'nom': '19thSignature', 'ville': 'Saint-Germain',     'dispo': false, 'specialite': 'Tresses & Coupes',        'type': 'coiffeur',   'initiales': '19'},
// // // //   {'nom': 'Afro_beauty',   'ville': 'Louvres',           'dispo': true,  'specialite': 'Maquillage & Coiffure',   'type': 'maquillage', 'initiales': 'AB'},
// // // //   {'nom': 'Beauty_Nails',  'ville': 'Paris',             'dispo': true,  'specialite': 'Manucure & Nail Art',     'type': 'manicure',   'initiales': 'BN'},
// // // //   {'nom': 'GlamMakeup',    'ville': 'Versailles',        'dispo': true,  'specialite': 'Maquillage événementiel', 'type': 'maquillage', 'initiales': 'GM'},
// // // // ];

// // // // // Couleurs de fond avatar selon l'index — style élégant
// // // // const _avatarColors = [
// // // //   Color(0xFF1A1A1A),  // noir profond
// // // //   Color(0xFF2D7A4F),  // vert
// // // //   Color(0xFF3D5A80),  // bleu nuit
// // // //   Color(0xFF6B3A4D),  // bordeaux
// // // //   Color(0xFF4A4A4A),  // gris anthracite
// // // //   Color(0xFF2D4A3E),  // vert foncé
// // // //   Color(0xFF5C3D2E),  // marron chaud
// // // // ];

// // // // class ClientAccueilTab extends StatelessWidget {
// // // //   final VoidCallback? onGoToRecherche;
// // // //   const ClientAccueilTab({super.key, this.onGoToRecherche});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return SingleChildScrollView(
// // // //       padding: const EdgeInsets.all(16),
// // // //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

// // // //         // ── Carte profil ──────────────────────────────────────────────
// // // //         Container(
// // // //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// // // //           decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             borderRadius: BorderRadius.circular(16),
// // // //             border: Border.all(color: const Color(0xFFF0F0F0)),
// // // //             boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
// // // //           ),
// // // //           child: Row(children: [
// // // //             Container(
// // // //               width: 48, height: 48,
// // // //               decoration: const BoxDecoration(shape: BoxShape.circle, color: _greenLight),
// // // //               child: const Icon(Icons.person, color: _green, size: 28)),
// // // //             const SizedBox(width: 12),
// // // //             const Expanded(
// // // //               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //                 Text('Bonjour william !',
// // // //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// // // //                 Text('Espace client',
// // // //                   style: TextStyle(fontSize: 13, color: _textGrey)),
// // // //               ]),
// // // //             ),
// // // //             Container(
// // // //               width: 36, height: 36,
// // // //               decoration: BoxDecoration(
// // // //                 shape: BoxShape.circle,
// // // //                 border: Border.all(color: const Color(0xFFE0E0E0))),
// // // //               child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
// // // //           ]),
// // // //         ),
// // // //         const SizedBox(height: 16),

// // // //         // ── Trouver un prestataire ────────────────────────────────────
// // // //         // ── Trouver un prestataire ────────────────────────────────────────
// // // // Container(
// // // //   padding: const EdgeInsets.all(20),
// // // //   decoration: BoxDecoration(
// // // //     color: Colors.white,
// // // //     borderRadius: BorderRadius.circular(20),
// // // //     border: Border.all(color: const Color(0xFFF0F0F0)),
// // // //     boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3))],
// // // //   ),
// // // //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //     Row(children: [
// // // //       Container(
// // // //         padding: const EdgeInsets.all(10),
// // // //         decoration: BoxDecoration(
// // // //           color: _greenLight,
// // // //           borderRadius: BorderRadius.circular(12)),
// // // //         child: const Icon(Icons.search, size: 22, color: _green)),
// // // //       const SizedBox(width: 12),
// // // //       const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// // // //         Text('Trouver un prestataire',
// // // //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
// // // //         SizedBox(height: 2),
// // // //         Text('Coiffeur, maquillage, manucure…',
// // // //           style: TextStyle(fontSize: 12, color: _textGrey)),
// // // //       ]),
// // // //     ]),
// // // //     const SizedBox(height: 16),
// // // //     GestureDetector(
// // // //       onTap: onGoToRecherche,
// // // //       child: Container(
// // // //         width: double.infinity,
// // // //         padding: const EdgeInsets.symmetric(vertical: 16),
// // // //         decoration: BoxDecoration(
// // // //           color: _green,
// // // //           borderRadius: BorderRadius.circular(16),
// // // //           boxShadow: [BoxShadow(
// // // //             color: _green.withOpacity(0.35),
// // // //             blurRadius: 12,
// // // //             offset: const Offset(0, 5))],
// // // //         ),
// // // //         child: const Row(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
// // // //             SizedBox(width: 10),
// // // //             Text('Commencer la recherche',
// // // //               style: TextStyle(
// // // //                 fontSize: 15,
// // // //                 fontWeight: FontWeight.w700,
// // // //                 color: Colors.white,
// // // //                 letterSpacing: 0.3)),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     ),
// // // //   ]),
// // // // ),
// // // //         const SizedBox(height: 22),

// // // //         // ── Titre section ─────────────────────────────────────────────
// // // //         const Text('Prestataires recommandés',
// // // //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
// // // //         const SizedBox(height: 4),
// // // //         const Text('Découvrez nos professionnels disponibles',
// // // //           style: TextStyle(fontSize: 14, color: _textGrey)),
// // // //         const SizedBox(height: 14),

// // // //         // ── Scroll horizontal ─────────────────────────────────────────
// // // //         SizedBox(
// // // //           height: 195,
// // // //           child: ListView.builder(
// // // //             scrollDirection: Axis.horizontal,
// // // //             padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
// // // //             itemCount: _coiffeursRecommandes.length,
// // // //             itemBuilder: (_, i) {
// // // //               final c         = _coiffeursRecommandes[i];
// // // //               final dispo     = c['dispo'] as bool;
// // // //               final type      = c['type'] as String;
// // // //               final initiales = c['initiales'] as String;
// // // //               final bgColor   = _avatarColors[i % _avatarColors.length];

// // // //               return GestureDetector(
// // // //                 onTap: () => Navigator.of(context).push(MaterialPageRoute(
// // // //                   builder: (_) => ProfilPrestataireScreen(
// // // //                     nom: c['nom'] as String,
// // // //                     ville: c['ville'] as String,
// // // //                     typePresta: type,
// // // //                   ),
// // // //                 )),
// // // //                 child: Container(
// // // //                   width: 145,
// // // //                   margin: const EdgeInsets.only(right: 12),
// // // //                   decoration: BoxDecoration(
// // // //                     color: Colors.white,
// // // //                     borderRadius: BorderRadius.circular(20),
// // // //                     border: Border.all(
// // // //                       color: dispo
// // // //                         ? _green.withOpacity(0.35)
// // // //                         : const Color(0xFFE8E8E8),
// // // //                       width: dispo ? 1.8 : 1.2),
// // // //                     boxShadow: [BoxShadow(
// // // //                       color: dispo
// // // //                         ? _green.withOpacity(0.10)
// // // //                         : const Color(0x08000000),
// // // //                       blurRadius: 14,
// // // //                       offset: const Offset(0, 5))],
// // // //                   ),
// // // //                   child: Padding(
// // // //                     padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
// // // //                     child: Column(
// // // //                       mainAxisAlignment: MainAxisAlignment.start,
// // // //                       children: [

// // // //                         // ── Avatar avec initiales style photo profil ──
// // // //                         Stack(
// // // //                           alignment: Alignment.center,
// // // //                           children: [
// // // //                             // Anneau extérieur vert
// // // //                             Container(
// // // //                               width: 76, height: 76,
// // // //                               decoration: BoxDecoration(
// // // //                                 shape: BoxShape.circle,
// // // //                                 border: Border.all(
// // // //                                   color: dispo ? _green : const Color(0xFFD0D0D0),
// // // //                                   width: 2.5),
// // // //                               ),
// // // //                             ),
// // // //                             // Avatar fond coloré + initiales
// // // //                             Container(
// // // //                               width: 68, height: 68,
// // // //                               decoration: BoxDecoration(
// // // //                                 shape: BoxShape.circle,
// // // //                                 color: bgColor,
// // // //                                 boxShadow: [BoxShadow(
// // // //                                   color: bgColor.withOpacity(0.4),
// // // //                                   blurRadius: 8, offset: const Offset(0, 2))],
// // // //                               ),
// // // //                               child: Center(
// // // //                                 child: Text(
// // // //                                   initiales,
// // // //                                   style: const TextStyle(
// // // //                                     fontSize: 20,
// // // //                                     fontWeight: FontWeight.w800,
// // // //                                     color: Colors.white,
// // // //                                     letterSpacing: 0.5),
// // // //                                 ),
// // // //                               ),
// // // //                             ),
// // // //                             // Point vert dispo
// // // //                             if (dispo)
// // // //                               Positioned(
// // // //                                 bottom: 2, right: 4,
// // // //                                 child: Container(
// // // //                                   width: 16, height: 16,
// // // //                                   decoration: BoxDecoration(
// // // //                                     color: _green,
// // // //                                     shape: BoxShape.circle,
// // // //                                     border: Border.all(color: Colors.white, width: 2.5),
// // // //                                     boxShadow: const [BoxShadow(
// // // //                                       color: Color(0x40000000), blurRadius: 4)],
// // // //                                   ),
// // // //                                 ),
// // // //                               ),
// // // //                           ],
// // // //                         ),
// // // //                         const SizedBox(height: 10),

// // // //                         // Nom
// // // //                         Text(c['nom'] as String,
// // // //                           style: const TextStyle(
// // // //                             fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
// // // //                           maxLines: 1, overflow: TextOverflow.ellipsis,
// // // //                           textAlign: TextAlign.center),
// // // //                         const SizedBox(height: 3),

// // // //                         // Ville
// // // //                         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
// // // //                           const Icon(Icons.location_on_outlined, size: 11, color: _textGrey),
// // // //                           const SizedBox(width: 2),
// // // //                           Flexible(child: Text(c['ville'] as String,
// // // //                             style: const TextStyle(fontSize: 11, color: _textGrey),
// // // //                             maxLines: 1, overflow: TextOverflow.ellipsis)),
// // // //                         ]),
// // // //                         const SizedBox(height: 8),

// // // //                         // Badge dispo
// // // //                         Container(
// // // //                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// // // //                           decoration: BoxDecoration(
// // // //                             color: dispo ? _greenLight : const Color(0xFFF2F2F7),
// // // //                             borderRadius: BorderRadius.circular(50),
// // // //                             border: Border.all(
// // // //                               color: dispo
// // // //                                 ? _green.withOpacity(0.4)
// // // //                                 : const Color(0xFFE0E0E0),
// // // //                               width: 1)),
// // // //                           child: Row(mainAxisSize: MainAxisSize.min, children: [
// // // //                             Container(
// // // //                               width: 6, height: 6,
// // // //                               decoration: BoxDecoration(
// // // //                                 shape: BoxShape.circle,
// // // //                                 color: dispo ? _green : _textGrey)),
// // // //                             const SizedBox(width: 5),
// // // //                             Text(
// // // //                               dispo ? 'Disponible' : 'Indisponible',
// // // //                               style: TextStyle(
// // // //                                 fontSize: 10, fontWeight: FontWeight.w600,
// // // //                                 color: dispo ? _green : _textGrey)),
// // // //                           ]),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               );
// // // //             },
// // // //           ),
// // // //         ),

// // // //         // Hint scroll
// // // //         const SizedBox(height: 8),
// // // //         Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
// // // //           Icon(Icons.chevron_left, size: 14, color: _textGrey),
// // // //           SizedBox(width: 4),
// // // //           Text('Faites glisser pour voir plus',
// // // //             style: TextStyle(fontSize: 11, color: _textGrey)),
// // // //           SizedBox(width: 4),
// // // //           Icon(Icons.chevron_right, size: 14, color: _textGrey),
// // // //         ]),
// // // //         const SizedBox(height: 22),

// // // //         // ── Rendez-vous récents ───────────────────────────────────────
// // // //         Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           decoration: BoxDecoration(
// // // //             color: Colors.white,
// // // //             borderRadius: BorderRadius.circular(16),
// // // //             border: Border.all(color: const Color(0xFFF0F0F0)),
// // // //           ),
// // // //           child: Column(children: [
// // // //             Row(children: [
// // // //               const Icon(Icons.calendar_today_outlined, size: 18, color: _textDark),
// // // //               const SizedBox(width: 8),
// // // //               const Expanded(child: Text('Rendez-vous récents',
// // // //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark))),
// // // //               TextButton(
// // // //                 onPressed: () {},
// // // //                 child: const Text('Voir tout',
// // // //                   style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600))),
// // // //             ]),
// // // //             const SizedBox(height: 12),
// // // //             const Text('Aucun rendez-vous à venir',
// // // //               style: TextStyle(fontSize: 14, color: _textGrey)),
// // // //           ]),
// // // //         ),
// // // //         const SizedBox(height: 24),
// // // //       ]),
// // // //     );
// // // //   }
// // // // }










