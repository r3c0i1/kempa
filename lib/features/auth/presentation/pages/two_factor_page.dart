import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kempa/core/extensions/context_extensions.dart';
import 'package:kempa/core/theme/app_text_styles.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_event.dart';
import 'package:kempa/features/auth/presentation/bloc/auth_state.dart';
import 'package:pinput/pinput.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({
    super.key,
  });

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {

  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  static const int _resendCooldown = 60;
  Timer? _timer;
  int _secondsRemaining = _resendCooldown;
  bool _canResend = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = _resendCooldown;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min}:${sec.toString().padLeft(2, '0')}';
  }

  void _onCodeCompleted(String code) {
    context.read<AuthBloc>().add(AuthTwoFactorCodeSubmittedEvent(code));
  }

  Future<void> _onResendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    context.read<AuthBloc>().add(AuthTwoFactorResendEvent());

    // Небольшая задержка для UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      _startTimer();
      _otpController.clear();
      _focusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: context.colors.primaryContainer,
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: context.colors.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Text(
                'Код отправлен повторно',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildResendButton(BuildContext context) {
    // Пока идёт повторная отправка
    if (_isResending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Отправка...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Можно отправить повторно
    if (_canResend) {
      return TextButton(
        onPressed: _onResendCode,
        child: const Text('Отправить код повторно'),
      );
    }

    // Таймер
    return Text(
      'Отправить повторно через ${_formatTime(_secondsRemaining)}',
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildOtpField(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      // textStyle: AppTextStyles.otpDigit.copyWith(
      //   color: context.colors.onSurface,
      // ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.primary,
          width: 1.5,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.error,
          width: 1.5,
        ),
      ),
    );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final hasError = state is AuthTwoFactorState && state.error != null;

        return Pinput(
          controller: _otpController,
          focusNode: _focusNode,
          length: 6,
          defaultPinTheme: hasError ? errorPinTheme : defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          separatorBuilder: (index) {
            // Разделитель после 3-й цифры
            if (index == 2) {
              return SizedBox(width: 16);
            }
            return SizedBox(width: 8);
          },
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.oneTimeCode],
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: _onCodeCompleted,
          onChanged: (_) {
            // Обновляем состояние кнопки
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthTwoFactorState && state.error != null) {
          // Очищаем поле при ошибке
          _otpController.clear();
          _focusNode.requestFocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: context.colors.errorContainer,
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.colors.onErrorContainer,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) { 
        final isLoading = state is AuthTwoFactorState && state.isLoading;

        return Scaffold(
        appBar: AppBar(
          leading: ElevatedButton.icon(
            onPressed: (){}, 
            label: Icon(Icons.arrow_back)
          ),
          // title: Text("Введите код"),
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 40,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 24,),
                Text(
                  "Введите код",
                  style: context.textTheme.headlineSmall
                ),
                SizedBox(height: 8,),
                Text(
                  "Мы отправили его на вашу почту,\nпривязанную к аккаунту",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48,),
                _buildOtpField(context),
                SizedBox(height: 32,),
                _buildResendButton(context),
                if (isLoading) ...[
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      }
    );
  }
}