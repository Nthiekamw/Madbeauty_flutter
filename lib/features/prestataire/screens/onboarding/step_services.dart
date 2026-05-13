// lib/features/prestataires/screens/onboarding/step_services.dart

import 'package:flutter/material.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

// ── Modèle service ─────────────────────────────────────────────────────────────
class ServiceItem {
  final String id;
  String nom;
  String description;
  double prix;
  int dureeMinutes;
  String categorie;

  ServiceItem({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.dureeMinutes,
    required this.categorie,
  });
}

// ── Catégories ─────────────────────────────────────────────────────────────────
const _categories = [
  // Coiffure
  {'label': 'Tresses / Braids',              'emoji': '🪢', 'group': 'Coiffure'},
  {'label': 'Twists',                         'emoji': '🌀', 'group': 'Coiffure'},
  {'label': 'Vanilles',                       'emoji': '✨', 'group': 'Coiffure'},
  {'label': 'Locks / Dreadlocks',             'emoji': '🔒', 'group': 'Coiffure'},
  {'label': 'Perruques / Wigs',               'emoji': '💆', 'group': 'Coiffure'},
  {'label': 'Tissages / Extensions',          'emoji': '💇', 'group': 'Coiffure'},
  {'label': 'Ponytails & Chignons',           'emoji': '🎀', 'group': 'Coiffure'},
  {'label': 'Coupes & Contours',              'emoji': '✂️', 'group': 'Coiffure'},
  {'label': 'Barbe & Soins Visage',           'emoji': '🧔', 'group': 'Coiffure'},
  {'label': 'Colorations & Transformations',  'emoji': '🎨', 'group': 'Coiffure'},
  {'label': 'Soins Capillaires & Techniques', 'emoji': '🧴', 'group': 'Coiffure'},
  {'label': 'Entretien & Retouches',          'emoji': '🔧', 'group': 'Coiffure'},
  {'label': 'Coiffures Événementielles',      'emoji': '💍', 'group': 'Coiffure'},
  {'label': 'Coiffures Enfants',              'emoji': '👧', 'group': 'Coiffure'},
  // Maquillage
  {'label': 'Maquillage quotidien',           'emoji': '💄', 'group': 'Maquillage'},
  {'label': 'Maquillage de mariée',           'emoji': '👰', 'group': 'Maquillage'},
  {'label': 'Maquillage de soirée',           'emoji': '🌙', 'group': 'Maquillage'},
  {'label': 'Maquillage afro & contouring',   'emoji': '✨', 'group': 'Maquillage'},
  {'label': 'Maquillage yeux & sourcils',     'emoji': '👁',  'group': 'Maquillage'},
  {'label': 'Extension de cils',              'emoji': '👀', 'group': 'Maquillage'},
  {'label': 'Microblading sourcils',          'emoji': '🖊',  'group': 'Maquillage'},
  {'label': 'Maquillage permanent',           'emoji': '💋', 'group': 'Maquillage'},
  // Ongles
  {'label': 'Manucure classique',             'emoji': '💅', 'group': 'Ongles'},
  {'label': 'Pédicure',                       'emoji': '🦶', 'group': 'Ongles'},
  {'label': 'Pose de gel / acrylique',        'emoji': '💎', 'group': 'Ongles'},
  {'label': 'Nail art',                       'emoji': '🎨', 'group': 'Ongles'},
  {'label': 'Ongles en résine',               'emoji': '✨', 'group': 'Ongles'},
  {'label': 'Semi-permanent',                 'emoji': '🌸', 'group': 'Ongles'},
  {'label': 'Dépose & Soin ongles',           'emoji': '🧖', 'group': 'Ongles'},
];

class StepServices extends StatefulWidget {
  const StepServices({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepServices> createState() => _StepServicesState();
}

class _StepServicesState extends State<StepServices> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final List<ServiceItem> _services = [];
  bool _showAddForm    = false;
  bool _showSuggest    = false;
  String? _selectedCat;

  // Formulaire nouveau service
  final _nomCtrl   = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _prixCtrl  = TextEditingController();
  final _dureeCtrl = TextEditingController();

  // Formulaire suggestion
  final _suggestNomCtrl  = TextEditingController();
  final _suggestDescCtrl = TextEditingController();

  final _groups = ['Coiffure', 'Maquillage', 'Ongles'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _groups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nomCtrl.dispose(); _descCtrl.dispose();
    _prixCtrl.dispose(); _dureeCtrl.dispose();
    _suggestNomCtrl.dispose(); _suggestDescCtrl.dispose();
    super.dispose();
  }

  void _addService() {
    if (_selectedCat == null || _nomCtrl.text.isEmpty) return;
    setState(() {
      _services.add(ServiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomCtrl.text,
        description: _descCtrl.text,
        prix: double.tryParse(_prixCtrl.text) ?? 0,
        dureeMinutes: int.tryParse(_dureeCtrl.text) ?? 60,
        categorie: _selectedCat!,
      ));
      _nomCtrl.clear(); _descCtrl.clear();
      _prixCtrl.clear(); _dureeCtrl.clear();
      _selectedCat = null;
      _showAddForm = false;
    });
  }

