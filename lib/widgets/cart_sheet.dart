import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../providers/cart_provider.dart';
import 'app_network_image.dart';
import 'state_view.dart';

Future<void> showCartSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.canvasBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => const CartSheet(),
  );
}

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.pastelPedestal,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Keranjang', style: AppText.headlineMedium),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: cart.clear,
                      child: Text(
                        'Kosongkan',
                        style: AppText.labelMedium.copyWith(
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const StateView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Keranjang masih kosong',
                  message: 'Tambahkan produk favoritmu untuk mulai belanja.',
                )
              else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return _CartRow(
                        item: item,
                        onRemove: () => cart.remove(item.key),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal (${cart.totalQuantity} item)',
                      style: AppText.bodyMedium,
                    ),
                    Text(
                      Formatters.price(cart.subtotal),
                      style: AppText.headlineMedium,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.slab),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.pastelPedestal,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: AppNetworkImage(
              url: item.product.thumbnail,
              memCacheWidth: 160,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.titleMedium.copyWith(fontSize: 14),
                ),
                Text(
                  '${item.color} · ${item.size} · x${item.quantity}',
                  style: AppText.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.price(item.total),
                  style: AppText.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus',
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
