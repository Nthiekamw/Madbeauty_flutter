
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tabs/client_accueil_tab.dart';
import 'tabs/client_recherche_tab.dart';
import 'tabs/client_rdv_tab.dart';
import 'tabs/client_chat_tab.dart';
import 'tabs/client_profil_tab.dart';

const _bgCream  = Color(0xFFF2EBE0);
const _gold     = Color(0xFFC4956A);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF9E8878);

class ClientHubScreen extends StatefulWidget {
  const ClientHubScreen({super.key});

  @override
  State<ClientHubScreen> createState() => _ClientHubScreenState();
}

class _ClientHubScreenState extends State<ClientHubScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: Column(children: [

          // ── Contenu ──────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: [
                ClientAccueilTab(
                  onGoToRecherche: () => setState(() => _navIndex = 1)),
                const ClientRechercheTab(),
                ClientRdvTab(
                  onGoToRecherche: () => setState(() => _navIndex = 1)),
                const ClientChatTab(),
                const ClientProfilTab(),
              ],
            ),
          ),

          // ── Navigation bas ────────────────────────────────────────────
          Container(
            height: h * 0.082,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEDE0CC))),
              boxShadow: [BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, -3))],
            ),
            child: Row(children: [
              _NavBtn(
                icon: Icons.home_outlined,
                iconActive: Icons.home_rounded,
                label: 'Accueil',
                index: 0,
                current: _navIndex,
                rem: rem,
                onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(
                icon: Icons.search_outlined,
                iconActive: Icons.search,
                label: 'Rechercher',
                index: 1,
                current: _navIndex,
                rem: rem,
                onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(
                icon: Icons.calendar_today_outlined,
                iconActive: Icons.calendar_today,
                label: 'Rendez-vous',
                index: 2,
                current: _navIndex,
                rem: rem,
                onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(
                icon: Icons.chat_bubble_outline,
                iconActive: Icons.chat_bubble,
                label: 'Chat',
                index: 3,
                current: _navIndex,
                rem: rem,
                onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(
                icon: Icons.person_outline,
                iconActive: Icons.person,
                label: 'Profil',
                index: 4,
                current: _navIndex,
                rem: rem,
                onTap: (i) => setState(() => _navIndex = i)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.index,
    required this.current,
    required this.rem,
    required this.onTap,
  });

  final IconData icon;
  final IconData iconActive;
  final String label;
  final int index, current;
  final double rem;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Icône avec fond doré si actif
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: rem * 3.5,
                vertical: rem * 1.2),
              decoration: BoxDecoration(
                color: active
                  ? const Color(0xFFEDE0CC)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(rem * 4),
              ),
              child: Icon(
                active ? iconActive : icon,
                size: rem * 6,
                color: active ? _gold : _textGrey),
            ),
            SizedBox(height: rem * 0.8),

            // Label
            Text(label,
              style: TextStyle(
                fontSize: rem * 2.6,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? _gold : _textGrey)),
          ],
        ),
      ),
    );
  }
}





































































// // client_hub_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'tabs/client_accueil_tab.dart';
// import 'tabs/client_recherche_tab.dart';
// import 'tabs/client_rdv_tab.dart';
// import 'tabs/client_chat_tab.dart';
// import 'tabs/client_profil_tab.dart';

// const _bgCream  = Color(0xFFF5EFE6);
// const _gold     = Color(0xFFD4A96A);
// const _textDark = Color(0xFF1A1A1A);
// const _textGrey = Color(0xFF8E8E93);

// class ClientHubScreen extends StatefulWidget {
//   const ClientHubScreen({super.key});
//   @override
//   State<ClientHubScreen> createState() => _ClientHubScreenState();
// }

// class _ClientHubScreenState extends State<ClientHubScreen> {
//   int _navIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: _bgCream,
//       body: SafeArea(
//         child: Column(children: [
//           Expanded(
//             child: IndexedStack(
//               index: _navIndex,
//               children: [
//                 ClientAccueilTab(onGoToRecherche: () => setState(() => _navIndex = 1)),
//                 const ClientRechercheTab(),
//                 ClientRdvTab(onGoToRecherche: () => setState(() => _navIndex = 1)),
//                 const ClientChatTab(),
//               ],
//             ),
//           ),

//           // ── Navigation bas ────────────────────────────────────────────
//           Container(
//             height: h * 0.075,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
//               boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))],
//             ),
//             child: Row(children: [
//               _NavBtn(icon: Icons.home_outlined,           label: 'Accueil',     index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.search,                  label: 'Rechercher',  index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.calendar_today_outlined, label: 'Rendez-vous', index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.chat_bubble_outline,     label: 'Chat',        index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _NavBtn extends StatelessWidget {
//   const _NavBtn({required this.icon, required this.label, required this.index, required this.current, required this.onTap});
//   final IconData icon; final String label; final int index, current; final ValueChanged<int> onTap;

//   @override
//   Widget build(BuildContext context) {
//     final active = index == current;
//     final w = MediaQuery.of(context).size.width;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTap(index),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(icon, size: w * 0.062, color: active ? _gold : _textGrey),
//           SizedBox(height: w * 0.008),
//           Text(label, style: TextStyle(
//             fontSize: w * 0.028,
//             fontWeight: active ? FontWeight.w700 : FontWeight.w400,
//             color: active ? _gold : _textGrey)),
//         ]),
//       ),
//     );
//   }
// }





















































