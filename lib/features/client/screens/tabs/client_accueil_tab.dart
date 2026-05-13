

import 'dart:async';
import 'package:flutter/material.dart';
import '../profil_prestataire_screen.dart';
import 'package:madbeauty/features/client/screens/profil_prestataire_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _coiffeursRecommandes = [
  {'nom': 'NiniLocks',      'ville': 'Corbeil-Essonnes', 'dispo': true,  'specialite': 'Tresses & Locks'},
  {'nom': 'Hairstylebymm',  'ville': 'Villepinte',        'dispo': true,  'specialite': 'Coiffure afro'},
  {'nom': 'Ashy.hair',      'ville': 'Cergy',             'dispo': true,  'specialite': 'Twists & Vanilles'},
  {'nom': '19thSignature',  'ville': 'Saint-Germain',     'dispo': false, 'specialite': 'Tresses & Coupes'},
  {'nom': 'Afro_beauty',    'ville': 'Louvres',           'dispo': true,  'specialite': 'Maquillage & Coiffure'},
];

class ClientAccueilTab extends StatefulWidget {
  final VoidCallback? onGoToRecherche;
  const ClientAccueilTab({super.key, this.onGoToRecherche});

  @override
  State<ClientAccueilTab> createState() => _ClientAccueilTabState();
}

class _ClientAccueilTabState extends State<ClientAccueilTab> {
  final PageController _pageCtrl = PageController(viewportFraction: 0.75);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentPage < _coiffeursRecommandes.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Carte profil ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _greenLight),
              child: const Icon(Icons.person, color: _green, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour william !',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                Text('Espace client',
                  style: TextStyle(fontSize: 13, color: _textGrey)),
              ]),
            ),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))),
              child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Trouver un coiffeur ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.search, size: 20, color: _textDark),
              SizedBox(width: 8),
              Text('Trouver un coiffeur',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onGoToRecherche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Commencer la recherche',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Coiffeurs recommandés ─────────────────────────────────────
        const Text('Coiffeurs recommandés',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 4),
        const Text('Découvrez nos coiffeurs disponibles',
          style: TextStyle(fontSize: 14, color: _textGrey)),
        const SizedBox(height: 14),

        // Carrousel auto-sliding
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _coiffeursRecommandes.length,
            itemBuilder: (_, i) {
              final c = _coiffeursRecommandes[i];
              final dispo = c['dispo'] as bool;
              final isActive = i == _currentPage;
              return AnimatedScale(
                scale: isActive ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfilPrestataireScreen(nom: c['nom'] as String, ville: c['ville'] as String)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? _green : const Color(0xFFE0E0E0),
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: [BoxShadow(
                        color: isActive ? _green.withOpacity(0.15) : const Color(0x08000000),
                        blurRadius: isActive ? 12 : 6,
                        offset: const Offset(0, 3),
                      )],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Stack(children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: _greenLight,
                            border: Border.all(color: _green.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.person, color: _green, size: 32),
                        ),
                        if (dispo)
                          Positioned(bottom: 2, right: 2,
                            child: Container(width: 14, height: 14,
                              decoration: BoxDecoration(
                                color: _green, shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)))),
                      ]),
                      const SizedBox(height: 8),
                      Text(c['nom'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: _textGrey),
                        const SizedBox(width: 2),
                        Flexible(child: Text(c['ville'] as String,
                          style: const TextStyle(fontSize: 11, color: _textGrey),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),

        // Indicateurs de page
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_coiffeursRecommandes.length, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _currentPage ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == _currentPage ? _green : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(3)),
          ))),
        const SizedBox(height: 20),

        // ── Rendez-vous récents ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: _textDark),
              const SizedBox(width: 8),
              const Expanded(child: Text('Rendez-vous récents',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark))),
              TextButton(onPressed: () {},
                child: const Text('Voir tout', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 12),
            const Text('Aucun rendez-vous à venir',
              style: TextStyle(fontSize: 14, color: _textGrey)),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}






























// import 'package:flutter/material.dart';

