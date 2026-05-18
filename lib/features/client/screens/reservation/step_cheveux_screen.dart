import 'package:flutter/material.dart';
import 'step_recap_screen.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

const _typeCheveux  = ['Afro naturels', 'Défrisés', 'Colorés', 'Mixtes', 'Fins'];
const _longueurs    = ['Courts (< 5cm)', 'Mi-courts', 'Mi-longs', 'Longs (> 20cm)'];
const _etatsCheveux = [
  'Cheveux naturels', 'Cheveux relaxés/défrisés', 'Cheveux colorés',
  'Cheveux abîmés',  'Cheveux secs',              'Cheveux gras',
];

class StepCheveuxScreen extends StatefulWidget {
  final String nomPresta, service, duree, creneau;
  final int prix;
  const StepCheveuxScreen({super.key, required this.nomPresta,
    required this.service, required this.prix,
    required this.duree,   required this.creneau});

  @override
  State<StepCheveuxScreen> createState() => _StepCheveuxScreenState();
}

class _StepCheveuxScreenState extends State<StepCheveuxScreen> {
  String? _type, _longueur;
  final Set<String> _etats = {};
  final _precCtrl = TextEditingController();

  @override
  void dispose() { _precCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // ── Header ────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 3.5),
          child: Column(children: [

            // Stepper
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _SD(rem: rem), _SL(done: true,  rem: rem),
              _SD(rem: rem), _SL(done: true,  rem: rem),
              _SA(num: 3,    rem: rem),
              _SL(done: false, rem: rem),
              _SG(num: 4,    rem: rem),
            ]),
            SizedBox(height: rem * 2),
            Text('Informations sur vos cheveux',
              style: TextStyle(fontSize: rem * 3, color: _textGrey)),
            SizedBox(height: rem * 3),

            // Retour
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rem * 3.5, vertical: rem * 2),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(rem * 5),
                    border: Border.all(color: const Color(0xFFEDE0CC))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_back_rounded,
                      size: rem * 4, color: _textDark),
                    SizedBox(width: rem * 1.5),
                    Text('Retour',
                      style: TextStyle(fontSize: rem * 3.2, color: _textDark)),
                  ]),
                ),
              ),
            ),
          ]),
        ),

        // ── Corps ────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(rem * 4),
            child: Container(
              padding: EdgeInsets.all(rem * 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rem * 4),
                boxShadow: [BoxShadow(
                  color: _textDark.withOpacity(0.06),
                  blurRadius: 10, offset: const Offset(0, 3))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text('Informations sur vos cheveux',
                  style: TextStyle(
                    fontSize: rem * 5,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
                SizedBox(height: rem * 1.5),
                Text(
                  'Ces informations aideront votre coiffeur à mieux préparer votre rendez-vous',
                  style: TextStyle(
                    fontSize: rem * 3.2, color: _textGrey, height: 1.4)),
                SizedBox(height: rem * 4),

                // Résumé RDV
                Container(
                  padding: EdgeInsets.all(rem * 3.5),
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(rem * 3)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.calendar_month_rounded,
                        size: rem * 4, color: _gold),
                      SizedBox(width: rem * 2),
                      Flexible(child: Text(widget.creneau,
                        style: TextStyle(
                          fontSize: rem * 3.2,
                          color: _goldDark,
                          fontWeight: FontWeight.w600))),
                    ]),
                    SizedBox(height: rem * 1.5),
                    Row(children: [
                      Icon(Icons.content_cut_rounded,
                        size: rem * 4, color: _gold),
                      SizedBox(width: rem * 2),
                      Flexible(child: Text(
                        '${widget.service} – ${widget.prix}€ (${widget.duree})',
                        style: TextStyle(fontSize: rem * 3.2, color: _goldDark))),
                    ]),
                  ]),
                ),
                SizedBox(height: rem * 4),

                // Info row
                Row(children: [
                  Icon(Icons.info_outline_rounded,
                    size: rem * 4.5, color: _gold),
                  SizedBox(width: rem * 2),
                  Text('Informations sur vos cheveux',
                    style: TextStyle(
                      fontSize: rem * 3.8,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
                ]),
                SizedBox(height: rem * 1.5),
                Text(
                  'Quelques informations rapides pour aider votre coiffeur à mieux vous conseiller',
                  style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                SizedBox(height: rem * 4),

                // Type
                Text('Type de cheveux',
                  style: TextStyle(
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
                SizedBox(height: rem * 2),
                _Drop(
                  hint: 'Sélectionner votre type...',
                  value: _type,
                  items: _typeCheveux,
                  rem: rem,
                  onChanged: (v) => setState(() => _type = v)),
                SizedBox(height: rem * 4),

                // Longueur
                Text('Longueur',
                  style: TextStyle(
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
                SizedBox(height: rem * 2),
                _Drop(
                  hint: 'Sélectionner la longueur...',
                  value: _longueur,
                  items: _longueurs,
                  rem: rem,
                  onChanged: (v) => setState(() => _longueur = v)),
                SizedBox(height: rem * 4),

                // État
                Text('État de vos cheveux',
                  style: TextStyle(
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
                SizedBox(height: rem * 2.5),
                Wrap(
                  spacing: rem * 2,
                  runSpacing: rem * 2,
                  children: _etatsCheveux.map((e) {
                    final sel = _etats.contains(e);
                    return GestureDetector(
                      onTap: () => setState(() =>
                        sel ? _etats.remove(e) : _etats.add(e)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rem * 3, vertical: rem * 2),
                        decoration: BoxDecoration(
                          color: sel ? _goldLight : const Color(0xFFF8F5F0),
                          borderRadius: BorderRadius.circular(rem * 5),
                          border: Border.all(
                            color: sel ? _gold : const Color(0xFFEDE0CC),
                            width: sel ? 2 : 1)),
                        child: Text(e,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: rem * 3,
                            fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w400,
                            color: sel ? _goldDark : _textDark))));
                  }).toList()),
                SizedBox(height: rem * 4),

                // Précisions
                Text('Précisions (optionnel)',
                  style: TextStyle(
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w600,
                    color: _textDark)),
                SizedBox(height: rem * 2),
                TextField(
                  controller: _precCtrl,
                  maxLines: 4,
                  style: TextStyle(fontSize: rem * 3.5, color: _textDark),
                  decoration: InputDecoration(
                    hintText:
                      'Ajoutez des détails importants (allergies, préférences, traitements récents...)',
                    hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3),
                    filled: true,
                    fillColor: const Color(0xFFF8F5F0),
                    contentPadding: EdgeInsets.all(rem * 3.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(rem * 3),
                      borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(rem * 3),
                      borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(rem * 3),
                      borderSide: BorderSide(color: _gold, width: 2)),
                  )),
              ]),
            ),
          ),
        ),

        // ── Bouton continuer ──────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, rem * 5),
          color: Colors.white,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => StepRecapScreen(
                nomPresta: widget.nomPresta,
                service:   widget.service,
                prix:      widget.prix,
                duree:     widget.duree,
                creneau:   widget.creneau))),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rem * 4),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(rem * 8),
                boxShadow: [BoxShadow(
                  color: _gold.withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 5))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: rem * 5.5),
                SizedBox(width: rem * 2.5),
                Text('Continuer vers la confirmation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w700)),
              ])),
          ),
        ),
      ])),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────────────────
