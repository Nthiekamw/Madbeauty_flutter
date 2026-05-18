

















import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

class PrestataireHubScreen extends StatefulWidget {
  const PrestataireHubScreen({super.key});
  @override
  State<PrestataireHubScreen> createState() => _PrestataireHubScreenState();
}

class _PrestataireHubScreenState extends State<PrestataireHubScreen> {
  int  _navIndex       = 0;
  bool _hasSubscription = false;

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // ── Top bar ───────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 2, rem * 3),
          child: Row(children: [
            Container(
              width: rem * 10, height: rem * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _goldLight,
                border: Border.all(color: _gold.withOpacity(0.4), width: 2)),
              child: Icon(Icons.person_rounded, color: _gold, size: rem * 5.5)),
            SizedBox(width: rem * 2.5),
            Text('Espace Pro', style: TextStyle(
              fontSize: rem * 4.2,
              fontWeight: FontWeight.w700,
              color: _textDark)),
            const Spacer(),

            // Thème
            PopupMenuButton<String>(
              icon: Icon(Icons.wb_sunny_outlined, size: rem * 5.5, color: _textDark),
              onSelected: (v) {},
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
                const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
                const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
              ],
            ),

            // Notifications
            Stack(children: [
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Notifications'),
                    content: const Text('Aucune notification'),
                    actions: [TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))],
                  )),
                icon: Icon(Icons.notifications_outlined, size: rem * 5.5, color: _textDark),
                padding: EdgeInsets.all(rem * 1.5),
                constraints: const BoxConstraints()),
              Positioned(top: rem * 1.5, right: rem * 1.5,
                child: Container(
                  width: rem * 2, height: rem * 2,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ]),

            // Aide
            PopupMenuButton<String>(
              icon: Icon(Icons.help_outline, size: rem * 5.5, color: _textDark),
              onSelected: (v) {},
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
                const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
              ],
            ),

            // Déconnexion
            IconButton(
              onPressed: () => context.go('/'),
              icon: Icon(Icons.logout_rounded, size: rem * 5.5, color: _textDark),
              padding: EdgeInsets.all(rem * 1.5),
              constraints: const BoxConstraints()),
          ]),
        ),

        // ── Contenu ───────────────────────────────────────────────────
        Expanded(
          child: IndexedStack(
            index: _navIndex,
            children: [
              _AccueilTab(hasSubscription: _hasSubscription),
              _RendezVousTab(hasSubscription: _hasSubscription),
              _ChatTab(hasSubscription: _hasSubscription),
              _ClientsTab(hasSubscription: _hasSubscription),
            ],
          ),
        ),

        // ── Navigation bas ────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEDE0CC))),
            boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))]),
          child: Row(children: [
            _NavBtn(icon: Icons.home_outlined,           iconActive: Icons.home_rounded,          label: 'Accueil',     index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavBtn(icon: Icons.calendar_today_outlined, iconActive: Icons.calendar_today,         label: 'Rendez-vous', index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavBtn(icon: Icons.chat_bubble_outline,     iconActive: Icons.chat_bubble_rounded,    label: 'Chat',        index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavBtn(icon: Icons.people_outline,          iconActive: Icons.people_rounded,         label: 'Clients',     index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
          ]),
        ),
      ])),
    );
  }
}

// ─── ONGLET ACCUEIL ───────────────────────────────────────────────────────────
class _AccueilTab extends StatelessWidget {
  const _AccueilTab({required this.hasSubscription});
  final bool hasSubscription;

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(rem * 4),
      child: Column(children: [

        // ── Carte profil ──────────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(rem * 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rem * 4),
            boxShadow: [BoxShadow(
              color: _textDark.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, 3))]),
          child: Column(children: [
            Row(children: [
              Container(
                width: rem * 13, height: rem * 13,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
                child: Icon(Icons.person_rounded, color: _gold, size: rem * 7)),
              SizedBox(width: rem * 3),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour !', style: TextStyle(
                  fontSize: rem * 4, fontWeight: FontWeight.w700, color: _textDark)),
                Text('Espace Prestataire', style: TextStyle(
                  fontSize: rem * 3.2, color: _textGrey)),
              ])),
              _CB(icon: Icons.refresh_rounded,        rem: rem, onTap: () {}),
              _CB(icon: Icons.credit_card_outlined,   rem: rem, onTap: () {}),
              _CB(icon: Icons.share_outlined,         rem: rem, onTap: () {
                showModalBottomSheet(context: context, builder: (_) => SafeArea(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFEDE0CC), borderRadius: BorderRadius.circular(2))),
                    ListTile(leading: Icon(Icons.copy,  color: _gold), title: const Text('Copier le lien'), onTap: () => Navigator.pop(context)),
                    ListTile(leading: Icon(Icons.share, color: _gold), title: const Text('Partager'),        onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 8),
                  ])));
              }),
              _CB(icon: Icons.settings_outlined, rem: rem, onTap: () {
                showModalBottomSheet(context: context, isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _ProfileSheet());
              }),
            ]),
            Divider(height: rem * 6, color: const Color(0xFFEDE0CC)),

            // Bannière profil incomplet
            GestureDetector(
              onTap: () => context.go('/prestataire/onboarding'),
              child: Container(
                padding: EdgeInsets.all(rem * 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(rem * 3.5),
                  border: Border.all(color: Colors.red.withOpacity(0.25))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(rem * 1.5),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Icon(Icons.error_outline, color: Colors.white, size: rem * 4)),
                    SizedBox(width: rem * 2.5),
                    Expanded(child: Text('Complétez votre profil pour recevoir des clients',
                      style: TextStyle(fontSize: rem * 3.5, fontWeight: FontWeight.w700, color: _textDark))),
                    Icon(Icons.chevron_right_rounded, color: _textGrey, size: rem * 5),
                  ]),
                  SizedBox(height: rem * 2),
                  Text('Complétez votre profil pour commencer à recevoir des réservations.',
                    style: TextStyle(fontSize: rem * 3.2, color: _textGrey, height: 1.4)),
                  SizedBox(height: rem * 2.5),
                  Row(children: [
                    Text('Progression', style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                    const Spacer(),
                    Text('0%', style: TextStyle(fontSize: rem * 3, color: _textGrey)),
                  ]),
                  SizedBox(height: rem * 1.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rem),
                    child: LinearProgressIndicator(
                      value: 0, minHeight: rem * 1.2,
                      backgroundColor: Colors.red.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(Colors.red))),
                  SizedBox(height: rem * 3),
                  const Wrap(spacing: 8, runSpacing: 8, children: [
                    _StepChip(label: '• Services'),
                    _StepChip(label: '• Réalisations'),
                    _StepChip(label: '• Disponibilités'),
                    _StepChip(label: '• Photo de profil'),
                    _StepChip(label: '• Abonnement Pro'),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
        SizedBox(height: rem * 3),

        // ── Stats ─────────────────────────────────────────────────────
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, label: "RDV aujourd'hui", value: '0',  accent: _gold, rem: rem)),
          SizedBox(width: rem * 3),
          Expanded(child: _StatCard(icon: Icons.people_outline,          label: 'Clients ce mois', value: '0',  accent: _gold, rem: rem)),
        ]),
        SizedBox(height: rem * 3),
        Row(children: [
          Expanded(child: _StatCard(icon: Icons.payments_outlined, label: 'Revenus mois',   value: '0€', accent: _goldDark, rem: rem)),
          SizedBox(width: rem * 3),
          Expanded(child: _StatCard(icon: Icons.trending_up,       label: 'Revenus totaux', value: '0€', accent: _goldDark, rem: rem)),
        ]),
        SizedBox(height: rem * 3),

        // ── Sections ──────────────────────────────────────────────────
        _SectionCard(icon: Icons.content_cut_rounded,      title: 'Services proposés',   emptyText: 'Aucun service configuré',  btnText: 'Créer mes services',        rem: rem, onTap: () => context.go('/prestataire/onboarding')),
        _SectionCard(icon: Icons.access_time_rounded,      title: 'Disponibilités',      emptyText: 'Aucune disponibilité',     btnText: 'Remplir mes disponibilités',rem: rem, onTap: () => context.go('/prestataire/onboarding')),
        _SectionCard(icon: Icons.photo_camera_outlined,    title: 'Réalisations (0/10)', emptyText: 'Aucune photo ajoutée',     btnText: 'Ajouter des photos',        rem: rem, onTap: () => context.go('/prestataire/onboarding')),
        _SectionCard(icon: Icons.shield_outlined,          title: 'Conditions',          emptyText: 'Aucune condition définie', btnText: 'Définir mes conditions',    rem: rem, onTap: () => context.go('/prestataire/onboarding')),
        _SectionCard(icon: Icons.star_outline,             title: 'Confort client',      emptyText: 'Aucun service de confort', btnText: 'Ajouter des commodités',    rem: rem, onTap: () => context.go('/prestataire/onboarding')),
        SizedBox(height: rem * 6),
      ]),
    );
  }
}

