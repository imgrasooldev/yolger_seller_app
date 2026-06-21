import 'package:hyper_local_seller/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:hyper_local_seller/config/hive_storage.dart';
import 'package:hyper_local_seller/screen/auth/bloc/verify-user/verify_user_bloc.dart';
import 'package:hyper_local_seller/utils/debouncer.dart';
import 'package:hyper_local_seller/utils/validator_utils.dart';
import 'package:hyper_local_seller/widgets/custom/custom_phone_field.dart';
import 'package:hyper_local_seller/widgets/custom/custom_textfield.dart';

/// Resolves the settings-API dial code (e.g. "91") to an ISO-2 country code
/// (e.g. "IN") that IntlPhoneField's `initialCountryCode` expects. Falls back
/// to "IN" when the dial code is empty or unrecognised.
String _initialIsoFromDialCode(String dialCode) {
  final cleaned = dialCode.replaceAll('+', '').trim();
  if (cleaned.isEmpty) return 'IN';
  final match = countries.firstWhere(
    (c) => c.dialCode == cleaned,
    orElse: () => countries.firstWhere(
      (c) => c.code == 'IN',
      orElse: () => countries.first,
    ),
  );
  return match.code;
}

class PersonalInformationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocusNode;
  final FocusNode mobileFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final Function(String code, String flag) onCountryChanged;
  final String selectedCountryCode;
  final String selectedCountryFlag;

  const PersonalInformationStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.mobileController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocusNode,
    required this.mobileFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.onCountryChanged,
    required this.selectedCountryCode,
    required this.selectedCountryFlag,
  });

  @override
  State<PersonalInformationStep> createState() =>
      _PersonalInformationStepState();
}

class _PersonalInformationStepState extends State<PersonalInformationStep> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Debouncer _emailDebouncer = Debouncer(milliseconds: 500);
  final Debouncer _phoneDebouncer = Debouncer(milliseconds: 500);

  String? _emailVerificationError;
  String? _phoneVerificationError;

  // Inline phone validation error (from validator_utils) — kept in sync
  // with the field's onChanged once the user has tried submitting.
  String? _phoneErrorText;
  bool _phoneSubmitAttempted = false;

  @override
  void initState() {
    super.initState();

    // Add listeners for email verification
    widget.emailController.addListener(_onEmailChanged);

    // Add listeners for phone verification
    widget.mobileController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _emailDebouncer.dispose();
    _phoneDebouncer.dispose();
    widget.emailController.removeListener(_onEmailChanged);
    widget.mobileController.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _onEmailChanged() {
    final email = widget.emailController.text.trim();

    // Clear error when user starts typing
    if (_emailVerificationError != null) {
      setState(() {
        _emailVerificationError = null;
      });
    }

    // Validate email format before making API call
    if (email.isNotEmpty) {
      // Basic email validation regex
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (emailRegex.hasMatch(email)) {
        _emailDebouncer.run(() {
          context.read<VerifyUserBloc>().add(VerifyUserEmail('email', email));
        });
      }
    }
  }

  void _onPhoneChanged() {
    final phone = widget.mobileController.text.trim();

    // Clear API "already exists" error when user starts typing
    if (_phoneVerificationError != null) {
      setState(() {
        _phoneVerificationError = null;
      });
    }

    // Keep inline validator error in sync once user has tried to submit
    if (_phoneSubmitAttempted && mounted) {
      setState(() {
        _phoneErrorText = ValidatorUtils.validatePhone(context, phone);
      });
    }

    // Only ping the duplicate-check API when the number passes our
    // basic validation (5-16 digits, digits-only).
    if (phone.isNotEmpty &&
        phone.length >= 5 &&
        phone.length <= 16 &&
        RegExp(r'^\d+$').hasMatch(phone)) {
      _phoneDebouncer.run(() {
        context.read<VerifyUserBloc>().add(VerifyUserPhone('mobile', phone));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<VerifyUserBloc, VerifyUserState>(
      listener: (context, state) {
        // NOTE: The event is dispatched with type 'mobile' (matches the
        // backend's `mobile` field), so the state's `type` is also 'mobile'.
        // The bloc's message is an English fallback — UI overrides with
        // a localized string.
        if (state is VerifyUserAlreadyExists) {
          setState(() {
            if (state.type == 'email') {
              _emailVerificationError =
                  l10n?.thisEmailIsAlreadyTaken ?? state.message;
            } else if (state.type == 'mobile') {
              _phoneVerificationError =
                  l10n?.thisPhoneNumberIsAlreadyTaken ?? state.message;
            }
          });
          // Re-run the form validators so the field's built-in errorText
          // updates immediately (otherwise the user wouldn't see the error
          // until their next interaction).
          widget.formKey.currentState?.validate();
        } else if (state is VerifyUserValid) {
          setState(() {
            if (state.type == 'email') {
              _emailVerificationError = null;
            } else if (state.type == 'mobile') {
              _phoneVerificationError = null;
            }
          });
          widget.formKey.currentState?.validate();
        } else if (state is VerifyUserError) {
          // Network/other errors — don't gate the form on these.
        }
      },
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: l10n?.sellerName ?? 'Seller Name',
              isRequired: true,
              hint: AppLocalizations.of(context)!.enterName,
              controller: widget.nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  ValidatorUtils.validateEmpty(context, value),
              focusNode: widget.nameFocusNode,
            ),
            const SizedBox(height: 20),

            CustomPhoneField(
              label: l10n?.mobileNumber ?? "Mobile Number",
              isRequired: true,
              controller: widget.mobileController,
              focusNode: widget.mobileFocusNode,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialCountryCode:
                  _initialIsoFromDialCode(HiveStorage.countryDialCode),
              onChanged: (PhoneNumber phone) {
                if (_phoneSubmitAttempted && mounted) {
                  setState(() {
                    _phoneErrorText =
                        ValidatorUtils.validatePhone(context, phone.number);
                  });
                }
              },
              validator: (PhoneNumber? phone) {
                _phoneSubmitAttempted = true;
                final formatErr =
                    ValidatorUtils.validatePhone(context, phone?.number);
                // Surface the format error first; if format is valid, fall
                // back to the verify-user API "already taken" error so the
                // form blocks Next on duplicates.
                final err = formatErr ?? _phoneVerificationError;
                _phoneErrorText = err;
                return err;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n?.emailAddress ?? 'Email Address',
              isRequired: true,
              hint: l10n?.enterYourEmailAddress ?? 'Enter Your Email Address',
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final formatErr = ValidatorUtils.validateEmail(context, value);
                // Surface format error first; otherwise surface the
                // verify-user API "already taken" error so the form blocks
                // Next on duplicates.
                return formatErr ?? _emailVerificationError;
              },
              focusNode: widget.emailFocusNode,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n?.password ?? 'Password',
              isRequired: true,
              hint:l10n?.enterPassword ?? 'Enter Password',
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) =>
                  ValidatorUtils.validatePassword(context, value),
              focusNode: widget.passwordFocusNode,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n?.confirmPassword ?? 'Confirm Password',
              isRequired: true,
              hint:l10n?.confirmYourPassword ?? 'Confirm Your Password',
              controller: widget.confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: (value) => ValidatorUtils.validateConfirmPassword(
                context,
                value,
                widget.passwordController.text,
              ),
              focusNode: widget.confirmPasswordFocusNode,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
