
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Couleurs ──────────────────────────────────────────────────────────────────
const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _bg        = Color(0xFFF2EBE0);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);

// ── Données ───────────────────────────────────────────────────────────────────
const _providerTypes = [
  {'key': 'hairdresser', 'label': 'Coiffeur(se)',       'icon': Icons.content_cut_rounded},
  {'key': 'makeup',      'label': 'Maquilleur(se)',      'icon': Icons.face_retouching_natural},
  {'key': 'manicure',    'label': 'Manucure / Pédicure', 'icon': Icons.back_hand_outlined},
];

const _workLocations = [
  {'key': 'home',   'label': 'À mon salon / chez moi', 'icon': Icons.home_rounded},
  {'key': 'client', 'label': 'Chez le client',          'icon': Icons.directions_car_rounded},
  {'key': 'both',   'label': 'Les deux',                'icon': Icons.swap_horiz_rounded},
];

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE PRINCIPALE LOGIN
// ═══════════════════════════════════════════════════════════════════════════════
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
    required this.onPasswordFieldSubmitted,
    this.showSupabaseConfigCard = false,
    this.emailError,
    this.passwordError,
    this.submitError,
    this.isLoading = false,
    this.formEnabled = true,
    this.onRegisterAsProvider,
    this.onRegisterAsClient,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onPasswordFieldSubmitted;
  final bool showSupabaseConfigCard;
  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback? onRegisterAsProvider;
  final VoidCallback? onRegisterAsClient;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rem * 6, vertical: rem * 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Logo + titre ────────────────────────────────────────
              Center(child: Column(children: [
                Container(
                  width: rem * 16, height: rem * 16,
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(rem * 4.5),
                    boxShadow: [BoxShadow(
                      color: _gold.withOpacity(0.4),
                      blurRadius: 16, offset: const Offset(0, 6))]),
                  child: Icon(Icons.auto_awesome,
                    color: Colors.white, size: rem * 8)),
                SizedBox(height: rem * 4),
                Text('Bienvenue', style: TextStyle(
                  fontSize: rem * 8,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  letterSpacing: -0.5)),
                SizedBox(height: rem * 1.5),
                Text('Votre beauté, à portée de main ✨',
                  style: TextStyle(fontSize: rem * 3.8, color: _textGrey)),
              ])),
              SizedBox(height: rem * 8),

              // ── Avertissement Supabase ─────────────────────────────
              if (widget.showSupabaseConfigCard) ...[
                Container(
                  padding: EdgeInsets.all(rem * 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(rem * 3),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5))),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                      color: const Color(0xFFB8860B), size: rem * 5),
                    SizedBox(width: rem * 2.5),
                    Expanded(child: Text('Supabase non configuré.',
                      style: TextStyle(
                        color: const Color(0xFF7A5800),
                        fontSize: rem * 3.2))),
                  ])),
                SizedBox(height: rem * 4),
              ],

              // ── Tabs Connexion / Inscription ───────────────────────
              Container(
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(rem * 8)),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(rem * 8),
                    boxShadow: [BoxShadow(
                      color: _gold.withOpacity(0.4),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: _textGrey,
                  labelStyle: TextStyle(
                    fontSize: rem * 3.8, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: TextStyle(
                    fontSize: rem * 3.8, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Connexion'),
                    Tab(text: 'Inscription'),
                  ]),
              ),
              SizedBox(height: rem * 5),

              // ── Contenu tabs ───────────────────────────────────────
              SizedBox(
                height: rem * 150,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [

                    // ── TAB 1 : CONNEXION ──────────────────────────
                    _LoginForm(
                      emailController: widget.emailController,
                      passwordController: widget.passwordController,
                      emailError: widget.emailError,
                      passwordError: widget.passwordError,
                      submitError: widget.submitError,
                      isLoading: widget.isLoading,
                      formEnabled: widget.formEnabled,
                      showPass: _showPass,
                      onTogglePass: () =>
                        setState(() => _showPass = !_showPass),
                      onSubmit: widget.onSubmit,
                      onPasswordFieldSubmitted:
                        widget.onPasswordFieldSubmitted,
                      rem: rem,
                    ),

                    // ── TAB 2 : INSCRIPTION → choisir rôle ─────────
                    _ChooseRolePage(
                      onChooseClient: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RegisterClientPage(
                            emailController: widget.emailController,
                            passwordController: widget.passwordController,
                            onSubmit: widget.onRegisterAsClient ?? () {},
                            formEnabled: widget.formEnabled,
                            isLoading: widget.isLoading,
                            submitError: widget.submitError,
                          )));
                      },
                      onChooseProvider: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RegisterProviderPage(
                            emailController: widget.emailController,
                            passwordController: widget.passwordController,
                            onSubmit: widget.onRegisterAsProvider ?? () {},
                            formEnabled: widget.formEnabled,
                            isLoading: widget.isLoading,
                            submitError: widget.submitError,
                          )));
                      },
                      rem: rem,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORMULAIRE CONNEXION
