


import 'package:flutter/material.dart';

const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);
const _bg        = Color(0xFFF2EBE0);

class StepPhotoProfil extends StatefulWidget {
  const StepPhotoProfil({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepPhotoProfil> createState() => _StepPhotoProfilState();
}

class _StepPhotoProfilState extends State<StepPhotoProfil> {
  final _prenomCtrl     = TextEditingController();
  final _nomCtrl        = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _telCtrl        = TextEditingController();
  final _villeCtrl      = TextEditingController();
  final _codePostalCtrl = TextEditingController();
  final _adresseCtrl    = TextEditingController();
  final _nomAffCtrl     = TextEditingController();
  final _expCtrl        = TextEditingController();
  final _descCtrl       = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _prenomCtrl,
      _nomCtrl,
      _emailCtrl,
      _telCtrl,
      _villeCtrl,
      _codePostalCtrl,
      _adresseCtrl,
      _nomAffCtrl,
      _expCtrl,
      _descCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Titre
      Center(
        child: Text(
          'Modifier le profil',
          style: TextStyle(
            fontSize: rem * 4.8,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
      ),
      SizedBox(height: rem * 5),

      // Photo
      Row(children: [
        Container(
          width: rem * 14,
          height: rem * 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _goldLight,
          ),
          child: Icon(Icons.person_rounded, color: _gold, size: rem * 8),
        ),
        SizedBox(width: rem * 3),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(vertical: rem * 3.5),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(rem * 5),
                border: Border.all(color: const Color(0xFFEDE0CC)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.upload_rounded, color: _textDark, size: rem * 4.5),
                SizedBox(width: rem * 2),
                Text(
                  'Changer la photo',
                  style: TextStyle(color: _textDark, fontSize: rem * 3.5),
                ),
              ]),
            ),
          ),
        ),
      ]),
      SizedBox(height: rem * 5),

      // Prénom / Nom
      Row(children: [
        Expanded(child: _F(label: 'Prénom', ctrl: _prenomCtrl, hint: 'Votre prénom', required: true, rem: rem)),
        SizedBox(width: rem * 3),
        Expanded(child: _F(label: 'Nom', ctrl: _nomCtrl, hint: 'Votre nom', required: true, rem: rem)),
      ]),

      _F(
        label: 'Email',
        ctrl: _emailCtrl,
        hint: 'votre@email.com',
        required: true,
        rem: rem,
        type: TextInputType.emailAddress,
      ),

      _F(
        label: 'Téléphone',
        ctrl: _telCtrl,
        hint: '0600000000',
        required: true,
        rem: rem,
        type: TextInputType.phone,
      ),

      // Ville / Code postal
      Row(children: [
        Expanded(child: _FL(label: 'Ville', ctrl: _villeCtrl, hint: 'Paris', required: true, rem: rem)),
        SizedBox(width: rem * 3),
        Expanded(child: _F(label: 'Code postal', ctrl: _codePostalCtrl, hint: '75000', required: true, rem: rem, type: TextInputType.number)),
      ]),

      _FL(label: 'Adresse', ctrl: _adresseCtrl, hint: '12 rue des Lilas', rem: rem),
      Padding(
        padding: EdgeInsets.only(bottom: rem * 3),
        child: Text(
          'Optionnel – Utile si vous recevez des clients à votre domicile/salon',
          style: TextStyle(fontSize: rem * 2.8, color: _textGrey),
        ),
      ),

      _F(label: 'Nom affiché', ctrl: _nomAffCtrl, hint: 'Nom visible par les clients', required: true, rem: rem),

      // Expérience
      _TextArea(
        label: 'Expérience professionnelle',
        ctrl: _expCtrl,
        hint: 'Décrivez votre expérience…',
        maxChars: 150,
        maxLines: 3,
        rem: rem,
      ),

      // Description
      _TextArea(
        label: 'Description',
        ctrl: _descCtrl,
        hint: 'Présentez-vous à vos clients…',
        maxChars: 200,
        maxLines: 4,
        rem: rem,
      ),

      // Avertissement
      Container(
        padding: EdgeInsets.all(rem * 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(rem * 2.5),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded,
            color: const Color(0xFFB8860B), size: rem * 4.5),
          SizedBox(width: rem * 2),
          Expanded(
            child: Text(
              'Interdit : réseaux sociaux, téléphone, email, liens externes',
              style: TextStyle(fontSize: rem * 3, color: const Color(0xFF7A5800)),
            ),
          ),
        ]),
      ),

      SizedBox(height: rem * 5),

      // Boutons enregistrer / annuler
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.onSave,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: rem * 3.8),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(rem * 6),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  'Enregistrer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: rem * 3),
        Expanded(
          child: GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: rem * 3.8),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(rem * 6),
                border: Border.all(color: const Color(0xFFEDE0CC)),
              ),
              child: Center(
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: rem * 3.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),

      SizedBox(height: rem * 3),

      // Supprimer compte
      GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: rem * 3.8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(rem * 6),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red, size: rem * 5.5),
            SizedBox(width: rem * 2),
            Text(
              'Supprimer mon compte',
              style: TextStyle(
                color: Colors.red,
                fontSize: rem * 3.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
      ),

      SizedBox(height: rem * 6),
    ]);
  }
}

