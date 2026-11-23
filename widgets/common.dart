import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

final datePt = DateFormat('dd MMM yyyy', 'pt_PT');
final dateShort = DateFormat('dd MMM', 'pt_PT');

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward, size: 18),
      label: Text(label),
    );
  }
}

class LcdPanel extends StatelessWidget {
  const LcdPanel({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    final inner = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? LcdColors.panel,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? LcdColors.line),
      ),
      child: child,
    );
    if (onTap == null) return inner;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: inner,
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.estado, {super.key, this.isClinica = false});
  final String estado;
  final bool isClinica;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            estadoNome(estado, isClinica: isClinica),
            style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.action,
  });

  // Kept optional for API compatibility; intentionally omitted from UI to avoid decorative kickers.
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 460;
          final headingBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(subtitle!, style: const TextStyle(color: LcdColors.muted, height: 1.45)),
                ),
            ],
          );

          if (narrow || action == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headingBlock,
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action!,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headingBlock),
              const SizedBox(width: 12),
              action!,
            ],
          );
        },
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LcdPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 32, color: LcdColors.muted),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: LcdColors.muted, fontSize: 13)),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

String prazoLabel(DateTime prazo) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(prazo.year, prazo.month, prazo.day);
  final days = target.difference(today).inDays;
  if (days < 0) return '${pluralPt(days.abs(), 'dia', 'dias')} em atraso';
  if (days == 0) return 'Entrega hoje';
  return 'Faltam ${pluralPt(days, 'dia', 'dias')}';
}