// ═══════════════════════════════════════════════════════════════════════════════
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.submitError,
    required this.isLoading,
    required this.formEnabled,
    required this.showPass,
    required this.onTogglePass,
    required this.onSubmit,
    required this.onPasswordFieldSubmitted,
    required this.rem,
  });

  final TextEditingController emailController, passwordController;
  final String? emailError, passwordError, submitError;
  final bool isLoading, formEnabled, showPass;
  final VoidCallback onTogglePass, onSubmit, onPasswordFieldSubmitted;
  final double rem;

  @override
  Widget build(BuildContext context) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    _Lbl(text: 'Email', rem: rem),
    _TF(ctrl: emailController, hint: 'votre@email.com',
      enabled: formEnabled, error: emailError, rem: rem,
      type: TextInputType.emailAddress),
    SizedBox(height: rem * 3.5),

    _Lbl(text: 'Mot de passe', rem: rem),
    TextField(
      controller: passwordController,
      enabled: formEnabled,
      obscureText: !showPass,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onPasswordFieldSubmitted(),
      style: TextStyle(fontSize: rem * 3.8, color: _textDark),
      decoration: _deco('••••••••', rem, error: passwordError).copyWith(
        suffixIcon: IconButton(
          icon: Text(showPass ? '🙈' : '👁',
            style: TextStyle(fontSize: rem * 4.5)),
          onPressed: onTogglePass))),
    SizedBox(height: rem * 2),

    Align(alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text('Mot de passe oublié ?', style: TextStyle(
          color: _gold, fontSize: rem * 3.2,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline)))),

    if (submitError != null) ...[
      SizedBox(height: rem * 2),
      _ErrBox(text: submitError!, rem: rem),
    ],
    SizedBox(height: rem * 5),

    _GoldBtn(
      label: 'Se connecter',
      enabled: formEnabled && !isLoading,
      isLoading: isLoading,
      rem: rem,
      onTap: onSubmit),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHOISIR RÔLE
// ═══════════════════════════════════════════════════════════════════════════════
class _ChooseRolePage extends StatelessWidget {
  const _ChooseRolePage({
    required this.onChooseClient,
    required this.onChooseProvider,
    required this.rem,
  });

  final VoidCallback onChooseClient, onChooseProvider;
  final double rem;

  @override
  Widget build(BuildContext context) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Qui êtes-vous ?', style: TextStyle(
      fontSize: rem * 5.5,
      fontWeight: FontWeight.w900,
      color: _textDark)),
    SizedBox(height: rem * 1.5),
    Text('Choisissez votre espace pour créer votre compte',
      style: TextStyle(fontSize: rem * 3.5, color: _textGrey)),
    SizedBox(height: rem * 5),

    // Client
    GestureDetector(
      onTap: onChooseClient,
      child: Container(
        padding: EdgeInsets.all(rem * 4.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rem * 4),
          border: Border.all(color: _goldLight, width: 1.5),
          boxShadow: [BoxShadow(
            color: _textDark.withOpacity(0.06),
            blurRadius: 10, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(
            width: rem * 14, height: rem * 14,
            decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
            child: Icon(Icons.person_rounded, color: _gold, size: rem * 7.5)),
          SizedBox(width: rem * 4),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Je suis client(e)', style: TextStyle(
              fontSize: rem * 4.2,
              fontWeight: FontWeight.w800,
              color: _textDark)),
            SizedBox(height: rem),
            Text(
              'Recherchez et réservez des prestataires beauté près de chez vous',
              style: TextStyle(
                fontSize: rem * 3, color: _textGrey, height: 1.4)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded,
            color: _gold, size: rem * 4.5),
        ])),
    ),
    SizedBox(height: rem * 3.5),

    // Prestataire
    GestureDetector(
      onTap: onChooseProvider,
      child: Container(
        padding: EdgeInsets.all(rem * 4.5),
        decoration: BoxDecoration(
          color: _goldLight,
          borderRadius: BorderRadius.circular(rem * 4),
          border: Border.all(color: _gold.withOpacity(0.4), width: 1.5),
          boxShadow: [BoxShadow(
            color: _gold.withOpacity(0.15),
            blurRadius: 10, offset: const Offset(0, 3))]),
        child: Row(children: [
          Container(
            width: rem * 14, height: rem * 14,
            decoration: BoxDecoration(color: _gold, shape: BoxShape.circle),
            child: Icon(Icons.content_cut_rounded,
              color: Colors.white, size: rem * 7.5)),
          SizedBox(width: rem * 4),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Je suis prestataire', style: TextStyle(
              fontSize: rem * 4.2,
              fontWeight: FontWeight.w800,
              color: _textDark)),
            SizedBox(height: rem),
            Text(
              'Développez votre activité et gérez vos réservations en ligne',
              style: TextStyle(
                fontSize: rem * 3, color: _goldDark, height: 1.4)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded,
            color: _goldDark, size: rem * 4.5),
        ])),
    ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE INSCRIPTION CLIENT
// ═══════════════════════════════════════════════════════════════════════════════
class RegisterClientPage extends StatefulWidget {
  const RegisterClientPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.formEnabled = true,
    this.isLoading = false,
    this.submitError,
  });

  final TextEditingController emailController, passwordController;
  final VoidCallback onSubmit;
  final bool formEnabled, isLoading;
  final String? submitError;

  @override
  State<RegisterClientPage> createState() => _RegisterClientPageState();
}