// ── Champ texte simple
class _F extends StatelessWidget {
  const _F({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.rem,
    this.required = false,
    this.type = TextInputType.text,
  });

  final String label, hint;
  final TextEditingController ctrl;
  final double rem;
  final bool required;
  final TextInputType type;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: TextStyle(
          fontSize: rem * 3.5,
          fontWeight: FontWeight.w600,
          color: _textDark,
        )),
        if (required)
          Text(' *', style: TextStyle(color: Colors.red, fontSize: rem * 3.5)),
      ]),
      SizedBox(height: rem * 2),
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: TextStyle(fontSize: rem * 3.5, color: _textDark),
        decoration: _deco(hint, rem),
      ),
      SizedBox(height: rem * 3.5),
    ],
  );
}

// ── Champ avec icône localisation
class _FL extends StatelessWidget {
  const _FL({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.rem,
    this.required = false,
  });

  final String label, hint;
  final TextEditingController ctrl;
  final double rem;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: TextStyle(
          fontSize: rem * 3.5,
          fontWeight: FontWeight.w600,
          color: _textDark,
        )),
        if (required)
          Text(' *', style: TextStyle(color: Colors.red, fontSize: rem * 3.5)),
      ]),
      SizedBox(height: rem * 2),
      TextField(
        controller: ctrl,
        style: TextStyle(fontSize: rem * 3.5, color: _textDark),
        decoration: _deco(hint, rem).copyWith(
          suffixIcon: Icon(Icons.location_on_outlined, color: _textGrey, size: rem * 5),
        ),
      ),
      SizedBox(height: rem * 3.5),
    ],
  );
}

// ── Champ textarea avec compteur
class _TextArea extends StatelessWidget {
  const _TextArea({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.maxChars,
    required this.maxLines,
    required this.rem,
  });

  final String label, hint;
  final TextEditingController ctrl;
  final int maxChars, maxLines;
  final double rem;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: TextStyle(
          fontSize: rem * 3.5,
          fontWeight: FontWeight.w600,
          color: _textDark,
        )),
        SizedBox(width: rem * 1.5),
        ValueListenableBuilder(
          valueListenable: ctrl,
          builder: (_, v, __) => Text(
            '(${v.text.length}/$maxChars)',
            style: TextStyle(fontSize: rem * 2.8, color: _textGrey),
          ),
        ),
      ]),
      SizedBox(height: rem * 2),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        maxLength: maxChars,
        style: TextStyle(fontSize: rem * 3.5, color: _textDark),
        decoration: _deco(hint, rem).copyWith(
          counterText: '',
          contentPadding: EdgeInsets.all(rem * 3.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rem * 3),
            borderSide: const BorderSide(color: Color(0xFFEDE0CC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rem * 3),
            borderSide: const BorderSide(color: Color(0xFFEDE0CC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rem * 3),
            borderSide: BorderSide(color: _gold, width: 2),
          ),
        ),
      ),
      SizedBox(height: rem * 4),
    ],
  );
}

