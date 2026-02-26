import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/core/constants/app_colors.dart';
import '../../app/core/constants/app_text_styles.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final List<_Address> _addresses = [
    _Address(
      label: 'Maison',
      icon: Icons.home_rounded,
      address: 'Cocody Riviera, Abidjan',
      complement: 'Résidence Les Palmiers, Apt 12',
      isDefault: true,
    ),
    _Address(
      label: 'Bureau',
      icon: Icons.work_rounded,
      address: 'Plateau, Abidjan',
      complement: '3ème étage, Immeuble CCIA',
      isDefault: false,
    ),
  ];

  // ── Liste d'adresses pour l'autocomplétion (Afrique) ──────────────────
  static const List<Map<String, dynamic>> _addressSuggestions = [
    // Cameroun — Douala
    {'address': 'Akwa, Douala', 'lat': 4.0510, 'lng': 9.7040},
    {'address': 'Bonanjo, Douala', 'lat': 4.0430, 'lng': 9.6940},
    {'address': 'Bonapriso, Douala', 'lat': 4.0200, 'lng': 9.6920},
    {'address': 'Deïdo, Douala', 'lat': 4.0600, 'lng': 9.7100},
    {'address': 'Bali, Douala', 'lat': 4.0350, 'lng': 9.6850},
    {'address': 'Makepe, Douala', 'lat': 4.0700, 'lng': 9.7350},
    {'address': 'Kotto, Douala', 'lat': 4.0650, 'lng': 9.7500},
    {'address': 'Logbessou, Douala', 'lat': 4.0800, 'lng': 9.7600},
    {'address': 'Ndokotti, Douala', 'lat': 4.0550, 'lng': 9.7250},
    {'address': 'New Bell, Douala', 'lat': 4.0380, 'lng': 9.7150},
    {'address': 'Bonabéri, Douala', 'lat': 4.0700, 'lng': 9.6700},
    {'address': 'Bessengue, Douala', 'lat': 4.0450, 'lng': 9.7200},
    // Cameroun — Yaoundé
    {'address': 'Centre Administratif, Yaoundé', 'lat': 3.8667, 'lng': 11.5167},
    {'address': 'Bastos, Yaoundé', 'lat': 3.8800, 'lng': 11.5100},
    {'address': 'Nlongkak, Yaoundé', 'lat': 3.8750, 'lng': 11.5200},
    {'address': 'Mvog-Mbi, Yaoundé', 'lat': 3.8550, 'lng': 11.5250},
    {'address': 'Tsinga, Yaoundé', 'lat': 3.8850, 'lng': 11.5050},
    {'address': 'Mvan, Yaoundé', 'lat': 3.8350, 'lng': 11.5100},
    {'address': 'Biyem-Assi, Yaoundé', 'lat': 3.8450, 'lng': 11.4850},
    {'address': 'Essos, Yaoundé', 'lat': 3.8700, 'lng': 11.5350},
    // Cameroun — Autres
    {'address': 'Centre, Bafoussam', 'lat': 5.4737, 'lng': 10.4176},
    {'address': 'Centre, Bamenda', 'lat': 5.9631, 'lng': 10.1591},
    {'address': 'Centre, Kribi', 'lat': 2.9400, 'lng': 9.9080},
    {'address': 'Centre, Limbé', 'lat': 4.0230, 'lng': 9.2150},
    // Côte d'Ivoire — Abidjan
    {'address': 'Cocody Riviera, Abidjan', 'lat': 5.3580, 'lng': -3.9710},
    {'address': 'Cocody Angré, Abidjan', 'lat': 5.3770, 'lng': -3.9870},
    {'address': 'Cocody 2 Plateaux, Abidjan', 'lat': 5.3510, 'lng': -3.9930},
    {'address': 'Plateau, Abidjan', 'lat': 5.3200, 'lng': -4.0150},
    {'address': 'Marcory, Abidjan', 'lat': 5.3050, 'lng': -3.9870},
    {'address': 'Treichville, Abidjan', 'lat': 5.3010, 'lng': -4.0060},
    {'address': 'Yopougon, Abidjan', 'lat': 5.3370, 'lng': -4.0660},
    {'address': 'Abobo, Abidjan', 'lat': 5.4180, 'lng': -4.0200},
    {'address': 'Koumassi, Abidjan', 'lat': 5.2950, 'lng': -3.9570},
    {'address': 'Adjamé, Abidjan', 'lat': 5.3580, 'lng': -4.0280},
    // Sénégal — Dakar
    {'address': 'Plateau, Dakar', 'lat': 14.6693, 'lng': -17.4380},
    {'address': 'Médina, Dakar', 'lat': 14.6720, 'lng': -17.4490},
    {'address': 'Almadies, Dakar', 'lat': 14.7350, 'lng': -17.5100},
    {'address': 'Mermoz, Dakar', 'lat': 14.7050, 'lng': -17.4780},
    {'address': 'Ouakam, Dakar', 'lat': 14.7250, 'lng': -17.4900},
    // Mali — Bamako
    {'address': 'Badalabougou, Bamako', 'lat': 12.6150, 'lng': -7.9900},
    {'address': 'Hamdallaye, Bamako', 'lat': 12.6250, 'lng': -8.0050},
    {'address': 'ACI 2000, Bamako', 'lat': 12.6100, 'lng': -8.0200},
    // Guinée — Conakry
    {'address': 'Kaloum, Conakry', 'lat': 9.5092, 'lng': -13.7122},
    {'address': 'Ratoma, Conakry', 'lat': 9.6250, 'lng': -13.6250},
    // Burkina Faso
    {'address': 'Ouaga 2000, Ouagadougou', 'lat': 12.3350, 'lng': -1.4850},
    {'address': 'Centre, Ouagadougou', 'lat': 12.3714, 'lng': -1.5197},
    // Bénin — Cotonou
    {'address': 'Cadjèhoun, Cotonou', 'lat': 6.3653, 'lng': 2.3924},
    {'address': 'Ganhi, Cotonou', 'lat': 6.3600, 'lng': 2.4250},
    // Togo — Lomé
    {'address': 'Tokoin, Lomé', 'lat': 6.1600, 'lng': 1.2150},
    {'address': 'Bè, Lomé', 'lat': 6.1400, 'lng': 1.2350},
    // Gabon — Libreville
    {'address': 'Centre-ville, Libreville', 'lat': 0.3924, 'lng': 9.4536},
    // Congo — Brazzaville
    {'address': 'Centre-ville, Brazzaville', 'lat': -4.2634, 'lng': 15.2429},
    // RD Congo — Kinshasa
    {'address': 'Gombe, Kinshasa', 'lat': -4.3050, 'lng': 15.3100},
    // Nigeria — Lagos
    {'address': 'Victoria Island, Lagos', 'lat': 6.4281, 'lng': 3.4219},
    {'address': 'Lekki, Lagos', 'lat': 6.4698, 'lng': 3.5852},
  ];

  @override
  Widget build(BuildContext context) {
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
          'Mes adresses',
          style: AmaraTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _addresses.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return _AddressCard(
                  address: addr,
                  onSetDefault: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      for (var a in _addresses) {
                        a.isDefault = false;
                      }
                      addr.isDefault = true;
                    });
                  },
                  onEdit: () => _showAddEditSheet(editIndex: index),
                  onDelete: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _addresses.removeAt(index));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AmaraColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Ajouter',
            style:
                AmaraTextStyles.labelMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────

  Widget _buildEmpty() {
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
            Text('Aucune adresse',
                style:
                    AmaraTextStyles.h2.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Ajoutez une adresse de livraison pour commander plus rapidement.',
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

  void _showAddEditSheet({int? editIndex}) {
    final isEdit = editIndex != null;
    final existing = isEdit ? _addresses[editIndex] : null;

    final labelCtrl =
        TextEditingController(text: existing?.label ?? '');
    final addressCtrl =
        TextEditingController(text: existing?.address ?? '');
    final complementCtrl =
        TextEditingController(text: existing?.complement ?? '');

    List<Map<String, dynamic>> filtered = [];

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
                filtered = _addressSuggestions
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
                      isEdit ? 'Modifier l\'adresse' : 'Nouvelle adresse',
                      style: AmaraTextStyles.h2
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),

                    // Nom de l'adresse
                    _buildSheetLabel('Nom de l\'adresse'),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: labelCtrl,
                      hint: 'Ex: Maison, Bureau, Chez Maman',
                      icon: Icons.label_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Adresse avec autocomplétion
                    _buildSheetLabel('Adresse'),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: addressCtrl,
                      hint: 'Rechercher une adresse...',
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
                    _buildSheetLabel('Infos complémentaires'),
                    const SizedBox(height: 8),
                    _buildSheetInput(
                      controller: complementCtrl,
                      hint:
                          'Bâtiment, étage, apt, code, instructions...',
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
                          setState(() {
                            if (isEdit) {
                              _addresses[editIndex].label =
                                  labelCtrl.text;
                              _addresses[editIndex].address =
                                  addressCtrl.text;
                              _addresses[editIndex].complement =
                                  complementCtrl.text;
                            } else {
                              _addresses.add(_Address(
                                label: labelCtrl.text,
                                icon: Icons.location_on_rounded,
                                address: addressCtrl.text,
                                complement: complementCtrl.text,
                                isDefault: _addresses.isEmpty,
                              ));
                            }
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? 'Adresse modifiée'
                                    : 'Adresse ajoutée',
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
                              ? 'Enregistrer les modifications'
                              : 'Ajouter l\'adresse',
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

// ─── Modèle adresse ─────────────────────────────────────────────────────────────

class _Address {
  String label;
  final IconData icon;
  String address;
  String complement;
  bool isDefault;

  _Address({
    required this.label,
    required this.icon,
    required this.address,
    this.complement = '',
    required this.isDefault,
  });
}

// ─── Carte adresse ──────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final _Address address;
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
                              'Par défaut',
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
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: AmaraColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          SizedBox(width: 8),
                          Text('Par défaut'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AmaraColors.error),
                        SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: AmaraColors.error)),
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
