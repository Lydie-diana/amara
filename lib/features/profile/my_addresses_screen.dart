import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';
import '../../app/core/l10n/app_localizations.dart';
import '../../app/providers/address_provider.dart';
import '../../app/providers/address_suggestions_provider.dart';

class MyAddressesScreen extends ConsumerWidget {
  const MyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AmaraColors.bg,
      appBar: AppBar(
        backgroundColor: AmaraColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.addressesTitle,
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: addresses.isEmpty
          ? _buildEmpty(l10n)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return _AddressCard(
                  address: addr,
                  onSetDefault: () {
                    HapticFeedback.selectionClick();
                    ref.read(addressProvider.notifier).setDefault(addr.id);
                  },
                  onEdit: () => _showAddEditSheet(context, ref, editAddress: addr),
                  onDelete: () {
                    HapticFeedback.mediumImpact();
                    ref.read(addressProvider.notifier).remove(addr.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context, ref),
        backgroundColor: AmaraColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(l10n.addressesAdd,
            style:
                AmaraTextStyles.labelMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AmaraColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded,
                  color: AmaraColors.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(l10n.addressesEmpty,
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              l10n.addressesEmptySubtitle,
              style: AmaraTextStyles.bodyMedium
                  .copyWith(color: AmaraColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet ajout / modification ──────────────────────────────────

  void _showAddEditSheet(BuildContext context, WidgetRef ref, {SavedAddress? editAddress}) {
    final isEdit = editAddress != null;
    final suggestions = ref.read(addressSuggestionsProvider).valueOrNull ?? [];
    final l10n = AppLocalizations.of(context);

    final labelCtrl =
        TextEditingController(text: editAddress?.label ?? '');
    final addressCtrl =
        TextEditingController(text: editAddress?.address ?? '');
    final complementCtrl =
        TextEditingController(text: editAddress?.complement ?? '');

    List<Map<String, dynamic>> filtered = [];
    double? selectedLat = editAddress?.lat;
    double? selectedLng = editAddress?.lng;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void onSearch(String query) {
              if (query.length < 2) {
                setSheetState(() => filtered = []);
                return;
              }
              final q = query.toLowerCase();
              setSheetState(() {
                filtered = suggestions
                    .where((s) =>
                        (s['address'] as String).toLowerCase().contains(q))
                    .toList();
              });
            }

            return Container(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              decoration: const BoxDecoration(
                color: AmaraColors.bgCard,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AmaraColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      isEdit ? l10n.addressesEditTitle : l10n.addressesNewTitle,
                      style: AmaraTextStyles.h2
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),

                    // Nom de l'adresse
                    _buildSheetLabel(l10n.addressesLabelField),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: labelCtrl,
                      hint: l10n.addressesLabelHint,
                      icon: Icons.label_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Adresse avec autocomplétion
                    _buildSheetLabel(l10n.addressesAddressField),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: addressCtrl,
                      hint: l10n.addressesAddressHint,
                      icon: Icons.search_rounded,
                      onChanged: onSearch,
                    ),

                    // Suggestions d'autocomplétion
                    if (filtered.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: AmaraColors.bgAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AmaraColors.divider),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color:
                                AmaraColors.divider.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (_, i) {
                            final s = filtered[i];
                            return GestureDetector(
                              onTap: () {
                                addressCtrl.text =
                                    s['address'] as String;
                                selectedLat = (s['lat'] as num?)?.toDouble();
                                selectedLng = (s['lng'] as num?)?.toDouble();
                                setSheetState(() => filtered = []);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: AmaraColors.primary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        s['address'] as String,
                                        style: AmaraTextStyles.bodyMedium
                                            .copyWith(
                                                color: AmaraColors
                                                    .textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Infos complémentaires
                    _buildSheetLabel(l10n.addressesComplementField),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: complementCtrl,
                      hint: l10n.addressesComplementHint,
                      icon: Icons.info_outline_rounded,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Bouton sauvegarder
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (labelCtrl.text.isEmpty ||
                              addressCtrl.text.isEmpty) {
                            return;
                          }
                          final notifier = ref.read(addressProvider.notifier);
                          if (isEdit) {
                            notifier.update(
                              editAddress.id,
                              label: labelCtrl.text,
                              address: addressCtrl.text,
                              complement: complementCtrl.text,
                              lat: selectedLat,
                              lng: selectedLng,
                            );
                          } else {
                            notifier.add(SavedAddress(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              label: labelCtrl.text,
                              address: addressCtrl.text,
                              complement: complementCtrl.text,
                              lat: selectedLat,
                              lng: selectedLng,
                            ));
                          }
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? l10n.addressesModified
                                    : l10n.addressesAdded,
                                style: AmaraTextStyles.bodyMedium
                                    .copyWith(color: Colors.white),
                              ),
                              backgroundColor: AmaraColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AmaraColors.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          isEdit
                              ? l10n.addressesSaveChanges
                              : l10n.addressesAddAddress,
                          style: AmaraTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AmaraTextStyles.labelMedium.copyWith(
          color: AmaraColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSheetInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AmaraColors.bgAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AmaraColors.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: AmaraTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AmaraTextStyles.bodyMedium.copyWith(color: AmaraColors.muted),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
                bottom: maxLines > 1 ? 24 : 0),
            child: Icon(icon, color: AmaraColors.primary, size: 20),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Carte adresse ──────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final SavedAddress address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AmaraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault
              ? AmaraColors.primary.withValues(alpha: 0.3)
              : AmaraColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AmaraColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: address.isDefault
                      ? AmaraColors.primary.withValues(alpha: 0.1)
                      : AmaraColors.bgAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  address.icon,
                  color: address.isDefault
                      ? AmaraColors.primary
                      : AmaraColors.muted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: AmaraTextStyles.labelLarge
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AmaraColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.addressesDefault,
                              style: AmaraTextStyles.caption.copyWith(
                                color: AmaraColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.address,
                      style: AmaraTextStyles.bodyMedium
                          .copyWith(color: AmaraColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Menu actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AmaraColors.muted, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (val) {
                  if (val == 'default') onSetDefault();
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 18, color: AmaraColors.textPrimary),
                        const SizedBox(width: 8),
                        Text(l10n.addressesEdit),
                      ],
                    ),
                  ),
                  if (!address.isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.addressesSetDefault),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AmaraColors.error),
                        const SizedBox(width: 8),
                        Text(l10n.addressesDelete,
                            style: const TextStyle(color: AmaraColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Infos complémentaires
          if (address.complement.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AmaraColors.bgAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AmaraColors.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.complement,
                      style: AmaraTextStyles.bodySmall.copyWith(
                        color: AmaraColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
