

// lib/features/prestataire/onboarding/steps/step_abonnement_pro.dart

import 'package:flutter/material.dart';

const _brown    = Color(0xFF8B6340);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF8E8E93);

const _avantages = [
  {
    'title': 'Visibilité prioritaire',
    'desc':
        'Apparaissez en tête des recherches et soyez visible auprès de +10000 clientes actives.'
  },
  {
    'title': 'Plus de réservations',
    'desc':
        'Recevez plus de demandes chaque semaine grâce à un profil boosté.'
  },
  {
    'title': 'Gestion complète des rendez-vous',
    'desc':
        'Acceptez, modifiez et confirmez vos RDV facilement en temps réel.'
  },
  {
    'title': 'Portfolio avancé (10 photos + 5 vidéos)',
    'desc':
        'Montrez votre travail avec photos et vidéos pour attirer plus de clientes.'
  },
  {
    'title': 'Chat professionnel illimité',
    'desc':
        'Discutez avec vos clientes, envoyez des photos et confirmez vos RDV rapidement.'
  },
  {
    'title': 'Statistiques détaillées',
    'desc':
        'Suivez vos performances et optimisez votre activité.'
  },
];

class StepAbonnementPro extends StatelessWidget {
  const StepAbonnementPro({
    super.key,
    required this.onNext,
    required this.onClose,
  });

  final VoidCallback onNext, onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: _textGrey),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Gagne plus de clients',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textDark,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Plus de revenus\nPlus de visibilité',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _brown,
            height: 1.3,
          ),
        ),

        // Indicateur
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: _brown,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 6),

              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _brown,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: _brown,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        const Center(
          child: Text(
            'Grâce à l\'abonnement MadBeauty',
            style: TextStyle(
              fontSize: 15,
              color: _textGrey,
            ),
          ),
        ),

        const SizedBox(height: 24),

        ..._avantages.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2E8D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: _brown,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['title']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _brown,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        a['desc']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: const Text(
              '✨  Commence à gagner plus de clients',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Paiement sécurisé • Résiliable à tout moment',
            style: TextStyle(
              fontSize: 12,
              color: _textGrey,
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Center(
          child: Text(
            'Multipliez vos opportunités de revenus avec +10000 clientes réparties dans toute la France',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _brown,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}





















































// // lib/features/prestataire/onboarding/steps/step_abonnement_pro.dart

// import 'package:flutter/material.dart';

// const _green    = Color(0xFF2D7A4F);
// const _textDark = Color(0xFF1A1A1A);
// const _textGrey = Color(0xFF8E8E93);

// const _avantages = [
//   {'title': 'Visibilité prioritaire',            'desc': 'Apparaissez en tête des recherches et soyez visible auprès de +10000 clientes actives.'},
//   {'title': 'Plus de réservations',              'desc': 'Recevez plus de demandes chaque semaine grâce à un profil boosté.'},
//   {'title': 'Gestion complète des rendez-vous',  'desc': 'Acceptez, modifiez et confirmez vos RDV facilement en temps réel.'},
//   {'title': 'Portfolio avancé (10 photos + 5 vidéos)', 'desc': 'Montrez votre travail avec photos et vidéos pour attirer plus de clientes.'},
//   {'title': 'Chat professionnel illimité',       'desc': 'Discutez avec vos clientes, envoyez des photos et confirmez vos RDV rapidement.'},
//   {'title': 'Statistiques détaillées',           'desc': 'Suivez vos performances et optimisez votre activité.'},
// ];

// class StepAbonnementPro extends StatelessWidget {
//   const StepAbonnementPro({super.key, required this.onNext, required this.onClose});
//   final VoidCallback onNext, onClose;

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Align(alignment: Alignment.centerRight,
//         child: GestureDetector(onTap: onClose,
//           child: const Icon(Icons.close, color: _textGrey))),
//       const SizedBox(height: 16),

//       const Text('Gagne plus de clients',
//         style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _textDark, height: 1.2)),
//       const SizedBox(height: 6),
//       const Text('Plus de revenus\nPlus de visibilité',
//         style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _green, height: 1.3)),

//       // Indicateur
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Container(width: 30, height: 3, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
//           const SizedBox(width: 6),
//           Container(width: 8, height: 8, decoration: BoxDecoration(color: _green, shape: BoxShape.circle)),
//           const SizedBox(width: 6),
//           Container(width: 30, height: 3, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
//         ]),
//       ),

//       const Center(child: Text('Grâce à l\'abonnement MadBeauty',
//         style: TextStyle(fontSize: 15, color: _textGrey))),
//       const SizedBox(height: 24),

//       ..._avantages.map((a) => Padding(
//         padding: const EdgeInsets.only(bottom: 18),
//         child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: 32, height: 32,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF2E8D9),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.check, color: _green, size: 18),
//           ),
//           const SizedBox(width: 14),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(a['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _green)),
//             const SizedBox(height: 4),
//             Text(a['desc']!, style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//           ])),
//         ]),
//       )),

//       const SizedBox(height: 24),
//       SizedBox(width: double.infinity, height: 56,
//         child: ElevatedButton(
//           onPressed: onNext,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _green,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//             elevation: 0,
//           ),
//           child: const Text('✨  Commence à gagner plus de clients',
//             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//         ),
//       ),
//       const SizedBox(height: 10),
//       const Center(child: Text('Paiement sécurisé • Résiliable à tout moment',
//         style: TextStyle(fontSize: 12, color: _textGrey))),
//       const SizedBox(height: 12),
//       const Center(child: Text('Multipliez vos opportunités de revenus avec +10000 clientes réparties dans toute la France',
//         textAlign: TextAlign.center,
//         style: TextStyle(fontSize: 13, color: _green, height: 1.4))),
//       const SizedBox(height: 24),
//     ]);
//   }
// }