import 'package:flutter/material.dart';

import '../theme.dart';

const upper = ['18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28'];
const lower = ['48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38'];

class Odontogram extends StatelessWidget {
  const Odontogram({
    super.key,
    required this.selected,
    this.onToggle,
    this.onClear,
  });

  final List<String> selected;
  final void Function(String dente)? onToggle;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LcdColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LcdColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Arcada superior',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: LcdColors.muted),
                ),
              ),
              if (onToggle != null && selected.isNotEmpty && onClear != null)
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: onClear,
                  child: const Text('Limpar', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _row(upper),
          ),
          const SizedBox(height: 12),
          const Text(
            'Arcada inferior',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: LcdColors.muted),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _row(lower),
          ),
          const SizedBox(height: 10),
          Text(
            selected.isEmpty
                ? 'Sem dentes unitários selecionados (arcada completa ou geral).'
                : 'Dentes selecionados (${selected.length}): ${selected.join(', ')}',
            style: const TextStyle(color: LcdColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> teeth) {
    return Row(
      children: [
        for (var i = 0; i < teeth.length; i++) ...[
          if (i == 8)
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: LcdColors.navyBorder,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _ToothButton(
              tooth: teeth[i],
              isSelected: selected.contains(teeth[i]),
              onTap: onToggle == null ? null : () => onToggle!(teeth[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ToothButton extends StatelessWidget {
  const _ToothButton({
    required this.tooth,
    required this.isSelected,
    this.onTap,
  });

  final String tooth;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 34,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? LcdColors.gold : LcdColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? LcdColors.gold : LcdColors.navyBorder),
      ),
      child: Text(
        tooth,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? LcdColors.ink : LcdColors.cream,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: 'Dente $tooth',
      child: onTap == null
          ? child
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: child,
              ),
            ),
    );
  }
}
