import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'criar_pedido.dart';
import 'trabalho_detail.dart';

class TrabalhosScreen extends StatefulWidget {
  const TrabalhosScreen({super.key, required this.mode});
  final String mode;
  @override
  State<TrabalhosScreen> createState() => _TrabalhosScreenState();
}

class _TrabalhosScreenState extends State<TrabalhosScreen> {
  String q = '';
  String estado = '';
  String tipo = '';
  String sort = 'prazo';
  String tabFiltro = 'todos';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isClinica = app.session?.isClinica == true;
    final currentUserId = app.session?.utilizadorId;

    final list = app.trabalhosVisiveis().where((t) {
      final p = app.db.pedidosTrabalho.where((p) => p.id == t.pedidoTrabalhoId).firstOrNull;
      final tip = app.db.tipoOf(t);
      final hay = '${t.referencia} ${p?.referencia ?? ""} ${p?.paciente ?? ""} ${t.material ?? ""} ${tip?.nome ?? ""}'.toLowerCase();
      if (q.isNotEmpty && !hay.contains(q.toLowerCase())) return false;

      if (!isClinica) {
        if (tabFiltro == 'meus') {
          if (t.atribuidoA != currentUserId || t.estado == 'concluido' || t.estado == 'entregue') {
            return false;
          }
        } else if (tabFiltro == 'disponiveis') {
          if (t.atribuidoA != null || (t.estado != 'por_iniciar' && t.estado != 'em_processamento')) {
            return false;
          }
        }
      }

      if (estado.isNotEmpty) {
        if (isClinica) {
          if (estado == 'por_aceitar' && t.estado != 'em_avaliacao') return false;
          if (estado == 'em_producao' &&
              (t.estado == 'em_avaliacao' || t.estado == 'concluido' || t.estado == 'entregue' || t.estado == 'cancelado' || t.estado == 'recusado')) {
            return false;
          }
          if (estado == 'concluido' && (t.estado != 'concluido' && t.estado != 'entregue')) return false;
        } else if (t.estado != estado) {
          return false;
        }
      }

      if (tipo.isNotEmpty && t.tipoId != tipo) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      if (sort == 'prazo') {
        final pa = app.db.pedidosTrabalho.where((p) => p.id == a.pedidoTrabalhoId).firstOrNull;
        final pb = app.db.pedidosTrabalho.where((p) => p.id == b.pedidoTrabalhoId).firstOrNull;
        final da = pa?.proximaConsulta ?? pa?.prazo ?? DateTime(2099);
        final db = pb?.proximaConsulta ?? pb?.prazo ?? DateTime(2099);
        return da.compareTo(db);
      }
      return b.criadoEm.compareTo(a.criadoEm);
    });