// ─── ONGLET RENDEZ-VOUS ───────────────────────────────────────────────────────
class _RendezVousTab extends StatefulWidget {
  const _RendezVousTab({required this.hasSubscription});
  final bool hasSubscription;
  @override State<_RendezVousTab> createState() => _RendezVousTabState();
}
class _RendezVousTabState extends State<_RendezVousTab> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;
    return Column(children: [
      _DualToggle(left: 'À venir (0)', right: 'Historique (0)', current: _tab, onTap: (i) => setState(() => _tab = i), rem: rem),
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.all(rem * 4),
        child: _EmptyCard(
          icon: Icons.calendar_month_rounded,
          title: 'Recevez vos premiers rendez-vous',
          subtitle: widget.hasSubscription
            ? 'Aucun rendez-vous pour le moment'
            : 'Activez votre abonnement Pro pour recevoir les demandes de +10000 clients actifs',
          btnText: widget.hasSubscription ? null : "Activer l'abonnement Pro",
          rem: rem,
          onTap: widget.hasSubscription ? null : () => context.go('/prestataire/onboarding')),
      )),
    ]);
  }
}

// ─── ONGLET CHAT ─────────────────────────────────────────────────────────────
class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.hasSubscription});
  final bool hasSubscription;
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;
    return SingleChildScrollView(
      padding: EdgeInsets.all(rem * 4),
      child: _EmptyCard(
        icon: Icons.chat_bubble_rounded,
        title: 'Messagerie instantanée',
        subtitle: hasSubscription
          ? 'Aucun message pour le moment'
          : "Échangez directement avec vos clients avec l'abonnement Pro",
        btnText: hasSubscription ? null : "Activer l'abonnement Pro",
        rem: rem,
        onTap: hasSubscription ? null : () => context.go('/prestataire/onboarding')));
  }
}

// ─── ONGLET CLIENTS ───────────────────────────────────────────────────────────
class _ClientsTab extends StatefulWidget {
  const _ClientsTab({required this.hasSubscription});
  final bool hasSubscription;
  @override State<_ClientsTab> createState() => _ClientsTabState();
}
class _ClientsTabState extends State<_ClientsTab> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;
    return Column(children: [
      _DualToggle(left: 'Clients (0)', right: 'Avis (0)', current: _tab, onTap: (i) => setState(() => _tab = i), rem: rem),
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.all(rem * 4),
        child: _EmptyCard(
          icon: _tab == 0 ? Icons.people_rounded : Icons.star_rounded,
          title: _tab == 0 ? 'Mes clients' : 'Mes avis',
          subtitle: _tab == 0
            ? (widget.hasSubscription ? 'Aucun client pour le moment' : "Accédez à +10000 clients actifs avec l'abonnement Pro")
            : 'Aucun avis pour le moment',
          btnText: (!widget.hasSubscription && _tab == 0) ? "Activer l'abonnement Pro" : null,
          rem: rem,
          onTap: (!widget.hasSubscription && _tab == 0) ? () => context.go('/prestataire/onboarding') : null),
      )),
    ]);
  }
}