class _Drop extends StatelessWidget {
  const _Drop({required this.hint, required this.value, required this.items,
    required this.onChanged, required this.rem});
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double rem;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    hint: Text(hint, style: TextStyle(color: _textGrey, fontSize: rem * 3.2)),
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F5F0),
      contentPadding: EdgeInsets.symmetric(
        horizontal: rem * 3.5, vertical: rem * 3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rem * 3),
        borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rem * 3),
        borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rem * 3),
        borderSide: BorderSide(color: _gold, width: 2)),
    ),
    items: items.map((e) => DropdownMenuItem(
      value: e,
      child: Text(e, style: TextStyle(
        fontSize: rem * 3.5, color: _textDark)))).toList(),
    onChanged: onChanged,
  );
}

// ── Stepper widgets ───────────────────────────────────────────────────────────
class _SD extends StatelessWidget {
  const _SD({required this.rem});
  final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 8, height: rem * 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold),
    child: Icon(Icons.check_rounded, color: Colors.white, size: rem * 4.5));
}

class _SA extends StatelessWidget {
  const _SA({required this.num, required this.rem});
  final int num; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 8, height: rem * 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold),
    child: Center(child: Text('$num',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: rem * 3.5))));
}

class _SG extends StatelessWidget {
  const _SG({required this.num, required this.rem});
  final int num; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 8, height: rem * 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFEDE0CC)),
    child: Center(child: Text('$num',
      style: TextStyle(
        color: _textGrey,
        fontWeight: FontWeight.w700,
        fontSize: rem * 3.5))));
}

