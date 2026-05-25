import 'package:flutter/material.dart';

import '../../theme/prototype_layout.dart';
import '../../theme/prototype_palette.dart';

/// Toggle segmenté (À venir / Historique) style Madbeauty_flutter.
class PrototypeSegmentToggle extends StatelessWidget {
  const PrototypeSegmentToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.darkActive = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Segment actif brun foncé (prestataire) au lieu de or (client).
  final bool darkActive;

  @override
  Widget build(BuildContext context) {
    final rem = PrototypeLayout(context).rem;

    return Container(
      padding: EdgeInsets.all(rem * 0.8),
      decoration: BoxDecoration(
        color: PrototypePalette.goldLight,
        borderRadius: BorderRadius.circular(rem * 6),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: rem * 2.2),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? (darkActive
                            ? PrototypePalette.brownDeep
                            : PrototypePalette.gold)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(rem * 5),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rem * 3.2,
                      fontWeight: FontWeight.w700,
                      color: i == selectedIndex
                          ? Colors.white
                          : PrototypePalette.goldDark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
