import 'package:flutter/material.dart';
import '../profil_prestataire_screen.dart';

const _bgCream   = Color(0xFFF5EFE6);
const _gold      = Color(0xFFD4A96A);
const _goldLight = Color(0xFFF0E6D3);
const _green     = Color(0xFF4CAF50);
const _textDark  = Color(0xFF2C1810);
const _textMed   = Color(0xFF6B4C35);
const _textGrey  = Color(0xFF9E8878);

const _prestataires = [
  {'nom': '19thSignature',  'ville': 'Saint-Germain-en-Laye', 'km': '2.4 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'type': 'coiffeur',   'tags': ['Braids', 'Locks', 'Coiffure', 'Soins'],         'clients': '120+', 'image': 'assets/images/cf.jpg',   'verified': true},
  {'nom': 'Glam_by_Naomie', 'ville': 'La Défense',            'km': '3.1 km', 'note': 4.8, 'avis': 98,  'dispo': true,  'type': 'maquillage', 'tags': ['Maquillage', 'Glam', 'Mariage', 'Shooting'],    'clients': '98+',  'image': 'assets/images/m.jpg',    'verified': true},
  {'nom': 'Nails_Luxury',   'ville': 'Versailles',            'km': '4.2 km', 'note': 4.9, 'avis': 76,  'dispo': true,  'type': 'manicure',   'tags': ['Manucure', 'Gel', 'Nail Art', 'Extensions'],    'clients': '76+',  'image': 'assets/images/pe.jpg',   'verified': true},
  {'nom': 'Pedicure_Spa',   'ville': 'Paris 15e',             'km': '5.0 km', 'note': 4.7, 'avis': 64,  'dispo': true,  'type': 'manicure',   'tags': ['Pédicure', 'Semi-permanent', 'Soin pieds'],     'clients': '64+',  'image': 'assets/images/pi.jpg',   'verified': false},
  {'nom': 'Ink_Aesthetic',  'ville': 'Paris 11e',             'km': '6.3 km', 'note': 4.9, 'avis': 85,  'dispo': true,  'type': 'coiffeur',   'tags': ['Tatouage', 'Fineline', 'Minimaliste', 'Cover'], 'clients': '85+',  'image': 'assets/images/ta.jpg',   'verified': true},
  {'nom': 'NiniLocks',      'ville': 'Corbeil-Essonnes',      'km': '8.2 km', 'note': 4.9, 'avis': 120, 'dispo': true,  'type': 'coiffeur',   'tags': ['Tresses', 'Locks', 'Twists', 'Vanilles'],       'clients': '120+', 'image': 'assets/images/cf1.jpg',  'verified': true},
  {'nom': 'BarberKing',     'ville': 'Paris 18e',             'km': '3.5 km', 'note': 4.7, 'avis': 88,  'dispo': false, 'type': 'coiffeur',   'tags': ['Coupe homme', 'Barbe', 'Dégradé', 'Contours'], 'clients': '88+',  'image': 'assets/images/ch.jpg',   'verified': true},
  {'nom': 'BeautyByMia',    'ville': 'Versailles',            'km': '12 km',  'note': 4.8, 'avis': 97,  'dispo': true,  'type': 'maquillage', 'tags': ['Maquillage', 'Naturel', 'Soirée', 'Événement'], 'clients': '97+',  'image': 'assets/images/mmm.webp', 'verified': false},
];

const _categories = [
  {'label': 'Coiffure',   'icon': Icons.content_cut,                        'value': 'coiffeur'},
  {'label': 'Maquillage', 'icon': Icons.face_retouching_natural,             'value': 'maquillage'},
  {'label': 'Manucure',   'icon': Icons.back_hand_outlined,                  'value': 'manicure'},
  {'label': 'Pédicure',   'icon': Icons.airline_seat_legroom_extra_outlined, 'value': 'pedicure'},
  {'label': 'Tatouage',   'icon': Icons.draw_outlined,                       'value': 'tatouage'},
  {'label': 'Plus',       'icon': Icons.grid_view_rounded,                   'value': 'plus'},
];

const _filtresRapides = [
  {'label': 'Disponibles aujourd\'hui', 'icon': Icons.access_time_filled},
  {'label': 'À proximité',             'icon': Icons.near_me},
  {'label': 'Femmes',                  'icon': Icons.female},
  {'label': 'Hommes',                  'icon': Icons.male},
];

class ClientRechercheTab extends StatefulWidget {
  const ClientRechercheTab({super.key});

  @override
  State<ClientRechercheTab> createState() => _ClientRechercheTabState();
}

class _ClientRechercheTabState extends State<ClientRechercheTab> {
  final _searchCtrl  = TextEditingController();
  String _recherche  = '';
  String _filtreType = 'tous';
  int    _filtreRapide = 0;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filtered => _prestataires.where((p) {
    final matchSearch = _recherche.isEmpty ||
      (p['nom'] as String).toLowerCase().contains(_recherche.toLowerCase()) ||
      (p['ville'] as String).toLowerCase().contains(_recherche.toLowerCase());
    final matchType = _filtreType == 'tous' || p['type'] == _filtreType;
    return matchSearch && matchType;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final h   = MediaQuery.of(context).size.height;
    final rem = w / 100;

    return Container(
      color: _bgCream,
      child: Column(children: [

        // ── Header ────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 4, rem * 4, rem * 3.5),
          child: Row(children: [

            // Avatar
            Container(
              width: rem * 12, height: rem * 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 2),
                boxShadow: [BoxShadow(
                  color: _gold.withOpacity(0.2), blurRadius: 8)]),
              child: ClipOval(
                child: Image.asset('assets/images/cf.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _goldLight,
                    child: Icon(Icons.person, color: _gold, size: rem * 6))))),
            SizedBox(width: rem * 3),

            // Texte
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Bonjour William ', style: TextStyle(
                  fontSize: rem * 4.2, fontWeight: FontWeight.w800, color: _textDark)),
                Text('👋', style: TextStyle(fontSize: rem * 4)),
              ]),
              Text('Trouvez les meilleurs pros près de chez vous',
                style: TextStyle(fontSize: rem * 2.8, color: _textGrey)),
            ])),

            // Cloche notif
            Stack(children: [
              Container(
                width: rem * 10, height: rem * 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF5F0EA)),
                child: Icon(Icons.notifications_outlined,
                  size: rem * 5.5, color: _textDark)),
              Positioned(top: rem * 0.8, right: rem * 0.8,
                child: Container(
                  width: rem * 2, height: rem * 2,
                  decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle))),
            ]),
          ]),
        ),

        // ── Corps scrollable ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Barre recherche ──────────────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(rem * 4, 0, rem * 4, rem * 4),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      height: rem * 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F4EF),
                        borderRadius: BorderRadius.circular(rem * 8),
                        border: Border.all(color: const Color(0xFFEDE8E0))),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _recherche = v),
                        style: TextStyle(fontSize: rem * 3.4, color: _textDark),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un service, un salon, une ville...',
                          hintStyle: TextStyle(
                            color: _textGrey.withOpacity(0.8),
                            fontSize: rem * 3.2),
                          prefixIcon: Icon(Icons.search_rounded,
                            color: _textGrey, size: rem * 5),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: rem * 3.2)),
                      ),
                    ),
                  ),
                  SizedBox(width: rem * 2.5),

                  // Bouton filtre
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(rem * 3),
                      boxShadow: [BoxShadow(
                        color: _gold.withOpacity(0.4),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                    child: Icon(Icons.tune_rounded,
                      color: Colors.white, size: rem * 5.5)),
                ]),
              ),

              // ── Catégories ───────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(bottom: rem * 4),
                child: SizedBox(
                  height: rem * 22,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: rem * 4),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat    = _categories[i];
                      final active = _filtreType == cat['value'];
                      return GestureDetector(
                        onTap: () => setState(() =>
                          _filtreType = active ? 'tous' : cat['value'] as String),
                        child: Container(
                          width: rem * 18,
                          margin: EdgeInsets.only(right: rem * 3),
                          child: Column(children: [
                            Container(
                              width: rem * 14, height: rem * 14,
                              decoration: BoxDecoration(
                                color: active ? _goldLight : const Color(0xFFF5F0EA),
                                borderRadius: BorderRadius.circular(rem * 4),
                                border: Border.all(
                                  color: active ? _gold : Colors.transparent,
                                  width: 2)),
                              child: Center(child: Icon(
                                cat['icon'] as IconData,
                                size: rem * 6.5,
                                color: active ? _gold : _textMed))),
                            SizedBox(height: rem * 1.5),
                            Text(cat['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: rem * 2.8,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? _gold : _textDark)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: rem * 3),

              // ── Bannière promo ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rem * 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rem * 5),
                  child: SizedBox(
                    height: rem * 42,
                    child: Row(children: [

                      // Texte gauche
                      Expanded(
                        flex: 5,
                        child: Container(
                          color: _goldLight,
                          padding: EdgeInsets.all(rem * 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Réservez votre',
                                style: TextStyle(
                                  fontSize: rem * 3.2,
                                  color: _textMed,
                                  fontWeight: FontWeight.w400)),
                              Text('Prochain look ✨',
                                style: TextStyle(
                                  fontSize: rem * 4.8,
                                  fontWeight: FontWeight.w900,
                                  color: _textDark,
                                  fontStyle: FontStyle.italic,
                                  height: 1.2)),
                              SizedBox(height: rem * 2),
                              Text(
                                'Découvrez des pros passionnés\net réservez en quelques clics.',
                                style: TextStyle(
                                  fontSize: rem * 2.7,
                                  color: _textMed, height: 1.5)),
                              SizedBox(height: rem * 2.5),
                              Row(children: List.generate(3, (i) => Container(
                                width: i == 0 ? rem * 5 : rem * 2,
                                height: rem * 2,
                                margin: EdgeInsets.only(right: rem),
                                decoration: BoxDecoration(
                                  color: i == 0 ? _gold : _gold.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(rem))))),
                            ],
                          ),
                        ),
                      ),

                      // Photos droite
                      Expanded(
                        flex: 4,
                        child: Stack(fit: StackFit.expand, children: [
                          Positioned(right: 0, top: 0, bottom: 0, width: rem * 22,
                            child: Image.asset('assets/images/m.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: _gold))),
                          Positioned(right: rem * 18, top: 0, bottom: 0, width: rem * 18,
                            child: Image.asset('assets/images/pe.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: _goldLight))),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(height: rem * 3.5),

              // ── Filtres rapides ───────────────────────────────────────
              SizedBox(
                height: rem * 10,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: rem * 4),
                  itemCount: _filtresRapides.length + 1,
                  itemBuilder: (_, i) {
                    if (i == _filtresRapides.length) {
                      return Container(
                        width: rem * 10, height: rem * 10,
                        margin: EdgeInsets.only(left: rem * 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFDDD0C0))),
                        child: Icon(Icons.tune_rounded,
                          size: rem * 4.5, color: _textGrey));
                    }
                    final f      = _filtresRapides[i];
                    final active = _filtreRapide == i;
                    return GestureDetector(
                      onTap: () => setState(() => _filtreRapide = i),
                      child: Container(
                        margin: EdgeInsets.only(right: rem * 2),
                        padding: EdgeInsets.symmetric(
                          horizontal: rem * 3, vertical: rem * 1.5),
                        decoration: BoxDecoration(
                          color: active ? _goldLight : Colors.white,
                          borderRadius: BorderRadius.circular(rem * 6),
                          border: Border.all(
                            color: active ? _gold : const Color(0xFFDDD0C0),
                            width: 1.2)),
                        child: Row(children: [
                          Icon(f['icon'] as IconData,
                            size: rem * 3.8,
                            color: active ? _gold : _textGrey),
                          SizedBox(width: rem * 1.5),
                          Text(f['label'] as String,
                            style: TextStyle(
                              fontSize: rem * 2.9,
                              fontWeight: FontWeight.w500,
                              color: active ? _gold : _textGrey)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: rem * 4),

              // ── Titre liste ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rem * 4),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Disponibles aujourd\'hui',
                        style: TextStyle(
                          fontSize: rem * 5,
                          fontWeight: FontWeight.w900,
                          color: _textDark)),
                      SizedBox(width: rem * 2),
                      Text('✨', style: TextStyle(fontSize: rem * 4.5)),
                    ]),
                    Text('Des professionnels disponibles près de chez vous',
                      style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                  ])),
                  TextButton(
                    onPressed: () {},
                    child: Row(children: [
                      Text('Voir tout',
                        style: TextStyle(
                          fontSize: rem * 3.2,
                          color: _gold,
                          fontWeight: FontWeight.w600)),
                      Icon(Icons.chevron_right, size: rem * 4.5, color: _gold),
                    ])),
                ]),
              ),
              SizedBox(height: rem * 3),

              // ── Liste prestataires ────────────────────────────────────
              if (_filtered.isEmpty)
                Center(child: Padding(
                  padding: EdgeInsets.all(rem * 8),
                  child: Text('Aucun prestataire trouvé',
                    style: TextStyle(fontSize: rem * 4, color: _textGrey))))
              else
                ..._filtered.map((data) => _PrestaCard(data: data, rem: rem)),

              SizedBox(height: rem * 6),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Carte prestataire ─────────────────────────────────────────────────────────
class _PrestaCard extends StatelessWidget {
  const _PrestaCard({required this.data, required this.rem});
  final Map<String, dynamic> data;
  final double rem;

  @override
  Widget build(BuildContext context) {
    final dispo    = data['dispo']    as bool;
    final note     = data['note']     as double;
    final avis     = data['avis']     as int;
    final tags     = data['tags']     as List;
    final clients  = data['clients']  as String;
    final verified = data['verified'] as bool;
    final type     = data['type']     as String;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProfilPrestataireScreen(
          nom: data['nom'] as String,
          ville: data['ville'] as String,
          typePresta: type))),
      child: Container(
        margin: EdgeInsets.fromLTRB(rem * 4, 0, rem * 4, rem * 3.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rem * 4.5),
          boxShadow: [BoxShadow(
            color: const Color(0xFF2C1810).withOpacity(0.08),
            blurRadius: 14, offset: const Offset(0, 4))]),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Photo ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(rem * 4.5)),
            child: SizedBox(
              width: rem * 30,
              child: Stack(children: [
                // Image
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(data['image'] as String,
                    fit: BoxFit.cover,
                    height: rem * 48,
                    errorBuilder: (_, __, ___) => Container(
                      height: rem * 48,
                      color: const Color(0xFF3D2B1F),
                      child: Icon(Icons.person,
                        color: Colors.white, size: rem * 12)))),

                // Badge dispo
                Positioned(
                  bottom: rem * 2, left: rem * 1.5,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rem * 2, vertical: rem * 0.8),
                    decoration: BoxDecoration(
                      color: dispo ? _green : Colors.black54,
                      borderRadius: BorderRadius.circular(rem * 4)),
                    child: Text(
                      dispo ? 'Disponible' : 'Indisponible',
                      style: TextStyle(
                        fontSize: rem * 2.4,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)))),
              ]),
            ),
          ),

          // ── Infos ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(rem * 3),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Nom + vérif + cœur
                Row(children: [
                  Expanded(child: Row(children: [
                    Flexible(child: Text(data['nom'] as String,
                      style: TextStyle(
                        fontSize: rem * 3.8,
                        fontWeight: FontWeight.w800,
                        color: _textDark),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (verified) ...[
                      SizedBox(width: rem),
                      Icon(Icons.verified, size: rem * 3.8, color: _gold),
                    ],
                  ])),
                  Icon(Icons.favorite_border, size: rem * 4.5, color: _textGrey),
                ]),
                SizedBox(height: rem * 1.2),

                // Ville + km
                Row(children: [
                  Icon(Icons.location_on_outlined, size: rem * 3.2, color: _textGrey),
                  SizedBox(width: rem),
                  Flexible(child: Text(data['ville'] as String,
                    style: TextStyle(fontSize: rem * 2.8, color: _textGrey),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: rem * 1.5),
                  Text('à ${data['km']}',
                    style: TextStyle(
                      fontSize: rem * 2.8,
                      color: _textGrey,
                      fontWeight: FontWeight.w600)),
                ]),
                SizedBox(height: rem * 1.5),

                // Note étoile
                Row(children: [
                  Icon(Icons.star_rounded,
                    size: rem * 3.8, color: const Color(0xFFFFB800)),
                  SizedBox(width: rem),
                  Text('$note ($avis avis)',
                    style: TextStyle(
                      fontSize: rem * 3,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
                ]),
                SizedBox(height: rem * 2),

                // Tags
                Wrap(
                  spacing: rem * 1.5,
                  runSpacing: rem * 1.2,
                  children: tags.take(4).map((tag) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rem * 2.2, vertical: rem * 0.8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0EA),
                      borderRadius: BorderRadius.circular(rem * 4)),
                    child: Text(tag as String,
                      style: TextStyle(
                        fontSize: rem * 2.5,
                        color: _textDark,
                        fontWeight: FontWeight.w500)))).toList()),
                SizedBox(height: rem * 2),

                // Clients satisfaits
                Row(children: [
                  SizedBox(
                    width: rem * 10, height: rem * 7,
                    child: Stack(children: [
                      Positioned(left: 0,
                        child: CircleAvatar(
                          radius: rem * 3.2,
                          backgroundColor: _goldLight,
                          child: Icon(Icons.person,
                            size: rem * 3, color: _gold))),
                      Positioned(left: rem * 3.5,
                        child: CircleAvatar(
                          radius: rem * 3.2,
                          backgroundColor: const Color(0xFFE8E8E8),
                          child: Icon(Icons.person,
                            size: rem * 3, color: _textGrey))),
                    ]),
                  ),
                  SizedBox(width: rem),
                  Flexible(child: Text('$clients clientes satisfaites',
                    style: TextStyle(fontSize: rem * 2.6, color: _textGrey),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                SizedBox(height: rem * 2.5),

                // ── Bouton Voir le profil ─────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProfilPrestataireScreen(
                      nom: data['nom'] as String,
                      ville: data['ville'] as String,
                      typePresta: type))),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: rem * 2.5),
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(rem * 4),
                      boxShadow: [BoxShadow(
                        color: _gold.withOpacity(0.4),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                    child: Text('Voir le profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rem * 3.2,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3))),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

























































// import 'package:flutter/material.dart';
// import '../profil_prestataire_screen.dart';

// const _bgCream   = Color(0xFFF5EFE6);
// const _gold      = Color(0xFFD4A96A);
// const _goldLight = Color(0xFFF0E6D3);
// const _green     = Color(0xFF4CAF50);
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// const _prestataires = [
//   {
//     'nom': '19thSignature',
//     'ville': 'Saint-Germain-en-Laye',
//     'km': '2.4 km',
//     'note': 4.9,
//     'avis': 120,
//     'dispo': true,
//     'type': 'coiffeur',
//     'tags': ['Braids', 'Locks', 'Coiffure', 'Soins'],
//     'clients': '120+',
//     'image': 'assets/images/cf.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'Glam_by_Naomie',
//     'ville': 'La Défense',
//     'km': '3.1 km',
//     'note': 4.8,
//     'avis': 98,
//     'dispo': true,
//     'type': 'maquillage',
//     'tags': ['Maquillage', 'Glam', 'Mariage', 'Shooting'],
//     'clients': '98+',
//     'image': 'assets/images/m.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'Nails_Luxury',
//     'ville': 'Versailles',
//     'km': '4.2 km',
//     'note': 4.9,
//     'avis': 76,
//     'dispo': true,
//     'type': 'manicure',
//     'tags': ['Manucure', 'Gel', 'Nail Art', 'Extensions'],
//     'clients': '76+',
//     'image': 'assets/images/pe.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'Pedicure_Spa',
//     'ville': 'Paris 15e',
//     'km': '5.0 km',
//     'note': 4.7,
//     'avis': 64,
//     'dispo': true,
//     'type': 'manicure',
//     'tags': ['Pédicure', 'Semi-permanent', 'Soin des pieds'],
//     'clients': '64+',
//     'image': 'assets/images/pi.jpg',
//     'verified': false,
//   },
//   {
//     'nom': 'Ink_Aesthetic',
//     'ville': 'Paris 11e',
//     'km': '6.3 km',
//     'note': 4.9,
//     'avis': 85,
//     'dispo': true,
//     'type': 'coiffeur',
//     'tags': ['Tatouage', 'Fineline', 'Minimaliste', 'Cover'],
//     'clients': '85+',
//     'image': 'assets/images/ta.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'NiniLocks',
//     'ville': 'Corbeil-Essonnes',
//     'km': '8.2 km',
//     'note': 4.9,
//     'avis': 120,
//     'dispo': true,
//     'type': 'coiffeur',
//     'tags': ['Tresses', 'Locks', 'Twists', 'Vanilles'],
//     'clients': '120+',
//     'image': 'assets/images/cf1.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'BarberKing',
//     'ville': 'Paris 18e',
//     'km': '3.5 km',
//     'note': 4.7,
//     'avis': 88,
//     'dispo': false,
//     'type': 'coiffeur',
//     'tags': ['Coupe homme', 'Barbe', 'Dégradé', 'Contours'],
//     'clients': '88+',
//     'image': 'assets/images/ch.jpg',
//     'verified': true,
//   },
//   {
//     'nom': 'BeautyByMia',
//     'ville': 'Versailles',
//     'km': '12 km',
//     'note': 4.8,
//     'avis': 97,
//     'dispo': true,
//     'type': 'maquillage',
//     'tags': ['Maquillage', 'Naturel', 'Soirée', 'Événement'],
//     'clients': '97+',
//     'image': 'assets/images/mmm.webp',
//     'verified': false,
//   },
// ];

// const _categories = [
//   {'label': 'Coiffure',   'emoji': '👩‍🦱', 'value': 'coiffeur'},
//   {'label': 'Maquillage', 'emoji': '👁',   'value': 'maquillage'},
//   {'label': 'Manucure',   'emoji': '💅',   'value': 'manicure'},
//   {'label': 'Pédicure',   'emoji': '🦶',   'value': 'pedicure'},
//   {'label': 'Tatouage',   'emoji': '🖊',   'value': 'tatouage'},
//   {'label': 'Plus',       'emoji': '⚙️',   'value': 'plus'},
// ];

// const _filtresRapides = [
//   {'label': 'Disponibles aujourd\'hui', 'icon': Icons.access_time},
//   {'label': 'À proximité',             'icon': Icons.location_on_outlined},
//   {'label': 'Femmes',                  'icon': Icons.female},
//   {'label': 'Hommes',                  'icon': Icons.male},
// ];

// class ClientRechercheTab extends StatefulWidget {
//   const ClientRechercheTab({super.key});

//   @override
//   State<ClientRechercheTab> createState() => _ClientRechercheTabState();
// }

// class _ClientRechercheTabState extends State<ClientRechercheTab> {
//   final _searchCtrl = TextEditingController();
//   String _recherche  = '';
//   String _filtreType = 'tous';
//   int    _filtreRapide = 0;

//   @override
//   void dispose() { _searchCtrl.dispose(); super.dispose(); }

//   List<Map<String, dynamic>> get _filtered => _prestataires.where((p) {
//     final matchSearch = _recherche.isEmpty ||
//       (p['nom'] as String).toLowerCase().contains(_recherche.toLowerCase()) ||
//       (p['ville'] as String).toLowerCase().contains(_recherche.toLowerCase());
//     final matchType = _filtreType == 'tous' || p['type'] == _filtreType;
//     return matchSearch && matchType;
//   }).toList();

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//     final p = w * 0.045;

//     return Container(
//       color: _bgCream,
//       child: Column(children: [

//         // ── Header ────────────────────────────────────────────────────
//         Container(
//           color: Colors.white,
//           padding: EdgeInsets.fromLTRB(p, h * 0.02, p, h * 0.018),
//           child: Row(children: [

//             // Avatar
//             Container(
//               width: w * 0.12, height: w * 0.12,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _goldLight,
//                 border: Border.all(color: _gold.withOpacity(0.5), width: 2),
//                 image: const DecorationImage(
//                   image: AssetImage('assets/images/cf.jpg'),
//                   fit: BoxFit.cover)),
//             ),
//             SizedBox(width: w * 0.03),

//             // Texte
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [
//                 Text('Bonjour William ', style: TextStyle(
//                   fontSize: w * 0.045, fontWeight: FontWeight.w800, color: _textDark)),
//                 Text('👋', style: TextStyle(fontSize: w * 0.045)),
//               ]),
//               Text('Trouvez les meilleurs pros près de chez vous',
//                 style: TextStyle(fontSize: w * 0.028, color: _textGrey)),
//             ])),

//             // Cloche notif
//             Stack(children: [
//               Container(
//                 width: w * 0.1, height: w * 0.1,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: const Color(0xFFF5F5F5)),
//                 child: Icon(Icons.notifications_outlined, size: w * 0.055, color: _textDark)),
//               Positioned(top: 6, right: 6,
//                 child: Container(width: w * 0.022, height: w * 0.022,
//                   decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
//             ]),
//           ]),
//         ),

//         // ── Corps scrollable ──────────────────────────────────────────
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//               // ── Barre recherche ──────────────────────────────────────
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.fromLTRB(p, 0, p, h * 0.018),
//                 child: Row(children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF8F4EF),
//                         borderRadius: BorderRadius.circular(w * 0.08),
//                         border: Border.all(color: const Color(0xFFEDE8E0))),
//                       child: TextField(
//                         controller: _searchCtrl,
//                         onChanged: (v) => setState(() => _recherche = v),
//                         decoration: InputDecoration(
//                           hintText: 'Rechercher un service, un salon, une ville...',
//                           hintStyle: TextStyle(color: _textGrey.withOpacity(0.7), fontSize: w * 0.032),
//                           prefixIcon: Icon(Icons.search, color: _textGrey, size: w * 0.05),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(vertical: h * 0.015)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: w * 0.02),
//                   // Bouton filtre
//                   Container(
//                     width: w * 0.12, height: w * 0.12,
//                     decoration: BoxDecoration(
//                       color: _gold,
//                       borderRadius: BorderRadius.circular(w * 0.03),
//                       boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]),
//                     child: Icon(Icons.tune, color: Colors.white, size: w * 0.055)),
//                 ]),
//               ),

//               // ── Catégories ───────────────────────────────────────────
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.only(bottom: h * 0.02),
//                 child: SizedBox(
//                   height: h * 0.105,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: EdgeInsets.symmetric(horizontal: p),
//                     itemCount: _categories.length,
//                     itemBuilder: (_, i) {
//                       final cat = _categories[i];
//                       final active = _filtreType == cat['value'];
//                       return GestureDetector(
//                         onTap: () => setState(() =>
//                           _filtreType = active ? 'tous' : cat['value'] as String),
//                         child: Container(
//                           width: w * 0.18,
//                           margin: EdgeInsets.only(right: w * 0.03),
//                           child: Column(children: [
//                             Container(
//                               width: w * 0.14, height: w * 0.14,
//                               decoration: BoxDecoration(
//                                 color: active ? _goldLight : const Color(0xFFF5F0EA),
//                                 borderRadius: BorderRadius.circular(w * 0.04),
//                                 border: Border.all(
//                                   color: active ? _gold : Colors.transparent,
//                                   width: 2)),
//                               child: Center(child: Text(cat['emoji'] as String,
//                                 style: TextStyle(fontSize: w * 0.065)))),
//                             SizedBox(height: h * 0.006),
//                             Text(cat['label'] as String,
//                               style: TextStyle(
//                                 fontSize: w * 0.028,
//                                 fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//                                 color: active ? _gold : _textDark),
//                               textAlign: TextAlign.center),
//                           ]),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),

//               SizedBox(height: h * 0.012),

//               // ── Bannière promo ────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: p),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(w * 0.05),
//                   child: Container(
//                     height: h * 0.17,
//                     decoration: BoxDecoration(
//                       color: _goldLight,
//                       borderRadius: BorderRadius.circular(w * 0.05)),
//                     child: Row(children: [
//                       // Texte gauche
//                       Expanded(
//                         flex: 5,
//                         child: Padding(
//                           padding: EdgeInsets.all(p * 0.8),
//                           child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center, children: [
//                             Text('Réservez votre', style: TextStyle(
//                               fontSize: w * 0.032, color: _textDark.withOpacity(0.7))),
//                             Text('Prochain look ✨', style: TextStyle(
//                               fontSize: w * 0.05, fontWeight: FontWeight.w800,
//                               color: _textDark, fontStyle: FontStyle.italic)),
//                             SizedBox(height: h * 0.008),
//                             Text('Découvrez des pros passionnés\net réservez en quelques clics.',
//                               style: TextStyle(fontSize: w * 0.027, color: _textGrey, height: 1.4)),
//                             SizedBox(height: h * 0.01),
//                             // Points indicateur
//                             Row(children: List.generate(3, (i) => Container(
//                               width: i == 0 ? w * 0.04 : w * 0.018,
//                               height: w * 0.018,
//                               margin: EdgeInsets.only(right: w * 0.01),
//                               decoration: BoxDecoration(
//                                 color: i == 0 ? _gold : _gold.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(10))))),
//                           ]),
//                         ),
//                       ),
//                       // Photos empilées droite
//                       Expanded(
//                         flex: 4,
//                         child: Stack(fit: StackFit.expand, children: [
//                           Positioned(right: 0, top: 0, bottom: 0, width: w * 0.22,
//                             child: Image.asset('assets/images/cf.jpg',
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(color: _gold))),
//                           Positioned(right: w * 0.18, top: 0, bottom: 0, width: w * 0.18,
//                             child: Image.asset('assets/images/pe.jpg',
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(color: _goldLight))),
//                         ]),
//                       ),
//                     ]),
//                   ),
//                 ),
//               ),
//               SizedBox(height: h * 0.016),

//               // ── Filtres rapides ───────────────────────────────────────
//               SizedBox(
//                 height: h * 0.045,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: p),
//                   itemCount: _filtresRapides.length + 1,
//                   itemBuilder: (_, i) {
//                     if (i == _filtresRapides.length) {
//                       return Container(
//                         margin: EdgeInsets.only(left: w * 0.02),
//                         width: w * 0.08, height: w * 0.08,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: const Color(0xFFE0D8D0))),
//                         child: Icon(Icons.tune, size: w * 0.04, color: _textGrey));
//                     }
//                     final f = _filtresRapides[i];
//                     final active = _filtreRapide == i;
//                     return GestureDetector(
//                       onTap: () => setState(() => _filtreRapide = i),
//                       child: Container(
//                         margin: EdgeInsets.only(right: w * 0.02),
//                         padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.006),
//                         decoration: BoxDecoration(
//                           color: active ? _goldLight : Colors.white,
//                           borderRadius: BorderRadius.circular(w * 0.06),
//                           border: Border.all(color: active ? _gold : const Color(0xFFE0D8D0))),
//                         child: Row(children: [
//                           Icon(f['icon'] as IconData, size: w * 0.036,
//                             color: active ? _gold : _textGrey),
//                           SizedBox(width: w * 0.015),
//                           Text(f['label'] as String, style: TextStyle(
//                             fontSize: w * 0.028, fontWeight: FontWeight.w500,
//                             color: active ? _gold : _textGrey)),
//                         ]),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(height: h * 0.018),

//               // ── Titre liste ───────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: p),
//                 child: Row(children: [
//                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       Text('Disponibles aujourd\'hui', style: TextStyle(
//                         fontSize: w * 0.048, fontWeight: FontWeight.w800, color: _textDark)),
//                       SizedBox(width: w * 0.02),
//                       Text('✨', style: TextStyle(fontSize: w * 0.042)),
//                     ]),
//                     Text('Des professionnels disponibles près de chez vous',
//                       style: TextStyle(fontSize: w * 0.03, color: _textGrey)),
//                   ])),
//                   TextButton(
//                     onPressed: () {},
//                     child: Row(children: [
//                       Text('Voir tout', style: TextStyle(
//                         fontSize: w * 0.032, color: _gold, fontWeight: FontWeight.w600)),
//                       Icon(Icons.chevron_right, size: w * 0.04, color: _gold),
//                     ])),
//                 ]),
//               ),
//               SizedBox(height: h * 0.012),

//               // ── Liste prestataires ────────────────────────────────────
//               ...(_filtered.isEmpty
//                 ? [Center(child: Padding(
//                     padding: EdgeInsets.all(p * 2),
//                     child: Text('Aucun prestataire trouvé',
//                       style: TextStyle(fontSize: w * 0.04, color: _textGrey))))]
//                 : _filtered.map((p2) => _PrestaCard(
//                     data: p2,
//                     screenWidth: w,
//                     screenHeight: h,
//                     padding: p,
//                   ))),

//               SizedBox(height: h * 0.03),
//             ]),
//           ),
//         ),
//       ]),
//     );
//   }
// }

// // ── Carte prestataire ─────────────────────────────────────────────────────────
// class _PrestaCard extends StatelessWidget {
//   const _PrestaCard({required this.data, required this.screenWidth,
//     required this.screenHeight, required this.padding});
//   final Map<String, dynamic> data;
//   final double screenWidth, screenHeight, padding;

//   @override
//   Widget build(BuildContext context) {
//     final w    = screenWidth;
//     final h    = screenHeight;
//     final p    = padding;
//     final dispo    = data['dispo'] as bool;
//     final note     = data['note'] as double;
//     final avis     = data['avis'] as int;
//     final tags     = data['tags'] as List;
//     final clients  = data['clients'] as String;
//     final verified = data['verified'] as bool;
//     final type     = data['type'] as String;

//     return GestureDetector(
//       onTap: () => Navigator.push(context, MaterialPageRoute(
//         builder: (_) => ProfilPrestataireScreen(
//           nom: data['nom'] as String,
//           ville: data['ville'] as String,
//           typePresta: type,
//         ),
//       )),
//       child: Container(
//         margin: EdgeInsets.fromLTRB(p, 0, p, h * 0.016),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(w * 0.045),
//           boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))]),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

//           // ── Photo ───────────────────────────────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.horizontal(left: Radius.circular(w * 0.045)),
//             child: Stack(children: [
//               SizedBox(
//                 width: w * 0.3, height: h * 0.17,
//                 child: Image.asset(data['image'] as String,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     color: const Color(0xFF3D2B1F),
//                     child: Icon(Icons.person, color: Colors.white, size: w * 0.1)))),
//               // Badge dispo
//               Positioned(bottom: h * 0.012, left: w * 0.02,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.004),
//                   decoration: BoxDecoration(
//                     color: dispo ? _green : Colors.black54,
//                     borderRadius: BorderRadius.circular(w * 0.05)),
//                   child: Text(dispo ? 'Disponible' : 'Indisponible',
//                     style: TextStyle(fontSize: w * 0.024,
//                       fontWeight: FontWeight.w700, color: Colors.white)))),
//             ]),
//           ),

//           // ── Infos ───────────────────────────────────────────────────
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(w * 0.03, h * 0.014, w * 0.02, h * 0.014),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//                 // Nom + vérif + cœur
//                 Row(children: [
//                   Expanded(child: Row(children: [
//                     Flexible(child: Text(data['nom'] as String,
//                       style: TextStyle(fontSize: w * 0.038,
//                         fontWeight: FontWeight.w800, color: _textDark),
//                       maxLines: 1, overflow: TextOverflow.ellipsis)),
//                     if (verified) ...[
//                       SizedBox(width: w * 0.01),
//                       Icon(Icons.verified, size: w * 0.038, color: _gold),
//                     ],
//                   ])),
//                   Icon(Icons.favorite_border, size: w * 0.045, color: _textGrey),
//                 ]),
//                 SizedBox(height: h * 0.004),

//                 // Ville + km
//                 Row(children: [
//                   Icon(Icons.location_on_outlined, size: w * 0.032, color: _textGrey),
//                   SizedBox(width: w * 0.008),
//                   Text(data['ville'] as String,
//                     style: TextStyle(fontSize: w * 0.028, color: _textGrey)),
//                   SizedBox(width: w * 0.015),
//                   Text('à ${data['km']}',
//                     style: TextStyle(fontSize: w * 0.028,
//                       color: _textGrey, fontWeight: FontWeight.w600)),
//                 ]),
//                 SizedBox(height: h * 0.006),

//                 // Note
//                 Row(children: [
//                   Icon(Icons.star_rounded, size: w * 0.038, color: const Color(0xFFFFB800)),
//                   SizedBox(width: w * 0.008),
//                   Text('$note ($avis avis)',
//                     style: TextStyle(fontSize: w * 0.03,
//                       fontWeight: FontWeight.w600, color: _textDark)),
//                 ]),
//                 SizedBox(height: h * 0.008),

//                 // Tags
//                 Wrap(spacing: w * 0.015, runSpacing: h * 0.005,
//                   children: tags.take(4).map((tag) => Container(
//                     padding: EdgeInsets.symmetric(horizontal: w * 0.022, vertical: h * 0.004),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5F0EA),
//                       borderRadius: BorderRadius.circular(w * 0.05)),
//                     child: Text(tag as String,
//                       style: TextStyle(fontSize: w * 0.025, color: _textDark,
//                         fontWeight: FontWeight.w500)),
//                   )).toList()),
//                 SizedBox(height: h * 0.008),

//                 // Clients + bouton
//                 Row(children: [
//                   // Avatars clients
//                   SizedBox(
//                     width: w * 0.1, height: w * 0.065,
//                     child: Stack(children: [
//                       Positioned(left: 0, child: CircleAvatar(radius: w * 0.032,
//                         backgroundColor: _goldLight,
//                         child: Icon(Icons.person, size: w * 0.03, color: _gold))),
//                       Positioned(left: w * 0.032, child: CircleAvatar(radius: w * 0.032,
//                         backgroundColor: const Color(0xFFE8E8E8),
//                         child: Icon(Icons.person, size: w * 0.03, color: _textGrey))),
//                     ]),
//                   ),
//                   SizedBox(width: w * 0.01),
//                   Text('$clients clientes satisfaites',
//                     style: TextStyle(fontSize: w * 0.026, color: _textGrey)),
//                   const Spacer(),

//                   // Bouton voir profil
//                   GestureDetector(
//                     onTap: () => Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => ProfilPrestataireScreen(
//                         nom: data['nom'] as String,
//                         ville: data['ville'] as String,
//                         typePresta: type,
//                       ),
//                     )),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.008),
//                       decoration: BoxDecoration(
//                         color: _gold,
//                         borderRadius: BorderRadius.circular(w * 0.05),
//                         boxShadow: [BoxShadow(color: _gold.withOpacity(0.35),
//                           blurRadius: 6, offset: const Offset(0, 3))]),
//                       child: Text('Voir le profil',
//                         style: TextStyle(fontSize: w * 0.028,
//                           fontWeight: FontWeight.w700, color: Colors.white))),
//                   ),
//                 ]),
//               ]),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }


















































































// // import 'package:flutter/material.dart';
// // import '../profil_prestataire_screen.dart';

// // const _green      = Color(0xFF2D7A4F);
// // const _greenLight = Color(0xFFE8F5EE);
// // const _textDark   = Color(0xFF1A1A1A);
// // const _textGrey   = Color(0xFF8E8E93);

// // const _prestataires = [
// //   {
// //     'nom': '19thSignature',
// //     'ville': 'Saint-Germain-en-Laye',
// //     'lieu': 'En salon',
// //     'dispo': true,
// //     'type': 'coiffeur',
// //     'specialite': 'Coiffure afro & tresses',
// //   },
// //   {
// //     'nom': 'Afro_beauty',
// //     'ville': 'Louvres',
// //     'lieu': 'Domicile & salon',
// //     'dispo': true,
// //     'type': 'maquillage',
// //     'specialite': 'Maquillage & soins visage',
// //   },
// //   {
// //     'nom': 'Ashy.hair',
// //     'ville': 'Cergy',
// //     'lieu': 'Domicile & salon',
// //     'dispo': true,
// //     'type': 'coiffeur',
// //     'specialite': 'Twists & vanilles',
// //   },
// //   {
// //     'nom': 'NiniLocks',
// //     'ville': 'Corbeil-Essonnes',
// //     'lieu': 'À domicile',
// //     'dispo': false,
// //     'type': 'coiffeur',
// //     'specialite': 'Locks & dreadlocks',
// //   },
// //   {
// //     'nom': 'Beauty_Nails',
// //     'ville': 'Paris',
// //     'lieu': 'En salon',
// //     'dispo': true,
// //     'type': 'manicure',
// //     'specialite': 'Manucure & nail art',
// //   },
// //   {
// //     'nom': 'GlamMakeup',
// //     'ville': 'Versailles',
// //     'lieu': 'Domicile & salon',
// //     'dispo': true,
// //     'type': 'maquillage',
// //     'specialite': 'Maquillage événementiel',
// //   },
// //   {
// //     'nom': 'Hairstylebymm',
// //     'ville': 'Villepinte',
// //     'lieu': 'En salon',
// //     'dispo': true,
// //     'type': 'coiffeur',
// //     'specialite': 'Coiffure afro',
// //   },
// //   {
// //     'nom': 'PetiPied',
// //     'ville': 'Montreuil',
// //     'lieu': 'En salon',
// //     'dispo': false,
// //     'type': 'manicure',
// //     'specialite': 'Pédicure & soins pieds',
// //   },
// // ];

// // // Icône selon le type
// // IconData _iconForType(String type) {
// //   switch (type) {
// //     case 'maquillage': return Icons.brush;
// //     case 'manicure':   return Icons.back_hand_outlined;
// //     default:           return Icons.content_cut;
// //   }
// // }

// // // Label selon le type
// // String _labelForType(String type) {
// //   switch (type) {
// //     case 'maquillage': return 'Maquilleur(se)';
// //     case 'manicure':   return 'Manucure / Pédicure';
// //     default:           return 'Coiffeur(se)';
// //   }
// // }

// // class ClientRechercheTab extends StatefulWidget {
// //   const ClientRechercheTab({super.key});

// //   @override
// //   State<ClientRechercheTab> createState() => _ClientRechercheTabState();
// // }

// // class _ClientRechercheTabState extends State<ClientRechercheTab> {
// //   final _searchCtrl = TextEditingController();
// //   String _filtreType = 'tous'; // 'tous', 'coiffeur', 'maquillage', 'manicure'
// //   String _recherche  = '';

// //   @override
// //   void dispose() {
// //     _searchCtrl.dispose();
// //     super.dispose();
// //   }

// //   List<Map<String, dynamic>> get _filtered {
// //     return _prestataires.where((p) {
// //       final matchType = _filtreType == 'tous' || p['type'] == _filtreType;
// //       final matchSearch = _recherche.isEmpty ||
// //         (p['nom'] as String).toLowerCase().contains(_recherche.toLowerCase()) ||
// //         (p['ville'] as String).toLowerCase().contains(_recherche.toLowerCase());
// //       return matchType && matchSearch;
// //     }).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(children: [

// //       // ── Carte profil ──────────────────────────────────────────────
// //       Padding(
// //         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(color: const Color(0xFFF0F0F0))),
// //           child: Row(children: [
// //             Container(width: 48, height: 48,
// //               decoration: const BoxDecoration(shape: BoxShape.circle, color: _greenLight),
// //               child: const Icon(Icons.person, color: _green, size: 28)),
// //             const SizedBox(width: 12),
// //             const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //               Text('Bonjour william !',
// //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //               Text('Espace client',
// //                 style: TextStyle(fontSize: 13, color: _textGrey)),
// //             ])),
// //             Container(width: 36, height: 36,
// //               decoration: BoxDecoration(shape: BoxShape.circle,
// //                 border: Border.all(color: const Color(0xFFE0E0E0))),
// //               child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
// //           ]),
// //         ),
// //       ),
// //       const SizedBox(height: 12),

// //       // ── Barre recherche ───────────────────────────────────────────
// //       Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         child: Row(children: [
// //           Expanded(
// //             child: TextField(
// //               controller: _searchCtrl,
// //               onChanged: (v) => setState(() => _recherche = v),
// //               decoration: InputDecoration(
// //                 hintText: 'Rechercher ville...',
// //                 hintStyle: const TextStyle(color: _green, fontSize: 14),
// //                 prefixIcon: const Icon(Icons.search, color: _green, size: 20),
// //                 filled: true, fillColor: Colors.white,
// //                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
// //                   borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
// //                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
// //                   borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
// //                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
// //                   borderSide: const BorderSide(color: _green, width: 1.5)),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           _FilterBtn(icon: Icons.location_on_outlined, onTap: () {}),
// //           const SizedBox(width: 8),
// //           _FilterBtn(icon: Icons.tune_outlined, onTap: () {
// //             // Filtre par type
// //             showModalBottomSheet(
// //               context: context,
// //               shape: const RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
// //               builder: (_) => _FiltreSheet(
// //                 current: _filtreType,
// //                 onSelect: (v) => setState(() => _filtreType = v),
// //               ),
// //             );
// //           }),
// //           const SizedBox(width: 8),
// //           _FilterBtnDot(icon: Icons.filter_list, onTap: () {}),
// //         ]),
// //       ),
// //       const SizedBox(height: 8),

// //       // ── Chips filtres type ────────────────────────────────────────
// //       SizedBox(
// //         height: 38,
// //         child: ListView(
// //           scrollDirection: Axis.horizontal,
// //           padding: const EdgeInsets.symmetric(horizontal: 16),
// //           children: [
// //             _TypeChip(label: 'Tous',               value: 'tous',       current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
// //             _TypeChip(label: '✂️ Coiffeur(se)',     value: 'coiffeur',   current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
// //             _TypeChip(label: '💄 Maquilleur(se)',   value: 'maquillage', current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
// //             _TypeChip(label: '💅 Manucure/Pédicure',value: 'manicure',   current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
// //           ],
// //         ),
// //       ),
// //       const SizedBox(height: 8),

// //       // ── Liste prestataires ────────────────────────────────────────
// //       Expanded(
// //         child: _filtered.isEmpty
// //           ? const Center(
// //               child: Text('Aucun prestataire trouvé',
// //                 style: TextStyle(fontSize: 15, color: _textGrey)))
// //           : ListView.separated(
// //               padding: const EdgeInsets.symmetric(horizontal: 16),
// //               itemCount: _filtered.length,
// //               separatorBuilder: (_, __) => const SizedBox(height: 12),
// //               itemBuilder: (_, i) {
// //                 final p = _filtered[i];
// //                 final dispo    = p['dispo']  as bool;
// //                 final type     = p['type']   as String;
// //                 final specialite = p['specialite'] as String;

// //                 return Container(
// //                   padding: const EdgeInsets.all(14),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(16),
// //                     border: Border.all(color: const Color(0xFFF0F0F0)),
// //                     boxShadow: const [BoxShadow(
// //                       color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
// //                   ),
// //                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                     Row(children: [

// //                       // Avatar avec icône selon type
// //                       Container(
// //                         width: 52, height: 52,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           color: _greenLight,
// //                           border: Border.all(color: _green.withOpacity(0.3))),
// //                         child: Icon(_iconForType(type), color: _green, size: 26)),
// //                       const SizedBox(width: 12),

// //                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                         Text(p['nom'] as String,
// //                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //                         const SizedBox(height: 2),

// //                         // Badge type
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                           decoration: BoxDecoration(
// //                             color: _greenLight,
// //                             borderRadius: BorderRadius.circular(50)),
// //                           child: Text(_labelForType(type),
// //                             style: const TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600))),
// //                         const SizedBox(height: 4),

// //                         Row(children: [
// //                           const Icon(Icons.location_on_outlined, size: 14, color: _textGrey),
// //                           const SizedBox(width: 4),
// //                           Text(p['ville'] as String,
// //                             style: const TextStyle(fontSize: 13, color: _textGrey)),
// //                         ]),
// //                         const SizedBox(height: 2),
// //                         Row(children: [
// //                           const Icon(Icons.access_time, size: 14, color: _textGrey),
// //                           const SizedBox(width: 4),
// //                           Text(p['lieu'] as String,
// //                             style: const TextStyle(fontSize: 13, color: _textGrey)),
// //                         ]),
// //                         const SizedBox(height: 2),
// //                         const Row(children: [
// //                           Icon(Icons.lock_outline, size: 14, color: _textGrey),
// //                           SizedBox(width: 4),
// //                           Text('Contact réservé aux clients',
// //                             style: TextStyle(fontSize: 13, color: _textGrey)),
// //                         ]),
// //                       ])),

// //                       // Badge dispo
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                         decoration: BoxDecoration(
// //                           color: dispo ? _green.withOpacity(0.1) : const Color(0xFFF2F2F7),
// //                           borderRadius: BorderRadius.circular(50),
// //                           border: Border.all(color: dispo ? _green : const Color(0xFFE0E0E0))),
// //                         child: Text(dispo ? 'Disponible' : 'Indisponible',
// //                           style: TextStyle(
// //                             fontSize: 12, fontWeight: FontWeight.w600,
// //                             color: dispo ? _green : _textGrey)),
// //                       ),
// //                     ]),
// //                     const SizedBox(height: 10),

// //                     // Spécialité
// //                     Text(specialite,
// //                       style: const TextStyle(fontSize: 12, color: _textGrey, fontStyle: FontStyle.italic)),
// //                     const SizedBox(height: 10),

// //                     Row(children: [
// //                       Expanded(
// //                         child: ElevatedButton(
// //                           onPressed: () => Navigator.push(context, MaterialPageRoute(
// //                             builder: (_) => ProfilPrestataireScreen(
// //                               nom: p['nom'] as String,
// //                               ville: p['ville'] as String,
// //                               typePresta: type,
// //                             ),
// //                           )),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: _green,
// //                             foregroundColor: Colors.white,
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //                             elevation: 0,
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                           ),
// //                           child: const Text('Voir profil',
// //                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Container(
// //                         width: 44, height: 44,
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           border: Border.all(color: const Color(0xFFE0E0E0))),
// //                         child: const Icon(Icons.calendar_today_outlined, size: 20, color: _textDark)),
// //                     ]),
// //                   ]),
// //                 );
// //               },
// //             ),
// //       ),
// //       const SizedBox(height: 8),
// //     ]);
// //   }
// // }

// // // ── Chip filtre type ──────────────────────────────────────────────────────────
// // class _TypeChip extends StatelessWidget {
// //   const _TypeChip({required this.label, required this.value, required this.current, required this.onTap});
// //   final String label, value, current; final ValueChanged<String> onTap;

// //   @override
// //   Widget build(BuildContext context) {
// //     final active = current == value;
// //     return GestureDetector(
// //       onTap: () => onTap(value),
// //       child: Container(
// //         margin: const EdgeInsets.only(right: 8),
// //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
// //         decoration: BoxDecoration(
// //           color: active ? _green : Colors.white,
// //           borderRadius: BorderRadius.circular(50),
// //           border: Border.all(color: active ? _green : const Color(0xFFE0E0E0))),
// //         child: Text(label, style: TextStyle(
// //           fontSize: 12, fontWeight: FontWeight.w600,
// //           color: active ? Colors.white : _textGrey)),
// //       ),
// //     );
// //   }
// // }

// // // ── Sheet filtre ──────────────────────────────────────────────────────────────
// // class _FiltreSheet extends StatelessWidget {
// //   const _FiltreSheet({required this.current, required this.onSelect});
// //   final String current; final ValueChanged<String> onSelect;

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: const EdgeInsets.all(20),
// //     child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       const Text('Filtrer par type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
// //       const SizedBox(height: 16),
// //       _FiltreItem(label: 'Tous les prestataires', value: 'tous',       current: current, onSelect: onSelect, context: context),
// //       _FiltreItem(label: '✂️ Coiffeur(se)',        value: 'coiffeur',   current: current, onSelect: onSelect, context: context),
// //       _FiltreItem(label: '💄 Maquilleur(se)',      value: 'maquillage', current: current, onSelect: onSelect, context: context),
// //       _FiltreItem(label: '💅 Manucure / Pédicure', value: 'manicure',   current: current, onSelect: onSelect, context: context),
// //       const SizedBox(height: 8),
// //     ]),
// //   );
// // }

// // Widget _FiltreItem({
// //   required String label, required String value,
// //   required String current, required ValueChanged<String> onSelect,
// //   required BuildContext context,
// // }) {
// //   final active = current == value;
// //   return GestureDetector(
// //     onTap: () { onSelect(value); Navigator.pop(context); },
// //     child: Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //       decoration: BoxDecoration(
// //         color: active ? _greenLight : Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: active ? _green : const Color(0xFFE0E0E0))),
// //       child: Row(children: [
// //         Expanded(child: Text(label, style: TextStyle(
// //           fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
// //           color: active ? _green : _textDark))),
// //         if (active) const Icon(Icons.check, color: _green, size: 18),
// //       ]),
// //     ),
// //   );
// // }

// // // ── Boutons filtres ───────────────────────────────────────────────────────────
// // class _FilterBtn extends StatelessWidget {
// //   const _FilterBtn({required this.icon, required this.onTap});
// //   final IconData icon; final VoidCallback onTap;

// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       width: 44, height: 44,
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle, color: Colors.white,
// //         border: Border.all(color: const Color(0xFFE0E0E0))),
// //       child: Icon(icon, size: 20, color: _textDark)),
// //   );
// // }

// // class _FilterBtnDot extends StatelessWidget {
// //   const _FilterBtnDot({required this.icon, required this.onTap});
// //   final IconData icon; final VoidCallback onTap;

// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Stack(children: [
// //       Container(
// //         width: 44, height: 44,
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle, color: Colors.white,
// //           border: Border.all(color: const Color(0xFFE0E0E0))),
// //         child: Icon(icon, size: 20, color: _textDark)),
// //       Positioned(top: 6, right: 6,
// //         child: Container(width: 8, height: 8,
// //           decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))),
// //     ]),
// //   );
// // }













