class _SL extends StatelessWidget {
  const _SL({required this.done, required this.rem});
  final bool done; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: rem * 7, height: 2,
    color: done ? _gold : const Color(0xFFEDE0CC));
}






















































































// import 'package:flutter/material.dart';
// import 'step_recap_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// const _typeCheveux   = ['Afro naturels', 'Défrisés', 'Colorés', 'Mixtes', 'Fins'];
// const _longueurs     = ['Courts (< 5cm)', 'Mi-courts', 'Mi-longs', 'Longs (> 20cm)'];
// const _etatsCheveux  = ['Cheveux naturels', 'Cheveux relaxés/défrisés', 'Cheveux colorés', 'Cheveux abîmés', 'Cheveux secs', 'Cheveux gras'];

// class StepCheveuxScreen extends StatefulWidget {
//   final String nomPresta, service, duree, creneau;
//   final int prix;
//   const StepCheveuxScreen({super.key, required this.nomPresta, required this.service,
//     required this.prix, required this.duree, required this.creneau});

//   @override
//   State<StepCheveuxScreen> createState() => _StepCheveuxScreenState();
// }

// class _StepCheveuxScreenState extends State<StepCheveuxScreen> {
//   String? _type, _longueur;
//   final Set<String> _etats = {};
//   final _precCtrl = TextEditingController();

//   @override
//   void dispose() { _precCtrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(child: Column(children: [

//         // Header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//           child: Column(children: [
//             // Stepper
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               _StepDone(), _StepLine(), _StepDone(), _StepLine(),
//               _StepActive(num: 3), _StepLineGrey(),
//               _StepGrey(num: 4),
//             ]),
//             const SizedBox(height: 8),
//             const Text('Informations sur vos cheveux',
//               style: TextStyle(fontSize: 13, color: _textGrey)),
//             const SizedBox(height: 12),

//             // Bouton retour
//             Align(alignment: Alignment.centerLeft,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(50),
//                     border: Border.all(color: const Color(0xFFE0E0E0))),
//                   child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.arrow_back, size: 16, color: _textDark),
//                     SizedBox(width: 4),
//                     Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
//                   ]),
//                 ),
//               ),
//             ),
//           ]),
//         ),

//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFF0F0F0))),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//                 const Text('Informations sur vos cheveux',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                 const SizedBox(height: 4),
//                 const Text('Ces informations aideront votre coiffeur à mieux préparer votre rendez-vous',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                 const SizedBox(height: 16),

//                 // Résumé RDV
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(12)),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       const Icon(Icons.calendar_today_outlined, size: 14, color: _green),
//                       const SizedBox(width: 6),
//                       Text(widget.creneau, style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600)),
//                     ]),
//                     const SizedBox(height: 4),
//                     Row(children: [
//                       const Icon(Icons.person_outline, size: 14, color: _green),
//                       const SizedBox(width: 6),
//                       Text('${widget.service} – ${widget.prix}€ (${widget.duree})',
//                         style: const TextStyle(fontSize: 13, color: _green)),
//                     ]),
//                   ]),
//                 ),
//                 const SizedBox(height: 20),

//                 // Info section
//                 Row(children: [
//                   const Icon(Icons.info_outline, size: 18, color: _green),
//                   const SizedBox(width: 8),
//                   const Text('Informations sur vos cheveux',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                 ]),
//                 const SizedBox(height: 4),
//                 const Text('Quelques informations rapides pour aider votre coiffeur à mieux vous conseiller',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 13, color: _textGrey)),
//                 const SizedBox(height: 16),

//                 // Type de cheveux
//                 const Text('Type de cheveux',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 _Dropdown(hint: 'Sélectionner votre type...', value: _type, items: _typeCheveux,
//                   onChanged: (v) => setState(() => _type = v)),
//                 const SizedBox(height: 16),

//                 // Longueur
//                 const Text('Longueur',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 _Dropdown(hint: 'Sélectionner la longueur...', value: _longueur, items: _longueurs,
//                   onChanged: (v) => setState(() => _longueur = v)),
//                 const SizedBox(height: 16),

//                 // État des cheveux
//                 const Text('État de vos cheveux',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 10),
//                 GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   childAspectRatio: 2.8,
//                   children: _etatsCheveux.map((e) {
//                     final sel = _etats.contains(e);
//                     return GestureDetector(
//                       onTap: () => setState(() => sel ? _etats.remove(e) : _etats.add(e)),
//                       child: Container(
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: sel ? _greenLight : Colors.white,
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(color: sel ? _green : const Color(0xFFE0E0E0), width: sel ? 2 : 1)),
//                         child: Text(e, textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
//                             color: sel ? _green : _textDark)),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 16),