// ─── SHEET PROFIL ─────────────────────────────────────────────────────────────
class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet();
  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;
    return DraggableScrollableSheet(
      initialChildSize: 0.92, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: ListView(controller: ctrl,
          padding: EdgeInsets.fromLTRB(rem * 5, rem * 3, rem * 5, rem * 8),
          children: [
          Center(child: Container(width: rem * 10, height: rem,
            margin: EdgeInsets.only(bottom: rem * 4),
            decoration: BoxDecoration(color: const Color(0xFFEDE0CC), borderRadius: BorderRadius.circular(rem)))),
          Center(child: Text('Modifier le profil', style: TextStyle(
            fontSize: rem * 4.5, fontWeight: FontWeight.w700, color: _textDark))),
          SizedBox(height: rem * 5),

          // Photo
          Row(children: [
            Container(width: rem * 14, height: rem * 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
              child: Icon(Icons.person_rounded, color: _gold, size: rem * 8)),
            SizedBox(width: rem * 3),
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.upload_rounded, size: rem * 4.5, color: _textDark),
              label: Text('Changer la photo', style: TextStyle(color: _textDark, fontSize: rem * 3.5)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEDE0CC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rem * 5)),
                padding: EdgeInsets.symmetric(vertical: rem * 3.5)))),
          ]),
          SizedBox(height: rem * 4),

          Row(children: [
            Expanded(child: _SF(label: 'Ville *',       hint: 'Drancy', rem: rem)),
            SizedBox(width: rem * 3),
            Expanded(child: _SF(label: 'Code postal *', hint: '93700',  rem: rem)),
          ]),
          _SF(label: 'Adresse',               hint: '18 Rue Roger Poujol 93700 Drancy', rem: rem),
          _SF(label: 'Nom affiché *',          hint: 'Votre nom',  rem: rem),
          _SF(label: 'Expérience professionnelle', hint: 'Décrivez votre expérience...', rem: rem, maxLines: 3),
          _SF(label: 'Description',            hint: 'Décrivez votre activité...', rem: rem, maxLines: 4),

          // Avertissement
          Container(
            padding: EdgeInsets.all(rem * 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(rem * 2.5),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5))),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: const Color(0xFFB8860B), size: rem * 4.5),
              SizedBox(width: rem * 2),
              Expanded(child: Text('Interdit : réseaux sociaux, téléphone, email, liens externes',
                style: TextStyle(fontSize: rem * 3, color: const Color(0xFF7A5800)))),
            ])),
          SizedBox(height: rem * 5),

          // Boutons
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rem * 3.5),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(rem * 5),
                  boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Center(child: Text('Enregistrer', style: TextStyle(
                  color: Colors.white, fontSize: rem * 3.8, fontWeight: FontWeight.w700)))))),
            SizedBox(width: rem * 3),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rem * 3.5),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(rem * 5),
                  border: Border.all(color: const Color(0xFFEDE0CC))),
                child: Center(child: Text('Annuler', style: TextStyle(
                  color: _textDark, fontSize: rem * 3.8, fontWeight: FontWeight.w600)))))),
          ]),
          SizedBox(height: rem * 3),

          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rem * 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(rem * 5),
                border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.delete_outline_rounded, color: Colors.red, size: rem * 5),
                SizedBox(width: rem * 2),
                Text('Supprimer mon compte', style: TextStyle(
                  color: Colors.red, fontSize: rem * 3.8, fontWeight: FontWeight.w600)),
              ]))),
        ]),
      ),
    );
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────
class _CB extends StatelessWidget {
  const _CB({required this.icon, required this.rem, required this.onTap});
  final IconData icon; final double rem; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(left: rem * 1.5),
      width: rem * 9, height: rem * 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _goldLight,
        border: Border.all(color: const Color(0xFFEDE0CC))),
      child: Icon(icon, size: rem * 4.5, color: _goldDark)));
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.iconActive, required this.label,
    required this.index, required this.current, required this.onTap});
  final IconData icon, iconActive; final String label;
  final int index, current; final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          SizedBox(height: rem * 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: rem * 3.5, vertical: rem * 1.2),
            decoration: BoxDecoration(
              color: active ? _goldLight : Colors.transparent,
              borderRadius: BorderRadius.circular(rem * 4)),
            child: Icon(active ? iconActive : icon,
              size: rem * 6, color: active ? _gold : _textGrey)),
          SizedBox(height: rem * 0.8),
          Text(label, style: TextStyle(
            fontSize: rem * 2.6,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? _gold : _textGrey)),
          SizedBox(height: rem * 2),
        ])));
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.accent, required this.rem});
  final IconData icon; final String label, value; final Color accent; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(rem * 3.5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rem * 3.5),
      boxShadow: [BoxShadow(color: _textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
    child: Row(children: [
      Container(
        padding: EdgeInsets.all(rem * 2),
        decoration: BoxDecoration(color: accent.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, size: rem * 4.5, color: accent)),
      SizedBox(width: rem * 2.5),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: rem * 2.8, color: _textGrey)),
        Text(value, style: TextStyle(fontSize: rem * 5, fontWeight: FontWeight.w800, color: accent)),
      ])),
    ]));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.emptyText,
    required this.btnText, required this.onTap, required this.rem});
  final IconData icon; final String title, emptyText, btnText;
  final VoidCallback onTap; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: rem * 3),
    padding: EdgeInsets.all(rem * 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rem * 4),
      boxShadow: [BoxShadow(color: _textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: rem * 10, height: rem * 10,
          decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
          child: Icon(icon, size: rem * 5.5, color: _gold)),
        SizedBox(width: rem * 3),
        Text(title, style: TextStyle(fontSize: rem * 3.8, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      SizedBox(height: rem * 4),
      Center(child: Text(emptyText, style: TextStyle(fontSize: rem * 3.2, color: _textGrey))),
      SizedBox(height: rem * 3),
      Center(child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: rem * 6, vertical: rem * 3),
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(rem * 5),
            boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Text(btnText, style: TextStyle(
            color: Colors.white, fontSize: rem * 3.5, fontWeight: FontWeight.w600))))),
    ]));
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.subtitle,
    this.btnText, this.onTap, required this.rem});
  final IconData icon; final String title, subtitle;
  final String? btnText; final VoidCallback? onTap; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(rem * 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rem * 4),
      boxShadow: [BoxShadow(color: _textDark.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
    child: Column(children: [
      Container(
        width: rem * 18, height: rem * 18,
        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
        child: Icon(icon, size: rem * 9, color: _gold)),
      SizedBox(height: rem * 4),
      Text(title, textAlign: TextAlign.center, style: TextStyle(
        fontSize: rem * 4.2, fontWeight: FontWeight.w700, color: _textDark)),
      SizedBox(height: rem * 2),
      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(
        fontSize: rem * 3.2, color: _textGrey, height: 1.4)),
      if (btnText != null) ...[
        SizedBox(height: rem * 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: rem * 7, vertical: rem * 3.5),
            decoration: BoxDecoration(
              color: _gold,
              borderRadius: BorderRadius.circular(rem * 6),
              boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Text(btnText!, style: TextStyle(
              color: Colors.white, fontSize: rem * 3.5, fontWeight: FontWeight.w600)))),
      ],
    ]));
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: Colors.red.withOpacity(0.4))),
    child: Text(label, style: const TextStyle(
      fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)));
}

class _DualToggle extends StatelessWidget {
  const _DualToggle({required this.left, required this.right, required this.current,
    required this.onTap, required this.rem});
  final String left, right; final int current;
  final ValueChanged<int> onTap; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(rem * 4),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0CC),
        borderRadius: BorderRadius.circular(rem * 8)),
      child: Row(children: [
        _TB(label: left,  active: current == 0, onTap: () => onTap(0), rem: rem),
        _TB(label: right, active: current == 1, onTap: () => onTap(1), rem: rem),
      ])));
}

class _TB extends StatelessWidget {
  const _TB({required this.label, required this.active, required this.onTap, required this.rem});
  final String label; final bool active; final VoidCallback onTap; final double rem;
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rem * 3),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(rem * 8)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          fontSize: rem * 3.2, fontWeight: FontWeight.w600,
          color: active ? Colors.white : _textGrey)))));
}

class _SF extends StatelessWidget {
  const _SF({required this.label, required this.hint, required this.rem, this.maxLines = 1});
  final String label, hint; final int maxLines; final double rem;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: rem * 3.5, fontWeight: FontWeight.w600, color: _textDark)),
    SizedBox(height: rem * 2),
    TextField(
      maxLines: maxLines,
      style: TextStyle(fontSize: rem * 3.5, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3.2),
        filled: true, fillColor: const Color(0xFFF8F5F0),
        contentPadding: EdgeInsets.symmetric(horizontal: rem * 3.5, vertical: rem * 3),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(rem * 3), borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rem * 3), borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rem * 3), borderSide: BorderSide(color: _gold, width: 2)),
      )),
    SizedBox(height: rem * 4),
  ]);
}





















// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// const _blue      = Color(0xFF1A73E8);
// const _blueLight = Color(0xFFE8F0FE);
// const _gold      = Color(0xFF3F51B5);
// const _goldLight = Color(0xFFFCE4F3);
// const _textDark  = Color(0xFF1A1A1A);
// const _textGrey  = Color(0xFF8E8E93);
// const _bgGrey    = Color(0xFFF8F8F8);

// class PrestataireHubScreen extends StatefulWidget {
//   const PrestataireHubScreen({super.key});

//   @override
//   State<PrestataireHubScreen> createState() => _PrestataireHubScreenState();
// }

// class _PrestataireHubScreenState extends State<PrestataireHubScreen> {
//   int  _navIndex       = 0;
//   bool _hasSubscription = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgGrey,
//       body: SafeArea(
//         child: Column(children: [

//           // ── Top bar ────────────────────────────────────────────────────
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//             child: Row(children: [
//               Container(
//                 width: 40, height: 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _blueLight,
//                   border: Border.all(color: _blue.withOpacity(0.3), width: 2),
//                 ),
//                 child: const Icon(Icons.person, color: _blue, size: 22),
//               ),
//               const SizedBox(width: 10),
//               const Text('Espace Pro',
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
//               const Spacer(),

