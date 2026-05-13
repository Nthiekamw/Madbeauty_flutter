
import 'package:flutter/material.dart';
import '../profil_prestataire_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _prestataires = [
  {
    'nom': '19thSignature',
    'ville': 'Saint-Germain-en-Laye',
    'lieu': 'En salon',
    'dispo': true,
    'type': 'coiffeur',
    'specialite': 'Coiffure afro & tresses',
  },
  {
    'nom': 'Afro_beauty',
    'ville': 'Louvres',
    'lieu': 'Domicile & salon',
    'dispo': true,
    'type': 'maquillage',
    'specialite': 'Maquillage & soins visage',
  },
  {
    'nom': 'Ashy.hair',
    'ville': 'Cergy',
    'lieu': 'Domicile & salon',
    'dispo': true,
    'type': 'coiffeur',
    'specialite': 'Twists & vanilles',
  },
  {
    'nom': 'NiniLocks',
    'ville': 'Corbeil-Essonnes',
    'lieu': 'À domicile',
    'dispo': false,
    'type': 'coiffeur',
    'specialite': 'Locks & dreadlocks',
  },
  {
    'nom': 'Beauty_Nails',
    'ville': 'Paris',
    'lieu': 'En salon',
    'dispo': true,
    'type': 'manicure',
    'specialite': 'Manucure & nail art',
  },
  {
    'nom': 'GlamMakeup',
    'ville': 'Versailles',
    'lieu': 'Domicile & salon',
    'dispo': true,
    'type': 'maquillage',
    'specialite': 'Maquillage événementiel',
  },
  {
    'nom': 'Hairstylebymm',
    'ville': 'Villepinte',
    'lieu': 'En salon',
    'dispo': true,
    'type': 'coiffeur',
    'specialite': 'Coiffure afro',
  },
  {
    'nom': 'PetiPied',
    'ville': 'Montreuil',
    'lieu': 'En salon',
    'dispo': false,
    'type': 'manicure',
    'specialite': 'Pédicure & soins pieds',
  },
];

// Icône selon le type
IconData _iconForType(String type) {
  switch (type) {
    case 'maquillage': return Icons.brush;
    case 'manicure':   return Icons.back_hand_outlined;
    default:           return Icons.content_cut;
  }
}

// Label selon le type
String _labelForType(String type) {
  switch (type) {
    case 'maquillage': return 'Maquilleur(se)';
    case 'manicure':   return 'Manucure / Pédicure';
    default:           return 'Coiffeur(se)';
  }
}

class ClientRechercheTab extends StatefulWidget {
  const ClientRechercheTab({super.key});

  @override
  State<ClientRechercheTab> createState() => _ClientRechercheTabState();
}