//                 // Précisions
//                 const Text('Précisions (optionnel)',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 TextField(controller: _precCtrl, maxLines: 4,
//                   decoration: InputDecoration(
//                     hintText: 'Ajoutez des détails importants pour votre coiffeur (allergies, préférences, traitements récents, etc.)',
//                     hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
//                     filled: true, fillColor: const Color(0xFFF8F8F8),
//                     contentPadding: const EdgeInsets.all(14),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//                     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//                     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
//                   )),
//               ]),
//             ),
//           ),
//         ),

//         // Bouton continuer
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: ElevatedButton(
//             onPressed: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) => StepRecapScreen(
//                 nomPresta: widget.nomPresta,
//                 service: widget.service,
//                 prix: widget.prix,
//                 duree: widget.duree,
//                 creneau: widget.creneau,
//               ),
//             )),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 52),
//             ),
//             child: const Text('Continuer vers la confirmation',
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ])),
//     );
//   }
// }

// class _Dropdown extends StatelessWidget {
//   const _Dropdown({required this.hint, required this.value, required this.items, required this.onChanged});
//   final String hint; final String? value; final List<String> items; final ValueChanged<String?> onChanged;

//   @override
//   Widget build(BuildContext context) => DropdownButtonFormField<String>(
//     value: value,
//     hint: Text(hint, style: const TextStyle(color: _textGrey, fontSize: 14)),
//     decoration: InputDecoration(
//       filled: true, fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
//     ),
//     items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//     onChanged: onChanged,
//   );
// }

// class _StepDone extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: const Icon(Icons.check, color: Colors.white, size: 18));
// }
// class _StepActive extends StatelessWidget {
//   const _StepActive({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepGrey extends StatelessWidget {
//   const _StepGrey({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF2F2F7)),
//     child: Center(child: Text('$num', style: const TextStyle(color: _textGrey, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepLine extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
// }
// class _StepLineGrey extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: const Color(0xFFE0E0E0));
// }









































// import 'package:flutter/material.dart';
// import 'step_recap_screen.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);

// const _typeCheveux   = ['Afro naturels', 'Défrisés', 'Colorés', 'Mixtes', 'Fins'];
// const _longueurs     = ['Courts (< 5cm)', 'Mi-courts', 'Mi-longs', 'Longs (> 20cm)'];
// const _etatsCheveux  = ['Cheveux naturels', 'Cheveux relaxés/défrisés', 'Cheveux colorés', 'Cheveux abîmés', 'Cheveux secs', 'Cheveux gras'];

// class StepCheveuxScreen extends StatefulWidget {
//   final String nomPresta, service, duree, creneau;
//   final int prix;
//   const StepCheveuxScreen({super.key, required this.nomPresta, required this.service,
//     required this.prix, required this.duree, required this.creneau});

//   @override
//   State<StepCheveuxScreen> createState() => _StepCheveuxScreenState();
// }

// class _StepCheveuxScreenState extends State<StepCheveuxScreen> {
//   String? _type, _longueur;
//   final Set<String> _etats = {};
//   final _precCtrl = TextEditingController();

//   @override
//   void dispose() { _precCtrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(child: Column(children: [

//         // Header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//           child: Column(children: [
//             // Stepper
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               _StepDone(), _StepLine(), _StepDone(), _StepLine(),
//               _StepActive(num: 3), _StepLineGrey(),
//               _StepGrey(num: 4),
//             ]),
//             const SizedBox(height: 8),
//             const Text('Informations sur vos cheveux',
//               style: TextStyle(fontSize: 13, color: _textGrey)),
//             const SizedBox(height: 12),

//             // Bouton retour
//             Align(alignment: Alignment.centerLeft,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(50),
//                     border: Border.all(color: const Color(0xFFE0E0E0))),
//                   child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.arrow_back, size: 16, color: _textDark),
//                     SizedBox(width: 4),
//                     Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
//                   ]),
//                 ),
//               ),
//             ),
//           ]),
//         ),

//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFF0F0F0))),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//                 const Text('Informations sur vos cheveux',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
//                 const SizedBox(height: 4),
//                 const Text('Ces informations aideront votre coiffeur à mieux préparer votre rendez-vous',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                 const SizedBox(height: 16),

