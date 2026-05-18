
// lib/features/prestataires/screens/onboarding/step_realisations.dart

import 'package:flutter/material.dart';

const _brown    = Color(0xFF8B6340);
const _textDark = Color(0xFF1A1A1A);
const _textGrey = Color(0xFF8E8E93);

class StepRealisations extends StatefulWidget {
  const StepRealisations({super.key, required this.onSave, required this.onCancel});
  final VoidCallback onSave, onCancel;

  @override
  State<StepRealisations> createState() => _StepRealisationsState();
}

class _StepRealisationsState extends State<StepRealisations> {
  final List<String> _photos = []; // en prod : File ou URL

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      const Row(children: [
        Icon(Icons.photo_camera, color: _brown, size: 22),
        SizedBox(width: 8),
        Text('Mes réalisations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      ]),
      const SizedBox(height: 16),

      // Interdiction stricte
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.error_outline, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Text('Interdiction stricte',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
          ]),
          SizedBox(height: 6),
          Text(
            'Il est formellement interdit d\'ajouter des images contenant du texte '
            '(prix, promotions, coordonnées, liens réseaux sociaux, etc.). '
            'Seules les photos de coiffures sont autorisées. '
            'Les comptes ne respectant pas cette règle seront suspendus.',
            style: TextStyle(fontSize: 13, color: Colors.red, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 16),

      Text(
        'Ajoutez jusqu\'à 10 photos de vos meilleures réalisations.\n'
        'Formats acceptés: JPEG, PNG, WebP. Les images volumineuses seront automatiquement optimisées.',
        style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.5)),
      const SizedBox(height: 16),

      const Text('Ajouter de nouveaux médias',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 10),

      // Zone upload
      GestureDetector(
        onTap: () {}, // image_picker en prod
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _brown.withOpacity(0.5),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Icon(Icons.upload, color: _textGrey, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Cliquez pour sélectionner des images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 4),
            const Text('Ou glissez-déposez vos fichiers ici',
              style: TextStyle(fontSize: 14, color: _textGrey)),
            const SizedBox(height: 6),
            Text('Max ${10 - _photos.length} image(s) supplémentaire(s)',
              style: const TextStyle(fontSize: 13, color: _brown, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      const SizedBox(height: 16),

      // Conseils
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Text('Conseils pour de belles photos',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue)),
          ]),
          SizedBox(height: 8),
          Text('• Prenez vos photos dans un bon éclairage naturel\n'
               '• Montrez différents angles et styles de coiffures\n'
               '• Assurez-vous que les photos sont nettes et bien cadrées\n'
               '• Respectez la confidentialité de vos clients',
            style: TextStyle(fontSize: 13, color: Colors.blue, height: 1.5)),
        ]),
      ),
      const SizedBox(height: 24),

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
                backgroundColor: _brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              child: const Text('Enregistrer',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 24),
    ]);
  }
}









































// // lib/features/prestataires/screens/onboarding/step_realisations.dart

// import 'package:flutter/material.dart';

// const _green    = Color(0xFF2D7A4F);
// const _textDark = Color(0xFF1A1A1A);
// const _textGrey = Color(0xFF8E8E93);

// class StepRealisations extends StatefulWidget {
//   const StepRealisations({super.key, required this.onSave, required this.onCancel});
//   final VoidCallback onSave, onCancel;

//   @override
//   State<StepRealisations> createState() => _StepRealisationsState();
// }

// class _StepRealisationsState extends State<StepRealisations> {
//   final List<String> _photos = []; // en prod : File ou URL

//   @override
//   Widget build(BuildContext context) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

//       const Row(children: [
//         Icon(Icons.photo_camera, color: _green, size: 22),
//         SizedBox(width: 8),
//         Text('Mes réalisations',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
//       ]),
//       const SizedBox(height: 16),

//       // Interdiction stricte
//       Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFEEEE),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.red.withOpacity(0.3)),
//         ),
//         child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 18),
//             SizedBox(width: 8),
//             Text('Interdiction stricte',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
//           ]),
//           SizedBox(height: 6),
//           Text(
//             'Il est formellement interdit d\'ajouter des images contenant du texte '
//             '(prix, promotions, coordonnées, liens réseaux sociaux, etc.). '
//             'Seules les photos de coiffures sont autorisées. '
//             'Les comptes ne respectant pas cette règle seront suspendus.',
//             style: TextStyle(fontSize: 13, color: Colors.red, height: 1.4)),
//         ]),
//       ),
//       const SizedBox(height: 16),

//       Text(
//         'Ajoutez jusqu\'à 10 photos de vos meilleures réalisations.\n'
//         'Formats acceptés: JPEG, PNG, WebP. Les images volumineuses seront automatiquement optimisées.',
//         style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.5)),
//       const SizedBox(height: 16),

//       const Text('Ajouter de nouveaux médias',
//         style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
//       const SizedBox(height: 10),

//       // Zone upload
//       GestureDetector(
//         onTap: () {}, // image_picker en prod
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 40),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F8F8),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: _green.withOpacity(0.5),
//               style: BorderStyle.solid, width: 2),
//           ),
//           child: Column(children: [
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white, shape: BoxShape.circle,
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//               ),
//               child: const Icon(Icons.upload, color: _textGrey, size: 28),
//             ),
//             const SizedBox(height: 12),
//             const Text('Cliquez pour sélectionner des images',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
//             const SizedBox(height: 4),
//             const Text('Ou glissez-déposez vos fichiers ici',
//               style: TextStyle(fontSize: 14, color: _textGrey)),
//             const SizedBox(height: 6),
//             Text('Max ${10 - _photos.length} image(s) supplémentaire(s)',
//               style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600)),
//           ]),
//         ),
//       ),
//       const SizedBox(height: 16),

//       // Conseils
//       Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFEEF4FF),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.blue.withOpacity(0.2)),
//         ),
//         child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Icon(Icons.info_outline, color: Colors.blue, size: 18),
//             SizedBox(width: 8),
//             Text('Conseils pour de belles photos',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue)),
//           ]),
//           SizedBox(height: 8),
//           Text('• Prenez vos photos dans un bon éclairage naturel\n'
//                '• Montrez différents angles et styles de coiffures\n'
//                '• Assurez-vous que les photos sont nettes et bien cadrées\n'
//                '• Respectez la confidentialité de vos clients',
//             style: TextStyle(fontSize: 13, color: Colors.blue, height: 1.5)),
//         ]),
//       ),
//       const SizedBox(height: 24),

//       Row(children: [
//         Expanded(
//           child: SizedBox(height: 52,
//             child: OutlinedButton(
//               onPressed: widget.onCancel,
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Color(0xFFE0E0E0)),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//               ),
//               child: const Text('Annuler', style: TextStyle(color: _textDark)),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: SizedBox(height: 52,
//             child: ElevatedButton(
//               onPressed: widget.onSave,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _green,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//                 elevation: 0,
//               ),
//               child: const Text('Enregistrer',
//                 style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//             ),
//           ),
//         ),
//       ]),
//       const SizedBox(height: 24),
//     ]);
//   }
// }