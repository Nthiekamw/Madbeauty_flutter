
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _bg        = Color(0xFFF2EBE0);
const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);

class ClientChatTab extends StatelessWidget {
  const ClientChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final h   = MediaQuery.of(context).size.height;
    final rem = w / 100;

    return Container(
      color: _bg,
      child: Column(children: [

        // ── Header ────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 4, rem * 2, rem * 3.5),
          child: Row(children: [
            Text('Chat', style: TextStyle(
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
                icon: Icon(Icons.notifications_outlined, size: rem * 5.5, color: _textDark)),
              Positioned(top: rem * 1, right: rem * 1,
                child: Container(
                  width: rem * 2, height: rem * 2,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
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
              onPressed: () => context.go('/'),
              icon: Icon(Icons.logout_rounded, size: rem * 5.5, color: _textDark)),
          ]),
        ),

        // ── Corps ─────────────────────────────────────────────────────
        Expanded(
          child: Column(children: [
            SizedBox(height: rem * 3.5),

            // Carte profil
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
                    child: Icon(Icons.person_rounded, color: _gold, size: rem * 7)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bonjour William !', style: TextStyle(
                      fontSize: rem * 4, fontWeight: FontWeight.w700, color: _textDark)),
                    SizedBox(height: rem * 0.5),
                    Text('Prêt(e) pour une nouvelle expérience beauté ?',
                      style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: _textGrey, size: rem * 5),
                ]),
              ),
            ),
            SizedBox(height: rem * 4),

            // Carte chat vide
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rem * 4),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rem * 5),
                    boxShadow: [BoxShadow(
                      color: _textDark.withOpacity(0.06),
                      blurRadius: 12, offset: const Offset(0, 4))]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    // Illustration
                    Stack(alignment: Alignment.center, children: [
                      // Cercle fond
                      Container(
                        width: rem * 38, height: rem * 38,
                        decoration: BoxDecoration(
                          color: _goldLight.withOpacity(0.5),
                          shape: BoxShape.circle)),

                      // Déco feuilles
                      Positioned(bottom: rem * 4, left: rem * 2,
                        child: Icon(Icons.auto_awesome,
                          size: rem * 8, color: _gold.withOpacity(0.2))),
                      Positioned(bottom: rem * 3, right: rem * 2,
                        child: Icon(Icons.auto_awesome,
                          size: rem * 6, color: _gold.withOpacity(0.15))),

                      // Étoiles déco
                      Positioned(top: rem * 4, left: rem * 6,
                        child: Text('✦', style: TextStyle(
                          fontSize: rem * 3, color: _gold.withOpacity(0.4)))),
                      Positioned(top: rem * 5, right: rem * 5,
                        child: Text('✦', style: TextStyle(
                          fontSize: rem * 2.5, color: _gold.withOpacity(0.3)))),
                      Positioned(bottom: rem * 8, right: rem * 2,
                        child: Text('✦', style: TextStyle(
                          fontSize: rem * 2, color: _gold.withOpacity(0.3)))),

                      // Icône bulle principale
                      Icon(Icons.chat_bubble_rounded,
                        size: rem * 20, color: _gold),
                    ]),
                    SizedBox(height: h * 0.03),

                    // Titre
                    Text('Aucune conversation', style: TextStyle(
                      fontSize: rem * 4.8,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
                    SizedBox(height: rem * 2),

                    // Ligne déco
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: rem * 8, height: 1.5,
                        color: _gold.withOpacity(0.3)),
                      Container(
                        width: rem * 2, height: rem * 2,
                        margin: EdgeInsets.symmetric(horizontal: rem * 1.5),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.5),
                          shape: BoxShape.circle)),
                      Container(width: rem * 8, height: 1.5,
                        color: _gold.withOpacity(0.3)),
                    ]),
                    SizedBox(height: rem * 2.5),

                    // Sous-titre
                    Text('Vos conversations apparaîtront ici',
                      style: TextStyle(fontSize: rem * 3.5, color: _textGrey)),
                  ]),
                ),
              ),
            ),
            SizedBox(height: rem * 4),
          ]),
        ),
      ]),
    );
  }
}























































// import 'package:flutter/material.dart';

// const _bgCream   = Color(0xFFF5EFE6);
// const _gold      = Color(0xFFD4A96A);
// const _goldLight = Color(0xFFF0E6D3);
// const _green     = Color(0xFF5B8A5F); // vert doux pour l'icône chat uniquement
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// class ClientChatTab extends StatelessWidget {
//   const ClientChatTab({super.key});

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
//           padding: EdgeInsets.fromLTRB(p, h * 0.02, p, h * 0.015),
//           child: Row(children: [
//             Text('Chat', style: TextStyle(
//               fontSize: w * 0.055, fontWeight: FontWeight.w800, color: _textDark)),
//             const Spacer(),

//             // Thème
//             PopupMenuButton<String>(
//               icon: Icon(Icons.wb_sunny_outlined, size: w * 0.055, color: _textDark),
//               onSelected: (v) {},
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
//                 const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
//                 const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
//               ],
//             ),

//             // Notifications
//             Stack(children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(Icons.notifications_outlined, size: w * 0.055, color: _textDark)),
//               Positioned(top: 8, right: 8,
//                 child: Container(width: w * 0.02, height: w * 0.02,
//                   decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
//             ]),

