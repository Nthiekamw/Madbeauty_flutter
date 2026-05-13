




import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 48),

                // ── Logo ──────────────────────────────────────────────────
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 24),

                // ── Titre ─────────────────────────────────────────────────
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.tagline,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // ── Avertissement Supabase ─────────────────────────────────
                if (!AppConfig.hasSupabase) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.supabaseMissingTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7A5800),
                                )),
                              const SizedBox(height: 4),
                              Text(AppStrings.supabaseMissingBody,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9A7020),
                                  height: 1.4,
                                )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Carte stats ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      _StatItem(value: '500+', label: 'Prestataires'),
                      _Divider(),
                      _StatItem(value: '4.9★', label: 'Note moyenne'),
                      _Divider(),
                      _StatItem(value: '10k+', label: 'Clientes'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Bouton principal (vert plein) ──────────────────────────
                GestureDetector(
                  onTap: () => context.push('/login'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Se connecter / S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Bouton secondaire (bordure verte) ──────────────────────
                GestureDetector(
                  onTap: () => context.push('/prestataire'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _green, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.content_cut, color: _green, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Espace prestataire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _green,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Footer ─────────────────────────────────────────────────
                Center(
                  child: Text(
                    'Beauté afro, à portée de main ✨',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF888888).withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(
        fontSize: 12, color: Color(0xFF888888))),
    ]),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: _green.withOpacity(0.2),
  );
}










































// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../../core/config/app_config.dart';
// import '../../../core/constants/app_strings.dart';
// import '../../../shared/theme/app_text_styles.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(AppStrings.appName)),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(AppStrings.appName, style: AppTextStyles.display(context)),
//               const SizedBox(height: 12),
//               Text(AppStrings.tagline, style: AppTextStyles.body(context)),
//               const Spacer(),
//               if (!AppConfig.hasSupabase)
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           AppStrings.supabaseMissingTitle,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           AppStrings.supabaseMissingBody,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               FilledButton(
//                 onPressed: () => context.push('/login'),
//                 child: Text(AppStrings.signInOrSignUp),
//               ),
//               const SizedBox(height: 12),
//               OutlinedButton(
//                 onPressed: () => context.push('/prestataire'),
//                 child: Text(AppStrings.openPrestataireSpace),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