//               // Thème
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.wb_sunny_outlined, size: 22, color: _textDark),
//                 onSelected: (v) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: 'light',  child: Row(children: [Icon(Icons.wb_sunny_outlined, size: 18), SizedBox(width: 10), Text('Clair')])),
//                   const PopupMenuItem(value: 'dark',   child: Row(children: [Icon(Icons.nightlight_round,  size: 18), SizedBox(width: 10), Text('Sombre')])),
//                   const PopupMenuItem(value: 'system', child: Row(children: [Icon(Icons.monitor,           size: 18), SizedBox(width: 10), Text('Système')])),
//                 ],
//               ),

//               // Notifications
//               IconButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: const Text('Notifications'),
//                       content: const Text('Aucune notification'),
//                       actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.notifications_outlined, size: 22, color: _textDark),
//                 padding: const EdgeInsets.all(6),
//                 constraints: const BoxConstraints(),
//               ),

//               // Aide
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.help_outline, size: 22, color: _textDark),
//                 onSelected: (v) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: 'new',  child: Row(children: [Icon(Icons.chat_bubble_outline, size: 18), SizedBox(width: 10), Text('Nouveau ticket')])),
//                   const PopupMenuItem(value: 'list', child: Row(children: [Icon(Icons.flag_outlined,       size: 18), SizedBox(width: 10), Text('Mes tickets (0)')])),
//                 ],
//               ),

//               // Déconnexion
//               IconButton(
//                 onPressed: () => context.go('/'),
//                 icon: const Icon(Icons.logout, size: 22, color: _textDark),
//                 padding: const EdgeInsets.all(6),
//                 constraints: const BoxConstraints(),
//               ),
//             ]),
//           ),

//           // ── Contenu ────────────────────────────────────────────────────
//           Expanded(
//             child: IndexedStack(
//               index: _navIndex,
//               children: [
//                 _AccueilTab(hasSubscription: _hasSubscription),
//                 _RendezVousTab(hasSubscription: _hasSubscription),
//                 _ChatTab(hasSubscription: _hasSubscription),
//                 _ClientsTab(hasSubscription: _hasSubscription),
//               ],
//             ),
//           ),

//           // ── Navigation bas ──────────────────────────────────────────────
//           Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
//             ),
//             child: Row(children: [
//               _NavBtn(icon: Icons.home_outlined,           label: 'Accueil',     index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.calendar_today_outlined, label: 'Rendez-vous', index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.chat_bubble_outline,     label: 'Chat',        index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//               _NavBtn(icon: Icons.people_outline,          label: 'Clients',     index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // ─── ONGLET ACCUEIL ───────────────────────────────────────────────────────────
// class _AccueilTab extends StatelessWidget {
//   const _AccueilTab({required this.hasSubscription});
//   final bool hasSubscription;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(children: [

//         // Carte profil
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: const Color(0xFFF0F0F0)),
//           ),
//           child: Column(children: [
//             Row(children: [
//               Container(
//                 width: 52, height: 52,
//                 decoration: const BoxDecoration(shape: BoxShape.circle, color: _goldLight),
//                 child: const Icon(Icons.person, color: _gold, size: 30),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text('Bonjour  !',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//                   Text('Espace Prestataire',
//                     style: TextStyle(fontSize: 13, color: _textGrey)),
//                 ]),
//               ),

//               // Refresh
//               _CircleBtn(icon: Icons.refresh, onTap: () {}),

//               // Abonnement
//               _CircleBtn(icon: Icons.credit_card_outlined, onTap: () {}),

//               // Partage
//               _CircleBtn(icon: Icons.share_outlined, onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Column(mainAxisSize: MainAxisSize.min, children: [
//                       Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
//                         decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2))),
//                       ListTile(leading: const Icon(Icons.copy),  title: const Text('Copier le lien'), onTap: () => Navigator.pop(context)),
//                       ListTile(leading: const Icon(Icons.share), title: const Text('Partager'),        onTap: () => Navigator.pop(context)),
//                       const SizedBox(height: 8),
//                     ]),
//                   ),
//                 );
//               }),

//               // Paramètres → sheet profil
//               _CircleBtn(icon: Icons.settings_outlined, onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (_) => const _ProfileSheet(),
//                 );
//               }),
//             ]),

//             const Divider(height: 24),

//             // Bannière profil incomplet
//             GestureDetector(
//               onTap: () => context.go('/prestataire/onboarding'),
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFEEEE),
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: Colors.red.withOpacity(0.25)),
//                 ),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Row(children: [
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                       child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
//                     ),
//                     const SizedBox(width: 10),
//                     const Expanded(
//                       child: Text('Complétez votre profil pour recevoir des clients',
//                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
//                     ),
//                     const Icon(Icons.chevron_right, color: _textGrey),
//                   ]),
//                   const SizedBox(height: 8),
//                   const Text('Complétez votre profil pour commencer à recevoir des réservations.',
//                     style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//                   const SizedBox(height: 10),
//                   Row(children: [
//                     const Text('Progression', style: TextStyle(fontSize: 12, color: _textGrey)),
//                     const Spacer(),
//                     const Text('0%', style: TextStyle(fontSize: 12, color: _textGrey)),
//                   ]),
//                   const SizedBox(height: 6),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: LinearProgressIndicator(
//                       value: 0, minHeight: 5,
//                       backgroundColor: Colors.red.withOpacity(0.15),
//                       valueColor: const AlwaysStoppedAnimation(Colors.red),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Wrap(spacing: 8, runSpacing: 8, children: [
//                     _StepChip(label: '• Services',              done: false),
//                     _StepChip(label: '• Réalisations',          done: false),
//                     _StepChip(label: '• Disponibilités',        done: false),
//                     _StepChip(label: '• Photo de profil',       done: false),
//                     _StepChip(label: '+ Conditions de service', done: true),
//                     _StepChip(label: '+ Confort client',        done: true),
//                     _StepChip(label: '• Abonnement Pro',        done: false),
//                     _StepChip(label: '+ Paiements en ligne',    done: true),
//                   ]),
//                 ]),
//               ),
//             ),
//           ]),
//         ),
//         const SizedBox(height: 12),

//         // Stats
//         Row(children: [
//           Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, label: "RDV aujourd'hui", value: '0',  accent: _blue)),
//           const SizedBox(width: 12),
//           Expanded(child: _StatCard(icon: Icons.people_outline,          label: 'Clients ce mois', value: '0',  accent: _blue)),
//         ]),
//         const SizedBox(height: 12),
//         Row(children: [
//           Expanded(child: _StatCard(icon: Icons.euro,        label: 'Revenus mois',   value: '0€', accent: _gold)),
//           const SizedBox(width: 12),
//           Expanded(child: _StatCard(icon: Icons.trending_up, label: 'Revenus totaux', value: '0€', accent: _gold)),
//         ]),
//         const SizedBox(height: 12),

//         // Sections
//         _SectionCard(icon: Icons.content_cut,         title: 'Services proposés',  emptyText: 'Aucun service configuré',  btnText: 'Créer mes services',        onTap: () => context.go('/prestataire/onboarding')),
//         _SectionCard(icon: Icons.access_time,          title: 'Disponibilités',     emptyText: 'Aucune disponibilité',     btnText: 'Remplir mes disponibilités',onTap: () => context.go('/prestataire/onboarding')),
//         _SectionCard(icon: Icons.photo_camera_outlined,title: 'Réalisations (0/10)',emptyText: 'Aucune photo ajoutée',     btnText: 'Ajouter des photos',        onTap: () => context.go('/prestataire/onboarding')),
//         _SectionCard(icon: Icons.shield_outlined,      title: 'Conditions',         emptyText: 'Aucune condition définie', btnText: 'Définir mes conditions',    onTap: () => context.go('/prestataire/onboarding')),
//         _SectionCard(icon: Icons.star_outline,         title: 'Confort client',     emptyText: 'Aucun service de confort', btnText: 'Ajouter des commodités',    onTap: () => context.go('/prestataire/onboarding')),
//         const SizedBox(height: 24),
//       ]),
//     );
//   }
// }

