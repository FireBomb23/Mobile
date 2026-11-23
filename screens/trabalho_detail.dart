import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/odontogram.dart';

Future<void> mostrarDialogConcluirEtapa(BuildContext context, AppState app, Trabalho t) async {
  final messenger = ScaffoldMessenger.of(context);
  final tipo = app.db.tipoOf(t);
  final etapaAtual = app.db.etapaById(t.etapaAtualId);
  final idx = tipo != null ? tipo.etapaIds.indexOf(t.etapaAtualId) : -1;
  String? proximaEtapaId;
  if (tipo != null && idx >= 0 && idx < tipo.etapaIds.length - 1) {
    proximaEtapaId = tipo.etapaIds[idx + 1];
  } else {
    proximaEtapaId = 'concluido';
  }
  String? atribuidoA = t.atribuidoA;
  var saving = false;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Concluir etapa: ${etapaAtual?.nome ?? "Atual"}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione a próxima etapa do fluxo. A atribuição a um técnico pode ficar em aberto.',
                    style: TextStyle(color: LcdColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: proximaEtapaId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Próxima etapa *',
                    ),
                    items: [
                      for (final e in app.db.etapas.where((e) => e.ativa))
                        DropdownMenuItem(value: e.id, child: Text(e.nome)),
                      const DropdownMenuItem(
                        value: 'concluido',
                        child: Text(
                          'Concluir trabalho',
                          style: TextStyle(color: LcdColors.gold, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                    onChanged: saving
                        ? null
                        : (v) {
                            if (v != null) {
                              setDialogState(() => proximaEtapaId = v);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: atribuidoA,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Técnico responsável (opcional)',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sem técnico atribuído')),
                      for (final c in app.db.colaboradores) DropdownMenuItem(value: c.id, child: Text(c.nome)),
                    ],
                    onChanged: saving ? null : (v) => setDialogState(() => atribuidoA = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: saving ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                onPressed: (proximaEtapaId == null || saving)
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        try {
                          await app.concluirEtapa(
                            trabalhoId: t.id,
                            proximaEtapaId: proximaEtapaId!,
                            atribuidoA: atribuidoA,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Etapa concluída.')),
                          );
                        } catch (e) {
                          if (ctx.mounted) setDialogState(() => saving = false);
                          messenger.showSnackBar(
                            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      },
                child: const Text('Confirmar avanço'),
              ),
            ],
          );
        },
      );
    },
  );
}

class TrabalhoDetailScreen extends StatefulWidget {
  const TrabalhoDetailScreen({super.key, required this.trabalhoId});
  final String trabalhoId;
  @override
  State<TrabalhoDetailScreen> createState() => _TrabalhoDetailScreenState();
}

class _TrabalhoDetailScreenState extends State<TrabalhoDetailScreen> {
  final nota = TextEditingController();
  final espera = TextEditingController();