// ── Décoration champ
InputDecoration _deco(String hint, double rem) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3.2),
  filled: true,
  fillColor: const Color(0xFFF8F5F0),
  contentPadding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.2),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: const BorderSide(color: Color(0xFFEDE0CC)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: const BorderSide(color: Color(0xFFEDE0CC)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(rem * 6),
    borderSide: BorderSide(color: _gold, width: 2),
  ),
);





















































// import 'package:flutter/material.dart';

// const _gold      = Color(0xFFC4956A);
// const _goldLight = Color(0xFFEDE0CC);
// const _goldDark  = Color(0xFF8B6340);
// const _textDark  = Color(0xFF2C1810);
// const _textGrey  = Color(0xFF9E8878);
// const _bg        = Color(0xFFF2EBE0);

// class StepPhotoProfil extends StatefulWidget {
//   const StepPhotoProfil({super.key, required this.onSave, required this.onCancel});
//   final VoidCallback onSave, onCancel;

//   @override
//   State<StepPhotoProfil> createState() => _StepPhotoProfilState();
// }

// class _StepPhotoProfilState extends State<StepPhotoProfil> {
//   final _prenomCtrl     = TextEditingController();
//   final _nomCtrl        = TextEditingController();
//   final _emailCtrl      = TextEditingController();
//   final _telCtrl        = TextEditingController();
//   final _villeCtrl      = TextEditingController();
//   final _codePostalCtrl = TextEditingController();
//   final _adresseCtrl    = TextEditingController();
//   final _nomAffCtrl     = TextEditingController();
//   final _expCtrl        = TextEditingController();
//   final _descCtrl       = TextEditingController();

//   @override
//   void dispose() {
//     for (final c in [_prenomCtrl, _nomCtrl, _emailCtrl, _telCtrl,
//       _villeCtrl, _codePostalCtrl, _adresseCtrl, _nomAffCtrl, _expCtrl, _descCtrl])
//       c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w   = MediaQuery.of(context).size.width;
//     final rem = w / 100;

//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//       // Titre
//       Center(child: Text('Modifier le profil',
//         style: TextStyle(
//           fontSize: rem * 4.8,
//           fontWeight: FontWeight.w800,
//           color: _textDark))),
//       SizedBox(height: rem * 5),

//       // Photo
//       Row(children: [
//         Container(
//           width: rem * 14, height: rem * 14,
//           decoration: BoxDecoration(shape: BoxShape.circle, color: _goldLight),
//           child: Icon(Icons.person_rounded, color: _gold, size: rem * 8)),
//         SizedBox(width: rem * 3),
//         Expanded(child: GestureDetector(
//           onTap: () {},
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: rem * 3.5),
//             decoration: BoxDecoration(
//               color: _bg,
//               borderRadius: BorderRadius.circular(rem * 5),
//               border: Border.all(color: const Color(0xFFEDE0CC))),
//             child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               Icon(Icons.upload_rounded, color: _textDark, size: rem * 4.5),
//               SizedBox(width: rem * 2),
//               Text('Changer la photo',
//                 style: TextStyle(color: _textDark, fontSize: rem * 3.5)),
//             ])))),
//       ]),
//       SizedBox(height: rem * 5),

//       // Prénom / Nom
//       Row(children: [
//         Expanded(child: _F(label: 'Prénom', ctrl: _prenomCtrl, hint: 'Votre prénom', required: true, rem: rem)),
//         SizedBox(width: rem * 3),
//         Expanded(child: _F(label: 'Nom', ctrl: _nomCtrl, hint: 'Votre nom', required: true, rem: rem)),
//       ]),
//       _F(label: 'Email', ctrl: _emailCtrl, hint: 'votre@email.com', required: true, rem: rem, type: TextInputType.emailAddress),
//       _F(label: 'Téléphone', ctrl: _telCtrl, hint: '0600000000', required: true, rem: rem, type: TextInputType.phone),