// // ─── ONGLET RENDEZ-VOUS ───────────────────────────────────────────────────────
// class _RendezVousTab extends StatefulWidget {
//   const _RendezVousTab({required this.hasSubscription});
//   final bool hasSubscription;
//   @override State<_RendezVousTab> createState() => _RendezVousTabState();
// }

// class _RendezVousTabState extends State<_RendezVousTab> {
//   int _tab = 0;
//   @override
//   Widget build(BuildContext context) => Column(children: [
//     _DualToggle(left: 'À venir (0)', right: 'Historique (0)', current: _tab, onTap: (i) => setState(() => _tab = i)),
//     Expanded(child: SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: _EmptyCard(
//         icon: Icons.calendar_today_outlined,
//         title: 'Recevez vos premiers rendez-vous',
//         subtitle: widget.hasSubscription
//           ? 'Aucun rendez-vous pour le moment'
//           : 'Activez votre abonnement Pro pour recevoir les demandes de +10000 clients actifs',
//         btnText: widget.hasSubscription ? null : "Activer l'abonnement Pro",
//         onTap: widget.hasSubscription ? null : () => context.go('/prestataire/onboarding'),
//       ),
//     )),
//   ]);
// }

// // ─── ONGLET CHAT ─────────────────────────────────────────────────────────────
// class _ChatTab extends StatelessWidget {
//   const _ChatTab({required this.hasSubscription});
//   final bool hasSubscription;
//   @override
//   Widget build(BuildContext context) => SingleChildScrollView(
//     padding: const EdgeInsets.all(16),
//     child: _EmptyCard(
//       icon: Icons.chat_bubble_outline,
//       title: 'Messagerie instantanée',
//       subtitle: hasSubscription
//         ? 'Aucun message pour le moment'
//         : "Échangez directement avec vos clients avec l'abonnement Pro",
//       btnText: hasSubscription ? null : "Activer l'abonnement Pro",
//       onTap: hasSubscription ? null : () => context.go('/prestataire/onboarding'),
//     ),
//   );
// }

// // ─── ONGLET CLIENTS ───────────────────────────────────────────────────────────
// class _ClientsTab extends StatefulWidget {
//   const _ClientsTab({required this.hasSubscription});
//   final bool hasSubscription;
//   @override State<_ClientsTab> createState() => _ClientsTabState();
// }

// class _ClientsTabState extends State<_ClientsTab> {
//   int _tab = 0;
//   @override
//   Widget build(BuildContext context) => Column(children: [
//     _DualToggle(left: 'Clients (0)', right: 'Avis (0)', current: _tab, onTap: (i) => setState(() => _tab = i)),
//     Expanded(child: SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: _EmptyCard(
//         icon: _tab == 0 ? Icons.people_outline : Icons.star_outline,
//         title: _tab == 0 ? 'Mes clients' : 'Mes avis',
//         subtitle: _tab == 0
//           ? (widget.hasSubscription ? 'Aucun client pour le moment' : "Accédez à +10000 clients actifs avec l'abonnement Pro")
//           : 'Aucun avis pour le moment',
//         btnText: (!widget.hasSubscription && _tab == 0) ? "Activer l'abonnement Pro" : null,
//         onTap: (!widget.hasSubscription && _tab == 0) ? () => context.go('/prestataire/onboarding') : null,
//       ),
//     )),
//   ]);
// }

// // ─── SHEET PROFIL ─────────────────────────────────────────────────────────────
// class _ProfileSheet extends StatelessWidget {
//   const _ProfileSheet();

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.92,
//       maxChildSize: 0.95,
//       minChildSize: 0.5,
//       builder: (_, ctrl) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
//           // Handle
//           Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),

//           const Center(child: Text('Modifier le profil',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark))),
//           const SizedBox(height: 20),

//           // Photo
//           Row(children: [
//             Container(width: 56, height: 56,
//               decoration: const BoxDecoration(shape: BoxShape.circle, color: _goldLight),
//               child: const Icon(Icons.person, color: _gold, size: 32)),
//             const SizedBox(width: 12),
//             Expanded(child: OutlinedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.upload, size: 18, color: _textDark),
//               label: const Text('Changer la photo', style: TextStyle(color: _textDark)),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Color(0xFFE0E0E0)),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             )),
//           ]),
//           const SizedBox(height: 20),

//           // Ville / Code postal
//           Row(children: [
//             Expanded(child: _SheetField(label: 'Ville *',        hint: 'Drancy')),
//             const SizedBox(width: 12),
//             Expanded(child: _SheetField(label: 'Code postal *',  hint: '93700')),
//           ]),
//           _SheetField(label: 'Adresse', hint: '18 Rue Roger Poujol 93700 Drancy'),
//           const Text('Optionnel – Utile si vous recevez des clients à votre domicile/salon',
//             style: TextStyle(fontSize: 12, color: _textGrey)),
//           const SizedBox(height: 16),
//           _SheetField(label: 'Nom affiché *', hint: 'wil'),
//           _SheetField(label: 'Expérience professionnelle (4/150 caractères)', hint: 'rib', maxLines: 3),
//           _SheetField(label: 'Description (10/200 caractères)', hint: 'trop fort', maxLines: 4),

//           // Avertissement
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFF8E7),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
//             ),
//             child: const Row(children: [
//               Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 16),
//               SizedBox(width: 8),
//               Expanded(child: Text('Interdit : réseaux sociaux, téléphone, email, liens externes',
//                 style: TextStyle(fontSize: 12, color: Color(0xFF7A5800)))),
//             ]),
//           ),
//           const SizedBox(height: 20),

//           // Boutons
//           Row(children: [
//             Expanded(child: SizedBox(height: 50,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _gold,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                   elevation: 0,
//                 ),
//                 child: const Text('Enregistrer',
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
//               ),
//             )),
//             const SizedBox(width: 12),
//             Expanded(child: SizedBox(height: 50,
//               child: OutlinedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Color(0xFFE0E0E0)),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 ),
//                 child: const Text('Annuler', style: TextStyle(color: _textDark)),
//               ),
//             )),
//           ]),
//           const SizedBox(height: 12),

//           // Supprimer
//           SizedBox(width: double.infinity, height: 50,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
//               label: const Text('Supprimer mon compte',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// // ─── WIDGETS PARTAGÉS ─────────────────────────────────────────────────────────
// class _CircleBtn extends StatelessWidget {
//   const _CircleBtn({required this.icon, required this.onTap});
//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       margin: const EdgeInsets.only(left: 6),
//       width: 36, height: 36,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Icon(icon, size: 16, color: _textDark),
//     ),
//   );
// }

// class _NavBtn extends StatelessWidget {
//   const _NavBtn({required this.icon, required this.label, required this.index, required this.current, required this.onTap});
//   final IconData icon; final String label; final int index, current; final ValueChanged<int> onTap;