  @override
  void dispose() {
    nota.dispose();
    espera.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<void> Function() action, {String? successMessage}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (mounted && successMessage != null) {
        messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.db.trabalhos.where((e) => e.id == widget.trabalhoId).firstOrNull;
    if (t == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trabalho')),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: EmptyStatePanel(
            icon: Icons.search_off_outlined,
            title: 'Trabalho não encontrado',
            subtitle: 'Verifique se o caso continua disponível na lista.',
          ),
        ),
      );
    }

    final p = app.db.pedidosTrabalho.where((e) => e.id == t.pedidoTrabalhoId).firstOrNull;
    final tipo = app.db.tipos.where((e) => e.id == t.tipoId).firstOrNull;
    final etapa = app.db.etapas.where((e) => e.id == t.etapaAtualId).firstOrNull;
    final lab = app.session?.isLab == true;
    final isClinica = !lab;
    final notas = app.db.notas.where((n) => n.trabalhoId == t.id && (lab || n.visivelClinica)).toList();
    final stls = app.db.ficheiros.where((f) => f.trabalhoId == t.id).toList();
    final clinica = p == null ? null : app.db.clinicaById(p.clinicaId);
    final medico = p == null ? null : app.db.medicoById(p.medicoId);

    return Scaffold(
      appBar: AppBar(title: Text(t.referencia)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeading(
            title: t.referencia,
            subtitle: p == null ? tipo?.nome : '${tipo?.nome ?? 'Trabalho'} · Paciente ${p.paciente} (${p.referencia})',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(t.estado, isClinica: isClinica),
              if (lab && etapa != null) Chip(label: Text('Etapa: ${etapa.nome}')),
            ],
          ),
          const SizedBox(height: 14),
          LcdPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dados da prescrição', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                if (clinica != null) ...[
                  _InfoLine(Icons.apartment_outlined, 'Clínica: ${clinica.nome}'),
                  const SizedBox(height: 6),
                ],
                if (medico != null) ...[
                  _InfoLine(Icons.person_outline, '${formatDoctorName(medico.nome)} · ${formatOmd(medico.numeroOrdem)}'),
                  const SizedBox(height: 6),
                ],
                if (p?.proximaConsulta != null) ...[
                  _InfoLine(Icons.calendar_today_outlined, 'Próxima consulta: ${datePt.format(p!.proximaConsulta!)}', highlight: true),
                  const SizedBox(height: 6),
                ],
                if (t.material != null && t.material!.isNotEmpty) ...[
                  _InfoLine(Icons.palette_outlined, 'Material: ${t.material}'),
                  const SizedBox(height: 6),
                ],
                if (tipo != null) _InfoLine(Icons.medical_services_outlined, 'Procedimento: ${tipo.nome}'),
                if (t.motivoEspera != null && t.motivoEspera!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: LcdColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LcdColors.warning.withValues(alpha: 0.5)),
                    ),
                    child: Text('Motivo de espera: ${t.motivoEspera}', style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          LcdPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Odontograma FDI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Odontogram(selected: t.dentes, onToggle: null),
              ],
            ),
          ),
          if (lab) ...[
            const SizedBox(height: 12),
            LcdPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fluxo técnico de etapas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  for (final id in tipo?.etapaIds ?? []) ...[
                    Builder(
                      builder: (context) {
                        final done = t.etapas.any((e) => e.etapaId == id && e.concluidoEm != null);
                        final current = id == t.etapaAtualId && !done;
                        final name = app.db.etapas.where((e) => e.id == id).firstOrNull?.nome ?? id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Icon(
                                done
                                    ? Icons.check_circle
                                    : current
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                color: done
                                    ? LcdColors.success
                                    : current
                                        ? LcdColors.gold
                                        : LcdColors.muted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: done || current ? LcdColors.cream : LcdColors.muted,
                                    fontWeight: current ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  onPressed: t.estado == 'entregue' || t.estado == 'cancelado'
                      ? null
                      : () => mostrarDialogConcluirEtapa(context, app, t),
                  label: const Text('Concluir etapa'),
                ),
                OutlinedButton(
                  onPressed: t.estado == 'concluido'
                      ? () => _runAction(() => app.entregar(t.id), successMessage: 'Trabalho marcado como entregue.')
                      : null,
                  child: const Text('Marcar entregue'),
                ),
                OutlinedButton(
                  onPressed: t.estado == 'em_espera'
                      ? () => _runAction(() => app.retomar(t.id), successMessage: 'Produção retomada.')
                      : () async {
                          espera.text = '';
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Colocar em espera'),
                              content: TextField(
                                controller: espera,
                                decoration: const InputDecoration(labelText: 'Motivo da suspensão'),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                              ],
                            ),
                          );
                          if (ok == true && espera.text.trim().isNotEmpty) {
                            await _runAction(() => app.colocarEmEspera(t.id, espera.text.trim()));
                          }
                        },
                  child: Text(t.estado == 'em_espera' ? 'Retomar produção' : 'Colocar em espera'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: t.atribuidoA,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Técnico responsável'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sem técnico atribuído')),
                for (final c in app.db.colaboradores) DropdownMenuItem(value: c.id, child: Text(c.nome)),
              ],
              onChanged: (v) => _runAction(() => app.atribuir(t.id, v)),
            ),
          ],
          const SizedBox(height: 14),
          LcdPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ficheiros STL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (stls.isEmpty)
                  const Text('Ainda não existem ficheiros associados a este trabalho.', style: TextStyle(color: LcdColors.muted)),
                for (final f in stls)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.view_in_ar_outlined, color: LcdColors.gold),
                    title: Text(f.nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('${f.tamanhoKb} KB · ${datePt.format(f.criadoEm)}', style: const TextStyle(color: LcdColors.muted, fontSize: 12)),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => app.escolherEAdicionarStl(t.id),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Anexar ficheiro STL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LcdPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notas e instruções', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (notas.isEmpty)
                  const Text('Sem notas registadas.', style: TextStyle(color: LcdColors.muted)),
                for (final n in notas)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LcdColors.bgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LcdColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.conteudo, style: const TextStyle(color: LcdColors.cream)),
                        const SizedBox(height: 4),
                        Text(datePt.format(n.criadoEm), style: const TextStyle(color: LcdColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                TextField(
                  controller: nota,
                  decoration: const InputDecoration(labelText: 'Nova nota técnica'),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () async {
                      final text = nota.text.trim();
                      if (text.isEmpty) return;
                      await _runAction(() async {
                        await app.adicionarNota(t.id, text);
                        nota.clear();
                      });
                    },
                    child: const Text('Guardar nota'),
                  ),
                ),
              ],
            ),
          ),
          if (app.session?.isClinica == true && t.estado == 'entregue') ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              icon: const Icon(Icons.build_outlined, size: 18),
              onPressed: () => _runAction(
                () => app.criarSolicitacao(
                  trabalhoId: t.id,
                  tipo: 'conserto',
                  motivo: 'Pedido de conserto submetido através da Área do Cliente.',
                ),
                successMessage: 'Solicitação de conserto enviada ao laboratório.',
              ),
              label: const Text('Pedir conserto'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.text, {this.highlight = false});
  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: highlight ? LcdColors.gold : LcdColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: highlight ? LcdColors.gold : LcdColors.cream,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
