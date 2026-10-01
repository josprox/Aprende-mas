import 'package:flutter/material.dart';

/// Helper de diseño responsivo para la aplicación.
/// Define breakpoints estándar y utilidades para adaptar la interfaz a Tablets y PCs.
class ResponsiveLayout {
  // Breakpoints
  static const double mobileMaxWidth = 640;
  static const double tabletMaxWidth = 1024;
  static const double contentMaxReadWidth = 920;
  static const double maxContentWidth = 1280;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileMaxWidth;

  /// Retorna el número de columnas recomendado para una cuadrícula según el ancho
  static int gridColumns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMaxWidth) return desktop;
    if (width >= mobileMaxWidth) return tablet;
    return mobile;
  }

  /// Retorna un padding horizontal adaptativo:
  /// En móvil: 16-20
  /// En tablet: 32
  /// En desktop: 48
  static EdgeInsets horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMaxWidth) {
      return const EdgeInsets.symmetric(horizontal: 40);
    } else if (width >= mobileMaxWidth) {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16);
  }
}

/// Envoltorio que limita el ancho máximo del contenido y lo centra horizontalmente en pantallas grandes.
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Alignment alignment;
  final EdgeInsetsGeometry? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveLayout.maxContentWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
