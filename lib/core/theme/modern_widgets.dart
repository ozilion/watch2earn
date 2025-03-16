import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

/// Gradient Container - Gradyan arkaplanı olan özel bir konteyner
class GradientContainer extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Alignment begin;
  final Alignment end;
  final BoxShape shape;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GradientContainer({
    Key? key,
    required this.colors,
    required this.child,
    this.borderRadius = 16,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.shape = BoxShape.rectangle,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        shape: shape,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Bounce Card - Basıldığında hafif animasyon efekti olan kart
class BounceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool showBorder;
  final Color? borderColor;
  final List<Color>? gradientColors;

  const BounceCard({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.color,
    this.elevation = 2,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.showBorder = false,
    this.borderColor,
    this.gradientColors, required List<BoxShadow> boxShadow,
  }) : super(key: key);

  @override
  State<BounceCard> createState() => _BounceCardState();
}

class _BounceCardState extends State<BounceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          _controller.reverse();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) {
          _controller.reverse();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.gradientColors != null
            ? GradientContainer(
          colors: widget.gradientColors!,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          margin: widget.margin,
          border: widget.showBorder
              ? Border.all(
            color: widget.borderColor ?? theme.colorScheme.outline,
            width: 1.5,
          )
              : null,
          boxShadow: widget.elevation > 0
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: widget.elevation * 3,
              offset: Offset(0, widget.elevation),
            ),
          ]
              : null,
          child: widget.child,
        )
            : Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            side: widget.showBorder
                ? BorderSide(
              color: widget.borderColor ?? theme.colorScheme.outline,
              width: 1.5,
            )
                : BorderSide.none,
          ),
          color: widget.color ?? theme.cardTheme.color,
          elevation: widget.elevation,
          margin: widget.margin,
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Gradient Button - Gradyan arkaplanı olan özel buton
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> colors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final IconData? icon;
  final double elevation;
  final bool isLoading;
  final double iconSize;
  final double iconSpacing;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.colors = const [AppColors.primaryColor, Color(0xFF9C6FFF)],
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height = 54,
    this.textStyle,
    this.icon,
    this.elevation = 3,
    this.isLoading = false,
    this.iconSize = 20,
    this.iconSpacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = textStyle ?? AppTextStyles.buttonText.copyWith(color: Colors.white);

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        boxShadow: elevation > 0
            ? [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: padding,
            child: Center(
              child: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : icon != null
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: Colors.white),
                  SizedBox(width: iconSpacing),
                  Text(text, style: effectiveTextStyle),
                ],
              )
                  : Text(text, style: effectiveTextStyle),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass Container - Buzlu cam efektli konteyner
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color color;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Border? border;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.color = Colors.white,
    this.opacity = 0.2,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity / 2),
            blurRadius: blur,
            spreadRadius: -blur / 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: child,
        )
      ),
    );
  }
}

/// Animated Counter - Değişen sayıları animasyonlu gösterir
class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int precision;
  final String prefix;
  final String suffix;
  final Curve curve;
  final Duration duration;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.style,
    this.precision = 2,
    this.prefix = '',
    this.suffix = '',
    this.curve = Curves.easeOutCubic,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = style ?? AppTextStyles.numeric;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.toStringAsFixed(precision)}$suffix',
          style: effectiveStyle,
        );
      },
    );
  }
}

/// Badge - Bildirim veya sayı göstermek için badge
class CustomBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final TextStyle? textStyle;
  final double size;
  final double top;
  final double right;
  final bool showZero;

  const CustomBadge({
    Key? key,
    required this.count,
    this.color,
    this.textStyle,
    this.size = 20,
    this.top = -8,
    this.right = -8,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppColors.accentColor;
    final effectiveTextStyle = textStyle ??
        AppTextStyles.overline.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (count > 0 || showZero)
          Positioned(
            top: top,
            right: right,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: effectiveColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: effectiveTextStyle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shimmer Loading - Yükleme efekti
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBaseColor = baseColor ??
        (isDark ? AppColors.darkShimmerBaseColor : AppColors.shimmerBaseColor);
    final effectiveHighlightColor = highlightColor ??
        (isDark ? AppColors.darkShimmerHighlightColor : AppColors.shimmerHighlightColor);

    if (!isLoading) {
      return child;
    }

    return ShimmerEffect(
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      duration: duration,
      child: child,
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerEffect({
    Key? key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Premium Badge - Premium kullanıcıları belirtmek için
class PremiumBadge extends StatelessWidget {
  final double size;
  final EdgeInsets padding;

  const PremiumBadge({
    Key? key,
    this.size = 24,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.tokenColor, AppColors.tokenSecondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tokenColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.star,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}

/// Rating Bar - Yıldız derecelendirme
class RatingBar extends StatelessWidget {
  final double rating;
  final double itemSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsets padding;
  final bool showText;
  final TextStyle? textStyle;
  final double spacing;

  const RatingBar({
    Key? key,
    required this.rating,
    this.itemSize = 18,
    this.activeColor,
    this.inactiveColor,
    this.padding = EdgeInsets.zero,
    this.showText = true,
    this.textStyle,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? AppColors.ratingColor;
    final effectiveInactiveColor = inactiveColor ?? effectiveActiveColor.withOpacity(0.3);
    final effectiveTextStyle = textStyle ?? AppTextStyles.ratingText;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor()
                    ? Icons.star
                    : (index == rating.floor() && rating % 1 != 0)
                    ? Icons.star_half
                    : Icons.star_border,
                color: effectiveActiveColor,
                size: itemSize,
              );
            }),
          ),
          if (showText) ...[
            SizedBox(width: spacing),
            Text(
              rating.toStringAsFixed(1),
              style: effectiveTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

// Add other custom widgets as needed for your UI components