class _RegisterClientPageState extends State<RegisterClientPage> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  bool _showPass   = false;
  bool _acceptCGU  = false;

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _phoneCtrl.dispose(); _villeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 3.5),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: rem * 9, height: rem * 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _goldLight)),
                child: Icon(Icons.arrow_back_rounded,
                  color: _textDark, size: rem * 5))),
            SizedBox(width: rem * 3),
            Text('Créer mon compte', style: TextStyle(
              fontSize: rem * 4.5,
              fontWeight: FontWeight.w800,
              color: _textDark)),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(rem * 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Badge
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.06),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: Row(children: [
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(
                      color: _goldLight, shape: BoxShape.circle),
                    child: Icon(Icons.person_rounded,
                      color: _gold, size: rem * 6.5)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Espace Client', style: TextStyle(
                      fontSize: rem * 4,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
                    Text('Inscription gratuite', style: TextStyle(
                      fontSize: rem * 3, color: _textGrey)),
                  ])),
                ])),
              SizedBox(height: rem * 5),

              // Champs
              Row(children: [
                Expanded(child: _Fld(
                  label: 'Prénom *', ctrl: _firstCtrl,
                  hint: 'Votre prénom', rem: rem)),
                SizedBox(width: rem * 3),
                Expanded(child: _Fld(
                  label: 'Nom *', ctrl: _lastCtrl,
                  hint: 'Votre nom', rem: rem)),
              ]),
              _Fld(label: 'Téléphone', ctrl: _phoneCtrl,
                hint: '+33 6 00 00 00 00', rem: rem,
                type: TextInputType.phone),
              _Fld(label: 'Ville *', ctrl: _villeCtrl,
                hint: 'Paris, Lyon…', rem: rem),

              _Lbl(text: 'Email *', rem: rem),
              _TF(ctrl: widget.emailController, hint: 'votre@email.com',
                enabled: widget.formEnabled, rem: rem,
                type: TextInputType.emailAddress),
              SizedBox(height: rem * 3.5),

              _Lbl(text: 'Mot de passe *', rem: rem),
              TextField(
                controller: widget.passwordController,
                enabled: widget.formEnabled,
                obscureText: !_showPass,
                style: TextStyle(fontSize: rem * 3.8, color: _textDark),
                decoration: _deco('••••••••', rem).copyWith(
                  suffixIcon: IconButton(
                    icon: Text(_showPass ? '🙈' : '👁',
                      style: TextStyle(fontSize: rem * 4.5)),
                    onPressed: () =>
                      setState(() => _showPass = !_showPass)))),
              SizedBox(height: rem * 4),

              // CGU
              _CguRow(
                accepted: _acceptCGU, rem: rem,
                onToggle: () => setState(() => _acceptCGU = !_acceptCGU)),
              SizedBox(height: rem * 4),

              if (widget.submitError != null) ...[
                _ErrBox(text: widget.submitError!, rem: rem),
                SizedBox(height: rem * 3),
              ],

              _GoldBtn(
                label: 'Créer mon compte',
                enabled: widget.formEnabled && !widget.isLoading && _acceptCGU,
                isLoading: widget.isLoading,
                rem: rem,
                onTap: widget.onSubmit),
              SizedBox(height: rem * 8),
            ]),
          ),
        ),
      ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAGE INSCRIPTION PRESTATAIRE
// ═══════════════════════════════════════════════════════════════════════════════
class RegisterProviderPage extends StatefulWidget {
  const RegisterProviderPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.formEnabled = true,
    this.isLoading = false,
    this.submitError,
  });

  final TextEditingController emailController, passwordController;
  final VoidCallback onSubmit;
  final bool formEnabled, isLoading;
  final String? submitError;

  @override
  State<RegisterProviderPage> createState() => _RegisterProviderPageState();
}

