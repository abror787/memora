import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final Widget? bottomNavBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AdaptiveLayout({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
        final isDesktop = screenWidth > 900;

        final maxWidth =
            isDesktop ? 800.0 : (isTablet ? 600.0 : double.infinity);

        return Scaffold(
          appBar: appBar != null
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: appBar!,
                )
              : null,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
          bottomNavigationBar: bottomNavBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        );
      },
    );
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: actions,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      child: SafeArea(child: body),
    );
  }
}