//                 // Résumé RDV
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(12)),
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     Row(children: [
//                       const Icon(Icons.calendar_today_outlined, size: 14, color: _green),
//                       const SizedBox(width: 6),
//                       Text(widget.creneau, style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600)),
//                     ]),
//                     const SizedBox(height: 4),
//                     Row(children: [
//                       const Icon(Icons.person_outline, size: 14, color: _green),
//                       const SizedBox(width: 6),
//                       Text('${widget.service} – ${widget.prix}€ (${widget.duree})',
//                         style: const TextStyle(fontSize: 13, color: _green)),
//                     ]),
//                   ]),
//                 ),
//                 const SizedBox(height: 20),

//                 // Info section
//                 Row(children: [
//                   const Icon(Icons.info_outline, size: 18, color: _green),
//                   const SizedBox(width: 8),
//                   const Text('Informations sur vos cheveux',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                 ]),
//                 const SizedBox(height: 4),
//                 const Text('Quelques informations rapides pour aider votre coiffeur à mieux vous conseiller',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 13, color: _textGrey)),
//                 const SizedBox(height: 16),

//                 // Type de cheveux
//                 const Text('Type de cheveux',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 _Dropdown(hint: 'Sélectionner votre type...', value: _type, items: _typeCheveux,
//                   onChanged: (v) => setState(() => _type = v)),
//                 const SizedBox(height: 16),

//                 // Longueur
//                 const Text('Longueur',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 _Dropdown(hint: 'Sélectionner la longueur...', value: _longueur, items: _longueurs,
//                   onChanged: (v) => setState(() => _longueur = v)),
//                 const SizedBox(height: 16),

//                 // État des cheveux
//                 const Text('État de vos cheveux',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 10),
//                 GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   childAspectRatio: 2.8,
//                   children: _etatsCheveux.map((e) {
//                     final sel = _etats.contains(e);
//                     return GestureDetector(
//                       onTap: () => setState(() => sel ? _etats.remove(e) : _etats.add(e)),
//                       child: Container(
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: sel ? _greenLight : Colors.white,
//                           borderRadius: BorderRadius.circular(50),
//                           border: Border.all(color: sel ? _green : const Color(0xFFE0E0E0), width: sel ? 2 : 1)),
//                         child: Text(e, textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
//                             color: sel ? _green : _textDark)),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 16),

//                 // Précisions
//                 const Text('Précisions (optionnel)',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                 const SizedBox(height: 8),
//                 TextField(controller: _precCtrl, maxLines: 4,
//                   decoration: InputDecoration(
//                     hintText: 'Ajoutez des détails importants pour votre coiffeur (allergies, préférences, traitements récents, etc.)',
//                     hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
//                     filled: true, fillColor: const Color(0xFFF8F8F8),
//                     contentPadding: const EdgeInsets.all(14),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//                     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//                     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
//                   )),
//               ]),
//             ),
//           ),
//         ),

//         // Bouton continuer
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//           decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
//           child: ElevatedButton(
//             onPressed: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) => StepRecapScreen(
//                 nomPresta: widget.nomPresta,
//                 service: widget.service,
//                 prix: widget.prix,
//                 duree: widget.duree,
//                 creneau: widget.creneau,
//               ),
//             )),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _green,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 52),
//             ),
//             child: const Text('Continuer vers la confirmation',
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//         ),
//       ])),
//     );
//   }
// }

// class _Dropdown extends StatelessWidget {
//   const _Dropdown({required this.hint, required this.value, required this.items, required this.onChanged});
//   final String hint; final String? value; final List<String> items; final ValueChanged<String?> onChanged;

//   @override
//   Widget build(BuildContext context) => DropdownButtonFormField<String>(
//     value: value,
//     hint: Text(hint, style: const TextStyle(color: _textGrey, fontSize: 14)),
//     decoration: InputDecoration(
//       filled: true, fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
//     ),
//     items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//     onChanged: onChanged,
//   );
// }

// class _StepDone extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: const Icon(Icons.check, color: Colors.white, size: 18));
// }
// class _StepActive extends StatelessWidget {
//   const _StepActive({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
//     child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepGrey extends StatelessWidget {
//   const _StepGrey({required this.num});
//   final int num;
//   @override
//   Widget build(BuildContext context) => Container(width: 36, height: 36,
//     decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF2F2F7)),
//     child: Center(child: Text('$num', style: const TextStyle(color: _textGrey, fontWeight: FontWeight.w700, fontSize: 15))));
// }
// class _StepLine extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
// }
// class _StepLineGrey extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => Container(width: 40, height: 2, color: const Color(0xFFE0E0E0));
// }