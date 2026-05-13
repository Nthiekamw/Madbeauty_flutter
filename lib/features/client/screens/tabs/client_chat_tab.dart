import 'package:flutter/material.dart';

const _rose      = Color(0xFF2D7A4F);
const _roseLight = Color(0xFFE8F5EE);
const _textDark  = Color(0xFF1A1A1A);
const _textGrey  = Color(0xFF8E8E93);

class ClientChatTab extends StatelessWidget {
  const ClientChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      // Carte profil
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _roseLight),
              child: const Icon(Icons.person, color: _rose, size: 28)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour william !', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
              Text('Espace client',     style: TextStyle(fontSize: 13, color: _textGrey)),
            ])),
            Container(width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))),
              child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
          ]),
        ),
      ),

      // Contenu vide
      Expanded(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: _rose),
            const SizedBox(height: 16),
            const Text('Aucune conversation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            const Text('Vos conversations apparaîtront ici',
              style: TextStyle(fontSize: 14, color: _textGrey)),
          ]),
        ),
      ),
    ]);
  }
}