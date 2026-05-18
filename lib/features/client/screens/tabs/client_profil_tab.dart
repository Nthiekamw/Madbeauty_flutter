import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _bg       = Color(0xFFF2EBE0);
const _gold     = Color(0xFFC4956A);
const _goldBg   = Color(0xFFEDE0CC);
const _goldDark = Color(0xFF8B6340);
const _textDark = Color(0xFF2C1810);
const _textGrey = Color(0xFF9E8878);

class ClientProfilTab extends StatelessWidget {
  const ClientProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [

          // ── Header blanc ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(rem * 4, rem * 6, rem * 4, rem * 6),
            child: Column(children: [

              // Avatar
              Stack(alignment: Alignment.bottomRight, children: [
                Container(
                  width: rem * 24, height: rem * 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold, width: 3),
                    boxShadow: [BoxShadow(
                      color: _gold.withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 6))]),
                  child: ClipOval(
                    child: Image.asset('assets/images/cf.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _goldBg,
                        child: Icon(Icons.person, color: _gold, size: rem * 13))))),
                Container(
                  width: rem * 8, height: rem * 8,
                  decoration: BoxDecoration(
                    color: _gold, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: rem * 4.5)),
              ]),
              SizedBox(height: rem * 4),

              Text('William Nthiekam',
                style: TextStyle(fontSize: rem * 5.5,
                  fontWeight: FontWeight.w800, color: _textDark)),
              SizedBox(height: rem),
              Text('Client MadBeauty',
                style: TextStyle(fontSize: rem * 3.5, color: _textGrey)),
              SizedBox(height: rem * 5),

              // Stats
              Row(children: [
                _StatBox(value: '5',   label: 'RDV\neffectués', rem: rem),
                _Div(),
                _StatBox(value: '3',   label: 'Favoris',        rem: rem),
                _Div(),
                _StatBox(value: '4.8', label: 'Note\nmoyenne',  rem: rem),
              ]),
            ]),
          ),
          SizedBox(height: rem * 3),

          // ── Mes informations ──────────────────────────────────────────
          _Section(title: 'Mes informations', rem: rem, children: [
            _InfoItem(icon: Icons.person_outline,       label: 'Nom',       value: 'William Nthiekam',      rem: rem),
            _InfoItem(icon: Icons.email_outlined,       label: 'Email',     value: 'william@gmail.com',     rem: rem),
            _InfoItem(icon: Icons.phone_outlined,       label: 'Téléphone', value: '+33 6 15 01 36 94',     rem: rem),
            _InfoItem(icon: Icons.location_on_outlined, label: 'Ville',     value: 'Drancy, 93700',         rem: rem, isLast: true),
          ]),
          SizedBox(height: rem * 3),

          // ── Préférences ───────────────────────────────────────────────
          _Section(title: 'Préférences', rem: rem, children: [
            _SwitchItem(icon: Icons.notifications_outlined, label: 'Notifications push', rem: rem),
            _SwitchItem(icon: Icons.email_outlined,         label: 'Emails de rappel',  rem: rem, initialValue: false),
            _SwitchItem(icon: Icons.location_on_outlined,   label: 'Géolocalisation',   rem: rem, isLast: true),
          ]),
          SizedBox(height: rem * 3),

          // ── Mon compte ────────────────────────────────────────────────
          _Section(title: 'Mon compte', rem: rem, children: [
            _MenuItem(icon: Icons.favorite_border,        label: 'Mes favoris',    rem: rem, onTap: () {}),
            _MenuItem(icon: Icons.star_border,            label: 'Mes avis',       rem: rem, onTap: () {}),
            _MenuItem(icon: Icons.history,                label: 'Historique',     rem: rem, onTap: () {}),
            _MenuItem(icon: Icons.card_giftcard_outlined, label: 'Parrainage',     rem: rem, onTap: () {}),
            _MenuItem(icon: Icons.help_outline,           label: 'Aide & Support', rem: rem, onTap: () {}),
            _MenuItem(icon: Icons.shield_outlined,        label: 'Confidentialité',rem: rem, onTap: () {}, isLast: true),
          ]),
          SizedBox(height: rem * 4),

          // ── Déconnexion ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rem * 4),
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: rem * 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(rem * 4),
                  border: Border.all(color: Colors.red.withOpacity(0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.logout, color: Colors.red, size: rem * 5.5),
                  SizedBox(width: rem * 2.5),
                  Text('Se déconnecter',
                    style: TextStyle(fontSize: rem * 4,
                      fontWeight: FontWeight.w700, color: Colors.red)),
                ]),
              ),
            ),
          ),
          SizedBox(height: rem * 3),

          // ── Supprimer compte ──────────────────────────────────────────
          TextButton(
            onPressed: () {},
            child: Text('Supprimer mon compte',
              style: TextStyle(fontSize: rem * 3.2, color: _textGrey,
                decoration: TextDecoration.underline,
                decorationColor: _textGrey)),
          ),
          SizedBox(height: rem * 8),
        ]),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, required this.rem});
  final String value, label; final double rem;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: TextStyle(
        fontSize: rem * 6.5, fontWeight: FontWeight.w900, color: _gold)),
      SizedBox(height: rem),
      Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: rem * 2.8, color: _textGrey, height: 1.3)),
    ]),
  );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Container(width: 1, height: 40, color: const Color(0xFFE5D5C5));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, required this.rem});
  final String title; final List<Widget> children; final double rem;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: rem * 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(
        fontSize: rem * 4, fontWeight: FontWeight.w800, color: _textDark)),
      SizedBox(height: rem * 2),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rem * 4),
          boxShadow: [BoxShadow(
            color: _textDark.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))]),
        child: Column(children: children)),
    ]),
  );
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label,
    required this.value, required this.rem, this.isLast = false});
  final IconData icon; final String label, value; final double rem;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.5),
    decoration: BoxDecoration(
      border: isLast ? null : const Border(
        bottom: BorderSide(color: Color(0xFFF5EDE0)))),
    child: Row(children: [
      Container(width: rem * 9, height: rem * 9,
        decoration: BoxDecoration(color: _goldBg, shape: BoxShape.circle),
        child: Icon(icon, color: _gold, size: rem * 4.5)),
      SizedBox(width: rem * 3),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: rem * 2.8, color: _textGrey)),
        SizedBox(height: rem * 0.5),
        Text(value, style: TextStyle(
          fontSize: rem * 3.5, fontWeight: FontWeight.w600, color: _textDark)),
      ])),
      Icon(Icons.chevron_right, color: _textGrey, size: rem * 5),
    ]),
  );
}

