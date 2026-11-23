import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import 'portal_shell.dart';

Future<void> showLoginSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: LcdColors.bgElevated,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const LoginSheet(),
  );
}

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});
  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final omd = TextEditingController();
  final pin = TextEditingController();
  final token = TextEditingController();
  final nova = TextEditingController();

  bool medico = false;
  bool recover = false;
  bool setPass = false;
  bool obscurePassword = true;
  bool loading = false;
  String recoverEmail = '';
  String? error;
  String? info;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    omd.dispose();
    pin.dispose();
    token.dispose();
    nova.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final app = context.read<AppState>();
    setState(() {
      error = null;
      info = null;
      loading = true;
    });

    try {
      if (recover) {
        if (setPass) {
          await app.resetPassword(recoverEmail, token.text.trim(), nova.text);
          if (!mounted) return;
          setState(() {
            recover = false;
            setPass = false;
            info = 'Palavra-passe alterada. Já pode iniciar sessão.';
          });
        } else {
          final demoCode = await app.recover(email.text.trim());
          if (!mounted) return;
          setState(() {
            recoverEmail = email.text.trim();
            setPass = true;
            info = demoCode != null
                ? 'Código de recuperação gerado para avaliação: $demoCode'
                : 'Se o email existir na plataforma, foi enviado um código de recuperação.';
          });
        }
        return;
      }

      final session = medico
          ? await app.loginOmd(omd.text.trim(), pin.text.trim())
          : await app.loginEmail(email.text.trim(), password.text);
      if (!mounted) return;
      Navigator.pop(context);
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PortalShell(mode: session.papel)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + inset),
      child: SingleChildScrollView(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: LcdColors.line, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const LabCdLogo(height: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recover
                                ? (setPass ? 'Definir nova palavra-passe' : 'Recuperar acesso')
                                : 'Área reservada',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            recover
                                ? (setPass
                                    ? 'Introduza o código associado a $recoverEmail.'
                                    : 'Indique o email registado da clínica ou colaborador.')
                                : 'Portal da Clínica e Backoffice LAB CD.',
                            style: const TextStyle(color: LcdColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (!recover) ...[
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('Email'), icon: Icon(Icons.mail_outline)),
                      ButtonSegment<bool>(value: true, label: Text('Cédula OMD'), icon: Icon(Icons.badge_outlined)),
                    ],
                    selected: {medico},
                    onSelectionChanged: (sel) => setState(() {
                      medico = sel.first;
                      error = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
                if (medico && !recover) ...[
                  TextFormField(
                    controller: omd,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de cédula OMD',
                      hintText: 'Ex.: 10482',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Indique o número da cédula OMD.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'PIN de 4 dígitos',
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.trim().length < 4) ? 'Indique o PIN de 4 dígitos.' : null,
                  ),
                ] else if (!setPass) ...[
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username, AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email', hintText: 'clinica@exemplo.pt'),
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.isEmpty || !text.contains('@')) return 'Indique um endereço de email válido.';
                      return null;
                    },
                  ),
                ],
                if (setPass) ...[
                  TextFormField(
                    controller: token,
                    decoration: const InputDecoration(labelText: 'Código de recuperação'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Indique o código de recuperação.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nova,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nova palavra-passe (mín. 8 caracteres)'),
                    validator: (v) => (v == null || v.length < 8) ? 'A palavra-passe deve ter pelo menos 8 caracteres.' : null,
                  ),
                ],
                if (!recover && !medico) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    obscureText: obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Palavra-passe',
                      suffixIcon: IconButton(
                        tooltip: obscurePassword ? 'Mostrar palavra-passe' : 'Ocultar palavra-passe',
                        icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Introduza a palavra-passe.' : null,
                  ),
                ],
                if (error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: LcdColors.danger.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LcdColors.danger.withValues(alpha: 0.5)),
                    ),
                    child: Text(error!, style: const TextStyle(color: LcdColors.danger, fontSize: 13)),
                  ),
                if (info != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: LcdColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LcdColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(info!, style: const TextStyle(color: LcdColors.goldSoft, fontSize: 13)),
                  ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: LcdColors.ink))
                      : Text(recover ? (setPass ? 'Alterar palavra-passe' : 'Enviar instruções') : 'Entrar no portal'),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => setState(() {
                    recover = !recover;
                    setPass = false;
                    error = null;
                    info = null;
                  }),
                  child: Text(recover ? 'Voltar ao login' : 'Esqueci-me da palavra-passe'),
                ),
                const SizedBox(height: 4),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Credenciais de avaliação', style: TextStyle(fontSize: 14, color: LcdColors.muted)),
                  children: [
                    for (final a in demoAccounts)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(a.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${a.email} · ${papelNome(a.papel)}', style: const TextStyle(color: LcdColors.muted, fontSize: 12)),
                        trailing: const Icon(Icons.touch_app_outlined, size: 18, color: LcdColors.gold),
                        onTap: () {
                          email.text = a.email;
                          password.text = app.passwordOf(a);
                          setState(() => medico = false);
                        },
                      ),
                    for (final m in app.db.medicos.where((m) => m.ativo))
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(formatDoctorName(m.nome), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${formatOmd(m.numeroOrdem)} · PIN ${m.pin}', style: const TextStyle(color: LcdColors.muted, fontSize: 12)),
                        trailing: const Icon(Icons.badge_outlined, size: 18, color: LcdColors.gold),
                        onTap: () {
                          omd.text = m.numeroOrdem.replaceAll(RegExp(r'\D'), '');
                          pin.text = m.pin;
                          setState(() => medico = true);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
