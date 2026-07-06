import 'package:flutter/material.dart';

import '../layout/prestataire_hub_step_meta.dart';

const _kHubStepChipWidth = 136.0;
const _kHubStepChipGap = 8.0;
const _kHubStepChipMinHeight = 88.0;

/// Navigation horizontale entre étapes (numérotée, scroll auto).
class PrestataireHubStepNavigator extends StatefulWidget {
  const PrestataireHubStepNavigator({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.enabled,
    required this.onTap,
  });

  final List<PrestataireHubStepMeta> steps;
  final int currentStep;
  final bool enabled;
  final ValueChanged<int> onTap;

  @override
  State<PrestataireHubStepNavigator> createState() =>
      _PrestataireHubStepNavigatorState();
}

class _PrestataireHubStepNavigatorState extends State<PrestataireHubStepNavigator> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PrestataireHubStepNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    final offset = (widget.currentStep * (_kHubStepChipWidth + _kHubStepChipGap))
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.steps.length; i++) ...[
            _HubStepChip(
              index: i + 1,
              title: widget.steps[i].title,
              icon: widget.steps[i].icon,
              selected: i == widget.currentStep,
              done: i < widget.currentStep,
              enabled: widget.enabled,
              onTap: () => widget.onTap(i),
              primary: primary,
              theme: theme,
            ),
            if (i < widget.steps.length - 1) const SizedBox(width: _kHubStepChipGap),
          ],
        ],
      ),
    );
  }
}

class _HubStepChip extends StatelessWidget {
  const _HubStepChip({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.done,
    required this.enabled,
    required this.onTap,
    required this.primary,
    required this.theme,
  });

  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final onPrimary = theme.colorScheme.onPrimary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final fg = selected ? onPrimary : (done ? primary : muted);
    final bg = selected
        ? primary
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _kHubStepChipWidth,
          constraints: const BoxConstraints(minHeight: _kHubStepChipMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: bg,
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? onPrimary.withValues(alpha: 0.2)
                          : primary.withValues(alpha: done ? 0.15 : 0.1),
                    ),
                    child: done && !selected
                        ? Icon(Icons.check_rounded, size: 14, color: primary)
                        : Text(
                            '$index',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: fg,
                              height: 1,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 15, color: fg),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
