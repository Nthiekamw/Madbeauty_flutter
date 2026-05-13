import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tabs/client_accueil_tab.dart';
import 'tabs/client_recherche_tab.dart';
import 'tabs/client_rdv_tab.dart';
import 'tabs/client_chat_tab.dart';

const _green     = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _rose      = Color(0xFF2D7A4F);
const _roseLight = Color(0xFFE8F5EE);
const _textDark  = Color(0xFF1A1A1A);
const _textGrey  = Color(0xFF8E8E93);

class ClientHubScreen extends StatefulWidget {
  const ClientHubScreen({super.key});

  @override
  State<ClientHubScreen> createState() => _ClientHubScreenState();
}

class _ClientHubScreenState extends State<ClientHubScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [

          // ── Top bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _roseLight,
                  border: Border.all(color: _rose.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.person, color: _rose, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('Mon Espace',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
              const Spacer(),

              // Thème
              PopupMenuButton<String>(
                icon: const Icon(Icons.wb_sunny_outlined, size: 22, color: _textDark),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
                  const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
                  const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
                ],
              ),

              // Notifications
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Notifications'),
                      content: const Text('Aucune notification'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined, size: 22, color: _textDark),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),

              // Aide
              PopupMenuButton<String>(
                icon: const Icon(Icons.help_outline, size: 22, color: _textDark),
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
                  const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
                ],
              ),

              // Déconnexion
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.logout, size: 22, color: _textDark),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ]),
          ),

          // ── Contenu ────────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _navIndex,
             children: [
  ClientAccueilTab(onGoToRecherche: () => setState(() => _navIndex = 1)),
  const ClientRechercheTab(),
  ClientRdvTab(onGoToRecherche: () => setState(() => _navIndex = 1)),
  const ClientChatTab(),
],
            ),
          ),

          // ── Navigation bas ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: Row(children: [
              _NavBtn(icon: Icons.home_outlined,           label: 'Accueil',     index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(icon: Icons.search,                  label: 'Rechercher',  index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(icon: Icons.calendar_today_outlined, label: 'Rendez-vous', index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
              _NavBtn(icon: Icons.chat_bubble_outline,     label: 'Chat',        index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.label, required this.index, required this.current, required this.onTap});
  final IconData icon; final String label; final int index, current; final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: Column(children: [
            Icon(icon, size: 24, color: active ? _rose : _textGrey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _rose : _textGrey)),
          ]),
        ),
      ),
    );
  }
}