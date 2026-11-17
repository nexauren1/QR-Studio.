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
    return StudioCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 12),
          Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: StudioColors.muted, fontSize: 11, height: 1.35)),
        ],
      ),
    );
  }
}
