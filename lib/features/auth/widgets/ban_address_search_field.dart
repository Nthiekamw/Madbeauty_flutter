import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/logic/address/postal_address_suggestion.dart';
import '../../../services/location/location_providers.dart';
import '../../../shared/widgets/app/app_text_field.dart';

class BanAddressSearchField extends ConsumerStatefulWidget {
  const BanAddressSearchField({
    super.key,
    required this.countryLabel,
    required this.enabled,
    required this.dense,
    required this.onSelected,
  });

  final String countryLabel;
  final bool enabled;
  final bool dense;
  final ValueChanged<PostalAddressSuggestion> onSelected;

  @override
  ConsumerState<BanAddressSearchField> createState() =>
      _BanAddressSearchFieldState();
}

class _BanAddressSearchFieldState extends ConsumerState<BanAddressSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  bool _touched = false;
  String? _error;
  List<PostalAddressSuggestion> _suggestions = const [];

  bool get _supportsBan {
    final country = widget.countryLabel.trim().toLowerCase();
    return country.isEmpty || country == 'fr' || country == 'france';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _touched = true;
    _debounce?.cancel();
    setState(() {
      _error = null;
      if (value.trim().length < 4) {
        _suggestions = const [];
        _loading = false;
      } else {
        _loading = _supportsBan;
      }
    });

    if (!_supportsBan || value.trim().length < 4) return;

    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final service = ref.read(addressAutocompleteServiceProvider);
      try {
        final suggestions = await service.searchFrenchAddresses(value);
        if (!mounted || _controller.text.trim() != value.trim()) return;
        setState(() {
          _loading = false;
          _error = null;
          _suggestions = suggestions;
        });
      } catch (_) {
        if (!mounted || _controller.text.trim() != value.trim()) return;
        setState(() {
          _loading = false;
          _suggestions = const [];
          _error = AuthStrings.registerAddressSearchError;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showEmptyState =
        _touched &&
        !_loading &&
        _error == null &&
        _controller.text.trim().length >= 4 &&
        _suggestions.isEmpty &&
        _supportsBan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          dense: widget.dense,
          controller: _controller,
          enabled: widget.enabled,
          label: AuthStrings.registerAddressSearchLabel,
          hint: AuthStrings.registerAddressSearchHint,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (_controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: CoreStrings.actionClear,
                        onPressed: widget.enabled
                            ? () {
                                _debounce?.cancel();
                                _controller.clear();
                                setState(() {
                                  _loading = false;
                                  _error = null;
                                  _suggestions = const [];
                                  _touched = false;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.close_rounded),
                      )),
          onChanged: widget.enabled ? _onChanged : null,
        ),
        const SizedBox(height: 6),
        Text(
          _supportsBan
              ? AuthStrings.registerAddressSearchHelp
              : AuthStrings.registerAddressSearchFranceOnly,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (showEmptyState) ...[
          const SizedBox(height: 8),
          Text(
            AuthStrings.registerAddressSearchNoResult,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _suggestions.length; i++) ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: widget.enabled
                          ? () {
                              final suggestion = _suggestions[i];
                              _controller.text = suggestion.label;
                              setState(() {
                                _suggestions = const [];
                                _error = null;
                                _loading = false;
                              });
                              widget.onSelected(suggestion);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _suggestions[i].label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (i < _suggestions.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
