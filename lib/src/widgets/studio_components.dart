import 'package:flutter/material.dart';

import '../theme/studio_theme.dart';

class StudioLogo extends StatelessWidget {
  const StudioLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .27),
        gradient: const LinearGradient(
          colors: [StudioColors.cyan, StudioColors.purple, StudioColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: StudioColors.purple.withValues(alpha: .28),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .18),
          color: StudioColors.background,
        ),
        child: Icon(Icons.qr_code_2_rounded,
            size: size * .62, color: Colors.white),
      ),
    );
  }
}

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? Theme.of(context).cardTheme.color
                : null,
            borderRadius: BorderRadius.circular(22),
            boxShadow: gradient == null
                ? [
                    BoxShadow(
                      color: StudioColors.purple.withValues(alpha: .055),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: StudioColors.blue.withValues(alpha: .20),
                      blurRadius: 25,
                      offset: const Offset(0, 9),
                    ),
                  ],
            border: Border.all(
              color: borderColor ?? StudioColors.border.withValues(alpha: .75),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [StudioColors.purple, StudioColors.blue],
        ),
        boxShadow: [
          BoxShadow(
            color: StudioColors.blue.withValues(alpha: .22),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: compact ? 17 : 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 12 : 16,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class ToolTile extends StatelessWidget {
  const ToolTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: .94, end: 1),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        final progress = ((scale - .94) / .06).clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - progress)),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: StudioCard(
        onTap: onTap,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: .22)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .12),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 12),
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: StudioColors.muted, fontSize: 11, height: 1.35)),
          ],
        ),
      ),
    );
  }
}

class StudioPageRoute<T> extends PageRouteBuilder<T> {
  StudioPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .045),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: .985, end: 1).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}

class StudioProcessingOverlay extends StatelessWidget {
  const StudioProcessingOverlay({
    super.key,
    required this.active,
    required this.title,
    required this.message,
    required this.child,
  });

  final bool active;
  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !active,
            child: AnimatedOpacity(
              opacity: active ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: .68),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: .92, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: active
                        ? _StudioProcessingPanel(
                            key: ValueKey<String>(title),
                            title: title,
                            message: message,
                          )
                        : const SizedBox.shrink(key: ValueKey<String>('idle')),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudioProcessingPanel extends StatelessWidget {
  const _StudioProcessingPanel({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(25, 26, 25, 23),
      decoration: BoxDecoration(
        color: const Color(0xFF151832),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: StudioColors.cyan.withValues(alpha: .30)),
        boxShadow: [
          BoxShadow(
            color: StudioColors.purple.withValues(alpha: .30),
            blurRadius: 34,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [StudioColors.purple, StudioColors.blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: StudioColors.blue.withValues(alpha: .28),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StudioColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              minHeight: 3,
              color: StudioColors.cyan,
              backgroundColor: Color(0xFF292D55),
            ),
          ),
        ],
      ),
    );
  }
}
