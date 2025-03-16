import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';

enum NeumorphicType {
  flat, // Flat neumorphic design
  pressed, // Pressed in appearance
  elevated, // Elevated appearance
  concave, // Concave surface
  convex, // Convex surface
}

class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final NeumorphicType type;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double intensity;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isAnimated;
  final Duration animationDuration;
  final BoxShape shape;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.type = NeumorphicType.flat,
    this.color,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(0),
    this.intensity = 0.5,
    this.width,
    this.height,
    this.onTap,
    this.isAnimated = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine base color
    final baseColor = widget.color ??
        (isDark ? AppColors.darkNeumorphicBase : AppColors.lightNeumorphicBase);

    // Calculate shadow colors and intensity
    final shadowIntensity = widget.intensity.clamp(0.0, 1.0);
    final Color lightShadowColor = isDark
        ? Color.lerp(baseColor, Colors.white, 0.1 * shadowIntensity)!
        : Color.lerp(baseColor, Colors.white, 0.7 * shadowIntensity)!;

    final Color darkShadowColor = isDark
        ? Color.lerp(baseColor, Colors.black, 0.7 * shadowIntensity)!
        : Color.lerp(baseColor, Colors.black, 0.2 * shadowIntensity)!;

    // Determine current type based on press state
    final currentType = _isPressed && widget.onTap != null
        ? NeumorphicType.pressed
        : widget.type;

    // Calculate shadow offset and blur radius
    final offset = _getShadowOffset(currentType, shadowIntensity);
    final blurRadius = shadowIntensity * 15.0;
    final spreadRadius = shadowIntensity * 1.0;

    // Build box decoration based on type
    final decoration = _buildDecoration(
      baseColor: baseColor,
      lightShadowColor: lightShadowColor,
      darkShadowColor: darkShadowColor,
      offset: offset,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      type: currentType,
    );

    // Build the card with animation if needed
    final card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: decoration,
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    );

    // Wrap with animated container if animated
    final animatedCard = widget.isAnimated
        ? AnimatedContainer(
      duration: widget.animationDuration,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: decoration,
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    )
        : card;

    // Add gesture detection if needed
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: animatedCard,
      );
    }

    return animatedCard;
  }

  Offset _getShadowOffset(NeumorphicType type, double intensity) {
    switch (type) {
      case NeumorphicType.flat:
        return Offset.zero;
      case NeumorphicType.pressed:
        return Offset.zero;
      case NeumorphicType.elevated:
        return Offset(3.0 * intensity, 3.0 * intensity);
      case NeumorphicType.concave:
        return Offset(1.5 * intensity, 1.5 * intensity);
      case NeumorphicType.convex:
        return Offset(1.5 * intensity, 1.5 * intensity);
    }
  }

  BoxDecoration _buildDecoration({
    required Color baseColor,
    required Color lightShadowColor,
    required Color darkShadowColor,
    required Offset offset,
    required double blurRadius,
    required double spreadRadius,
    required NeumorphicType type,
  }) {
    // Base decoration
    final decoration = BoxDecoration(
      color: baseColor,
      borderRadius: widget.shape == BoxShape.circle
          ? null
          : BorderRadius.circular(widget.borderRadius),
      shape: widget.shape,
    );

    // Add shadows based on type
    switch (type) {
      case NeumorphicType.flat:
      // No shadows for flat
        return decoration;

      case NeumorphicType.pressed:
      // Inner shadow effect
        return decoration.copyWith(
          boxShadow: [
            BoxShadow(
              color: darkShadowColor,
              offset: const Offset(-1, -1),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius / 2,
            ),
            BoxShadow(
              color: lightShadowColor,
              offset: const Offset(1, 1),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius / 2,
            ),
          ],
        );

      case NeumorphicType.elevated:
      // Outer shadow effect
        return decoration.copyWith(
          boxShadow: [
            BoxShadow(
              color: lightShadowColor,
              offset: Offset(-offset.dx, -offset.dy),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
            BoxShadow(
              color: darkShadowColor,
              offset: offset,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
          ],
        );

      case NeumorphicType.concave:
      // Concave gradient effect
        return decoration.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.darken(0.1),
              baseColor.brighten(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: lightShadowColor,
              offset: Offset(-offset.dx, -offset.dy),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
            BoxShadow(
              color: darkShadowColor,
              offset: offset,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
          ],
        );

      case NeumorphicType.convex:
      // Convex gradient effect
        return decoration.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.brighten(0.15),
              baseColor.darken(0.15),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: lightShadowColor,
              offset: Offset(-offset.dx, -offset.dy),
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
            BoxShadow(
              color: darkShadowColor,
              offset: offset,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
            ),
          ],
        );
    }
  }
}

// Extension methods to brighten and darken colors
extension ColorExtension on Color {
  Color brighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation,
      (hsl.lightness + amount).clamp(0.0, 1.0),
    ).toColor();
  }

  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation,
      (hsl.lightness - amount).clamp(0.0, 1.0),
    ).toColor();
  }
}