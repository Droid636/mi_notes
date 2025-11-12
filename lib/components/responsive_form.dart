import 'package:flutter/material.dart';

class ResponsiveForm extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveForm({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Ajustes responsivos
    final horizontalPadding = width < 600 ? 16.0 : 32.0;
    final verticalPadding = width < 600 ? 16.0 : 24.0;
    final maxWidth = width < 800 ? width : 700.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
