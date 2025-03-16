// lib/core/theme/modern_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

/// GradientContainer - A container with gradient background
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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

/// GlassContainer - Container with frosted glass effect
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
  final List<BoxShadow>? boxShadow;

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
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border,
              color: color.withOpacity(opacity),
              boxShadow: boxShadow ?? [
                BoxShadow(
                  color: color.withOpacity(opacity / 2),
                  blurRadius: blur,
                  spreadRadius: -blur / 2,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// AnimatedCounter - Animated numeric counter
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
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix${animatedValue.toStringAsFixed(precision)}$suffix',
          style: effectiveStyle,
        );
      },
    );
  }
}

/// CustomBadge - Notification badge with counter
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
    this.size = 22,
    this.top = -10,
    this.right = -10,
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

    if (count <= 0 && !showZero) {
      return const SizedBox.shrink();
    }

    return Positioned(
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
    );
  }
}

/// ShimmerLoading - Shimmer effect for loading states
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

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: false);

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

/// PremiumBadge - Badge for premium users
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

/// RatingBar - Star rating widget
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
    final effectiveInactiveColor = inactiveColor ??
        effectiveActiveColor.withOpacity(0.3);
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

/// Animated List Item - Create beautiful entry animations for lists
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final int itemCount;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset? beginOffset;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.itemCount = 20, // Default value for itemCount
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutQuart,
    this.beginOffset,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final double startDelay = widget.index / widget.itemCount;
    final effectiveDelay = widget.delay.inMilliseconds * startDelay;

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: widget.curve),
      ),
    );

    final beginOffset = widget.beginOffset ?? const Offset(0, 0.25);
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    Future.delayed(Duration(milliseconds: effectiveDelay.round()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// ScaleOnHover - Widget that scales slightly when hovered (especially for web/desktop)
class ScaleOnHover extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  const ScaleOnHover({
    Key? key,
    required this.child,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<ScaleOnHover> createState() => _ScaleOnHoverState();
}

class _ScaleOnHoverState extends State<ScaleOnHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

/// CustomProgressIndicator - A branded progress indicator
class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final List<Color> progressColors;
  final bool animated;
  final Duration animationDuration;

  const CustomProgressIndicator({
    Key? key,
    required this.value,
    this.height = 8.0,
    this.borderRadius = 4.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColors = const [AppColors.primaryColor, Color(0xFF8E75FD)],
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 750),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: animated
            ? TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return _buildProgressBar(animatedValue);
          },
        )
            : _buildProgressBar(value),
      ),
    );
  }

  Widget _buildProgressBar(double currentValue) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: currentValue.clamp(0.0, 1.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: progressColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

/// GradientButton - Button with gradient background
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final bool isLoading;
  final double elevation;
  final double? width;
  final double? height;
  final Widget? icon;
  final double borderRadius;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.colors = const [AppColors.primaryColor, Color(0xFF8E75FD)],
    this.isLoading = false,
    this.elevation = 2,
    this.width,
    this.height = 50,
    this.icon,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed == null ? [Colors.grey, Colors.grey.shade400] : colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// BounceCard - Card with bounce animation on tap
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
  final List<BoxShadow>? boxShadow;

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
    this.gradientColors,
    this.boxShadow,
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
    final defaultShadow = [
      BoxShadow(
        color: (theme.colorScheme.shadow).withOpacity(0.1),
        blurRadius: widget.elevation * 3,
        offset: Offset(0, widget.elevation),
      ),
    ];

    final effectiveBoxShadow = widget.boxShadow ?? defaultShadow;

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
          boxShadow: effectiveBoxShadow,
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
          shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}