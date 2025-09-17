import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_bloc.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_event.dart';
import 'package:mobile/features/prescriptions/presentation/widgets/prescription_item.dart';
import 'package:mobile/features/prescriptions/presentation/widgets/prescription_filter_chip.dart';

import '../../../../generated/l10n.dart';
import '../../domain/entities/prescription.dart';
import '../bloc/prescription_state.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({Key? key}) : super(key: key);

  @override
  _PrescriptionsScreenState createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  String _selectedFilter = 'all';
  final _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PrescriptionBloc>().add(LoadPrescriptions());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200) {
      if (!_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onRefresh() {
    context.read<PrescriptionBloc>().add(LoadPrescriptions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prescriptions_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: BlocConsumer<PrescriptionBloc, PrescriptionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state is PrescriptionLoading && state.prescriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final prescriptions = _filterPrescriptions(
            state.prescriptions,
            _selectedFilter,
          );

          return RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildHeader(theme, l10n, state, context),
                if (prescriptions.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PrescriptionItem(
                        prescription: prescriptions[index],
                        onStatusChanged: (isCompleted) {
                          context.read<PrescriptionBloc>().add(
                            UpdatePrescriptionStatus(
                              fieldId: prescriptions[index].fieldId,
                              prescriptionId: prescriptions[index].id,
                              isCompleted: isCompleted,
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirmation(
                            context,
                            () => context.read<PrescriptionBloc>().add(
                              DeletePrescription(prescriptions[index].id),
                            ),
                            l10n,
                          );
                        },
                      ),
                      childCount: prescriptions.length,
                    ),
                  )
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        _getEmptyStateMessage(_selectedFilter, l10n),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          _showScrollToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              )
              : null,
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    S l10n,
    PrescriptionState state,
    BuildContext context,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.prescriptions_title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  PrescriptionFilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
                    onSelected: () => _onFilterChanged('all'),
                  ),
                  const SizedBox(width: 8),
                  PrescriptionFilterChip(
                    label: 'Active',
                    isSelected: _selectedFilter == 'active',
                    onSelected: () => _onFilterChanged('active'),
                  ),
                  const SizedBox(width: 8),
                  PrescriptionFilterChip(
                    label: 'Completed',
                    isSelected: _selectedFilter == 'completed',
                    onSelected: () => _onFilterChanged('completed'),
                  ),
                ],
              ),
            ),
            if (state.hasNewPrescriptions) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'New prescriptions available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<PrescriptionBloc>().add(
                          CheckForNewPrescriptions(),
                        );
                      },
                      child: Text('View'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Prescription> _filterPrescriptions(
    List<Prescription> prescriptions,
    String filter,
  ) {
    switch (filter) {
      case 'active':
        return prescriptions.where((p) => !p.isCompleted).toList();
      case 'completed':
        return prescriptions.where((p) => p.isCompleted).toList();
      case 'all':
      default:
        return prescriptions;
    }
  }

  String _getEmptyStateMessage(String filter, S l10n) {
    switch (filter) {
      case 'active':
        return 'No active prescriptions found';
      case 'completed':
        return 'No completed prescriptions found';
      case 'all':
      default:
        return 'No prescriptions found';
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
    S l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete prescription?'),
            content: Text('Are you sure you want to delete this prescription?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      onConfirm();
    }
  }
}