//       // Ville / Code postal
//       Row(children: [
//         Expanded(child: _FL(label: 'Ville', ctrl: _villeCtrl, hint: 'Paris', required: true, rem: rem)),
//         SizedBox(width: rem * 3),
//         Expanded(child: _F(label: 'Code postal', ctrl: _codePostalCtrl, hint: '75000', required: true, rem: rem, type: TextInputType.number)),
//       ]),

//       _FL(label: 'Adresse', ctrl: _adresseCtrl, hint: '12 rue des Lilas', rem: rem),
//       Padding(
//         padding: EdgeInsets.only(bottom: rem * 3),
//         child: Text(
//           'Optionnel – Utile si vous recevez des clients à votre domicile/salon',
//           style: TextStyle(fontSize: rem * 2.8, color: _textGrey))),

//       _F(label: 'Nom affiché', ctrl: _nomAffCtrl, hint: 'Nom visible par les clients', required: true, rem: rem),

//       // Expérience
//       _TextArea(
//         label: 'Expérience professionnelle',
//         ctrl: _expCtrl,
//         hint: 'Décrivez votre expérience…',
//         maxChars: 150,
//         maxLines: 3,
//         rem: rem),

//       // Description
//       _TextArea(
//         label: 'Description',
//         ctrl: _descCtrl,
//         hint: 'Présentez-vous à vos clients…',
//         maxChars: 200,
//         maxLines: 4,
//         rem: rem),

//       // Avertissement
//       Container(
//         padding: EdgeInsets.all(rem * 3),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFF8E7),
//           borderRadius: BorderRadius.circular(rem * 2.5),
//           border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5))),
//         child: Row(children: [
//           Icon(Icons.warning_amber_rounded,
//             color: const Color(0xFFB8860B), size: rem * 4.5),
//           SizedBox(width: rem * 2),
//           Expanded(child: Text(
//             'Interdit : réseaux sociaux, téléphone, email, liens externes',
//             style: TextStyle(fontSize: rem * 3, color: const Color(0xFF7A5800)))),
//         ])),
//       SizedBox(height: rem * 5),

//       // Boutons enregistrer / annuler
//       Row(children: [
//         Expanded(child: GestureDetector(
//           onTap: widget.onSave,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: rem * 3.8),
//             decoration: BoxDecoration(
//               color: _gold,
//               borderRadius: BorderRadius.circular(rem * 6),
//               boxShadow: [BoxShadow(
//                 color: _gold.withOpacity(0.4),
//                 blurRadius: 10, offset: const Offset(0, 4))]),
//             child: Center(child: Text('Enregistrer',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: rem * 3.8,
//                 fontWeight: FontWeight.w700)))))),
//         SizedBox(width: rem * 3),
//         Expanded(child: GestureDetector(
//           onTap: widget.onCancel,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: rem * 3.8),
//             decoration: BoxDecoration(
//               color: _bg,
//               borderRadius: BorderRadius.circular(rem * 6),
//               border: Border.all(color: const Color(0xFFEDE0CC))),
//             child: Center(child: Text('Annuler',
//               style: TextStyle(
//                 color: _textDark,
//                 fontSize: rem * 3.8,
//                 fontWeight: FontWeight.w600)))))),
//       ]),
//       SizedBox(height: rem * 3),

//       // Supprimer compte
//       GestureDetector(
//         onTap: () {},
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(vertical: rem * 3.8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFFEEEE),
//             borderRadius: BorderRadius.circular(rem * 6),
//             border: Border.all(color: Colors.red.withOpacity(0.3))),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(Icons.delete_outline_rounded, color: Colors.red, size: rem * 5.5),
//             SizedBox(width: rem * 2),
//             Text('Supprimer mon compte',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: rem * 3.8,
//                 fontWeight: FontWeight.w600)),
//           ]))),
//       SizedBox(height: rem * 6),
//     ]);
//   }
// }

// // ── Champ texte simple ────────────────────────────────────────────────────────
// class _F extends StatelessWidget {
//   const _F({required this.label, required this.ctrl, required this.hint,
//     required this.rem, this.required = false, this.type = TextInputType.text});
//   final String label, hint;
//   final TextEditingController ctrl;
//   final double rem;
//   final bool required;
//   final TextInputType type;

