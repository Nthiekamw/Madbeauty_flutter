
import 'package:flutter/material.dart';
import 'step_date_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

// ── Services par type de prestataire ──────────────────────────────────────────
const _servicesByType = {
  'coiffeur': [
    {'categorie': 'Tresses / Braids', 'count': 3, 'icon': Icons.content_cut, 'prestations': [
      {'nom': 'Stitch Braids', 'prix': 35, 'duree': '1h'},
      {'nom': 'Fulani Braids', 'prix': 40, 'duree': '1h'},
      {'nom': 'Cornrows',      'prix': 30, 'duree': '1h'},
    ]},
    {'categorie': 'Twists', 'count': 5, 'icon': Icons.content_cut, 'prestations': [
      {'nom': 'Flat Twists',        'prix': 40,  'duree': '1h'},
      {'nom': 'Départ Locks Twist', 'prix': 100, 'duree': '3h'},
      {'nom': 'Barrel Twists',      'prix': 50,  'duree': '1h'},
      {'nom': 'Reprise Twist',      'prix': 60,  'duree': '1h'},
      {'nom': 'Two Strand Twists',  'prix': 50,  'duree': '1h'},
    ]},
    {'categorie': 'Vanilles', 'count': 6, 'icon': Icons.content_cut, 'prestations': [
      {'nom': 'Vanilles Fines',        'prix': 60, 'duree': '1h'},
      {'nom': 'Vanilles Épaisses',     'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Courtes',      'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Sans Mèches',  'prix': 40, 'duree': '1h'},
      {'nom': 'Vanilles Avec Mèches',  'prix': 50, 'duree': '1h'},
      {'nom': 'Vanilles Simples',      'prix': 40, 'duree': '1h'},
    ]},
    {'categorie': 'Locks / Dreadlocks', 'count': 2, 'icon': Icons.content_cut, 'prestations': [
      {'nom': 'Retwist',      'prix': 50,  'duree': '1h'},
      {'nom': 'Départ Locks', 'prix': 100, 'duree': '1h'},
    ]},
    {'categorie': 'Barbe & Soins Visage', 'count': 3, 'icon': Icons.face, 'prestations': [
      {'nom': 'Contours Barbe', 'prix': 10, 'duree': '30min'},
      {'nom': 'Dégradé Barbe',  'prix': 10, 'duree': '30min'},
      {'nom': 'Taille Barbe',   'prix': 10, 'duree': '30min'},
    ]},
    {'categorie': 'Coupes & Contours', 'count': 8, 'icon': Icons.content_cut, 'prestations': [
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
    {'categorie': 'Maquillage Jour', 'count': 3, 'icon': Icons.brush, 'prestations': [
      {'nom': 'Maquillage naturel',  'prix': 40, 'duree': '45min'},
      {'nom': 'Maquillage bureau',   'prix': 45, 'duree': '45min'},
      {'nom': 'Maquillage étudiant', 'prix': 35, 'duree': '30min'},
    ]},
    {'categorie': 'Maquillage Soirée', 'count': 4, 'icon': Icons.brush, 'prestations': [
      {'nom': 'Maquillage soirée',  'prix': 60, 'duree': '1h'},
      {'nom': 'Maquillage glamour', 'prix': 70, 'duree': '1h'},
      {'nom': 'Maquillage smoky',   'prix': 65, 'duree': '1h'},
      {'nom': 'Maquillage scène',   'prix': 80, 'duree': '1h30'},
    ]},
    {'categorie': 'Maquillage Événement', 'count': 4, 'icon': Icons.star_outline, 'prestations': [
      {'nom': 'Maquillage mariée',     'prix': 120, 'duree': '2h'},
      {'nom': 'Maquillage cérémonie',  'prix': 80,  'duree': '1h30'},
      {'nom': 'Maquillage EVJF',       'prix': 60,  'duree': '1h'},
      {'nom': 'Maquillage shooting',   'prix': 90,  'duree': '1h30'},
    ]},
    {'categorie': 'Soins Visage', 'count': 3, 'icon': Icons.face, 'prestations': [
      {'nom': 'Soin hydratant',    'prix': 45, 'duree': '45min'},
      {'nom': 'Nettoyage de peau', 'prix': 50, 'duree': '1h'},
      {'nom': 'Soin anti-taches',  'prix': 55, 'duree': '1h'},
    ]},
    {'categorie': 'Sourcils & Cils', 'count': 4, 'icon': Icons.remove_red_eye_outlined, 'prestations': [
      {'nom': 'Épilation sourcils',       'prix': 15, 'duree': '20min'},
      {'nom': 'Restructuration sourcils', 'prix': 25, 'duree': '30min'},
      {'nom': 'Pose cils classiques',     'prix': 60, 'duree': '1h30'},
      {'nom': 'Pose cils volume',         'prix': 80, 'duree': '2h'},
    ]},
  ],
  'manicure': [
    {'categorie': 'Manucure', 'count': 4, 'icon': Icons.back_hand_outlined, 'prestations': [
      {'nom': 'Manucure simple',        'prix': 25, 'duree': '45min'},
      {'nom': 'Manucure semi-permanent','prix': 35, 'duree': '1h'},
      {'nom': 'Manucure gel',           'prix': 40, 'duree': '1h'},
      {'nom': 'Manucure french',        'prix': 35, 'duree': '1h'},
    ]},
    {'categorie': 'Nail Art', 'count': 4, 'icon': Icons.palette_outlined, 'prestations': [
      {'nom': 'Nail art simple',        'prix': 45, 'duree': '1h'},
      {'nom': 'Nail art dégradé',       'prix': 55, 'duree': '1h30'},
      {'nom': 'Nail art 3D',            'prix': 70, 'duree': '2h'},
      {'nom': 'Nail art personnalisé',  'prix': 65, 'duree': '1h30'},
    ]},
    {'categorie': 'Extensions Ongles', 'count': 3, 'icon': Icons.back_hand_outlined, 'prestations': [
      {'nom': 'Pose capsules',          'prix': 50, 'duree': '1h30'},
      {'nom': 'Pose gel',               'prix': 55, 'duree': '1h30'},
      {'nom': 'Rallongement acrylique', 'prix': 60, 'duree': '2h'},
    ]},
    {'categorie': 'Pédicure', 'count': 3, 'icon': Icons.back_hand_outlined, 'prestations': [
      {'nom': 'Pédicure simple',        'prix': 30, 'duree': '45min'},
      {'nom': 'Pédicure semi-permanent','prix': 40, 'duree': '1h'},
      {'nom': 'Pédicure beauté',        'prix': 45, 'duree': '1h'},
    ]},
    {'categorie': 'Soins Mains & Pieds', 'count': 3, 'icon': Icons.spa_outlined, 'prestations': [
      {'nom': 'Soin hydratant mains', 'prix': 20, 'duree': '30min'},
      {'nom': 'Gommage mains',        'prix': 25, 'duree': '30min'},
      {'nom': 'Bain de pieds',        'prix': 20, 'duree': '30min'},
    ]},
  ],
};

// Icône selon le type de prestataire
IconData _iconForType(String type) {
  switch (type) {
    case 'maquillage': return Icons.brush;
    case 'manicure':   return Icons.back_hand_outlined;
    default:           return Icons.content_cut;
  }
}

class ReservationScreen extends StatefulWidget {
  final String nomPresta;
  final String service;
  final String typePresta; // 'coiffeur', 'maquillage', 'manicure'
  final int prix;
  final String duree;

  const ReservationScreen({
    super.key,
    required this.nomPresta,
    required this.service,
    required this.prix,
    required this.duree,
    this.typePresta = 'coiffeur',
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _step = 1;
  String? _selectedService;
  int _selectedPrix = 0;
  String _selectedDuree = '';
  final Set<int> _expandedCats = {0};

  // Services selon le type de prestataire
  List<Map<String, dynamic>> get _services =>
    List<Map<String, dynamic>>.from(
      _servicesByType[widget.typePresta] ?? _servicesByType['coiffeur']!);

  @override
  void initState() {
    super.initState();
    if (widget.prix > 0) {
      _selectedService = widget.service;
      _selectedPrix    = widget.prix;
      _selectedDuree   = widget.duree;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [

          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: _textDark)),
              const SizedBox(width: 10),
              Container(width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
                child: Icon(_iconForType(widget.typePresta), color: _green, size: 20)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Réservation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                Text(widget.nomPresta,
                  style: const TextStyle(fontSize: 12, color: _textGrey)),
              ]),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [

                // ── Carte prestataire ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight,
                        border: Border.all(color: _green.withOpacity(0.4), width: 3)),
                      child: Icon(_iconForType(widget.typePresta), color: _green, size: 38))),
                    const SizedBox(height: 12),
                    Text(widget.nomPresta,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                    const SizedBox(height: 8),
                    const _InfoRow(icon: Icons.location_on_outlined, text: 'Saint-Germain-en-Laye'),
                    const _InfoRow(icon: Icons.lock_outline,         text: 'Contact réservé aux clients'),
                    const _InfoRow(icon: Icons.lock_outline,         text: 'Email réservé aux clients'),
                    const SizedBox(height: 8),
                    const Text(
                      'Je suis une professionnelle passionnée qui aime sublimer mes clients !',
                      style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Stepper ────────────────────────────────────────────
                _Stepper(currentStep: _step),
                const SizedBox(height: 20),

                // ── Étape 1 : Choisir service ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Choisissez votre service',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                    Text('Chez ${widget.nomPresta}',
                      style: const TextStyle(fontSize: 14, color: _textGrey)),
                    const SizedBox(height: 16),

                    ..._services.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      final expanded = _expandedCats.contains(i);
                      final prestations = s['prestations'] as List;
                      final catIcon = s['icon'] as IconData? ?? _iconForType(widget.typePresta);

                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            if (expanded) _expandedCats.remove(i);
                            else _expandedCats.add(i);
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(children: [
                              Container(width: 40, height: 40,
                                decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
                                child: Icon(catIcon, color: _green, size: 20)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(s['categorie'] as String,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(50)),
                                child: Text('${s['count']} prestations',
                                  style: const TextStyle(fontSize: 11, color: _textGrey))),
                              const SizedBox(width: 6),
                              Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: _textGrey),
                            ]),
                          ),
                        ),

                        if (expanded)
                          ...prestations.map((p) {
                            final key = '${s['categorie']} – ${p['nom']}';
                            final sel = _selectedService == key;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedService = key;
                                _selectedPrix    = p['prix'] as int;
                                _selectedDuree   = p['duree'] as String;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: sel ? _greenLight : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel ? _green : const Color(0xFFE8E8E8),
                                    width: sel ? 2 : 1)),
                                child: Row(children: [
                                  const SizedBox(width: 50),
                                  Expanded(child: Text(p['nom'] as String,
                                    style: TextStyle(fontSize: 14, color: _textDark,
                                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400))),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text('${p['prix']}€',
                                      style: const TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.w700, color: _green)),
                                    Row(children: [
                                      const Icon(Icons.access_time, size: 12, color: _textGrey),
                                      const SizedBox(width: 2),
                                      Text(p['duree'] as String,
                                        style: const TextStyle(fontSize: 12, color: _textGrey)),
                                    ]),
                                  ]),
                                ]),
                              ),
                            );
                          }),

                        const Divider(height: 1),
                      ]);
                    }),
                  ]),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),

          // ── Bouton continuer ──────────────────────────────────────────
          if (_selectedService != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StepDateScreen(
                    nomPresta: widget.nomPresta,
                    service: _selectedService!,
                    prix: _selectedPrix,
                    duree: _selectedDuree,
                  ),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('Continuer',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
      ),
    );
  }
}

