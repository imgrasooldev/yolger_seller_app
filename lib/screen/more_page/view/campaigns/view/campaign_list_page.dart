import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local_seller/config/colors.dart';
import 'package:hyper_local_seller/config/hive_storage.dart';
import 'package:hyper_local_seller/l10n/app_localizations.dart';
import 'package:hyper_local_seller/router/app_routes.dart';
import 'package:hyper_local_seller/utils/ui_utils.dart';
import 'package:hyper_local_seller/widgets/custom/card_shimmers.dart';
import 'package:hyper_local_seller/widgets/custom/custom_scaffold.dart';
import 'package:hyper_local_seller/utils/debouncer.dart';
import 'package:hyper_local_seller/widgets/custom/custom_snackbar.dart';
import 'package:hyper_local_seller/widgets/custom/custom_textfield.dart';
import '../bloc/campaign_list_bloc/campaign_list_bloc.dart';
import '../bloc/campaign_wallet_bloc/campaign_wallet_bloc.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_wallet_card.dart';

class CampaignListPage extends StatefulWidget {
  const CampaignListPage({super.key});

  @override
  State<CampaignListPage> createState() => _CampaignListPageState();
}

class _CampaignListPageState extends State<CampaignListPage> {
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  bool _isSearching = false;

  final List<String> _statusFilters = [
    'all',
    'draft',
    'pending_approval',
    'approved',
    'rejected',
    'running',
    'paused',
    'paused_by_admin',
    'completed',
    'force_stopped',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CampaignListBloc>().add(const LoadCampaignsInitial());
    context.read<CampaignWalletBloc>().add(FetchAdWallet());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CampaignListBloc>().add(LoadMoreCampaigns());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// Navigate to detail and refresh list when returning
  Future<void> _openDetail(int campaignId) async {
    final result = await context.pushNamed<bool>(
      AppRoutes.campaignDetail,
      pathParameters: {'id': campaignId.toString()},
    );
    // Refresh list if campaign was modified (paused/resumed)
    if (result == true && mounted) {
      context.read<CampaignListBloc>().add(RefreshCampaigns());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenType = context.screenType;

    return CustomScaffold(
      title: l10n?.myCampaigns ?? 'My Campaigns',
      showAppbar: true,
      centerTitle: true,
      appBarActions: [
        IconButton(
          onPressed: () async {
            if(HiveStorage.advertisementEnable){
              final result =
              await context.pushNamed<bool>(AppRoutes.createCampaign);

              log('Hello result  $result');
              if (result == true && context.mounted) {
                context.read<CampaignListBloc>().add(RefreshCampaigns());
                context.read<CampaignWalletBloc>().add(FetchAdWallet());
              }
            } else {
              showCustomSnackbar(
                context: context,
                message: 'This feature is currently unavailable',
                isWarning: true
              );
            }

          },
          icon: const Icon(Icons.add_circle_outline),
          tooltip: l10n?.createCampaign ?? 'Create Campaign',
        ),
        IconButton(
          onPressed: () {
            context.pushNamed(AppRoutes.campaignWallet);
          },
          icon: const Icon(Icons.account_balance_wallet_outlined),
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          context.read<CampaignListBloc>().add(RefreshCampaigns());
          context.read<CampaignWalletBloc>().add(FetchAdWallet());
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Wallet Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: UIUtils.pagePadding(screenType),
                child: const CampaignWalletCard(),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: UIUtils.pagePadding(screenType).left,
                ),
                child: _buildSearchBar(l10n, screenType),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: UIUtils.gapMD(screenType)),
            ),

            // Status Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: UIUtils.pagePadding(screenType).left,
                  ),
                  itemCount: _statusFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _statusFilters[index];
                    final isSelected =
                        (_selectedStatus == null && filter == 'all') ||
                            _selectedStatus == filter;
                    return _buildFilterChip(
                      filter,
                      isSelected,
                      l10n,
                      screenType,
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: UIUtils.gapMD(screenType)),
            ),

            // Campaign List
            BlocBuilder<CampaignListBloc, CampaignListState>(
              builder: (context, state) {
                // ─── Initial loading: shimmer placeholders ───
                if (state.isInitialLoading) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: UIUtils.pagePadding(screenType).left,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: UIUtils.gapMD(screenType),
                          ),
                          child: CardShimmer(
                            type: 'campaign',
                            screenType: screenType,
                          ),
                        ),
                        childCount: 4,
                      ),
                    ),
                  );
                }

                // ─── Error with no data ───
                if (state.error != null && state.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(l10n, screenType),
                  );
                }

                // ─── Empty state ───
                if (state.items.isEmpty) {
                  final hasActiveFilter = _selectedStatus != null ||
                      _searchController.text.isNotEmpty;
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: hasActiveFilter
                        ? _buildNoResultsState(l10n, screenType)
                        : _buildEmptyState(l10n, screenType),
                  );
                }

                // ─── Data loaded ───
                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: UIUtils.pagePadding(screenType).left,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.items.length) {
                          return state.isPaginating
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        final campaign = state.items[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: UIUtils.gapMD(screenType),
                          ),
                          child: CampaignCard(
                            campaign: campaign,
                            onTap: () => _openDetail(campaign.id),
                          ),
                        );
                      },
                      childCount:
                          state.items.length + (state.isPaginating ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations? l10n, ScreenType screenType) {
    return CustomTextField(
      controller: _searchController,
      hint: l10n?.searchCampaigns ?? 'Search campaigns...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _isSearching ? Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      ) : _searchController.text.isNotEmpty
          ? IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _searchController.clear();
          setState(() => _isSearching = false);
          context
              .read<CampaignListBloc>()
              .add(const SearchCampaigns(''));
        },
      ) : null,
      onChanged: (value) {
        setState(() => _isSearching = value.isNotEmpty);
        _debouncer.run(() {
          if (mounted) {
            setState(() => _isSearching = false);
          }
          context.read<CampaignListBloc>().add(SearchCampaigns(value));
        });
      },
    );
  }

  Widget _buildFilterChip(
    String filter,
    bool isSelected,
    AppLocalizations? l10n,
    ScreenType screenType,
  ) {
    return FilterChip(
      label: Text(_getStatusLabel(filter, l10n)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = filter == 'all' ? null : filter;
        });
        context.read<CampaignListBloc>().add(
              FilterCampaignsByStatus(filter == 'all' ? null : filter),
            );
      },
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        fontSize: UIUtils.caption(screenType),
        color: isSelected ? AppColors.primaryColor : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ─── Empty / Error states ──────────────────────────────────

  Widget _buildEmptyState(AppLocalizations? l10n, ScreenType screenType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIUtils.gapXL(screenType)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 72,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: UIUtils.gapMD(screenType)),
            Text(
              l10n?.noCampaignsYet ?? 'No campaigns yet',
              style: TextStyle(
                fontSize: UIUtils.tileTitle(screenType),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: UIUtils.gapSM(screenType)),
            Text(
              l10n?.createFirstCampaign ??
                  'Create your first campaign to promote your products and increase visibility.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIUtils.body(screenType),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: UIUtils.gapXL(screenType)),
            ElevatedButton.icon(
              onPressed: () async {
                final result =
                    await context.pushNamed<bool>(AppRoutes.createCampaign);
                if (result == true && mounted) {
                  context.read<CampaignListBloc>().add(RefreshCampaigns());
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                l10n?.createCampaign ?? 'Create Campaign',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: UIUtils.gapXL(screenType),
                  vertical: UIUtils.gapMD(screenType),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UIUtils.radiusMD(screenType)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(
      AppLocalizations? l10n, ScreenType screenType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIUtils.gapXL(screenType)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: UIUtils.gapMD(screenType)),
            Text(
              l10n?.noResultsFound ?? 'No results found',
              style: TextStyle(
                fontSize: UIUtils.tileTitle(screenType),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: UIUtils.gapSM(screenType)),
            Text(
              l10n?.tryDifferentFilter ??
                  'Try a different search term or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIUtils.body(screenType),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: UIUtils.gapLG(screenType)),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedStatus = null;
                  _isSearching = false;
                });
                context.read<CampaignListBloc>().add(const LoadCampaignsInitial());
                context.read<CampaignWalletBloc>().add(FetchAdWallet());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UIUtils.radiusMD(screenType)),
                ),
              ),
              child: Text(l10n?.clearFilters ?? 'Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations? l10n, ScreenType screenType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(UIUtils.gapXL(screenType)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: UIUtils.gapMD(screenType)),
            Text(
              l10n?.somethingWentWrong ?? 'Something went wrong',
              style: TextStyle(
                fontSize: UIUtils.tileTitle(screenType),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: UIUtils.gapSM(screenType)),
            Text(
              l10n?.pullToRetry ?? 'Pull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIUtils.body(screenType),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: UIUtils.gapLG(screenType)),
            OutlinedButton.icon(
              onPressed: () {
                context.read<CampaignListBloc>().add(const LoadCampaignsInitial());
                context.read<CampaignWalletBloc>().add(FetchAdWallet());
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.retry ?? 'Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(UIUtils.radiusMD(screenType)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status, AppLocalizations? l10n) {
    switch (status) {
      case 'all':
        return l10n?.all ?? 'All';
      case 'draft':
        return l10n?.draft ?? 'Draft';
      case 'pending_approval':
        return l10n?.pendingApproval ?? 'Pending';
      case 'approved':
        return l10n?.approved ?? 'Approved';
      case 'rejected':
        return l10n?.rejected ?? 'Rejected';
      case 'running':
        return l10n?.running ?? 'Running';
      case 'paused':
        return l10n?.paused ?? 'Paused';
      case 'paused_by_admin':
        return l10n?.pausedByAdmin ?? 'Paused by Admin';
      case 'completed':
        return l10n?.completed ?? 'Completed';
      case 'force_stopped':
        return l10n?.forceStopped ?? 'Force Stopped';
      default:
        return status;
    }
  }
}