class _RegisterProviderPageState extends State<RegisterProviderPage> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _expCtrl   = TextEditingController();
  final _bioCtrl   = TextEditingController();
  bool _showPass   = false;
  bool _acceptCGU  = false;
  String _type     = 'hairdresser';
  String _location = 'home';

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _phoneCtrl.dispose();
    _villeCtrl.dispose(); _expCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 3.5),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: rem * 9, height: rem * 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _goldLight)),
                child: Icon(Icons.arrow_back_rounded,
                  color: _textDark, size: rem * 5))),
            SizedBox(width: rem * 3),
            Text('Espace Prestataire', style: TextStyle(
              fontSize: rem * 4.5,
              fontWeight: FontWeight.w800,
              color: _textDark)),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(rem * 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Badge
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(rem * 4),
                  border: Border.all(color: _gold.withOpacity(0.3))),
                child: Row(children: [
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(color: _gold, shape: BoxShape.circle),
                    child: Icon(Icons.content_cut_rounded,
                      color: Colors.white, size: rem * 6.5)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Espace Pro', style: TextStyle(
                      fontSize: rem * 4,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
                    Text('Développez votre activité beauté', style: TextStyle(
                      fontSize: rem * 3, color: _goldDark)),
                  ])),
                ])),
              SizedBox(height: rem * 5),

              // Identité
              _SecTitle(label: 'Identité', icon: Icons.person_rounded, rem: rem),
              Row(children: [
                Expanded(child: _Fld(
                  label: 'Prénom *', ctrl: _firstCtrl,
                  hint: 'Votre prénom', rem: rem)),
                SizedBox(width: rem * 3),
                Expanded(child: _Fld(
                  label: 'Nom *', ctrl: _lastCtrl,
                  hint: 'Votre nom', rem: rem)),
              ]),
              _Fld(label: 'Téléphone *', ctrl: _phoneCtrl,
                hint: '+33 6 00 00 00 00', rem: rem,
                type: TextInputType.phone),
              _Fld(label: 'Ville *', ctrl: _villeCtrl,
                hint: 'Paris, Lyon…', rem: rem),
              SizedBox(height: rem * 2),

              // Activité
              _SecTitle(label: 'Activité professionnelle',
                icon: Icons.work_outline_rounded, rem: rem),
              Text('Votre spécialité *', style: TextStyle(
                fontSize: rem * 3.8, fontWeight: FontWeight.w600,
                color: _textDark)),
              SizedBox(height: rem * 2),
              ..._providerTypes.map((pt) => _ChoiceBtn(
                icon: pt['icon'] as IconData,
                label: pt['label'] as String,
                active: _type == pt['key'],
                rem: rem,
                onTap: () => setState(() => _type = pt['key'] as String))),
              SizedBox(height: rem * 3),

              Text('Où travaillez-vous ? *', style: TextStyle(
                fontSize: rem * 3.8, fontWeight: FontWeight.w600,
                color: _textDark)),
              SizedBox(height: rem * 2),
              ..._workLocations.map((wl) => _ChoiceBtn(
                icon: wl['icon'] as IconData,
                label: wl['label'] as String,
                active: _location == wl['key'],
                rem: rem,
                onTap: () => setState(() => _location = wl['key'] as String))),
              SizedBox(height: rem * 3),

              // Profil pro
              _SecTitle(label: 'Profil pro',
                icon: Icons.badge_outlined, rem: rem),
              _Fld(label: "Années d'expérience", ctrl: _expCtrl,
                hint: 'Ex : 5 ans en coiffure afro', rem: rem),
              _Lbl(text: 'Bio / Présentation *', rem: rem),
              TextField(
                controller: _bioCtrl, maxLines: 4,
                style: TextStyle(fontSize: rem * 3.8, color: _textDark),
                decoration: _deco(
                  'Parlez de vous, votre style, vos techniques…', rem).copyWith(
                  contentPadding: EdgeInsets.all(rem * 3.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: BorderSide(color: _gold, width: 2)))),
              SizedBox(height: rem * 5),

              // Compte
              _SecTitle(label: 'Compte',
                icon: Icons.lock_outline_rounded, rem: rem),
              _Lbl(text: 'Email *', rem: rem),
              _TF(ctrl: widget.emailController, hint: 'votre@email.com',
                enabled: widget.formEnabled, rem: rem,
                type: TextInputType.emailAddress),
              SizedBox(height: rem * 3.5),

              _Lbl(text: 'Mot de passe *', rem: rem),
              TextField(
                controller: widget.passwordController,
                enabled: widget.formEnabled,
                obscureText: !_showPass,
                style: TextStyle(fontSize: rem * 3.8, color: _textDark),
                decoration: _deco('••••••••', rem).copyWith(
                  suffixIcon: IconButton(
                    icon: Text(_showPass ? '🙈' : '👁',
                      style: TextStyle(fontSize: rem * 4.5)),
                    onPressed: () =>
                      setState(() => _showPass = !_showPass)))),
              SizedBox(height: rem * 5),

              // CGU
              _CguRow(
                accepted: _acceptCGU, rem: rem,
                onToggle: () => setState(() => _acceptCGU = !_acceptCGU)),
              SizedBox(height: rem * 4),

              if (widget.submitError != null) ...[
                _ErrBox(text: widget.submitError!, rem: rem),
                SizedBox(height: rem * 3),
              ],

              _GoldBtn(
                label: 'Créer mon espace Pro',
                icon: Icons.arrow_forward_rounded,
                enabled: widget.formEnabled && !widget.isLoading && _acceptCGU,
                isLoading: widget.isLoading,
                rem: rem,
                onTap: widget.onSubmit),
              SizedBox(height: rem * 8),
            ]),
          ),
        ),
      ])),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS UTILITAIRES — tous dans ce fichier
// ═══════════════════════════════════════════════════════════════════════════════

// Label
class _Lbl extends StatelessWidget {
  const _Lbl({required this.text, required this.rem});
  final String text; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 2),
    child: Text(text, style: TextStyle(
      fontSize: rem * 3.8,
      fontWeight: FontWeight.w600,
      color: _textDark)));
}

// Champ avec label
class _Fld extends StatelessWidget {
  const _Fld({required this.label, required this.ctrl, required this.hint,
    required this.rem, this.type = TextInputType.text});
  final String label, hint;
  final TextEditingController ctrl;
  final double rem;
  final TextInputType type;
  @override
  Widget build(BuildContext context) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(
      fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)),
    SizedBox(height: rem * 2),
    _TF(ctrl: ctrl, hint: hint, enabled: true, rem: rem, type: type),
    SizedBox(height: rem * 3.5),
  ]);
}

// TextField nu
class _TF extends StatelessWidget {
  const _TF({required this.ctrl, required this.hint, required this.enabled,
    required this.rem, this.type = TextInputType.text, this.error});
  final TextEditingController ctrl;
  final String hint;
  final bool enabled;
  final double rem;
  final TextInputType type;
  final String? error;
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, enabled: enabled, keyboardType: type,
    style: TextStyle(fontSize: rem * 3.8, color: _textDark),
    decoration: _deco(hint, rem, error: error));
}

// Décoration
InputDecoration _deco(String hint, double rem, {String? error}) =>
  InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3.5),
    errorText: error,
    filled: true, fillColor: const Color(0xFFF8F5F0),
    contentPadding: EdgeInsets.symmetric(
      horizontal: rem * 4, vertical: rem * 3.2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rem * 6),
      borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rem * 6),
      borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rem * 6),
      borderSide: BorderSide(color: _gold, width: 2)),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(rem * 6),
      borderSide: const BorderSide(color: Colors.red)));