  void _removeService(String id) =>
      setState(() => _services.removeWhere((s) => s.id == id));

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── En-tête ────────────────────────────────────────────────────
      const Row(children: [
        Icon(Icons.content_cut, color: _green, size: 22),
        SizedBox(width: 8),
        Text('Gestion des services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      const SizedBox(height: 16),

      // ── Bouton ajouter ─────────────────────────────────────────────
      SizedBox(width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _showAddForm = !_showAddForm),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('+ Ajouter un service',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // ── Formulaire ajout service ───────────────────────────────────
      if (_showAddForm) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _greenLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Créer un service',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 14),

            // Onglets catégories
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: _green,
                unselectedLabelColor: _textGrey,
                indicatorColor: _green,
                dividerColor: Colors.transparent,
                tabs: _groups.map((g) => Tab(text: g)).toList(),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabCtrl,
                children: _groups.map((group) {
                  final cats = _categories.where((c) => c['group'] == group).toList();
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.2,
                    children: cats.map((c) => GestureDetector(
                      onTap: () => setState(() => _selectedCat = c['label']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedCat == c['label'] ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedCat == c['label'] ? _green : const Color(0xFFE0E0E0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(children: [
                          Text(c['emoji']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(c['label']!,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: _selectedCat == c['label'] ? Colors.white : _textDark),
                            maxLines: 2, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    )).toList(),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            _inputField('Nom du service *', _nomCtrl, 'Ex: Tresses box braids'),
            _inputField('Description', _descCtrl, 'Décrivez votre service…'),
            Row(children: [
              Expanded(child: _inputField('Prix (€) *', _prixCtrl, '0', type: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('Durée (min) *', _dureeCtrl, '60', type: TextInputType.number)),
            ]),

            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: const Text('Créer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showAddForm = false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Annuler', style: TextStyle(color: _textDark)),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
      ],

      // ── Liste services ajoutés ─────────────────────────────────────
      if (_services.isEmpty && !_showAddForm)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
          ),
          child: Column(children: [
            Icon(Icons.content_cut, size: 48, color: _green.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Aucun service ajouté',
              style: TextStyle(fontSize: 15, color: _green.withOpacity(0.7), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Cliquez sur "Nouveau service" pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _green.withOpacity(0.6))),
          ]),
        ),

      ..._services.map((s) => _ServiceCard(
        service: s,
        onDelete: () => _removeService(s.id),
      )),

      if (_services.isNotEmpty) const SizedBox(height: 12),

      // ── Suggérer une catégorie ──────────────────────────────────────
      GestureDetector(
        onTap: () => setState(() => _showSuggest = !_showSuggest),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: const Column(children: [
            Icon(Icons.add, color: _textGrey),
            SizedBox(height: 4),
            Text('Suggérer une nouvelle catégorie',
              style: TextStyle(color: _textGrey, fontSize: 14)),
          ]),
        ),
      ),

      if (_showSuggest) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 10)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🎨 ', style: TextStyle(fontSize: 18)),
              const Expanded(child: Text('Suggérer une catégorie de service',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              GestureDetector(onTap: () => setState(() => _showSuggest = false),
                child: const Icon(Icons.close, color: _textGrey)),
            ]),
            const SizedBox(height: 4),
            const Text('Une catégorie manque ? Proposez-la !',
              style: TextStyle(fontSize: 13, color: _green)),
            const Divider(height: 20),
            const Text('Nom de la catégorie *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _suggestNomCtrl,
              decoration: _deco('Ex: Soins du cuir chevelu')),
            const SizedBox(height: 4),
            ValueListenableBuilder(valueListenable: _suggestNomCtrl,
              builder: (_, v, __) => Text('${v.text.length}/50 caractères',
                style: const TextStyle(fontSize: 12, color: _textGrey))),
            const SizedBox(height: 12),
            const Text('Description (optionnel)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _suggestDescCtrl, maxLines: 3,
              decoration: _deco('Décrivez les services que cette catégorie inclurait…')),
            const SizedBox(height: 4),
            ValueListenableBuilder(valueListenable: _suggestDescCtrl,
              builder: (_, v, __) => Text('${v.text.length}/200 caractères',
                style: const TextStyle(fontSize: 12, color: _textGrey))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showSuggest = false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('Annuler', style: TextStyle(color: _textDark)),
              ),
            ),
          ]),
        ),
      ],

      const SizedBox(height: 24),

      // ── Boutons bas ────────────────────────────────────────────────
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
              onPressed: _services.isNotEmpty ? widget.onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0xFFB0D4BE),
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

  Widget _inputField(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: type, decoration: _deco(hint)),
      const SizedBox(height: 10),
    ]);

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
  );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onDelete});
  final ServiceItem service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE8E8E8)),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.content_cut, color: _green, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(service.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
        Text(service.categorie, style: const TextStyle(fontSize: 12, color: _textGrey)),
        const SizedBox(height: 4),
        Row(children: [
          Text('${service.prix.toStringAsFixed(0)}€',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green)),
          const SizedBox(width: 10),
          Text('${service.dureeMinutes} min',
            style: const TextStyle(fontSize: 13, color: _textGrey)),
        ]),
      ])),
      IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
      ),
    ]),
  );
}