//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Text(label, style: TextStyle(
//         fontSize: rem * 3.5, fontWeight: FontWeight.w600, color: _textDark)),
//       if (required) Text(' *', style: TextStyle(color: Colors.red, fontSize: rem * 3.5)),
//     ]),
//     SizedBox(height: rem * 2),
//     TextField(
//       controller: ctrl, keyboardType: type,
//       style: TextStyle(fontSize: rem * 3.5, color: _textDark),
//       decoration: _deco(hint, rem)),
//     SizedBox(height: rem * 3.5),
//   ]);
// }

// // ── Champ avec icône localisation ─────────────────────────────────────────────
// class _FL extends StatelessWidget {
//   const _FL({required this.label, required this.ctrl, required this.hint,
//     required this.rem, this.required = false});
//   final String label, hint;
//   final TextEditingController ctrl;
//   final double rem;
//   final bool required;

//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Text(label, style: TextStyle(
//         fontSize: rem * 3.5, fontWeight: FontWeight.w600, color: _textDark)),
//       if (required) Text(' *', style: TextStyle(color: Colors.red, fontSize: rem * 3.5)),
//     ]),
//     SizedBox(height: rem * 2),
//     TextField(
//       controller: ctrl,
//       style: TextStyle(fontSize: rem * 3.5, color: _textDark),
//       decoration: _deco(hint, rem).copyWith(
//         suffixIcon: Icon(Icons.location_on_outlined, color: _textGrey, size: rem * 5))),
//     SizedBox(height: rem * 3.5),
//   ]);
// }

// // ── Champ textarea avec compteur ──────────────────────────────────────────────
// class _TextArea extends StatelessWidget {
//   const _TextArea({required this.label, required this.ctrl, required this.hint,
//     required this.maxChars, required this.maxLines, required this.rem});
//   final String label, hint;
//   final TextEditingController ctrl;
//   final int maxChars, maxLines;
//   final double rem;

//   @override
//   Widget build(BuildContext context) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Text(label, style: TextStyle(
//         fontSize: rem * 3.5, fontWeight: FontWeight.w600, color: _textDark)),
//       SizedBox(width: rem * 1.5),
//       ValueListenableBuilder(
//         valueListenable: ctrl,
//         builder: (_, v, __) => Text(
//           '(${v.text.length}/$maxChars)',
//           style: TextStyle(fontSize: rem * 2.8, color: _textGrey))),
//     ]),
//     SizedBox(height: rem * 2),
//     TextField(
//       controller: ctrl, maxLines: maxLines, maxLength: maxChars,
//       style: TextStyle(fontSize: rem * 3.5, color: _textDark),
//       decoration: _deco(hint, rem).copyWith(
//         counterText: '',
//         contentPadding: EdgeInsets.all(rem * 3.5),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(rem * 3),
//           borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(rem * 3),
//           borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(rem * 3),
//           borderSide: BorderSide(color: _gold, width: 2)))),
//     SizedBox(height: rem * 4),
//   ]);
// }

// // ── Décoration champ ──────────────────────────────────────────────────────────
// InputDecoration _deco(String hint, double rem) => InputDecoration(
//   hintText: hint,
//   hintStyle: TextStyle(color: _textGrey, fontSize: rem * 3.2),
//   filled: true, fillColor: const Color(0xFFF8F5F0),
//   contentPadding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.2),
//   border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(rem * 6),
//     borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
//   enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(rem * 6),
//     borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(rem * 6),
//     borderSide: BorderSide(color: _gold, width: 2)));













































































// // // lib/features/prestataire/onboarding/steps/step_photo_profil.dart

// // import 'package:flutter/material.dart';

// // const _green    = Color(0xFF2D7A4F);
// // const _textDark = Color(0xFF1A1A1A);
// // const _textGrey = Color(0xFF8E8E93);