// Bouton doré
class _GoldBtn extends StatelessWidget {
  const _GoldBtn({required this.label, required this.enabled,
    required this.isLoading, required this.rem, required this.onTap,
    this.icon});
  final String label; final bool enabled, isLoading;
  final double rem; final VoidCallback onTap; final IconData? icon;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rem * 4),
      decoration: BoxDecoration(
        color: enabled ? _gold : _goldLight,
        borderRadius: BorderRadius.circular(rem * 8),
        boxShadow: enabled ? [BoxShadow(
          color: _gold.withOpacity(0.4),
          blurRadius: 12, offset: const Offset(0, 5))] : null),
      child: Center(child: isLoading
        ? SizedBox(width: rem * 5, height: rem * 5,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: rem * 5),
              SizedBox(width: rem * 2),
            ],
            Text(label, style: TextStyle(
              color: Colors.white,
              fontSize: rem * 4,
              fontWeight: FontWeight.w700)),
          ]))));
}

// Erreur
class _ErrBox extends StatelessWidget {
  const _ErrBox({required this.text, required this.rem});
  final String text; final double rem;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(rem * 3),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(rem * 2.5)),
    child: Row(children: [
      Icon(Icons.error_outline, color: Colors.red, size: rem * 4.5),
      SizedBox(width: rem * 2),
      Expanded(child: Text(text, style: TextStyle(
        color: Colors.red, fontSize: rem * 3))),
    ]));
}

// CGU
class _CguRow extends StatelessWidget {
  const _CguRow({required this.accepted, required this.rem,
    required this.onToggle});
  final bool accepted; final double rem; final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onToggle,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: rem * 6, height: rem * 6,
        decoration: BoxDecoration(
          color: accepted ? _gold : Colors.white,
          borderRadius: BorderRadius.circular(rem * 1.5),
          border: Border.all(
            color: accepted ? _gold : const Color(0xFFEDE0CC), width: 1.5)),
        child: accepted
          ? Icon(Icons.check_rounded, color: Colors.white, size: rem * 4)
          : null),
      SizedBox(width: rem * 3),
      Expanded(child: RichText(text: TextSpan(
        style: TextStyle(fontSize: rem * 3.2, color: _textGrey, height: 1.5),
        children: [
          const TextSpan(text: "J'accepte les "),
          TextSpan(
            text: "conditions générales d'utilisation",
            style: TextStyle(
              color: _gold, fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(
                Uri.parse('https://madbeauty.fr/cgu'))),
        ]))),
    ]));
}

// Titre de section
class _SecTitle extends StatelessWidget {
  const _SecTitle({required this.label, required this.icon, required this.rem});
  final String label; final IconData icon; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 3),
    child: Row(children: [
      Container(
        width: rem * 8, height: rem * 8,
        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
        child: Icon(icon, color: _gold, size: rem * 4.5)),
      SizedBox(width: rem * 2.5),
      Text(label, style: TextStyle(
        fontSize: rem * 3.8,
        fontWeight: FontWeight.w700,
        color: _goldDark)),
    ]));
}

// Bouton choix
class _ChoiceBtn extends StatelessWidget {
  const _ChoiceBtn({required this.icon, required this.label,
    required this.active, required this.onTap, required this.rem});
  final IconData icon; final String label;
  final bool active; final VoidCallback onTap; final double rem;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: rem * 2),
      padding: EdgeInsets.symmetric(
        horizontal: rem * 4, vertical: rem * 3.5),
      decoration: BoxDecoration(
        color: active ? _goldLight : Colors.white,
        borderRadius: BorderRadius.circular(rem * 3.5),
        border: Border.all(
          color: active ? _gold : const Color(0xFFEDE0CC),
          width: active ? 2 : 1)),
      child: Row(children: [
        Container(
          width: rem * 9, height: rem * 9,
          decoration: BoxDecoration(
            color: active ? _gold : const Color(0xFFF5F0EA),
            shape: BoxShape.circle),
          child: Icon(icon,
            color: active ? Colors.white : _textGrey, size: rem * 4.5)),
        SizedBox(width: rem * 3),
        Expanded(child: Text(label, style: TextStyle(
          fontSize: rem * 3.8,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? _goldDark : _textGrey))),
        if (active)
          Icon(Icons.check_circle_rounded, color: _gold, size: rem * 5.5),
      ])));
}


























































// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:url_launcher/url_launcher.dart';

// const _green      = Color(0xFF2D7A4F);
// const _greenLight = Color(0xFFE8F5EE);
// const _greyBg     = Color(0xFFF2F2F7);
// const _textDark   = Color(0xFF1A1A1A);
// const _textGrey   = Color(0xFF8E8E93);
// const _white      = Colors.white;

// const _providerTypes = [
//   {'key': 'hairdresser', 'label': 'Coiffeur(se)',       'icon': '✂️'},
//   {'key': 'makeup',      'label': 'Maquilleur(se)',      'icon': '💄'},
//   {'key': 'manicure',    'label': 'Manucure / Pédicure', 'icon': '💅'},
// ];

// const _workLocations = [
//   {'key': 'home',   'label': 'À mon salon / chez moi', 'icon': '🏠'},
//   {'key': 'client', 'label': 'Chez le client',          'icon': '🚗'},
//   {'key': 'both',   'label': 'Les deux',                'icon': '🔄'},
// ];

