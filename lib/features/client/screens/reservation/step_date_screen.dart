
import 'package:flutter/material.dart';
import 'step_cheveux_screen.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

const _creneaux = [
  {'jour': 'Lundi 18 Mai',    'heures': ['11:30']},
  {'jour': 'Mardi 19 Mai',    'heures': ['14:00']},
  {'jour': 'Mercredi 20 Mai', 'heures': ['11:30', '12:00']},
  {'jour': 'Lundi 25 Mai',    'heures': ['11:30']},
  {'jour': 'Mardi 26 Mai',    'heures': ['14:00']},
  {'jour': 'Mercredi 27 Mai', 'heures': ['11:30', '12:00']},
];

class StepDateScreen extends StatefulWidget {
  final String nomPresta, service, duree;
  final int prix;
  const StepDateScreen({super.key, required this.nomPresta,
    required this.service, required this.prix, required this.duree});

  @override
  State<StepDateScreen> createState() => _StepDateScreenState();
}

class _StepDateScreenState extends State<StepDateScreen> {
  String? _selectedCreneau;

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
              _SA(num: 2,    rem: rem),
              _SL(done: false, rem: rem),
              _SG(num: 3,    rem: rem),
              _SL(done: false, rem: rem),
              _SG(num: 4,    rem: rem),
            ]),
            SizedBox(height: rem * 2),
            Text('Sélectionnez un créneau',
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

        // ── Résumé service ────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 4, rem * 4, 0),
          child: Container(
            padding: EdgeInsets.all(rem * 3.5),
            decoration: BoxDecoration(
              color: _goldLight,
              borderRadius: BorderRadius.circular(rem * 3.5),
              border: Border.all(color: _gold.withOpacity(0.3))),
            child: Row(children: [
              Container(
                width: rem * 10, height: rem * 10,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  shape: BoxShape.circle),
                child: Icon(Icons.content_cut_rounded,
                  color: _goldDark, size: rem * 5.5)),
              SizedBox(width: rem * 3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.service,
                  style: TextStyle(
                    fontSize: rem * 3.5,
                    fontWeight: FontWeight.w700,
                    color: _textDark),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: rem),
                Row(children: [
                  Icon(Icons.access_time_rounded,
                    size: rem * 3.2, color: _textGrey),
                  SizedBox(width: rem),
                  Text(widget.duree,
                    style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                ]),
              ])),
              Text('${widget.prix}€',
                style: TextStyle(
                  fontSize: rem * 5,
                  fontWeight: FontWeight.w900,
                  color: _gold)),
            ]),
          ),
        ),
        SizedBox(height: rem * 4),

        // ── Titre ─────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rem * 4),
          child: Row(children: [
            Icon(Icons.calendar_month_rounded, color: _gold, size: rem * 5.5),
            SizedBox(width: rem * 2),
            Text('Choisissez un créneau',
              style: TextStyle(
                fontSize: rem * 4.5,
                fontWeight: FontWeight.w800,
                color: _textDark)),
          ]),
        ),
        SizedBox(height: rem * 3),

        // ── Liste créneaux ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: _creneaux.map((c) => Container(
                margin: EdgeInsets.only(bottom: rem * 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.05),
                    blurRadius: 8, offset: const Offset(0, 3))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Jour
                  Padding(
                    padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 2.5),
                    child: Row(children: [
                      Icon(Icons.today_rounded, color: _gold, size: rem * 4.5),
                      SizedBox(width: rem * 2),
                      Text(c['jour'] as String,
                        style: TextStyle(
                          fontSize: rem * 3.8,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                    ]),
                  ),

                  // Séparateur
                  Container(height: 1, color: const Color(0xFFEDE0CC)),

                  // Créneaux horaires
                  Padding(
                    padding: EdgeInsets.all(rem * 3.5),
                    child: Wrap(
                      spacing: rem * 2.5,
                      runSpacing: rem * 2,
                      children: (c['heures'] as List<String>).map((h) {
                        final key = '${c['jour']}_$h';
                        final sel = _selectedCreneau == key;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCreneau = key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: rem * 5, vertical: rem * 2.5),
                            decoration: BoxDecoration(
                              color: sel ? _gold : const Color(0xFFF8F5F0),
                              borderRadius: BorderRadius.circular(rem * 6),
                              border: Border.all(
                                color: sel ? _gold : const Color(0xFFEDE0CC),
                                width: sel ? 0 : 1),
                              boxShadow: sel ? [BoxShadow(
                                color: _gold.withOpacity(0.4),
                                blurRadius: 8, offset: const Offset(0, 3))] : null),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(
                                sel
                                  ? Icons.check_circle_rounded
                                  : Icons.access_time_rounded,
                                size: rem * 3.8,
                                color: sel ? Colors.white : _textGrey),
                              SizedBox(width: rem * 1.5),
                              Text(h, style: TextStyle(
                                fontSize: rem * 3.5,
                                fontWeight: FontWeight.w700,
                                color: sel ? Colors.white : _textDark)),
                            ]),
                          ),
                        );
                      }).toList()),
                  ),
                ]),
              )).toList(),
            ),
          ),
        ),

        // ── Bouton continuer ──────────────────────────────────────────
        if (_selectedCreneau != null)
          Container(
            padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, rem * 5),
            color: Colors.white,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => StepCheveuxScreen(
                  nomPresta: widget.nomPresta,
                  service:   widget.service,
                  prix:      widget.prix,
                  duree:     widget.duree,
                  creneau:   _selectedCreneau!.replaceAll('_', ' ')))),
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
                  Text('Continuer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rem * 4,
                      fontWeight: FontWeight.w700)),
                  SizedBox(width: rem * 2),
                  Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: rem * 5),
                ])),
            ),
          ),
      ])),
    );
  }
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