// // class StepPhotoProfil extends StatefulWidget {
// //   const StepPhotoProfil({super.key, required this.onSave, required this.onCancel});
// //   final VoidCallback onSave, onCancel;

// //   @override
// //   State<StepPhotoProfil> createState() => _StepPhotoProfilState();
// // }

// // class _StepPhotoProfilState extends State<StepPhotoProfil> {
// //   final _prenomCtrl      = TextEditingController();
// //   final _nomCtrl         = TextEditingController();
// //   final _emailCtrl       = TextEditingController();
// //   final _telCtrl         = TextEditingController();
// //   final _villeCtrl       = TextEditingController();
// //   final _codePostalCtrl  = TextEditingController();
// //   final _adresseCtrl     = TextEditingController();
// //   final _nomAffCtrl      = TextEditingController();
// //   final _expCtrl         = TextEditingController();
// //   final _descCtrl        = TextEditingController();

// //   @override
// //   void dispose() {
// //     for (final c in [_prenomCtrl, _nomCtrl, _emailCtrl, _telCtrl,
// //       _villeCtrl, _codePostalCtrl, _adresseCtrl, _nomAffCtrl, _expCtrl, _descCtrl]) c.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       const Center(child: Text('Modifier le profil',
// //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark))),
// //       const SizedBox(height: 20),

// //       // Photo
// //       Row(children: [
// //         Container(
// //           width: 56, height: 56,
// //           decoration: BoxDecoration(color: const Color(0xFFF2E8D9), shape: BoxShape.circle),
// //           child: const Icon(Icons.person, color: Color(0xFFD4A878), size: 32),
// //         ),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: OutlinedButton.icon(
// //             onPressed: () {},
// //             icon: const Icon(Icons.upload, color: _textDark, size: 18),
// //             label: const Text('Changer la photo', style: TextStyle(color: _textDark)),
// //             style: OutlinedButton.styleFrom(
// //               side: const BorderSide(color: Color(0xFFE0E0E0)),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //               padding: const EdgeInsets.symmetric(vertical: 14),
// //             ),
// //           ),
// //         ),
// //       ]),
// //       const SizedBox(height: 20),

// //       // Prénom / Nom
// //       Row(children: [
// //         Expanded(child: _Field(label: 'Prénom *', ctrl: _prenomCtrl, placeholder: 'Votre prénom', required: true)),
// //         const SizedBox(width: 12),
// //         Expanded(child: _Field(label: 'Nom *', ctrl: _nomCtrl, placeholder: 'Votre nom', required: true)),
// //       ]),

// //       _Field(label: 'Email *', ctrl: _emailCtrl, placeholder: 'votre@email.com', required: true, type: TextInputType.emailAddress),
// //       _Field(label: 'Téléphone *', ctrl: _telCtrl, placeholder: '0600000000', required: true, type: TextInputType.phone),

// //       // Ville / Code postal
// //       Row(children: [
// //         Expanded(child: _FieldWithIcon(label: 'Ville *', ctrl: _villeCtrl, placeholder: 'Paris', required: true)),
// //         const SizedBox(width: 12),
// //         Expanded(child: _Field(label: 'Code postal *', ctrl: _codePostalCtrl, placeholder: '75000', required: true, type: TextInputType.number)),
// //       ]),

// //       _FieldWithIcon(label: 'Adresse', ctrl: _adresseCtrl, placeholder: '12 rue des Lilas'),
// //       const Padding(
// //         padding: EdgeInsets.only(bottom: 12),
// //         child: Text('Optionnel – Utile si vous recevez des clients à votre domicile/salon',
// //           style: TextStyle(fontSize: 12, color: _textGrey)),
// //       ),

// //       _Field(label: 'Nom affiché *', ctrl: _nomAffCtrl, placeholder: 'Nom visible par les clients', required: true),