// ─── WIDGETS ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: _textGrey),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: _textGrey))),
    ]),
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _StepCircle(num: 1, done: currentStep > 1, active: currentStep == 1),
        _StepLine(done: currentStep > 1),
        _StepCircle(num: 2, done: currentStep > 2, active: currentStep == 2),
        _StepLine(done: currentStep > 2),
        _StepCircle(num: 3, done: currentStep > 3, active: currentStep == 3),
        _StepLine(done: currentStep > 3),
        _StepCircle(num: 4, done: currentStep > 4, active: currentStep == 4),
      ]),
      const SizedBox(height: 8),
      Text(
        currentStep == 1 ? 'Choisissez votre service'
          : currentStep == 2 ? 'Sélectionnez un créneau'
          : currentStep == 3 ? 'Informations sur vos cheveux'
          : 'Récapitulatif',
        style: const TextStyle(fontSize: 13, color: _textGrey)),
    ]);
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.num, required this.done, required this.active});
  final int num; final bool done, active;
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: (done || active) ? _green : const Color(0xFFF2F2F7)),
    child: done
      ? const Icon(Icons.check, color: Colors.white, size: 18)
      : Center(child: Text('$num', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: active ? Colors.white : _textGrey))),
  );
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.done});
  final bool done;
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 2,
    color: done ? _green : const Color(0xFFE0E0E0));
}































