//             // Support
//             PopupMenuButton<String>(
//               icon: Icon(Icons.help_outline, size: w * 0.055, color: _textDark),
//               onSelected: (v) {},
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
//                 const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
//               ],
//             ),

//             // Déconnexion
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.logout, size: w * 0.055, color: _textDark)),

//             // Paramètres
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.settings_outlined, size: w * 0.055, color: _textDark)),
//           ]),
//         ),

//         // ── Corps ─────────────────────────────────────────────────────
//         Expanded(
//           child: Column(children: [
//             SizedBox(height: h * 0.015),

//             // Carte profil
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: p),
//               child: Container(
//                 padding: EdgeInsets.all(p * 0.8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(w * 0.04),
//                   boxShadow: const [BoxShadow(
//                     color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
//                 child: Row(children: [
//                   Container(
//                     width: w * 0.13, height: w * 0.13,
//                     decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
//                     child: Icon(Icons.person, color: _gold, size: w * 0.07)),
//                   SizedBox(width: w * 0.03),
//                   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Text('Bonjour William !', style: TextStyle(
//                       fontSize: w * 0.04, fontWeight: FontWeight.w700, color: _textDark)),
//                     Text('Prêt(e) pour une nouvelle expérience beauté ?',
//                       style: TextStyle(fontSize: w * 0.03, color: _textGrey)),
//                   ])),
//                   Icon(Icons.chevron_right, color: _textGrey, size: w * 0.05),
//                 ]),
//               ),
//             ),
//             SizedBox(height: h * 0.02),

//             // Carte chat vide
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: p),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(w * 0.05),
//                     boxShadow: const [BoxShadow(
//                       color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))]),
//                   child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

//                     // Illustration bulle chat
//                     Stack(alignment: Alignment.center, children: [
//                       // Cercle fond
//                       Container(
//                         width: w * 0.38, height: w * 0.38,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF0F5F0),
//                           shape: BoxShape.circle)),

//                       // Feuilles déco
//                       Positioned(bottom: w * 0.04, left: w * 0.02,
//                         child: Icon(Icons.eco, size: w * 0.1,
//                           color: _green.withOpacity(0.25))),
//                       Positioned(bottom: w * 0.04, right: w * 0.02,
//                         child: Icon(Icons.eco, size: w * 0.08,
//                           color: _green.withOpacity(0.2))),

//                       // Étoiles déco
//                       Positioned(top: w * 0.04, left: w * 0.06,
//                         child: Text('✦', style: TextStyle(
//                           fontSize: w * 0.03, color: _green.withOpacity(0.4)))),
//                       Positioned(top: w * 0.06, right: w * 0.05,
//                         child: Text('✦', style: TextStyle(
//                           fontSize: w * 0.025, color: _green.withOpacity(0.3)))),
//                       Positioned(bottom: w * 0.1, right: w * 0.02,
//                         child: Text('✦', style: TextStyle(
//                           fontSize: w * 0.02, color: _green.withOpacity(0.3)))),

//                       // Icône bulle principale
//                       Icon(Icons.chat_bubble_outline,
//                         size: w * 0.2,
//                         color: _green),
//                     ]),
//                     SizedBox(height: h * 0.03),

//                     // Titre
//                     Text('Aucune conversation', style: TextStyle(
//                       fontSize: w * 0.048,
//                       fontWeight: FontWeight.w800,
//                       color: _textDark)),
//                     SizedBox(height: h * 0.008),

//                     // Ligne déco
//                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       Container(width: w * 0.08, height: 1.5,
//                         color: _green.withOpacity(0.3)),
//                       Container(
//                         width: w * 0.02, height: w * 0.02,
//                         margin: EdgeInsets.symmetric(horizontal: w * 0.015),
//                         decoration: BoxDecoration(
//                           color: _green.withOpacity(0.5),
//                           shape: BoxShape.circle)),
//                       Container(width: w * 0.08, height: 1.5,
//                         color: _green.withOpacity(0.3)),
//                     ]),
//                     SizedBox(height: h * 0.012),

//                     // Sous-titre
//                     Text('Vos conversations apparaîtront ici',
//                       style: TextStyle(fontSize: w * 0.035, color: _textGrey)),
//                   ]),
//                 ),
//               ),
//             ),
//             SizedBox(height: h * 0.02),
//           ]),
//         ),
//       ]),
//     );
//   }
// }








































// import 'package:flutter/material.dart';

// const _rose      = Color(0xFF2D7A4F);
// const _roseLight = Color(0xFFE8F5EE);
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// class ClientChatTab extends StatelessWidget {
//   const ClientChatTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [

//       // Carte profil
//       Padding(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

//       // Contenu vide
//       Expanded(
//         child: Center(
//           child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//             const Icon(Icons.chat_bubble_outline, size: 64, color: _rose),
//             const SizedBox(height: 16),
//             const Text('Aucune conversation',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//             const SizedBox(height: 8),
//             const Text('Vos conversations apparaîtront ici',
//               style: TextStyle(fontSize: 14, color: _textGrey)),
//           ]),
//         ),
//       ),
//     ]);
//   }
// }