// const _green     = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _rose      = Color(0xFF2D7A4F);   // vert
// const _roseLight = Color(0xFFE8F5EE);   // vert clair
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// // Données simulées — à brancher Supabase
// const _coiffeursRecommandes = [
//   {'nom': 'NiniLocks',      'ville': 'Corbeil-Essonnes', 'dispo': true},
//   {'nom': 'Hairstylebymm',  'ville': 'Villepinte',        'dispo': true},
//   {'nom': 'Ashy.hair',      'ville': 'Cergy',             'dispo': false},
// ];

// class ClientAccueilTab extends StatelessWidget {
//   const ClientAccueilTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//         // ── Carte profil ──────────────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFF0F0F0)),
//             boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
//           ),
//           child: Row(children: [
//             Container(
//               width: 48, height: 48,
//               decoration: const BoxDecoration(shape: BoxShape.circle, color: _roseLight),
//               child: const Icon(Icons.person, color: _rose, size: 28),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Bonjour william !',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                 Text('Espace client',
//                   style: TextStyle(fontSize: 13, color: _textGrey)),
//               ]),
//             ),
//             Container(
//               width: 36, height: 36,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//               ),
//               child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 16),

//         // ── Trouver un coiffeur ───────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFF0F0F0)),
//           ),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Row(children: [
//               Icon(Icons.search, size: 20, color: _textDark),
//               SizedBox(width: 8),
//               Text('Trouver un Prestataire',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//             ]),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _rose,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Commencer la recherche',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//               ),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 20),

//         // ── Coiffeurs recommandés ─────────────────────────────────────
//         const Text('Prestataires recommandés',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//         const SizedBox(height: 4),
//         const Text('Découvrez nos coiffeurs disponibles',
//           style: TextStyle(fontSize: 14, color: _textGrey)),
//         const SizedBox(height: 14),

//         SizedBox(
//           height: 160,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: _coiffeursRecommandes.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (_, i) {
//               final c = _coiffeursRecommandes[i];
//               final dispo = c['dispo'] as bool;
//               return Container(
//                 width: 140,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: dispo ? _rose.withOpacity(0.5) : const Color(0xFFE0E0E0),
//                     width: dispo ? 1.5 : 1,
//                   ),
//                   boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
//                 ),
//                 child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Stack(
//                     children: [
//                       Container(
//                         width: 56, height: 56,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _roseLight,
//                           border: Border.all(color: _rose.withOpacity(0.3), width: 2),
//                         ),
//                         child: const Icon(Icons.person, color: _rose, size: 30),
//                       ),
//                       if (dispo)
//                         Positioned(
//                           bottom: 2, right: 2,
//                           child: Container(
//                             width: 14, height: 14,
//                             decoration: BoxDecoration(
//                               color: _green,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(c['nom'] as String,
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
//                     maxLines: 1, overflow: TextOverflow.ellipsis),
//                   const SizedBox(height: 4),
//                   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     const Icon(Icons.location_on_outlined, size: 12, color: _textGrey),
//                     const SizedBox(width: 2),
//                     Flexible(child: Text(c['ville'] as String,
//                       style: const TextStyle(fontSize: 11, color: _textGrey),
//                       maxLines: 1, overflow: TextOverflow.ellipsis)),
//                   ]),
//                 ]),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 20),

//         // ── Rendez-vous récents ───────────────────────────────────────
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFF0F0F0)),
//           ),
//           child: Column(children: [
//             Row(children: [
//               const Icon(Icons.calendar_today_outlined, size: 18, color: _textDark),
//               const SizedBox(width: 8),
//               const Expanded(
//                 child: Text('Rendez-vous récents',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text('Voir tout', style: TextStyle(color: _rose, fontSize: 13, fontWeight: FontWeight.w600)),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             const Text('Aucun rendez-vous à venir',
//               style: TextStyle(fontSize: 14, color: _textGrey)),
//             const SizedBox(height: 4),
//           ]),
//         ),
//         const SizedBox(height: 24),
//       ]),
//     );
//   }
// }