// class LoginPage extends StatefulWidget {
//   const LoginPage({
//     super.key,
//     required this.emailController,
//     required this.passwordController,
//     required this.onSubmit,
//     required this.onBack,
//     required this.onPasswordFieldSubmitted,
//     this.showSupabaseConfigCard = false,
//     this.emailError,
//     this.passwordError,
//     this.submitError,
//     this.isLoading = false,
//     this.formEnabled = true,
//     // 👇 NOUVEAUX PARAMÈTRES
//     this.onRegisterAsProvider,
//     this.onRegisterAsClient,
//   });

//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final VoidCallback onSubmit;
//   final VoidCallback onBack;
//   final VoidCallback onPasswordFieldSubmitted;
//   final bool showSupabaseConfigCard;
//   final String? emailError;
//   final String? passwordError;
//   final String? submitError;
//   final bool isLoading;
//   final bool formEnabled;

//   /// Appelé quand inscription prestataire réussie → navigue vers onboarding
//   final VoidCallback? onRegisterAsProvider;
//   /// Appelé quand inscription client réussie → navigue vers accueil client
//   final VoidCallback? onRegisterAsClient;

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   String _userType     = 'client';
//   String _authMode     = 'login';
//   bool   _showPass     = false;
//   bool   _acceptedCGU  = false;
//   String _providerType = 'hairdresser';
//   String _workLocation = 'home';

//   final _firstNameCtrl  = TextEditingController();
//   final _lastNameCtrl   = TextEditingController();
//   final _phoneCtrl      = TextEditingController();
//   final _cityCtrl       = TextEditingController();
//   final _addressCtrl    = TextEditingController();
//   final _bioCtrl        = TextEditingController();
//   final _experienceCtrl = TextEditingController();

//   bool get _isProvider => _userType == 'provider';
//   bool get _isLogin    => _authMode  == 'login';

//   @override
//   void dispose() {
//     _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
//     _phoneCtrl.dispose(); _cityCtrl.dispose();
//     _addressCtrl.dispose(); _bioCtrl.dispose();
//     _experienceCtrl.dispose();
//     super.dispose();
//   }

//   // Appelé quand l'utilisateur appuie sur le bouton principal
//   void _handleSubmit() {
//     if (!_isLogin) {
//       // Inscription
//       if (_isProvider) {
//         widget.onRegisterAsProvider?.call();
//       } else {
//         widget.onRegisterAsClient?.call();
//       }
//     } else {
//       // Connexion → login_route gère la redirection selon le rôle
//       widget.onSubmit();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               const Center(
//                 child: Text('Bienvenue',
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _textDark)),
//               ),
//               const SizedBox(height: 28),

//               if (widget.showSupabaseConfigCard) ...[
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF3CD),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: const Color(0xFFFFD700)),
//                   ),
//                   child: const Row(children: [
//                     Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 20),
//                     SizedBox(width: 10),
//                     Expanded(child: Text('Supabase non configuré.',
//                       style: TextStyle(color: Color(0xFF7A5800), fontSize: 13))),
//                   ]),
//                 ),
//                 const SizedBox(height: 20),
//               ],

//               // Toggle Client / Prestataire
//               Row(children: [
//                 _RoleButton(label: '👥  Client',      type: 'client',   current: _userType, onTap: (v) => setState(() => _userType = v)),
//                 const SizedBox(width: 12),
//                 _RoleButton(label: '✂️  Prestataire', type: 'provider', current: _userType, onTap: (v) => setState(() => _userType = v)),
//               ]),
//               const SizedBox(height: 16),

//               // Toggle Connexion / Inscription
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(color: _greyBg, borderRadius: BorderRadius.circular(14)),
//                 child: Row(children: [
//                   _ModeButton(label: 'Connexion',   mode: 'login',    current: _authMode, onTap: (v) => setState(() => _authMode = v)),
//                   _ModeButton(label: 'Inscription', mode: 'register', current: _authMode, onTap: (v) => setState(() => _authMode = v)),
//                 ]),
//               ),
//               const SizedBox(height: 20),

//               // Carte formulaire
//               Container(
//                 decoration: BoxDecoration(
//                   color: _white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: const Color(0xFFEBEBEB)),
//                   boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2))],
//                 ),
//                 padding: const EdgeInsets.all(22),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//                   Text(
//                     '${_isLogin ? "Se connecter" : "S\'inscrire"} – ${_isProvider ? "Prestataire Pro" : "Client"}',
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textDark),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _isLogin ? 'Accédez à votre espace personnel'
//                       : _isProvider ? 'Créez votre espace professionnel'
//                       : 'Créez votre compte gratuitement',
//                     style: const TextStyle(fontSize: 14, color: _textGrey),
//                   ),
//                   const SizedBox(height: 22),

//                   if (!_isLogin) ...[
//                     _SectionLabel(text: '👤 Identité'),
//                     _Field(label: 'Prénom *',  ctrl: _firstNameCtrl,  placeholder: 'Votre prénom'),
//                     _Field(label: 'Nom *',     ctrl: _lastNameCtrl,   placeholder: 'Votre nom'),
//                     _Field(label: 'Téléphone', ctrl: _phoneCtrl,      placeholder: '+33 6 00 00 00 00', type: TextInputType.phone, caps: TextCapitalization.none),
//                     _SectionLabel(text: '📍 Localisation'),
//                     _Field(label: 'Ville *',   ctrl: _cityCtrl,       placeholder: 'Paris, Lyon…'),
//                     _Field(label: 'Adresse',   ctrl: _addressCtrl,    placeholder: '12 rue des Lilas (facultatif)'),

