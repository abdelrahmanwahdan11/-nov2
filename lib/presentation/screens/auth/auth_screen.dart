import 'package:flutter/material.dart';

import '../../../application/stores/app_store.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_motion.dart';
import '../../widgets/primary_button.dart';

enum AuthStage { welcome, signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthStage stage = AuthStage.welcome;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _infoMessage;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchStage(AuthStage newStage) {
    setState(() {
      stage = newStage;
      _infoMessage = null;
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;
      if (newStage != AuthStage.signUp) {
        _confirmPasswordController.clear();
        _passwordStrength = 0;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (stage == AuthStage.welcome) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await AppStore.instance.setAuthenticated(true);
    setState(() {
      _infoMessage = SahaLocalizations.of(context).t('signin_success');
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    AppRouter.instance.setRoot('/home');
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return SahaLocalizations.of(context).t('invalid_email');
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) {
      return SahaLocalizations.of(context).t('invalid_email');
    }
    return null;
  }

  void _updateStrength() {
    final value = _passwordController.text;
    setState(() {
      _passwordStrength = _calculateStrength(value);
    });
  }

  double _calculateStrength(String value) {
    if (value.isEmpty) {
      return 0;
    }
    double score = 0;
    if (value.length >= 8) score += 0.25;
    if (value.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (value.contains(RegExp(r'[a-z]'))) score += 0.25;
    if (value.contains(RegExp(r'[0-9]')) || value.contains(RegExp(r'[!@#\$%^&*]'))) {
      score += 0.25;
    }
    return score.clamp(0, 1);
  }

  String _strengthLabel(SahaLocalizations l10n) {
    if (_passwordStrength >= 0.75) {
      return l10n.t('strength_strong');
    }
    if (_passwordStrength >= 0.5) {
      return l10n.t('strength_good');
    }
    return l10n.t('strength_weak');
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return SahaLocalizations.of(context).t('invalid_password');
    }
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    if (!hasUpper || !hasLower || !hasDigit) {
      return SahaLocalizations.of(context).t('invalid_password');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SahaLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1216), Color(0xFF151A1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () async {
                      await AppStore.instance.setAuthenticated(false);
                      if (!mounted) return;
                      AppRouter.instance.setRoot('/home');
                    },
                    child: Text(l10n.t('guest_continue')),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.duration(context, const Duration(milliseconds: 450)),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildContent(l10n, textTheme),
                  ),
                ),
                if (_infoMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _infoMessage!,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.info),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _buildFooter(l10n, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SahaLocalizations l10n, TextTheme textTheme) {
    switch (stage) {
      case AuthStage.welcome:
        return _buildWelcome(l10n, textTheme);
      case AuthStage.signIn:
        return _buildForm(l10n, textTheme, l10n.t('sign_in'));
      case AuthStage.signUp:
        return _buildForm(l10n, textTheme, l10n.t('sign_up'), includeName: true);
      case AuthStage.forgotPassword:
        return _buildForgot(l10n, textTheme);
    }
  }

  Widget _buildWelcome(SahaLocalizations l10n, TextTheme textTheme) {
    return Column(
      key: const ValueKey('welcome'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.t('welcome_title'), style: textTheme.displayLarge),
        const SizedBox(height: 12),
        Text(
          l10n.t('welcome_desc'),
          style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
        const Spacer(),
        PrimaryButton(
          label: l10n.t('sign_in'),
          onPressed: () => _switchStage(AuthStage.signIn),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _switchStage(AuthStage.signUp),
          child: Text(l10n.t('create_account')),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildForm(SahaLocalizations l10n, TextTheme textTheme, String title,
      {bool includeName = false}) {
    return Form(
      key: _formKey,
      child: ListView(
        key: ValueKey(title),
        children: [
          Text(title, style: textTheme.displayLarge),
          const SizedBox(height: 16),
          if (includeName)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.t('name')),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return l10n.t('invalid_name');
                }
                return null;
              },
            ),
          if (includeName) const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.t('email')),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: l10n.t('password'),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),
          if (includeName)
            _PasswordStrengthIndicator(
              strength: _passwordStrength,
              label: '${l10n.t('password_strength')}: ${_strengthLabel(l10n)}',
            ),
          if (includeName) const SizedBox(height: 12),
          if (includeName)
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: l10n.t('confirm_password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n.t('passwords_mismatch');
                }
                return null;
              },
            ),
          if (includeName) const SizedBox(height: 12),
          if (!includeName)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _switchStage(AuthStage.forgotPassword),
                child: Text(l10n.t('forgot_password')),
              ),
            ),
          if (!includeName) const SizedBox(height: 16),
          PrimaryButton(
            label: title,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildForgot(SahaLocalizations l10n, TextTheme textTheme) {
    return Form(
      key: const ValueKey('forgot'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.t('forgot_password'), style: textTheme.displayLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.t('email')),
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: l10n.t('continue'),
            onPressed: () {
              _switchStage(AuthStage.signIn);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(SahaLocalizations l10n, TextTheme textTheme) {
    switch (stage) {
      case AuthStage.welcome:
        return Column(
          children: [
            Text(
              l10n.t('or'),
              style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await AppStore.instance.setAuthenticated(false);
                if (!mounted) return;
                AppRouter.instance.setRoot('/home');
              },
              child: Text(l10n.t('guest_mode')),
            ),
          ],
        );
      case AuthStage.signIn:
        return TextButton(
          onPressed: () => _switchStage(AuthStage.signUp),
          child: Text(l10n.t('create_account')),
        );
      case AuthStage.signUp:
        return TextButton(
          onPressed: () => _switchStage(AuthStage.signIn),
          child: Text(l10n.t('sign_in')),
        );
      case AuthStage.forgotPassword:
        return TextButton(
          onPressed: () => _switchStage(AuthStage.signIn),
          child: Text(l10n.t('sign_in')),
        );
    }
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.strength, required this.label});

  final double strength;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (strength >= 0.75) {
      color = Colors.greenAccent;
    } else if (strength >= 0.5) {
      color = Colors.orangeAccent;
    } else {
      color = Colors.redAccent;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: strength, color: color, backgroundColor: theme.cardColor.withOpacity(0.4)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