class _SwitchItem extends StatefulWidget {
  const _SwitchItem({required this.icon, required this.label,
    required this.rem, this.initialValue = true, this.isLast = false});
  final IconData icon; final String label; final double rem;
  final bool initialValue, isLast;

  @override
  State<_SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<_SwitchItem> {
  late bool _val;

  @override
  void initState() { super.initState(); _val = widget.initialValue; }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: widget.rem * 4, vertical: widget.rem * 2.5),
    decoration: BoxDecoration(
      border: widget.isLast ? null : const Border(
        bottom: BorderSide(color: Color(0xFFF5EDE0)))),
    child: Row(children: [
      Container(width: widget.rem * 9, height: widget.rem * 9,
        decoration: BoxDecoration(color: _goldBg, shape: BoxShape.circle),
        child: Icon(widget.icon, color: _gold, size: widget.rem * 4.5)),
      SizedBox(width: widget.rem * 3),
      Expanded(child: Text(widget.label,
        style: TextStyle(fontSize: widget.rem * 3.5,
          fontWeight: FontWeight.w600, color: _textDark))),
      Switch(
        value: _val,
        onChanged: (v) => setState(() => _val = v),
        activeColor: _gold,
        activeTrackColor: _goldBg),
    ]),
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label,
    required this.rem, required this.onTap, this.isLast = false});
  final IconData icon; final String label; final double rem;
  final VoidCallback onTap; final bool isLast;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.5),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(
          bottom: BorderSide(color: Color(0xFFF5EDE0)))),
      child: Row(children: [
        Container(width: rem * 9, height: rem * 9,
          decoration: BoxDecoration(color: _goldBg, shape: BoxShape.circle),
          child: Icon(icon, color: _gold, size: rem * 4.5)),
        SizedBox(width: rem * 3),
        Expanded(child: Text(label,
          style: TextStyle(fontSize: rem * 3.5,
            fontWeight: FontWeight.w600, color: _textDark))),
        Icon(Icons.chevron_right, color: _textGrey, size: rem * 5),
      ]),
    ),
  );
}