//                     if (_isProvider) ...[
//                       _SectionLabel(text: '💼 Activité professionnelle'),
//                       const Text('Spécialité *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                       const SizedBox(height: 8),
//                       ..._providerTypes.map((pt) => _ChoiceButton(
//                         icon: pt['icon']!, label: pt['label']!,
//                         active: _providerType == pt['key'],
//                         onTap: () => setState(() => _providerType = pt['key']!),
//                       )),
//                       const SizedBox(height: 12),
//                       const Text('Où travaillez-vous ? *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                       const SizedBox(height: 8),
//                       ..._workLocations.map((wl) => _ChoiceButton(
//                         icon: wl['icon']!, label: wl['label']!,
//                         active: _workLocation == wl['key'],
//                         onTap: () => setState(() => _workLocation = wl['key']!),
//                       )),
//                       _SectionLabel(text: '📋 Profil pro'),
//                       _Field(label: "Années d'expérience", ctrl: _experienceCtrl, placeholder: 'Ex : 5 ans en coiffure afro'),
//                       const Text('Bio / Présentation *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: _bioCtrl,
//                         maxLines: 4,
//                         enabled: widget.formEnabled,
//                         style: const TextStyle(fontSize: 15, color: _textDark),
//                         decoration: _inputDeco('Parlez de vous, votre style, vos techniques…'),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ],

//                   const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: widget.emailController,
//                     enabled: widget.formEnabled,
//                     keyboardType: TextInputType.emailAddress,
//                     textCapitalization: TextCapitalization.none,
//                     textInputAction: TextInputAction.next,
//                     style: const TextStyle(fontSize: 15, color: _textDark),
//                     decoration: _inputDeco('votre@email.com', error: widget.emailError),
//                   ),
//                   const SizedBox(height: 16),

//                   const Text('Mot de passe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: widget.passwordController,
//                     enabled: widget.formEnabled,
//                     obscureText: !_showPass,
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (_) => widget.onPasswordFieldSubmitted(),
//                     style: const TextStyle(fontSize: 15, color: _textDark),
//                     decoration: _inputDeco('••••••••', error: widget.passwordError).copyWith(
//                       suffixIcon: IconButton(
//                         icon: Text(_showPass ? '🙈' : '👁', style: const TextStyle(fontSize: 18)),
//                         onPressed: () => setState(() => _showPass = !_showPass),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   if (!_isLogin) ...[
//                     GestureDetector(
//                       onTap: () => setState(() => _acceptedCGU = !_acceptedCGU),
//                       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Container(
//                           width: 22, height: 22,
//                           decoration: BoxDecoration(
//                             color: _acceptedCGU ? _green : _white,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(color: _acceptedCGU ? _green : const Color(0xFFE0E0E0), width: 1.5),
//                           ),
//                           child: _acceptedCGU ? const Icon(Icons.check, color: _white, size: 14) : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: RichText(
//                             text: TextSpan(
//                               style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
//                               children: [
//                                 const TextSpan(text: "J'accepte les "),
//                                 TextSpan(
//                                   text: "conditions générales d'utilisation",
//                                   style: const TextStyle(color: _green, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () => launchUrl(Uri.parse('https://madbeauty.fr/cgu')),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ]),
//                     ),
//                     const SizedBox(height: 18),
//                   ],

//                   if (widget.submitError != null) ...[
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(10)),
//                       child: Row(children: [
//                         const Icon(Icons.error_outline, color: Color(0xFFCC3333), size: 18),
//                         const SizedBox(width: 8),
//                         Expanded(child: Text(widget.submitError!,
//                           style: const TextStyle(color: Color(0xFFCC3333), fontSize: 13))),
//                       ]),
//                     ),
//                     const SizedBox(height: 14),
//                   ],

//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: (widget.formEnabled && !widget.isLoading && (_isLogin || _acceptedCGU))
//                         ? _handleSubmit : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _green,
//                         foregroundColor: _white,
//                         disabledBackgroundColor: const Color(0xFFA0C4B0),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                         elevation: 0,
//                       ),
//                       child: widget.isLoading
//                         ? const SizedBox(width: 22, height: 22,
//                             child: CircularProgressIndicator(strokeWidth: 2.5, color: _white))
//                         : Text(
//                             _isLogin ? 'Se connecter'
//                               : _isProvider ? 'Créer mon espace Pro'
//                               : 'Créer mon compte',
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                           ),
//                     ),
//                   ),

//                   if (_isLogin) ...[
//                     const SizedBox(height: 14),
//                     Center(
//                       child: TextButton(
//                         onPressed: widget.formEnabled ? () {} : null,
//                         child: const Text('Mot de passe oublié ?',
//                           style: TextStyle(color: _green, fontSize: 14,
//                             fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
//                       ),
//                     ),
//                   ],
//                 ]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// InputDecoration _inputDeco(String hint, {String? error}) => InputDecoration(
//   hintText: hint, hintStyle: const TextStyle(color: _textGrey),
//   errorText: error, filled: true, fillColor: _white,
//   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//   border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
//   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
//   errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCC3333))),
// );

// class _SectionLabel extends StatelessWidget {
//   const _SectionLabel({required this.text});
//   final String text;
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(top: 8, bottom: 12),
//     child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green, letterSpacing: 0.8)),
//   );
// }

