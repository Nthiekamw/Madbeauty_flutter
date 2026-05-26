import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/auth_form_styles.dart';

/// Champ texte avec bordure outline arrondie (Material 3).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.borderRadius = AuthFormStyles.fieldRadius,
    this.filled = true,
    this.dense = false,
  });

  /// Rayon des coins (défaut auth : 16).
  final double borderRadius;

  /// Fond léger dans le champ (recommandé sur écrans auth).
  final bool filled;

  /// Hauteur réduite (wizard inscription).
  final bool dense;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final outline = theme.colorScheme.outline.withValues(alpha: 0.35);
    final focused = theme.colorScheme.primary;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final viewInsets = MediaQuery.viewInsetsOf(context);
    final scrollPadding = EdgeInsets.fromLTRB(
      24,
      24,
      24,
      viewInsets.bottom + 120,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      scrollPadding: scrollPadding,
      onChanged: onChanged,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: filled
            ? theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.45 : 0.65,
              )
            : null,
        border: border(outline),
        enabledBorder: border(outline),
        focusedBorder: border(focused, width: 1.6),
        errorBorder: border(theme.colorScheme.error),
        focusedErrorBorder: border(theme.colorScheme.error, width: 1.6),
        isDense: dense,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: dense ? 12 : 16,
        ),
      ),
    );
  }
}