class _ClientRechercheTabState extends State<ClientRechercheTab> {
  final _searchCtrl = TextEditingController();
  String _filtreType = 'tous'; // 'tous', 'coiffeur', 'maquillage', 'manicure'
  String _recherche  = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _prestataires.where((p) {
      final matchType = _filtreType == 'tous' || p['type'] == _filtreType;
      final matchSearch = _recherche.isEmpty ||
        (p['nom'] as String).toLowerCase().contains(_recherche.toLowerCase()) ||
        (p['ville'] as String).toLowerCase().contains(_recherche.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      // ── Carte profil ──────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0))),
          child: Row(children: [
            Container(width: 48, height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _greenLight),
              child: const Icon(Icons.person, color: _green, size: 28)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour william !',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
              Text('Espace client',
                style: TextStyle(fontSize: 13, color: _textGrey)),
            ])),
            Container(width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0))),
              child: const Icon(Icons.settings_outlined, size: 18, color: _textGrey)),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      // ── Barre recherche ───────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              decoration: InputDecoration(
                hintText: 'Rechercher ville...',
                hintStyle: const TextStyle(color: _green, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: _green, size: 20),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: _green, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _FilterBtn(icon: Icons.location_on_outlined, onTap: () {}),
          const SizedBox(width: 8),
          _FilterBtn(icon: Icons.tune_outlined, onTap: () {
            // Filtre par type
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => _FiltreSheet(
                current: _filtreType,
                onSelect: (v) => setState(() => _filtreType = v),
              ),
            );
          }),
          const SizedBox(width: 8),
          _FilterBtnDot(icon: Icons.filter_list, onTap: () {}),
        ]),
      ),
      const SizedBox(height: 8),

      // ── Chips filtres type ────────────────────────────────────────
      SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _TypeChip(label: 'Tous',               value: 'tous',       current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
            _TypeChip(label: '✂️ Coiffeur(se)',     value: 'coiffeur',   current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
            _TypeChip(label: '💄 Maquilleur(se)',   value: 'maquillage', current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
            _TypeChip(label: '💅 Manucure/Pédicure',value: 'manicure',   current: _filtreType, onTap: (v) => setState(() => _filtreType = v)),
          ],
        ),
      ),
      const SizedBox(height: 8),

      // ── Liste prestataires ────────────────────────────────────────
      Expanded(
        child: _filtered.isEmpty
          ? const Center(
              child: Text('Aucun prestataire trouvé',
                style: TextStyle(fontSize: 15, color: _textGrey)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = _filtered[i];
                final dispo    = p['dispo']  as bool;
                final type     = p['type']   as String;
                final specialite = p['specialite'] as String;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                    boxShadow: const [BoxShadow(
                      color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [

                      // Avatar avec icône selon type
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _greenLight,
                          border: Border.all(color: _green.withOpacity(0.3))),
                        child: Icon(_iconForType(type), color: _green, size: 26)),
                      const SizedBox(width: 12),

                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p['nom'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                        const SizedBox(height: 2),

                        // Badge type
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _greenLight,
                            borderRadius: BorderRadius.circular(50)),
                          child: Text(_labelForType(type),
                            style: const TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600))),
                        const SizedBox(height: 4),

                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: _textGrey),
                          const SizedBox(width: 4),
                          Text(p['ville'] as String,
                            style: const TextStyle(fontSize: 13, color: _textGrey)),
                        ]),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(Icons.access_time, size: 14, color: _textGrey),
                          const SizedBox(width: 4),
                          Text(p['lieu'] as String,
                            style: const TextStyle(fontSize: 13, color: _textGrey)),
                        ]),
                        const SizedBox(height: 2),
                        const Row(children: [
                          Icon(Icons.lock_outline, size: 14, color: _textGrey),
                          SizedBox(width: 4),
                          Text('Contact réservé aux clients',
                            style: TextStyle(fontSize: 13, color: _textGrey)),
                        ]),
                      ])),

                      // Badge dispo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: dispo ? _green.withOpacity(0.1) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: dispo ? _green : const Color(0xFFE0E0E0))),
                        child: Text(dispo ? 'Disponible' : 'Indisponible',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: dispo ? _green : _textGrey)),
                      ),
                    ]),
                    const SizedBox(height: 10),

                    // Spécialité
                    Text(specialite,
                      style: const TextStyle(fontSize: 12, color: _textGrey, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 10),

                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ProfilPrestataireScreen(
                              nom: p['nom'] as String,
                              ville: p['ville'] as String,
                              typePresta: type,
                            ),
                          )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Voir profil',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE0E0E0))),
                        child: const Icon(Icons.calendar_today_outlined, size: 20, color: _textDark)),
                    ]),
                  ]),
                );
              },
            ),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

// ── Chip filtre type ──────────────────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.value, required this.current, required this.onTap});
  final String label, value, current; final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _green : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: active ? _green : const Color(0xFFE0E0E0))),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: active ? Colors.white : _textGrey)),
      ),
    );
  }
}