//   @override
//   Widget build(BuildContext context) {
//     final active = index == current;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTap(index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           color: Colors.transparent,
//           child: Column(children: [
//             Icon(icon, size: 24, color: active ? _gold : _textGrey),
//             const SizedBox(height: 4),
//             Text(label, style: TextStyle(
//               fontSize: 11,
//               fontWeight: active ? FontWeight.w700 : FontWeight.w400,
//               color: active ? _gold : _textGrey)),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   const _StatCard({required this.icon, required this.label, required this.value, required this.accent});
//   final IconData icon; final String label, value; final Color accent;

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: const Color(0xFFF0F0F0)),
//     ),
//     child: Row(children: [
//       Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
//         child: Icon(icon, size: 18, color: accent),
//       ),
//       const SizedBox(width: 10),
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(label, style: const TextStyle(fontSize: 11, color: _textGrey)),
//         Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
//       ]),
//     ]),
//   );
// }

// class _SectionCard extends StatelessWidget {
//   const _SectionCard({required this.icon, required this.title, required this.emptyText, required this.btnText, required this.onTap});
//   final IconData icon; final String title, emptyText, btnText; final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     margin: const EdgeInsets.only(bottom: 12),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: const Color(0xFFF0F0F0)),
//     ),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Row(children: [
//         Icon(icon, size: 18, color: _textDark),
//         const SizedBox(width: 8),
//         Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
//       ]),
//       const SizedBox(height: 16),
//       Center(child: Text(emptyText, style: const TextStyle(fontSize: 13, color: _textGrey))),
//       const SizedBox(height: 12),
//       Center(child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _gold,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//         child: Text(btnText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//       )),
//     ]),
//   );
// }

// class _EmptyCard extends StatelessWidget {
//   const _EmptyCard({required this.icon, required this.title, required this.subtitle, this.btnText, this.onTap});
//   final IconData icon; final String title, subtitle; final String? btnText; final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(24),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: const Color(0xFFF0F0F0)),
//     ),
//     child: Column(children: [
//       Icon(icon, size: 48, color: _gold),
//       const SizedBox(height: 14),
//       Text(title, textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//       const SizedBox(height: 8),
//       Text(subtitle, textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
//       if (btnText != null) ...[
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: onTap,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _gold,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//             elevation: 0,
//             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
//           ),
//           child: Text(btnText!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//         ),
//       ],
//     ]),
//   );
// }

// class _StepChip extends StatelessWidget {
//   const _StepChip({required this.label, required this.done});
//   final String label; final bool done;

//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     decoration: BoxDecoration(
//       color: const Color(0xFFFFEEEE),
//       borderRadius: BorderRadius.circular(50),
//       border: Border.all(color: Colors.red.withOpacity(0.4)),
//     ),
//     child: Text(label,
//       style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
//   );
// }

// class _DualToggle extends StatelessWidget {
//   const _DualToggle({required this.left, required this.right, required this.current, required this.onTap});
//   final String left, right; final int current; final ValueChanged<int> onTap;

//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.all(16),
//     child: Container(
//       decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
//       child: Row(children: [
//         _TabBtn(label: left,  active: current == 0, onTap: () => onTap(0)),
//         _TabBtn(label: right, active: current == 1, onTap: () => onTap(1)),
//       ]),
//     ),
//   );
// }

// class _TabBtn extends StatelessWidget {
//   const _TabBtn({required this.label, required this.active, required this.onTap});
//   final String label; final bool active; final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) => Expanded(
//     child: GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: active ? _gold : Colors.transparent,
//           borderRadius: BorderRadius.circular(50),
//         ),
//         alignment: Alignment.center,
//         child: Text(label, style: TextStyle(
//           fontSize: 14, fontWeight: FontWeight.w600,
//           color: active ? Colors.white : _textGrey)),
//       ),
//     ),
//   );
// }

// class _SheetField extends StatelessWidget {
//   const _SheetField({required this.label, required this.hint, this.maxLines = 1});
//   final String label, hint; final int maxLines;

//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//       const SizedBox(height: 8),
//       TextField(
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           hintText: hint, hintStyle: const TextStyle(color: _textGrey),
//           filled: true, fillColor: const Color(0xFFF8F8F8),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold, width: 2)),
//         ),
//       ),
//       const SizedBox(height: 16),
//     ],
//   );
// }





































































// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';

// // const _blue       = Color(0xFF1A73E8);
// // const _blueLight  = Color(0xFFE8F0FE);
// // const _gold = Color(0xFF3F51B5);  // bleu indigo   
// // const _goldLight  = Color(0xFFFCE4F3);   // 👈 fond rose clair
// // const _textDark   = Color(0xFF1A1A1A);
// // const _textGrey   = Color(0xFF8E8E93);
// // const _bgGrey     = Color(0xFFF8F8F8);

// // class PrestataireHubScreen extends StatefulWidget {
// //   const PrestataireHubScreen({super.key});

// //   @override
// //   State<PrestataireHubScreen> createState() => _PrestataireHubScreenState();
// // }

// // class _PrestataireHubScreenState extends State<PrestataireHubScreen> {
// //   int  _navIndex       = 0;
// //   bool _hasSubscription = false; // brancher sur Supabase

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _bgGrey,
// //       body: SafeArea(
// //         child: Column(children: [

// //           // ── Top bar ──────────────────────────────────────────────────
// //           Container(
// //             color: Colors.white,
// //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //             child: Row(children: [
// //               Container(
// //                 width: 40, height: 40,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: _blueLight,
// //                   border: Border.all(color: _blue.withOpacity(0.3), width: 2),
// //                 ),
// //                 child: const Icon(Icons.person, color: _blue, size: 22),
// //               ),
// //               const SizedBox(width: 10),
// //               const Text('Espace Pro',
// //                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
// //               const Spacer(),
// //               _TopBtn(icon: Icons.wb_sunny_outlined,       onTap: () {}),
// //               _TopBtn(icon: Icons.notifications_outlined,  onTap: () {}),
// //               _TopBtn(icon: Icons.help_outline,            onTap: () {}),
// //               _TopBtn(icon: Icons.logout,                  onTap: () => context.go('/')),
// //             ]),
// //           ),

// //           // ── Contenu ──────────────────────────────────────────────────
// //           Expanded(
// //             child: IndexedStack(
// //               index: _navIndex,
// //               children: [
// //                 _AccueilTab(hasSubscription: _hasSubscription),
// //                 _RendezVousTab(hasSubscription: _hasSubscription),
// //                 _ChatTab(hasSubscription: _hasSubscription),
// //                 _ClientsTab(hasSubscription: _hasSubscription),
// //               ],
// //             ),
// //           ),

// //           // ── Navigation bas ────────────────────────────────────────────
// //           Container(
// //             decoration: const BoxDecoration(
// //               color: Colors.white,
// //               border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
// //             ),
// //             child: Row(
// //               children: [
// //                 _NavBtn(icon: Icons.home_outlined,           label: 'Accueil',      index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
// //                 _NavBtn(icon: Icons.calendar_today_outlined, label: 'Rendez-vous',  index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
// //                 _NavBtn(icon: Icons.chat_bubble_outline,     label: 'Chat',         index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
// //                 _NavBtn(icon: Icons.people_outline,          label: 'Clients',      index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
// //               ],
// //             ),
// //           ),
// //         ]),
// //       ),
// //     );
// //   }
// // }