// class _Field extends StatelessWidget {
//   const _Field({required this.label, required this.ctrl, required this.placeholder,
//     this.type = TextInputType.text, this.caps = TextCapitalization.words});
//   final String label, placeholder;
//   final TextEditingController ctrl;
//   final TextInputType type;
//   final TextCapitalization caps;
//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
//       const SizedBox(height: 8),
//       TextField(controller: ctrl, keyboardType: type, textCapitalization: caps,
//         style: const TextStyle(fontSize: 15, color: _textDark),
//         decoration: _inputDeco(placeholder)),
//       const SizedBox(height: 16),
//     ],
//   );
// }

// class _ChoiceButton extends StatelessWidget {
//   const _ChoiceButton({required this.icon, required this.label, required this.active, required this.onTap});
//   final String icon, label;
//   final bool active;
//   final VoidCallback onTap;
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//       decoration: BoxDecoration(
//         color: active ? _greenLight : _white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: active ? _green : const Color(0xFFE0E0E0), width: 1.5),
//       ),
//       child: Row(children: [
//         Text(icon, style: const TextStyle(fontSize: 20)),
//         const SizedBox(width: 12),
//         Expanded(child: Text(label, style: TextStyle(
//           fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//           color: active ? _green : _textGrey))),
//         if (active) const Text('✓', style: TextStyle(fontSize: 16, color: _green, fontWeight: FontWeight.w700)),
//       ]),
//     ),
//   );
// }

// class _RoleButton extends StatelessWidget {
//   const _RoleButton({required this.label, required this.type, required this.current, required this.onTap});
//   final String label, type, current;
//   final ValueChanged<String> onTap;
//   @override
//   Widget build(BuildContext context) {
//     final active = current == type;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTap(type),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: active ? _green : _white,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(color: _green, width: 1.5),
//           ),
//           alignment: Alignment.center,
//           child: Text(label, style: TextStyle(
//             fontSize: 15, fontWeight: FontWeight.w600,
//             color: active ? _white : _green)),
//         ),
//       ),
//     );
//   }
// }

// class _ModeButton extends StatelessWidget {
//   const _ModeButton({required this.label, required this.mode, required this.current, required this.onTap});
//   final String label, mode, current;
//   final ValueChanged<String> onTap;
//   @override
//   Widget build(BuildContext context) {
//     final active = current == mode;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onTap(mode),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: active ? _green : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           alignment: Alignment.center,
//           child: Text(label, style: TextStyle(
//             fontSize: 15, fontWeight: FontWeight.w600,
//             color: active ? _white : _textGrey)),
//         ),
//       ),
//     );
//   }
// }













// // import 'package:flutter/material.dart';

// // import '../../../../core/constants/app_strings.dart';

// // /// Page de connexion : mise en page uniquement (aucune règle métier).
// // class LoginPage extends StatelessWidget {
// //   const LoginPage({
// //     super.key,
// //     required this.showSupabaseConfigCard,
// //     required this.emailController,
// //     required this.passwordController,
// //     required this.emailError,
// //     required this.passwordError,
// //     required this.submitError,
// //     required this.isLoading,
// //     required this.formEnabled,
// //     required this.onBack,
// //     required this.onSubmit,
// //     required this.onPasswordFieldSubmitted,
// //   });

// //   final bool showSupabaseConfigCard;
// //   final TextEditingController emailController;
// //   final TextEditingController passwordController;
// //   final String? emailError;
// //   final String? passwordError;
// //   final String? submitError;
// //   final bool isLoading;
// //   final bool formEnabled;
// //   final VoidCallback onBack;
// //   final VoidCallback onSubmit;
// //   final VoidCallback onPasswordFieldSubmitted;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(AppStrings.loginTitle),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: isLoading ? null : onBack,
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Text(
// //                 AppStrings.loginDescription,
// //                 style: Theme.of(context).textTheme.bodyMedium,
// //               ),
// //               const SizedBox(height: 24),
// //               if (showSupabaseConfigCard) ...[
// //                 Card(
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           AppStrings.supabaseMissingTitle,
// //                           style: Theme.of(context).textTheme.titleMedium,
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           AppStrings.supabaseMissingBody,
// //                           style: Theme.of(context).textTheme.bodyMedium,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //               ],
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   TextField(
// //                     controller: emailController,
// //                     enabled: formEnabled,
// //                     keyboardType: TextInputType.emailAddress,
// //                     autocorrect: false,
// //                     textInputAction: TextInputAction.next,
// //                     decoration: InputDecoration(
// //                       labelText: AppStrings.loginFieldEmail,
// //                       errorText: emailError,
// //                       border: const OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   TextField(
// //                     controller: passwordController,
// //                     enabled: formEnabled,
// //                     obscureText: true,
// //                     textInputAction: TextInputAction.done,
// //                     onSubmitted: (_) => onPasswordFieldSubmitted(),
// //                     decoration: InputDecoration(
// //                       labelText: AppStrings.loginFieldPassword,
// //                       errorText: passwordError,
// //                       border: const OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   if (submitError != null) ...[
// //                     const SizedBox(height: 16),
// //                     Material(
// //                       color: Theme.of(context).colorScheme.errorContainer,
// //                       borderRadius: BorderRadius.circular(12),
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(12),
// //                         child: Text(
// //                           submitError!,
// //                           style:
// //                               Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                                     color: Theme.of(context)
// //                                         .colorScheme
// //                                         .onErrorContainer,
// //                                   ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                   const SizedBox(height: 24),
// //                   FilledButton(
// //                     onPressed: !formEnabled || isLoading ? null : onSubmit,
// //                     child: isLoading
// //                         ? const SizedBox(
// //                             height: 22,
// //                             width: 22,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           )
// //                         : Text(AppStrings.loginActionSubmit),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