// ── Sheet filtre ──────────────────────────────────────────────────────────────
class _FiltreSheet extends StatelessWidget {
  const _FiltreSheet({required this.current, required this.onSelect});
  final String current; final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Filtrer par type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      _FiltreItem(label: 'Tous les prestataires', value: 'tous',       current: current, onSelect: onSelect, context: context),
      _FiltreItem(label: '✂️ Coiffeur(se)',        value: 'coiffeur',   current: current, onSelect: onSelect, context: context),
      _FiltreItem(label: '💄 Maquilleur(se)',      value: 'maquillage', current: current, onSelect: onSelect, context: context),
      _FiltreItem(label: '💅 Manucure / Pédicure', value: 'manicure',   current: current, onSelect: onSelect, context: context),
      const SizedBox(height: 8),
    ]),
  );
}

Widget _FiltreItem({
  required String label, required String value,
  required String current, required ValueChanged<String> onSelect,
  required BuildContext context,
}) {
  final active = current == value;
  return GestureDetector(
    onTap: () { onSelect(value); Navigator.pop(context); },
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: active ? _greenLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? _green : const Color(0xFFE0E0E0))),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(
          fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: active ? _green : _textDark))),
        if (active) const Icon(Icons.check, color: _green, size: 18),
      ]),
    ),
  );
}

// ── Boutons filtres ───────────────────────────────────────────────────────────
class _FilterBtn extends StatelessWidget {
  const _FilterBtn({required this.icon, required this.onTap});
  final IconData icon; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Icon(icon, size: 20, color: _textDark)),
  );
}

class _FilterBtnDot extends StatelessWidget {
  const _FilterBtnDot({required this.icon, required this.onTap});
  final IconData icon; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0))),
        child: Icon(icon, size: 20, color: _textDark)),
      Positioned(top: 6, right: 6,
        child: Container(width: 8, height: 8,
          decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))),
    ]),
  );
}

















































// import 'package:flutter/material.dart';
// import '../profil_prestataire_screen.dart';

// const _green     = Color(0xFF2D7A4F);
// const _rose      = Color(0xFF2D7A4F);
// const _roseLight = Color(0xFFE8F5EE);
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);

// const _prestataires = [
//   {
//     'nom': '19thSignature',
//     'ville': 'Saint-Germain-en-Laye',
//     'lieu': 'En salon',
//     'dispo': true
//   },
//   {
//     'nom': 'Afro_beauty',
//     'ville': 'Louvres',
//     'lieu': 'Domicile & salon',
//     'dispo': true
//   },
//   {
//     'nom': 'Ashy.hair',
//     'ville': 'Cergy',
//     'lieu': 'Domicile & salon',
//     'dispo': true
//   },
//   {
//     'nom': 'NiniLocks',
//     'ville': 'Corbeil-Essonnes',
//     'lieu': 'À domicile',
//     'dispo': false
//   },
// ];

// class ClientRechercheTab extends StatefulWidget {
//   const ClientRechercheTab({super.key});

//   @override
//   State<ClientRechercheTab> createState() => _ClientRechercheTabState();
// }

// class _ClientRechercheTabState extends State<ClientRechercheTab> {
//   final _searchCtrl = TextEditingController();

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//         // ── Carte profil ─────────────────────────────────────────────
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFFF0F0F0),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: _roseLight,
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: _rose,
//                     size: 28,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Bonjour !',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: _textDark,
//                         ),
//                       ),
//                       Text(
//                         'Espace client',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: _textGrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: const Color(0xFFE0E0E0),
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.settings_outlined,
//                     size: 18,
//                     color: _textGrey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         // ── Barre recherche ───────────────────────────────────────────
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _searchCtrl,
//                   decoration: InputDecoration(
//                     hintText: 'Rechercher ville...',
//                     hintStyle: const TextStyle(
//                       color: _rose,
//                       fontSize: 14,
//                     ),
//                     prefixIcon: const Icon(
//                       Icons.search,
//                       color: _rose,
//                       size: 20,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(50),
//                       borderSide: const BorderSide(
//                         color: Color(0xFFE0E0E0),
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(50),
//                       borderSide: const BorderSide(
//                         color: Color(0xFFE0E0E0),
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(50),
//                       borderSide: const BorderSide(
//                         color: _rose,
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 10),