    final meusCount = app.db.trabalhos.where((t) => t.atribuidoA == currentUserId && t.estado != 'concluido' && t.estado != 'entregue').length;
    final disponiveisCount = app.db.trabalhos.where((t) => t.atribuidoA == null && (t.estado == 'por_iniciar' || t.estado == 'em_processamento')).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PageHeading(
          title: 'Trabalhos',
          subtitle: isClinica
              ? 'Acompanhe o estado dos casos clínicos submetidos ao laboratório.'
              : 'Filtre trabalhos por estado, tipo protético ou fila de atribuição.',
          action: FilledButton.icon(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CriarPedidoScreen(mode: widget.mode))),
            label: const Text('Novo pedido'),
          ),
        ),
        if (!isClinica) ...[
          SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(value: 'todos', label: Text('Todos (${app.trabalhosVisiveis().length})')),
              ButtonSegment<String>(value: 'meus', label: Text('Meus ($meusCount)')),
              ButtonSegment<String>(value: 'disponiveis', label: Text('Por assumir ($disponiveisCount)')),
            ],
            selected: {tabFiltro},
            onSelectionChanged: (sel) => setState(() => tabFiltro = sel.first),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Pesquisar por referência, paciente, tipo ou material',
          ),
          onChanged: (v) => setState(() => q = v),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final colWidth = constraints.maxWidth >= 680 ? (constraints.maxWidth - 16) / 3 : constraints.maxWidth;
            return Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: colWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: estado,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: isClinica
                        ? const [
                            DropdownMenuItem(value: '', child: Text('Todos os estados')),
                            DropdownMenuItem(value: 'por_aceitar', child: Text('Por aceitar')),
                            DropdownMenuItem(value: 'em_producao', child: Text('Em produção')),
                            DropdownMenuItem(value: 'concluido', child: Text('Concluído')),
                          ]
                        : [
                            const DropdownMenuItem(value: '', child: Text('Todos os estados')),
                            for (final e in ['em_avaliacao', 'por_iniciar', 'em_processamento', 'em_espera', 'em_prova', 'concluido', 'entregue', 'cancelado'])
                              DropdownMenuItem(value: e, child: Text(estadoNome(e))),
                          ],
                    onChanged: (v) => setState(() => estado = v ?? ''),
                  ),
                ),
                SizedBox(
                  width: colWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: tipo,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Tipo de trabalho'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Todos os tipos')),
                      for (final t in app.db.tipos) DropdownMenuItem(value: t.id, child: Text(t.nome)),
                    ],
                    onChanged: (v) => setState(() => tipo = v ?? ''),
                  ),
                ),
                SizedBox(
                  width: colWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: sort,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Ordenação'),
                    items: const [
                      DropdownMenuItem(value: 'prazo', child: Text('Próxima consulta')),
                      DropdownMenuItem(value: 'recente', child: Text('Mais recentes')),
                    ],
                    onChanged: (v) => setState(() => sort = v ?? 'prazo'),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          EmptyStatePanel(
            icon: Icons.medical_services_outlined,
            title: 'Sem trabalhos para os filtros selecionados',
            subtitle: 'Ajuste os termos de pesquisa ou crie um novo pedido clínico.',
            action: (q.isNotEmpty || estado.isNotEmpty || tipo.isNotEmpty)
                ? OutlinedButton(
                    onPressed: () => setState(() {
                      q = '';
                      estado = '';
                      tipo = '';
                    }),
                    child: const Text('Limpar filtros'),
                  )
                : null,
          )
        else
          for (final t in list) _JobTile(trabalho: t, isClinica: isClinica),
      ],
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.trabalho, required this.isClinica});
  final Trabalho trabalho;
  final bool isClinica;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.db.pedidosTrabalho.where((e) => e.id == trabalho.pedidoTrabalhoId).firstOrNull;
    final tipo = app.db.tipos.where((e) => e.id == trabalho.tipoId).firstOrNull;
    final etapa = app.db.etapas.where((e) => e.id == trabalho.etapaAtualId).firstOrNull;
    final clinica = p == null ? null : app.db.clinicas.where((c) => c.id == p.clinicaId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LcdPanel(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrabalhoDetailScreen(trabalhoId: trabalho.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trabalho.referencia,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                StatusChip(trabalho.estado, isClinica: isClinica),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${tipo?.nome ?? 'Trabalho'} · Paciente ${p?.paciente ?? '—'}${trabalho.material != null && trabalho.material!.isNotEmpty ? " · ${trabalho.material}" : ""}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            if (isClinica)
              Text(clinica?.nome ?? '', style: const TextStyle(color: LcdColors.muted, fontSize: 13))
            else
              Text('${clinica?.nome ?? ''} · ${etapa?.nome ?? ''}', style: const TextStyle(color: LcdColors.muted, fontSize: 13)),
            const SizedBox(height: 6),
            if (p?.proximaConsulta != null)
              Text(
                'Próxima consulta: ${datePt.format(p!.proximaConsulta!)}',
                style: const TextStyle(color: LcdColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
              )
            else if (!isClinica && p != null)
              Text(
                prazoLabel(p.prazo),
                style: TextStyle(
                  color: p.prazo.isBefore(DateTime.now()) ? LcdColors.danger : LcdColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