// // // ─── ONGLET ACCUEIL ───────────────────────────────────────────────────────────
// // class _AccueilTab extends StatelessWidget {
// //   const _AccueilTab({required this.hasSubscription});
// //   final bool hasSubscription;

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(children: [

// //         // ── Carte profil ─────────────────────────────────────────────
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(color: const Color(0xFFF0F0F0)),
// //           ),
// //           child: Column(children: [
// //             Row(children: [
// //               Container(
// //                 width: 52, height: 52,
// //                 decoration: const BoxDecoration(
// //                   shape: BoxShape.circle, color: _goldLight),
// //                 child: const Icon(Icons.person, color: _gold, size: 30),
// //               ),
// //               const SizedBox(width: 12),
// //               const Expanded(
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Text('Bonjour wil !',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //                   Text('Espace coiffeur',
// //                     style: TextStyle(fontSize: 13, color: _textGrey)),
// //                 ]),
// //               ),
// //               _ActionBtn(icon: Icons.refresh),
// //               _ActionBtn(icon: Icons.credit_card_outlined),
// //               _ActionBtn(icon: Icons.share_outlined),
// //               _ActionBtn(icon: Icons.settings_outlined),
// //             ]),
// //             const Divider(height: 24),

// //             // ── Bannière profil incomplet ────────────────────────────
// //             GestureDetector(
// //               onTap: () => context.go('/prestataire/onboarding'),
// //               child: Container(
// //                 padding: const EdgeInsets.all(14),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFFFEEEE),
// //                   borderRadius: BorderRadius.circular(14),
// //                   border: Border.all(color: Colors.red.withOpacity(0.25)),
// //                 ),
// //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Row(children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(6),
// //                       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
// //                       child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     const Expanded(
// //                       child: Text('Complétez votre profil pour recevoir des clients',
// //                         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
// //                     ),
// //                     const Icon(Icons.chevron_right, color: _textGrey),
// //                   ]),
// //                   const SizedBox(height: 8),
// //                   const Text('Complétez votre profil pour commencer à recevoir des réservations.',
// //                     style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
// //                   const SizedBox(height: 10),
// //                   Row(children: [
// //                     const Text('Progression', style: TextStyle(fontSize: 12, color: _textGrey)),
// //                     const Spacer(),
// //                     const Text('0%', style: TextStyle(fontSize: 12, color: _textGrey)),
// //                   ]),
// //                   const SizedBox(height: 6),
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(4),
// //                     child: LinearProgressIndicator(
// //                       value: 0,
// //                       minHeight: 5,
// //                       backgroundColor: Colors.red.withOpacity(0.15),
// //                       valueColor: const AlwaysStoppedAnimation(Colors.red),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Wrap(spacing: 8, runSpacing: 8, children: const [
// //                     _StepChip(label: '• Services',              done: false),
// //                     _StepChip(label: '• Réalisations',          done: false),
// //                     _StepChip(label: '• Disponibilités',        done: false),
// //                     _StepChip(label: '• Photo de profil',       done: false),
// //                     _StepChip(label: '+ Conditions de service', done: true),
// //                     _StepChip(label: '+ Confort client',        done: true),
// //                     _StepChip(label: '• Abonnement Pro',        done: false),
// //                     _StepChip(label: '+ Paiements en ligne',    done: true),
// //                   ]),
// //                 ]),
// //               ),
// //             ),
// //           ]),
// //         ),
// //         const SizedBox(height: 12),

// //         // ── Stats ─────────────────────────────────────────────────────
// //         Row(children: [
// //           Expanded(child: _StatCard(icon: Icons.calendar_today_outlined, label: "RDV aujourd'hui",  value: '0',  accent: _blue)),
// //           const SizedBox(width: 12),
// //           Expanded(child: _StatCard(icon: Icons.people_outline,          label: 'Clients ce mois',  value: '0',  accent: _blue)),
// //         ]),
// //         const SizedBox(height: 12),
// //         Row(children: [
// //           Expanded(child: _StatCard(icon: Icons.euro,         label: 'Revenus mois',   value: '0€', accent: _gold)),
// //           const SizedBox(width: 12),
// //           Expanded(child: _StatCard(icon: Icons.trending_up,  label: 'Revenus totaux', value: '0€', accent: _gold)),
// //         ]),
// //         const SizedBox(height: 12),

// //         // ── Sections ──────────────────────────────────────────────────
// //         _SectionCard(icon: Icons.content_cut,        title: 'Services proposés',   emptyText: 'Aucun service configuré',   btnText: 'Créer mes services',         onTap: () => context.go('/prestataire/onboarding')),
// //         _SectionCard(icon: Icons.access_time,         title: 'Disponibilités',      emptyText: 'Aucune disponibilité',      btnText: 'Remplir mes disponibilités', onTap: () => context.go('/prestataire/onboarding')),
// //         _SectionCard(icon: Icons.photo_camera_outlined,title: 'Réalisations (0/10)',emptyText: 'Aucune photo ajoutée',      btnText: 'Ajouter des photos',         onTap: () => context.go('/prestataire/onboarding')),
// //         _SectionCard(icon: Icons.shield_outlined,     title: 'Conditions',          emptyText: 'Aucune condition définie',  btnText: 'Définir mes conditions',     onTap: () => context.go('/prestataire/onboarding')),
// //         _SectionCard(icon: Icons.star_outline,        title: 'Confort client',      emptyText: 'Aucun service de confort',  btnText: 'Ajouter des commodités',     onTap: () => context.go('/prestataire/onboarding')),
// //         const SizedBox(height: 24),
// //       ]),
// //     );
// //   }
// // }

// // // ─── ONGLET RENDEZ-VOUS ───────────────────────────────────────────────────────
// // class _RendezVousTab extends StatefulWidget {
// //   const _RendezVousTab({required this.hasSubscription});
// //   final bool hasSubscription;
// //   @override State<_RendezVousTab> createState() => _RendezVousTabState();
// // }

// // class _RendezVousTabState extends State<_RendezVousTab> {
// //   int _tab = 0;
// //   @override
// //   Widget build(BuildContext context) => Column(children: [
// //     _DualToggle(left: 'À venir (0)', right: 'Historique (0)', current: _tab, onTap: (i) => setState(() => _tab = i)),
// //     Expanded(child: SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: _EmptyCard(
// //         icon: Icons.calendar_today_outlined,
// //         title: 'Recevez vos premiers rendez-vous',
// //         subtitle: widget.hasSubscription
// //           ? 'Aucun rendez-vous pour le moment'
// //           : 'Activez votre abonnement Pro pour recevoir les demandes de +10000 clients actifs',
// //         btnText: widget.hasSubscription ? null : "Activer l'abonnement Pro",
// //         onTap: widget.hasSubscription ? null : () => context.go('/prestataire/onboarding'),
// //       ),
// //     )),
// //   ]);
// // }

// // // ─── ONGLET CHAT ─────────────────────────────────────────────────────────────
// // class _ChatTab extends StatelessWidget {
// //   const _ChatTab({required this.hasSubscription});
// //   final bool hasSubscription;
// //   @override
// //   Widget build(BuildContext context) => SingleChildScrollView(
// //     padding: const EdgeInsets.all(16),
// //     child: _EmptyCard(
// //       icon: Icons.chat_bubble_outline,
// //       title: 'Messagerie instantanée',
// //       subtitle: hasSubscription
// //         ? 'Aucun message pour le moment'
// //         : "Échangez directement avec vos clients avec l'abonnement Pro",
// //       btnText: hasSubscription ? null : "Activer l'abonnement Pro",
// //       onTap: hasSubscription ? null : () => context.go('/prestataire/onboarding'),
// //     ),
// //   );
// // }

// // // ─── ONGLET CLIENTS ───────────────────────────────────────────────────────────
// // class _ClientsTab extends StatefulWidget {
// //   const _ClientsTab({required this.hasSubscription});
// //   final bool hasSubscription;
// //   @override State<_ClientsTab> createState() => _ClientsTabState();
// // }

// // class _ClientsTabState extends State<_ClientsTab> {
// //   int _tab = 0;
// //   @override
// //   Widget build(BuildContext context) => Column(children: [
// //     _DualToggle(left: 'Clients (0)', right: 'Avis (0)', current: _tab, onTap: (i) => setState(() => _tab = i)),
// //     Expanded(child: SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: _EmptyCard(
// //         icon: _tab == 0 ? Icons.people_outline : Icons.star_outline,
// //         title: _tab == 0 ? 'Mes clients' : 'Mes avis',
// //         subtitle: _tab == 0
// //           ? (widget.hasSubscription ? 'Aucun client pour le moment' : 'Accédez à +10000 clients actifs avec l\'abonnement Pro')
// //           : 'Aucun avis pour le moment',
// //         btnText: (!widget.hasSubscription && _tab == 0) ? "Activer l'abonnement Pro" : null,
// //         onTap: (!widget.hasSubscription && _tab == 0) ? () => context.go('/prestataire/onboarding') : null,
// //       ),
// //     )),
// //   ]);
// // }

// // // ─── WIDGETS PARTAGÉS ─────────────────────────────────────────────────────────
// // class _TopBtn extends StatelessWidget {
// //   const _TopBtn({required this.icon, this.onTap});
// //   final IconData icon; final VoidCallback? onTap;
// //   @override
// //   Widget build(BuildContext context) => IconButton(
// //     onPressed: onTap,
// //     icon: Icon(icon, size: 22, color: _textGrey),
// //     padding: const EdgeInsets.all(6),
// //     constraints: const BoxConstraints(),
// //   );
// // }

// // class _ActionBtn extends StatelessWidget {
// //   const _ActionBtn({required this.icon});
// //   final IconData icon;
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(left: 6),
// //     width: 36, height: 36,
// //     decoration: BoxDecoration(
// //       shape: BoxShape.circle,
// //       border: Border.all(color: const Color(0xFFE0E0E0)),
// //     ),
// //     child: Icon(icon, size: 16, color: _textGrey),
// //   );
// // }

// // class _NavBtn extends StatelessWidget {
// //   const _NavBtn({required this.icon, required this.label, required this.index, required this.current, required this.onTap});
// //   final IconData icon; final String label; final int index, current; final ValueChanged<int> onTap;
// //   @override
// //   Widget build(BuildContext context) {
// //     final active = index == current;
// //     return Expanded(
// //       child: GestureDetector(
// //         onTap: () => onTap(index),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(vertical: 10),
// //           color: Colors.transparent,
// //           child: Column(children: [
// //             Icon(icon, size: 24, color: active ? _gold : _textGrey),
// //             const SizedBox(height: 4),
// //             Text(label, style: TextStyle(
// //               fontSize: 11,
// //               fontWeight: active ? FontWeight.w700 : FontWeight.w400,
// //               color: active ? _gold : _textGrey)),
// //           ]),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _StatCard extends StatelessWidget {
// //   const _StatCard({required this.icon, required this.label, required this.value, required this.accent});
// //   final IconData icon; final String label, value; final Color accent;
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.all(14),
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(14),
// //       border: Border.all(color: const Color(0xFFF0F0F0)),
// //     ),
// //     child: Row(children: [
// //       Container(
// //         padding: const EdgeInsets.all(8),
// //         decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
// //         child: Icon(icon, size: 18, color: accent),
// //       ),
// //       const SizedBox(width: 10),
// //       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Text(label, style: const TextStyle(fontSize: 11, color: _textGrey)),
// //         Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
// //       ]),
// //     ]),
// //   );
// // }

// // class _SectionCard extends StatelessWidget {
// //   const _SectionCard({required this.icon, required this.title, required this.emptyText, required this.btnText, required this.onTap});
// //   final IconData icon; final String title, emptyText, btnText; final VoidCallback onTap;
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     width: double.infinity,
// //     margin: const EdgeInsets.only(bottom: 12),
// //     padding: const EdgeInsets.all(16),
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: const Color(0xFFF0F0F0)),
// //     ),
// //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       Row(children: [
// //         Icon(icon, size: 18, color: _textDark),
// //         const SizedBox(width: 8),
// //         Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
// //       ]),
// //       const SizedBox(height: 16),
// //       Center(child: Text(emptyText, style: const TextStyle(fontSize: 13, color: _textGrey))),
// //       const SizedBox(height: 12),
// //       Center(
// //         child: ElevatedButton(
// //           onPressed: onTap,
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: _gold,
// //             foregroundColor: Colors.white,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //             elevation: 0,
// //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //           ),
// //           child: Text(btnText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
// //         ),
// //       ),
// //     ]),
// //   );
// // }

// // class _EmptyCard extends StatelessWidget {
// //   const _EmptyCard({required this.icon, required this.title, required this.subtitle, this.btnText, this.onTap});
// //   final IconData icon; final String title, subtitle; final String? btnText; final VoidCallback? onTap;
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     width: double.infinity,
// //     padding: const EdgeInsets.all(24),
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: const Color(0xFFF0F0F0)),
// //     ),
// //     child: Column(children: [
// //       Icon(icon, size: 48, color: _gold),
// //       const SizedBox(height: 14),
// //       Text(title, textAlign: TextAlign.center,
// //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
// //       const SizedBox(height: 8),
// //       Text(subtitle, textAlign: TextAlign.center,
// //         style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.4)),
// //       if (btnText != null) ...[
// //         const SizedBox(height: 16),
// //         ElevatedButton(
// //           onPressed: onTap,
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: _gold,
// //             foregroundColor: Colors.white,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //             elevation: 0,
// //             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
// //           ),
// //           child: Text(btnText!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
// //         ),
// //       ],
// //     ]),
// //   );
// // }

// // class _StepChip extends StatelessWidget {
// //   const _StepChip({required this.label, required this.done});
// //   final String label; final bool done;
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //     decoration: BoxDecoration(
// //       color: done ? const Color(0xFFFFEEEE) : const Color(0xFFFFEEEE),
// //       borderRadius: BorderRadius.circular(50),
// //       border: Border.all(color: Colors.red.withOpacity(0.4)),
// //     ),
// //     child: Text(label,
// //       style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
// //   );
// // }

// // class _DualToggle extends StatelessWidget {
// //   const _DualToggle({required this.left, required this.right, required this.current, required this.onTap});
// //   final String left, right; final int current; final ValueChanged<int> onTap;
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: const EdgeInsets.all(16),
// //     child: Container(
// //       decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(50)),
// //       child: Row(children: [
// //         _TabBtn(label: left,  active: current == 0, onTap: () => onTap(0)),
// //         _TabBtn(label: right, active: current == 1, onTap: () => onTap(1)),
// //       ]),
// //     ),
// //   );
// // }

// // class _TabBtn extends StatelessWidget {
// //   const _TabBtn({required this.label, required this.active, required this.onTap});
// //   final String label; final bool active; final VoidCallback onTap;
// //   @override
// //   Widget build(BuildContext context) => Expanded(
// //     child: GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(vertical: 12),
// //         decoration: BoxDecoration(
// //           color: active ? _gold : Colors.transparent,
// //           borderRadius: BorderRadius.circular(50),
// //         ),
// //         alignment: Alignment.center,
// //         child: Text(label, style: TextStyle(
// //           fontSize: 14, fontWeight: FontWeight.w600,
// //           color: active ? Colors.white : _textGrey)),
// //       ),
// //     ),
// //   );
// // }




































