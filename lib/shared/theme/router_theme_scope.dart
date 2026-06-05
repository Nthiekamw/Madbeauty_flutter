import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_area.dart';

/// Chemin affiché sans utiliser [GoRouter.state] : celui-ci peut être indisponible
/// tant que [GoRouterDelegate.currentConfiguration] est encore vide (premier frame,
/// hot restart).
String _themeLocationPath(GoRouter router) {
  final config = router.routerDelegate.currentConfiguration;
  if (config.isNotEmpty) {
    return config.uri.path;
  }
  final fromProvider = router.routeInformationProvider.value.uri.path;
  if (fromProvider.isNotEmpty) {
    return fromProvider;
  }
  return '/';
}

/// Reconstruit l'arbre quand la route change pour appliquer le thème client / prestataire.
class RouterThemeScope extends StatefulWidget {
  const RouterThemeScope({
    super.key,
    required this.router,
    required this.builder,
  });

  final GoRouter router;
  final Widget Function(BuildContext context, AppArea area) builder;

  @override
  State<RouterThemeScope> createState() => _RouterThemeScopeState();
}

class _RouterThemeScopeState extends State<RouterThemeScope> {
  /// Évite [setState] pendant la phase de build (notifications du routeur au 1er frame).
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRoute);
    widget.router.routeInformationProvider.addListener(_onRoute);
  }

  @override
  void didUpdateWidget(covariant RouterThemeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_onRoute);
      oldWidget.router.routeInformationProvider.removeListener(_onRoute);
      widget.router.routerDelegate.addListener(_onRoute);
      widget.router.routeInformationProvider.addListener(_onRoute);
    }
  }

  void _onRoute() {
    if (!mounted) return;
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildScheduled = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRoute);
    widget.router.routeInformationProvider.removeListener(_onRoute);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final area = appAreaFromPath(_themeLocationPath(widget.router));
    return widget.builder(context, area);
  }
}

