import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local_seller/config/colors.dart';
import 'package:hyper_local_seller/config/hive_storage.dart';
import 'package:hyper_local_seller/l10n/app_localizations.dart';
import 'package:hyper_local_seller/utils/ui_utils.dart';
import 'package:hyper_local_seller/widgets/custom/custom_scaffold.dart';
import 'package:hyper_local_seller/widgets/custom/custom_snackbar.dart';

import '../../../../../router/app_routes.dart';
import '../bloc/campaign_wallet_bloc/campaign_wallet_bloc.dart';
import '../bloc/create_campaign_bloc/create_campaign_bloc.dart';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  final TextEditingController _budgetController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  String? _selectedProductTitle;
  String? _selectedProductImage;
  bool _useSlider = true;
  double _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    context.read<CreateCampaignBloc>().add(FetchCampaignConfig());
    context.read<CampaignWalletBloc>().add(FetchAdWallet());
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenType = context.screenType;
    final theme = Theme.of(context);

    return BlocListener<CreateCampaignBloc, CreateCampaignState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == CampaignSubmitStatus.success) {
          showCustomSnackbar(
            context: context,
            message: state.actionMessage ??
                (l10n?.campaignSubmittedForApproval ??
                    'Campaign submitted for approval'),
          );
          context.read<CreateCampaignBloc>().add(ClearCampaignAction());
          context.pop(true);
        } else if (state.submitStatus == CampaignSubmitStatus.failure) {
          showCustomSnackbar(
            context: context,
            message: state.error ?? (l10n?.somethingWentWrong ?? 'Failed'),
            isWarning: true,
          );
          context.read<CreateCampaignBloc>().add(ClearCampaignAction());
        }
      },
      child: CustomScaffold(
        title: l10n?.createCampaign ?? 'Create Campaign',
        showAppbar: true,
        centerTitle: true,
        body: BlocBuilder<CreateCampaignBloc, CreateCampaignState>(
          builder: (context, state) {
            if (state.configStatus == CampaignConfigStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.configStatus == CampaignConfigStatus.failure) {
              return Center(
                child: Text(
                  l10n?.somethingWentWrong ?? 'Failed to load config',
                ),
              );
            }

            final config = state.config;
            if (config == null) return const SizedBox.shrink();

            // Initialize slider value on first config load
            if (_sliderValue == 0 && _useSlider) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _sliderValue == 0) {
                  setState(() {
                    _sliderValue = config.minBudget;
                  });
                }
              });
            }

            return SingleChildScrollView(
              padding: UIUtils.pagePadding(screenType),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    _buildInfoCard(config, l10n, screenType, theme),

                    SizedBox(height: UIUtils.gapXL(screenType)),

                    // Select Product
                    Text(
                      l10n?.selectProduct ?? 'Select Product',
                      style: TextStyle(
                        fontSize: UIUtils.tileTitle(screenType),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: UIUtils.gapSM(screenType)),
                    _buildProductSelector(l10n, screenType, theme),

                    SizedBox(height: UIUtils.gapXL(screenType)),

                    // Budget Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n?.budget ?? 'Budget',
                          style: TextStyle(
                            fontSize: UIUtils.tileTitle(screenType),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Toggle: Slider / Manual
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(
                              UIUtils.radiusSM(screenType),
                            ),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildToggleOption(
                                label: l10n?.slider ?? 'Slider',
                                isSelected: _useSlider,
                                onTap: () {
                                  setState(() {
                                    _useSlider = true;
                                    if (_sliderValue == 0) {
                                      _sliderValue = config.minBudget;
                                    }
                                  });
                                },
                                screenType: screenType,
                              ),
                              _buildToggleOption(
                                label: l10n?.manual ?? 'Manual',
                                isSelected: !_useSlider,
                                onTap: () {
                                  setState(() {
                                    _useSlider = false;
                                    if (_sliderValue > 0) {
                                      _budgetController.text =
                                          _sliderValue.toStringAsFixed(0);
                                    }
                                  });
                                },
                                screenType: screenType,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: UIUtils.gapXS(screenType)),
                    Text(
                      '${l10n?.minBudget ?? "Min"}: ${HiveStorage.currencySymbol}${config.minBudget.toStringAsFixed(0)} | ${l10n?.maxBudget ?? "Max"}: ${HiveStorage.currencySymbol}${config.maxBudget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: UIUtils.caption(screenType),
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: UIUtils.gapSM(screenType)),

                    // Slider Mode
                    if (_useSlider) ...[
                      // Budget display
                      Center(
                        child: Text(
                          '${HiveStorage.currencySymbol}${_sliderValue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: UIUtils.pageTitle(screenType) * 1.3,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: UIUtils.gapSM(screenType)),
                      Slider(
                        value: _sliderValue.clamp(
                          config.minBudget,
                          config.maxBudget,
                        ),
                        min: config.minBudget,
                        max: config.maxBudget,
                        activeColor: AppColors.primaryColor,
                        inactiveColor:
                            AppColors.primaryColor.withValues(alpha: 0.2),
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = value;
                          });
                        },
                      ),
                      // Min/Max labels under slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${HiveStorage.currencySymbol}${config.minBudget.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: UIUtils.caption(screenType),
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${HiveStorage.currencySymbol}${config.maxBudget.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: UIUtils.caption(screenType),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Manual Mode
                    if (!_useSlider)
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText:
                              l10n?.enterBudget ?? 'Enter budget amount',
                          prefixText: '${HiveStorage.currencySymbol} ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              UIUtils.radiusMD(screenType),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_useSlider) return null;
                          if (value == null || value.isEmpty) {
                            return l10n?.budgetRequired ??
                                'Budget is required';
                          }
                          final budget = double.tryParse(value);
                          if (budget == null) {
                            return l10n?.enterValidAmount ??
                                'Enter a valid amount';
                          }
                          if (budget < config.minBudget) {
                            return '${l10n?.minimumBudgetIs ?? "Minimum budget is"} ${HiveStorage.currencySymbol}${config.minBudget.toStringAsFixed(0)}';
                          }
                          if (budget > config.maxBudget) {
                            return '${l10n?.maximumBudgetIs ?? "Maximum budget is"} ${HiveStorage.currencySymbol}${config.maxBudget.toStringAsFixed(0)}';
                          }
                          return null;
                        },
                      ),

                    SizedBox(height: UIUtils.gapXL(screenType)),

                    // Wallet Balance Warning
                    BlocBuilder<CampaignWalletBloc, CampaignWalletState>(
                      builder: (context, walletState) {
                        final balance = double.tryParse(
                                walletState.walletData?.balance ?? '0') ??
                            0;
                        if (balance <= 0) {
                          return Container(
                            padding: EdgeInsets.all(UIUtils.gapMD(screenType)),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                UIUtils.radiusMD(screenType),
                              ),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange),
                                SizedBox(width: UIUtils.gapSM(screenType)),
                                Expanded(
                                  child: Text(
                                    l10n?.insufficientAdWalletBalance ??
                                        'Insufficient ad wallet balance. Please top up your campaign wallet first.',
                                    style: TextStyle(
                                      fontSize: UIUtils.caption(screenType),
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: UIUtils.gapXL(screenType)),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.submitStatus ==
                                CampaignSubmitStatus.submitting
                            ? null
                            : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: UIUtils.gapMD(screenType),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              UIUtils.radiusMD(screenType),
                            ),
                          ),
                        ),
                        child: state.submitStatus ==
                                CampaignSubmitStatus.submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n?.submitForApproval ?? 'Submit for Approval',
                                style: TextStyle(
                                  fontSize: UIUtils.tileTitle(screenType),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    dynamic config,
    AppLocalizations? l10n,
    ScreenType screenType,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(UIUtils.gapMD(screenType)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UIUtils.radiusMD(screenType)),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: UIUtils.gapSM(screenType)),
              Text(
                l10n?.campaignInfo ?? 'Campaign Info',
                style: TextStyle(
                  fontSize: UIUtils.tileTitle(screenType),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: UIUtils.gapSM(screenType)),
          Text(
            '${l10n?.cpcRate ?? "Cost per click"}: ${HiveStorage.currencySymbol}${config.cpcRate}',
            style: TextStyle(fontSize: UIUtils.body(screenType)),
          ),
          SizedBox(height: UIUtils.gapXS(screenType)),
          Text(
            l10n?.campaignPlacements ??
                'Your product will appear in search results and similar product listings.',
            style: TextStyle(
              fontSize: UIUtils.caption(screenType),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector(
    AppLocalizations? l10n,
    ScreenType screenType,
    ThemeData theme,
  ) {
    if (_selectedProductId != null) {
      return Container(
        padding: EdgeInsets.all(UIUtils.gapMD(screenType)),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(UIUtils.radiusMD(screenType)),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            if (_selectedProductImage != null &&
                _selectedProductImage!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(UIUtils.radiusSM(screenType)),
                child: Image.network(
                  _selectedProductImage!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            SizedBox(width: UIUtils.gapMD(screenType)),
            Expanded(
              child: Text(
                _selectedProductTitle ?? '',
                style: TextStyle(
                  fontSize: UIUtils.body(screenType),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: _selectProduct,
              icon: const Icon(Icons.edit, size: 20),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _selectProduct,
      borderRadius: BorderRadius.circular(UIUtils.radiusMD(screenType)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(UIUtils.gapLG(screenType)),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(UIUtils.radiusMD(screenType)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: UIUtils.gapSM(screenType)),
            Text(
              l10n?.tapToSelectProduct ?? 'Tap to select a product',
              style: TextStyle(
                fontSize: UIUtils.body(screenType),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectProduct() {
    context.pushNamed(
      AppRoutes.campaignProductSelect,
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _selectedProductId = result['id'] as int?;
          _selectedProductTitle = result['title'] as String?;
          _selectedProductImage = result['image'] as String?;
        });
      }
    });
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ScreenType screenType,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIUtils.gapMD(screenType),
          vertical: UIUtils.gapXS(screenType),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UIUtils.radiusSM(screenType)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: UIUtils.caption(screenType),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_selectedProductId == null) {
      showCustomSnackbar(
        context: context,
        message: AppLocalizations.of(context)?.pleaseSelectProduct ??
            'Please select a product',
        isWarning: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final double budget;
    if (_useSlider) {
      budget = _sliderValue;
    } else {
      final parsed = double.tryParse(_budgetController.text);
      if (parsed == null) return;
      budget = parsed;
    }

    // Check wallet balance
    final walletState = context.read<CampaignWalletBloc>().state;
    final balance =
        double.tryParse(walletState.walletData?.balance ?? '0') ?? 0;
    if (budget > balance) {
      showCustomSnackbar(
        context: context,
        message: AppLocalizations.of(context)?.insufficientAdWalletBalance ??
            'Insufficient ad wallet balance',
        isWarning: true,
      );
      return;
    }

    context.read<CreateCampaignBloc>().add(
          SubmitCampaign(productId: _selectedProductId!, budget: budget),
        );
  }
}
