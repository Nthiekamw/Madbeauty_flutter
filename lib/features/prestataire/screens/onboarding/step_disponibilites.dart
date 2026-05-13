// lib/features/prestataires/screens/onboarding/step_disponibilites.dart

import 'package:flutter/material.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

const _jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
const _heures = ['08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30',
  '12:00','12:30','13:00','13:30','14:00','14:30','15:00','15:30',
  '16:00','16:30','17:00','17:30','18:00','18:30','19:00','19:30','20:00'];

class _DispoRecurrente {
  final String jour, heureDebut, heureFin;
  _DispoRecurrente({required this.jour, required this.heureDebut, required this.heureFin});
}

class _DispoSpecifique {
  final DateTime date;
  final String heureDebut, heureFin;
  _DispoSpecifique({required this.date, required this.heureDebut, required this.heureFin});
}

class StepDisponibilites extends StatefulWidget {
  const StepDisponibilites({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepDisponibilites> createState() => _StepDisponibilitesState();
}

class _StepDisponibilitesState extends State<StepDisponibilites>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<_DispoRecurrente> _recurrentes = [];
  final List<_DispoSpecifique> _specifiques = [];

  String? _jourSel, _heureDebutRec, _heureFinRec, _heureDebutSpec, _heureFinSpec;
  DateTime? _dateSel;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _addRecurrente() {
    if (_jourSel == null || _heureDebutRec == null || _heureFinRec == null) return;
    setState(() {
      _recurrentes.add(_DispoRecurrente(
        jour: _jourSel!, heureDebut: _heureDebutRec!, heureFin: _heureFinRec!));
      _jourSel = null; _heureDebutRec = null; _heureFinRec = null;
    });
  }

  void _addSpecifique() {
    if (_dateSel == null || _heureDebutSpec == null || _heureFinSpec == null) return;
    setState(() {
      _specifiques.add(_DispoSpecifique(
        date: _dateSel!, heureDebut: _heureDebutSpec!, heureFin: _heureFinSpec!));
      _dateSel = null; _heureDebutSpec = null; _heureFinSpec = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.access_time, color: _textDark, size: 22),
        SizedBox(width: 8),
        Text('Gestion des disponibilités',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      const SizedBox(height: 16),

      // Onglets
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabCtrl,
          labelColor: _textDark,
          unselectedLabelColor: _textGrey,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 4)],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.repeat, size: 16), SizedBox(width: 6), Text('Récurrentes'),
            ])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.calendar_month, size: 16), SizedBox(width: 6), Text('Spécifiques'),
            ])),
          ],
        ),
      ),
      const SizedBox(height: 16),

      SizedBox(
        height: 520,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Récurrentes ───────────────────────────────────────────
            SingleChildScrollView(child: Column(children: [
              // Conseils
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 18),
                    SizedBox(width: 8),
                    Text('Conseils pour les disponibilités récurrentes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7A5800))),
                  ]),
                  SizedBox(height: 6),
                  Text(
                    '• Évitez de créer plusieurs disponibilités pour le même jour\n'
                    '• Groupez toutes les heures d\'un même jour en une seule disponibilité\n'
                    '• Cela améliore la lisibilité pour vos clients',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9A7020), height: 1.4)),
                ]),
              ),
              const SizedBox(height: 14),

              // Formulaire récurrente
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.access_time, color: _green, size: 18),
                    SizedBox(width: 8),
                    Text('Ajouter une disponibilité récurrente',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Pour des horaires fixes qui se répètent chaque semaine',
                    style: TextStyle(fontSize: 12, color: _textGrey)),
                  const SizedBox(height: 14),
                  const Text('Jour de la semaine',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  _dropdown('Sélectionner un jour', _jourSel, _jours,
                    (v) => setState(() => _jourSel = v)),
                  const SizedBox(height: 12),
                  const Text('Sélectionner les heures',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _dropdown('Début', _heureDebutRec, _heures,
                      (v) => setState(() => _heureDebutRec = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _dropdown('Fin', _heureFinRec, _heures,
                      (v) => setState(() => _heureFinRec = v))),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addRecurrente,
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Ajouter la disponibilité récurrente',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Liste récurrentes
              if (_recurrentes.isEmpty)
                _emptyState(Icons.access_time, 'Aucune disponibilité récurrente ajoutée',
                  'Ajoutez des créneaux qui se répètent chaque semaine')
              else
                ..._recurrentes.map((d) => _DispoTile(
                  label: '${d.jour}  ${d.heureDebut} – ${d.heureFin}',
                  icon: Icons.repeat,
                  onDelete: () => setState(() => _recurrentes.remove(d)),
                )),
            ])),

            // ── Spécifiques ───────────────────────────────────────────
            SingleChildScrollView(child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.calendar_month, color: _green, size: 18),
                    SizedBox(width: 8),
                    Text('Ajouter une disponibilité spécifique',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Idéal pour les créneaux exceptionnels, jours fériés, ou horaires variables',
                    style: TextStyle(fontSize: 12, color: _textGrey)),
                  const SizedBox(height: 14),
                  const Text('Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _dateSel = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_month, color: _green, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _dateSel != null
                            ? '${_dateSel!.day}/${_dateSel!.month}/${_dateSel!.year}'
                            : 'Choisir une date',
                          style: TextStyle(color: _dateSel != null ? _textDark : _textGrey, fontSize: 14)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Heure de début', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  _dropdown('Début', _heureDebutSpec, _heures,
                    (v) => setState(() => _heureDebutSpec = v)),
                  const SizedBox(height: 12),
                  const Text('Heure de fin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  _dropdown('Fin', _heureFinSpec, _heures,
                    (v) => setState(() => _heureFinSpec = v)),
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addSpecifique,
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Ajouter la disponibilité spécifique',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              if (_specifiques.isEmpty)
                _emptyState(Icons.calendar_month, 'Aucune disponibilité spécifique ajoutée',
                  'Ajoutez des créneaux pour des dates précises')
              else
                ..._specifiques.map((d) => _DispoTile(
                  label: '${d.date.day}/${d.date.month}/${d.date.year}  ${d.heureDebut} – ${d.heureFin}',
                  icon: Icons.calendar_month,
                  onDelete: () => setState(() => _specifiques.remove(d)),
                )),
            ])),
          ],
        ),
      ),

      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: SizedBox(height: 52,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: const Text('Annuler', style: TextStyle(color: _textDark)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(height: 52,
            child: ElevatedButton(
              onPressed: widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              child: const Text('Sauvegarder',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ]);
  }

  Widget _dropdown(String hint, String? val, List<String> items, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(
      value: val,
      hint: Text(hint, style: const TextStyle(color: _textGrey, fontSize: 14)),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );

  Widget _emptyState(IconData icon, String title, String sub) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _green.withOpacity(0.3), style: BorderStyle.solid),
    ),
    child: Column(children: [
      Icon(icon, size: 40, color: _green.withOpacity(0.4)),
      const SizedBox(height: 10),
      Text(title, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _green.withOpacity(0.7))),
      const SizedBox(height: 4),
      Text(sub, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: _green.withOpacity(0.6))),
    ]),
  );
}

class _DispoTile extends StatelessWidget {
  const _DispoTile({required this.label, required this.icon, required this.onDelete});
  final String label;
  final IconData icon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5EE),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2D7A4F).withOpacity(0.3)),
    ),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF2D7A4F), size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)))),
      GestureDetector(onTap: onDelete,
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
    ]),
  );
}