// import 'package:flutter/material.dart';
// import 'step_date_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// const _servicesDispos = [
//   {'categorie': 'Tresses / Braids', 'count': 3, 'prestations': [
//     {'nom': 'Stitch Braids', 'prix': 35, 'duree': '1h'},
//     {'nom': 'Fulani Braids', 'prix': 40, 'duree': '1h'},
//     {'nom': 'Cornrows',      'prix': 30, 'duree': '1h'},
//   ]},
//   {'categorie': 'Twists', 'count': 5, 'prestations': [
//     {'nom': 'Flat Twists',        'prix': 40,  'duree': '1h'},
//     {'nom': 'Départ Locks Twist', 'prix': 100, 'duree': '3h'},
//     {'nom': 'Barrel Twists',      'prix': 50,  'duree': '1h'},
//     {'nom': 'Reprise Twist',      'prix': 60,  'duree': '1h'},
//     {'nom': 'Two Strand Twists',  'prix': 50,  'duree': '1h'},
//   ]},
//   {'categorie': 'Coupes & Contours', 'count': 8, 'prestations': [
//     {'nom': 'Contours', 'prix': 10, 'duree': '1h'},
//     {'nom': 'Burst Fade', 'prix': 20, 'duree': '1h'},
//   ]},
// ];

// class ReservationScreen extends StatefulWidget {
//   final String nomPresta;
//   final String service;
//   final int prix;
//   final String duree;