// //       // Expérience
// //       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Row(children: [
// //           const Text('Expérience professionnelle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
// //           const SizedBox(width: 6),
// //           ValueListenableBuilder(valueListenable: _expCtrl,
// //             builder: (_, v, __) => Text('(${v.text.length}/150 caractères)',
// //               style: const TextStyle(fontSize: 12, color: _textGrey))),
// //         ]),
// //         const SizedBox(height: 8),
// //         TextField(controller: _expCtrl, maxLines: 3,
// //           decoration: _inputDeco('Décrivez votre expérience…')),
// //       ]),
// //       const SizedBox(height: 16),

// //       // Description
// //       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //         Row(children: [
// //           const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
// //           const SizedBox(width: 6),
// //           ValueListenableBuilder(valueListenable: _descCtrl,
// //             builder: (_, v, __) => Text('(${v.text.length}/200 caractères)',
// //               style: const TextStyle(fontSize: 12, color: _textGrey))),
// //         ]),
// //         const SizedBox(height: 8),
// //         TextField(controller: _descCtrl, maxLines: 4,
// //           decoration: _inputDeco('Présentez-vous à vos clients…')),
// //         const SizedBox(height: 8),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFFFFF8E7),
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
// //           ),
// //           child: const Row(children: [
// //             Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 16),
// //             SizedBox(width: 8),
// //             Expanded(child: Text('Interdit : réseaux sociaux, téléphone, email, liens externes',
// //               style: TextStyle(fontSize: 12, color: Color(0xFF7A5800)))),
// //           ]),
// //         ),
// //       ]),
// //       const SizedBox(height: 24),

// //       // Boutons
// //       Row(children: [
// //         Expanded(
// //           child: SizedBox(height: 52,
// //             child: ElevatedButton(
// //               onPressed: widget.onSave,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: _green,
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //                 elevation: 0,
// //               ),
// //               child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: SizedBox(height: 52,
// //             child: OutlinedButton(
// //               onPressed: widget.onCancel,
// //               style: OutlinedButton.styleFrom(
// //                 side: const BorderSide(color: Color(0xFFE0E0E0)),
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //               ),
// //               child: const Text('Annuler', style: TextStyle(color: _textDark)),
// //             ),
// //           ),
// //         ),
// //       ]),
// //       const SizedBox(height: 16),
// //       SizedBox(width: double.infinity, height: 52,
// //         child: ElevatedButton.icon(
// //           onPressed: () {},
// //           icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
// //           label: const Text('Supprimer mon compte', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.red,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
// //             elevation: 0,
// //           ),
// //         ),
// //       ),
// //       const SizedBox(height: 24),
// //     ]);
// //   }
// // }

// // class _Field extends StatelessWidget {
// //   const _Field({required this.label, required this.ctrl, required this.placeholder,
// //     this.required = false, this.type = TextInputType.text});
// //   final String label, placeholder;
// //   final TextEditingController ctrl;
// //   final bool required;
// //   final TextInputType type;

// //   @override
// //   Widget build(BuildContext context) => Column(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       Row(children: [
// //         Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
// //         if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
// //       ]),
// //       const SizedBox(height: 8),
// //       TextField(controller: ctrl, keyboardType: type, decoration: _inputDeco(placeholder)),
// //       const SizedBox(height: 14),
// //     ],
// //   );
// // }

// // class _FieldWithIcon extends StatelessWidget {
// //   const _FieldWithIcon({required this.label, required this.ctrl, required this.placeholder, this.required = false});
// //   final String label, placeholder;
// //   final TextEditingController ctrl;
// //   final bool required;

// //   @override
// //   Widget build(BuildContext context) => Column(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       Row(children: [
// //         Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
// //         if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
// //       ]),
// //       const SizedBox(height: 8),
// //       TextField(controller: ctrl,
// //         decoration: _inputDeco(placeholder).copyWith(
// //           suffixIcon: const Icon(Icons.location_on_outlined, color: _textGrey),
// //         )),
// //       const SizedBox(height: 14),
// //     ],
// //   );
// // }

// // InputDecoration _inputDeco(String hint) => InputDecoration(
// //   hintText: hint, hintStyle: const TextStyle(color: _textGrey),
// //   filled: true, fillColor: const Color(0xFFF8F8F8),
// //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
// //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
// //   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
// //   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: const BorderSide(color: _green, width: 2)),
// // );