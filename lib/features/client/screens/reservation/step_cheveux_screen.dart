import 'package:flutter/material.dart';
import 'step_recap_screen.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _typeCheveux   = ['Afro naturels', 'Défrisés', 'Colorés', 'Mixtes', 'Fins'];
const _longueurs     = ['Courts (< 5cm)', 'Mi-courts', 'Mi-longs', 'Longs (> 20cm)'];
const _etatsCheveux  = ['Cheveux naturels', 'Cheveux relaxés/défrisés', 'Cheveux colorés', 'Cheveux abîmés', 'Cheveux secs', 'Cheveux gras'];

class StepCheveuxScreen extends StatefulWidget {
  final String nomPresta, service, duree, creneau;
  final int prix;
  const StepCheveuxScreen({super.key, required this.nomPresta, required this.service,
    required this.prix, required this.duree, required this.creneau});

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(children: [
            // Stepper
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _StepDone(), _StepLine(), _StepDone(), _StepLine(),
              _StepActive(num: 3), _StepLineGrey(),
              _StepGrey(num: 4),
            ]),
            const SizedBox(height: 8),
            const Text('Informations sur vos cheveux',
              style: TextStyle(fontSize: 13, color: _textGrey)),
            const SizedBox(height: 12),

            // Bouton retour
            Align(alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFE0E0E0))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_back, size: 16, color: _textDark),
                    SizedBox(width: 4),
                    Text('Retour', style: TextStyle(fontSize: 14, color: _textDark)),
                  ]),
                ),
              ),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const Text('Informations sur vos cheveux',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                const SizedBox(height: 4),
                const Text('Ces informations aideront votre coiffeur à mieux préparer votre rendez-vous',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
                const SizedBox(height: 16),

                // Résumé RDV
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: _green),
                      const SizedBox(width: 6),
                      Text(widget.creneau, style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_outline, size: 14, color: _green),
                      const SizedBox(width: 6),
                      Text('${widget.service} – ${widget.prix}€ (${widget.duree})',
                        style: const TextStyle(fontSize: 13, color: _green)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),

                // Info section
                Row(children: [
                  const Icon(Icons.info_outline, size: 18, color: _green),
                  const SizedBox(width: 8),
                  const Text('Informations sur vos cheveux',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                ]),
                const SizedBox(height: 4),
                const Text('Quelques informations rapides pour aider votre coiffeur à mieux vous conseiller',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _textGrey)),
                const SizedBox(height: 16),

                // Type de cheveux
                const Text('Type de cheveux',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                const SizedBox(height: 8),
                _Dropdown(hint: 'Sélectionner votre type...', value: _type, items: _typeCheveux,
                  onChanged: (v) => setState(() => _type = v)),
                const SizedBox(height: 16),

                // Longueur
                const Text('Longueur',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                const SizedBox(height: 8),
                _Dropdown(hint: 'Sélectionner la longueur...', value: _longueur, items: _longueurs,
                  onChanged: (v) => setState(() => _longueur = v)),
                const SizedBox(height: 16),

                // État des cheveux
                const Text('État de vos cheveux',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.8,
                  children: _etatsCheveux.map((e) {
                    final sel = _etats.contains(e);
                    return GestureDetector(
                      onTap: () => setState(() => sel ? _etats.remove(e) : _etats.add(e)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? _greenLight : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: sel ? _green : const Color(0xFFE0E0E0), width: sel ? 2 : 1)),
                        child: Text(e, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? _green : _textDark)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Précisions
                const Text('Précisions (optionnel)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                const SizedBox(height: 8),
                TextField(controller: _precCtrl, maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ajoutez des détails importants pour votre coiffeur (allergies, préférences, traitements récents, etc.)',
                    hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
                    filled: true, fillColor: const Color(0xFFF8F8F8),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
                  )),
              ]),
            ),
          ),
        ),

        // Bouton continuer
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => StepRecapScreen(
                nomPresta: widget.nomPresta,
                service: widget.service,
                prix: widget.prix,
                duree: widget.duree,
                creneau: widget.creneau,
              ),
            )),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: const Text('Continuer vers la confirmation',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ])),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.hint, required this.value, required this.items, required this.onChanged});
  final String hint; final String? value; final List<String> items; final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    hint: Text(hint, style: const TextStyle(color: _textGrey, fontSize: 14)),
    decoration: InputDecoration(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: onChanged,
  );
}

class _StepDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 36, height: 36,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
    child: const Icon(Icons.check, color: Colors.white, size: 18));
}
class _StepActive extends StatelessWidget {
  const _StepActive({required this.num});
  final int num;
  @override
  Widget build(BuildContext context) => Container(width: 36, height: 36,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
    child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))));
}
class _StepGrey extends StatelessWidget {
  const _StepGrey({required this.num});
  final int num;
  @override
  Widget build(BuildContext context) => Container(width: 36, height: 36,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF2F2F7)),
    child: Center(child: Text('$num', style: const TextStyle(color: _textGrey, fontWeight: FontWeight.w700, fontSize: 15))));
}
class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 2, color: _green);
}
class _StepLineGrey extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 40, height: 2, color: const Color(0xFFE0E0E0));
}