//   const ReservationScreen({
//     super.key,
//     required this.nomPresta,
//     required this.service,
//     required this.prix,
//     required this.duree,
//   });

//   @override
//   State<ReservationScreen> createState() => _ReservationScreenState();
// }

// class _ReservationScreenState extends State<ReservationScreen> {
//   int _step = 1;
//   String? _selectedService;
//   int _selectedPrix = 0;
//   String _selectedDuree = '';
//   final Set<int> _expandedCats = {0};

//   @override
//   void initState() {
//     super.initState();
//     if (widget.prix > 0) {
//       _selectedService = widget.service;
//       _selectedPrix    = widget.prix;
//       _selectedDuree   = widget.duree;
//       _step = 1;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(children: [

//           // ── Header ───────────────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
//             child: Row(children: [
//               GestureDetector(onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.arrow_back, color: _textDark)),
//               const SizedBox(width: 10),
//               Container(width: 36, height: 36,
//                 decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
//                 child: const Icon(Icons.person, color: _green, size: 20)),
//               const SizedBox(width: 10),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const Text('Réservation',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                 Text(widget.nomPresta,
//                   style: const TextStyle(fontSize: 12, color: _textGrey)),
//               ]),
//             ]),
//           ),

//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(children: [

//                 // ── Carte prestataire ─────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Center(child: Container(
//                       width: 70, height: 70,
//                       decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight,
//                         border: Border.all(color: _green.withOpacity(0.4), width: 3)),
//                       child: const Icon(Icons.person, color: _green, size: 38))),
//                     const SizedBox(height: 12),
//                     Text(widget.nomPresta,
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                     const SizedBox(height: 8),
//                     const _InfoRow(icon: Icons.location_on_outlined, text: 'Saint-Germain-en-Laye'),
//                     const _InfoRow(icon: Icons.lock_outline,         text: 'Contact réservé aux clients'),
//                     const _InfoRow(icon: Icons.lock_outline,         text: 'Email réservé aux clients'),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Je suis une coiffeuse autodidacte qui aiment sublimer les gens ! Je veux que mes clients se sentent nouveaux en sortant de chez moi',
//                       style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                   ]),
//                 ),
//                 const SizedBox(height: 20),

//                 // ── Stepper ───────────────────────────────────────────
//                 _Stepper(currentStep: _step),
//                 const SizedBox(height: 20),