//               _FilterBtn(
//                 icon: Icons.location_on_outlined,
//                 onTap: () {},
//               ),

//               const SizedBox(width: 8),

//               _FilterBtn(
//                 icon: Icons.tune_outlined,
//                 onTap: () {},
//               ),

//               const SizedBox(width: 8),

//               _FilterBtnDot(
//                 icon: Icons.filter_list,
//                 onTap: () {},
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 12),

//         // ── Liste prestataires ────────────────────────────────────────
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: _prestataires.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (_, i) {

//               final p = _prestataires[i];
//               final dispo = p['dispo'] as bool;

//               return Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: const Color(0xFFF0F0F0),
//                   ),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x06000000),
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     )
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     Row(
//                       children: [

//                         Container(
//                           width: 52,
//                           height: 52,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _roseLight,
//                             border: Border.all(
//                               color: _rose.withOpacity(0.3),
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.person,
//                             color: _rose,
//                             size: 28,
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [

//                               Text(
//                                 p['nom'] as String,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w700,
//                                   color: _textDark,
//                                 ),
//                               ),

//                               const SizedBox(height: 4),

//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.location_on_outlined,
//                                     size: 14,
//                                     color: _textGrey,
//                                   ),

//                                   const SizedBox(width: 4),

//                                   Text(
//                                     p['ville'] as String,
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       color: _textGrey,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               const SizedBox(height: 2),

//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time,
//                                     size: 14,
//                                     color: _textGrey,
//                                   ),

//                                   const SizedBox(width: 4),

//                                   Text(
//                                     p['lieu'] as String,
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       color: _textGrey,
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               const SizedBox(height: 2),

//                               const Row(
//                                 children: [
//                                   Icon(
//                                     Icons.lock_outline,
//                                     size: 14,
//                                     color: _textGrey,
//                                   ),

//                                   SizedBox(width: 4),

//                                   Text(
//                                     'Contact réservé aux clients',
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: _textGrey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),

//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: dispo
//                                 ? _green.withOpacity(0.1)
//                                 : const Color(0xFFF2F2F7),
//                             borderRadius: BorderRadius.circular(50),
//                             border: Border.all(
//                               color: dispo
//                                   ? _green
//                                   : const Color(0xFFE0E0E0),
//                             ),
//                           ),
//                           child: Text(
//                             dispo ? 'Disponible' : 'Indisponible',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: dispo ? _green : _textGrey,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     Row(
//                       children: [

//                         Expanded(
//                           child: ElevatedButton(
//                             // ✅ Navigation vers le profil
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ProfilPrestataireScreen(
//                                   nom: p['nom'] as String,
//                                   ville: p['ville'] as String,
//                                 ),
//                               ),
//                             ),

//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _rose,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 12,
//                               ),
//                             ),

//                             child: const Text(
//                               'Voir profil',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 10),

//                         Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: const Color(0xFFE0E0E0),
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.calendar_today_outlined,
//                             size: 20,
//                             color: _textDark,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),

//         const SizedBox(height: 8),
//       ],
//     );
//   }
// }

// class _FilterBtn extends StatelessWidget {

//   const _FilterBtn({
//     required this.icon,
//     required this.onTap,
//   });

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//           border: Border.all(
//             color: const Color(0xFFE0E0E0),
//           ),
//         ),
//         child: Icon(
//           icon,
//           size: 20,
//           color: _textDark,
//         ),
//       ),
//     );
//   }
// }

// class _FilterBtnDot extends StatelessWidget {

//   const _FilterBtnDot({
//     required this.icon,
//     required this.onTap,
//   });

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {

//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         children: [

//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//             ),
//             child: Icon(
//               icon,
//               size: 20,
//               color: _textDark,
//             ),
//           ),

//           Positioned(
//             top: 6,
//             right: 6,
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                 color: _rose,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



























