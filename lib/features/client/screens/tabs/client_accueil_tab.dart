import 'package:flutter/material.dart';
import '../profil_prestataire_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _coiffeursRecommandes = [
  {'nom': 'NiniLocks',     'ville': 'Corbeil-Essonnes', 'dispo': true,  'specialite': 'Tresses & Locks',         'type': 'coiffeur',   'initiales': 'NL'},
  {'nom': 'Hairstylebymm', 'ville': 'Villepinte',        'dispo': true,  'specialite': 'Coiffure afro',           'type': 'coiffeur',   'initiales': 'M'},
  {'nom': 'Ashy.hair',     'ville': 'Cergy',             'dispo': true,  'specialite': 'Twists & Vanilles',       'type': 'coiffeur',   'initiales': 'AH'},
  {'nom': '19thSignature', 'ville': 'Saint-Germain',     'dispo': false, 'specialite': 'Tresses & Coupes',        'type': 'coiffeur',   'initiales': '19'},
  {'nom': 'Afro_beauty',   'ville': 'Louvres',           'dispo': true,  'specialite': 'Maquillage & Coiffure',   'type': 'maquillage', 'initiales': 'AB'},
  {'nom': 'Beauty_Nails',  'ville': 'Paris',             'dispo': true,  'specialite': 'Manucure & Nail Art',     'type': 'manicure',   'initiales': 'BN'},
  {'nom': 'GlamMakeup',    'ville': 'Versailles',        'dispo': true,  'specialite': 'Maquillage événementiel', 'type': 'maquillage', 'initiales': 'GM'},
];

// Couleurs de fond avatar selon l'index — style élégant
const _avatarColors = [
  Color(0xFF1A1A1A),  // noir profond
  Color(0xFF2D7A4F),  // vert
  Color(0xFF3D5A80),  // bleu nuit
  Color(0xFF6B3A4D),  // bordeaux
  Color(0xFF4A4A4A),  // gris anthracite
  Color(0xFF2D4A3E),  // vert foncé
  Color(0xFF5C3D2E),  // marron chaud
];

class ClientAccueilTab extends StatelessWidget {
  final VoidCallback? onGoToRecherche;
  const ClientAccueilTab({super.key, this.onGoToRecherche});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Carte profil ──────────────────────────────────────────────
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
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _greenLight),
              child: const Icon(Icons.person, color: _green, size: 28)),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0))),
              child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Trouver un prestataire ────────────────────────────────────
        // ── Trouver un prestataire ────────────────────────────────────────
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFF0F0F0)),
    boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3))],
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.search, size: 22, color: _green)),
      const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Trouver un prestataire',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
        SizedBox(height: 2),
        Text('Coiffeur, maquillage, manucure…',
          style: TextStyle(fontSize: 12, color: _textGrey)),
      ]),
    ]),
    const SizedBox(height: 16),
    GestureDetector(
      onTap: onGoToRecherche,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: _green.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Commencer la recherche',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3)),
          ],
        ),
      ),
    ),
  ]),
),
        const SizedBox(height: 22),

        // ── Titre section ─────────────────────────────────────────────
        const Text('Prestataires recommandés',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 4),
        const Text('Découvrez nos professionnels disponibles',
          style: TextStyle(fontSize: 14, color: _textGrey)),
        const SizedBox(height: 14),

        // ── Scroll horizontal ─────────────────────────────────────────
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            itemCount: _coiffeursRecommandes.length,
            itemBuilder: (_, i) {
              final c         = _coiffeursRecommandes[i];
              final dispo     = c['dispo'] as bool;
              final type      = c['type'] as String;
              final initiales = c['initiales'] as String;
              final bgColor   = _avatarColors[i % _avatarColors.length];

              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfilPrestataireScreen(
                    nom: c['nom'] as String,
                    ville: c['ville'] as String,
                    typePresta: type,
                  ),
                )),
                child: Container(
                  width: 145,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: dispo
                        ? _green.withOpacity(0.35)
                        : const Color(0xFFE8E8E8),
                      width: dispo ? 1.8 : 1.2),
                    boxShadow: [BoxShadow(
                      color: dispo
                        ? _green.withOpacity(0.10)
                        : const Color(0x08000000),
                      blurRadius: 14,
                      offset: const Offset(0, 5))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        // ── Avatar avec initiales style photo profil ──
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Anneau extérieur vert
                            Container(
                              width: 76, height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: dispo ? _green : const Color(0xFFD0D0D0),
                                  width: 2.5),
                              ),
                            ),
                            // Avatar fond coloré + initiales
                            Container(
                              width: 68, height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgColor,
                                boxShadow: [BoxShadow(
                                  color: bgColor.withOpacity(0.4),
                                  blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Center(
                                child: Text(
                                  initiales,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5),
                                ),
                              ),
                            ),
                            // Point vert dispo
                            if (dispo)
                              Positioned(
                                bottom: 2, right: 4,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: BoxDecoration(
                                    color: _green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: const [BoxShadow(
                                      color: Color(0x40000000), blurRadius: 4)],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Nom
                        Text(c['nom'] as String,
                          style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center),
                        const SizedBox(height: 3),

                        // Ville
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.location_on_outlined, size: 11, color: _textGrey),
                          const SizedBox(width: 2),
                          Flexible(child: Text(c['ville'] as String,
                            style: const TextStyle(fontSize: 11, color: _textGrey),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 8),

                        // Badge dispo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: dispo ? _greenLight : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: dispo
                                ? _green.withOpacity(0.4)
                                : const Color(0xFFE0E0E0),
                              width: 1)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dispo ? _green : _textGrey)),
                            const SizedBox(width: 5),
                            Text(
                              dispo ? 'Disponible' : 'Indisponible',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: dispo ? _green : _textGrey)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Hint scroll
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.chevron_left, size: 14, color: _textGrey),
          SizedBox(width: 4),
          Text('Faites glisser pour voir plus',
            style: TextStyle(fontSize: 11, color: _textGrey)),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 14, color: _textGrey),
        ]),
        const SizedBox(height: 22),

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
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout',
                  style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600))),
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