//                 // ── Étape 1 : Choisir service ─────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: const Color(0xFFF0F0F0))),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('Choisissez votre service',
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                     Text('Chez ${widget.nomPresta}',
//                       style: const TextStyle(fontSize: 14, color: _textGrey)),
//                     const SizedBox(height: 16),

//                     ..._servicesDispos.asMap().entries.map((e) {
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
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             child: Row(children: [
//                               Container(width: 40, height: 40,
//                                 decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
//                                 child: const Icon(Icons.content_cut, color: _green, size: 20)),
//                               const SizedBox(width: 10),
//                               Expanded(child: Text(s['categorie'] as String,
//                                 style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark))),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
//                                 child: Text('${s['count']} prestations',
//                                   style: const TextStyle(fontSize: 11, color: _textGrey))),
//                               const SizedBox(width: 6),
//                               Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                                 color: _textGrey),
//                             ]),
//                           ),
//                         ),
//                         if (expanded)
//                           ...prestations.map((p) {
//                             final key = '${s['categorie']} – ${p['nom']}';
//                             final sel = _selectedService == key;
//                             return GestureDetector(
//                               onTap: () => setState(() {
//                                 _selectedService = key;
//                                 _selectedPrix    = p['prix'] as int;
//                                 _selectedDuree   = p['duree'] as String;
//                               }),
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 8),
//                                 padding: const EdgeInsets.all(14),
//                                 decoration: BoxDecoration(
//                                   color: sel ? _greenLight : Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: sel ? _green : const Color(0xFFE8E8E8),
//                                     width: sel ? 2 : 1)),
//                                 child: Row(children: [
//                                   const SizedBox(width: 50),
//                                   Expanded(child: Text(p['nom'] as String,
//                                     style: TextStyle(fontSize: 14, color: _textDark,
//                                       fontWeight: sel ? FontWeight.w700 : FontWeight.w400))),
//                                   Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
//                                     Text('${p['prix']}€',
//                                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
//                                         color: sel ? _green : _green)),
//                                     Row(children: [
//                                       const Icon(Icons.access_time, size: 12, color: _textGrey),
//                                       const SizedBox(width: 2),
//                                       Text(p['duree'] as String,
//                                         style: const TextStyle(fontSize: 12, color: _textGrey)),
//                                     ]),
//                                   ]),
//                                 ]),
//                               ),
//                             );
//                           }),
//                         const Divider(height: 1),
//                       ]);
//                     }),
//                   ]),
//                 ),
//                 const SizedBox(height: 80),
//               ]),
//             ),
//           ),

//           // ── Bouton continuer ─────────────────────────────────────────
//           if (_selectedService != null)
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//               child: ElevatedButton(
//                 onPressed: () => Navigator.push(context, MaterialPageRoute(
//                   builder: (_) => StepDateScreen(
//                     nomPresta: widget.nomPresta,
//                     service: _selectedService!,
//                     prix: _selectedPrix,
//                     duree: _selectedDuree,
//                   ),
//                 )),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _green,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                   elevation: 0,
//                   minimumSize: const Size(double.infinity, 52),
//                 ),
//                 child: const Text('Continuer',
//                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//               ),
//             ),
//         ]),
//       ),
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

// class _Stepper extends StatelessWidget {
//   const _Stepper({required this.currentStep});
//   final int currentStep;

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         _StepCircle(num: 1, done: currentStep > 1, active: currentStep == 1),
//         _StepLine(done: currentStep > 1),
//         _StepCircle(num: 2, done: currentStep > 2, active: currentStep == 2),
//         _StepLine(done: currentStep > 2),
//         _StepCircle(num: 3, done: currentStep > 3, active: currentStep == 3),
//         _StepLine(done: currentStep > 3),
//         _StepCircle(num: 4, done: currentStep > 4, active: currentStep == 4),
//       ]),
//       const SizedBox(height: 8),
//       Text(
//         currentStep == 1 ? 'Choisissez votre service'
//           : currentStep == 2 ? 'Sélectionnez un créneau'
//           : currentStep == 3 ? 'Informations sur vos cheveux'
//           : 'Récapitulatif',
//         style: const TextStyle(fontSize: 13, color: _textGrey)),
//     ]);
//   }
// }

// class _StepCircle extends StatelessWidget {
//   const _StepCircle({required this.num, required this.done, required this.active});
//   final int num; final bool done, active;
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 36, height: 36,
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: (done || active) ? _green : const Color(0xFFF2F2F7)),
//     child: done
//       ? const Icon(Icons.check, color: Colors.white, size: 18)
//       : Center(child: Text('$num', style: TextStyle(
//           fontSize: 15, fontWeight: FontWeight.w700,
//           color: active ? Colors.white : _textGrey))),
//   );
// }

// class _StepLine extends StatelessWidget {
//   const _StepLine({required this.done});
//   final bool done;
//   @override
//   Widget build(BuildContext context) => Container(
//     width: 40, height: 2,
//     color: done ? _green : const Color(0xFFE0E0E0));
// }