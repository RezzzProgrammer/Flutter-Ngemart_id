import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/ui_feedback.dart';
import '../core/variant_options.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'app_network_image.dart';
import 'circle_icon_button.dart';

/// Two-column grid delegate: fixed card height keeps the overlap layout stable.
const SliverGridDelegate kProductGridDelegate =
    SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 16,
  crossAxisSpacing: 14,
  mainAxisExtent: 270,
);

/// Pastel base plate + floating product image + overlapping white info slab.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  void _quickAdd(BuildContext context) {
    final result = context.read<CartProvider>().add(
          product,
          color: VariantOptions.colors.first.name,
          size: VariantOptions.sizesFor(product.category).first,
        );
    showCartResult(context, product, result);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: product.title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.pastelPedestal,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: _RatingBadge(rating: product.rating),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Selector<WishlistProvider, bool>(
                  selector: (_, wishlist) => wishlist.contains(product.id),
                  builder: (context, isFavorite, _) {
                    return CircleIconButton(
                      size: 40,
                      tooltip: isFavorite
                          ? 'Hapus dari wishlist'
                          : 'Tambah ke wishlist',
                      active: isFavorite,
                      icon: isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      onTap: () =>
                          context.read<WishlistProvider>().toggle(product),
                    );
                  },
                ),
              ),
              Positioned(
                top: 44,
                left: 8,
                right: 8,
                bottom: 78,
                child: Hero(
                  tag: 'product-${product.id}',
                  child: AppNetworkImage(url: product.thumbnail),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: _InfoSlab(
                  product: product,
                  onAdd: () => _quickAdd(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 3),
          Text(rating.toStringAsFixed(1), style: AppText.labelMedium),
        ],
      ),
    );
  }
}

class _InfoSlab extends StatelessWidget {
  const _InfoSlab({required this.product, required this.onAdd});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.slab),
        boxShadow: AppShadows.lifted,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.titleMedium.copyWith(
              fontSize: 14,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  Formatters.price(product.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Tambah ke keranjang',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAdd,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryInk,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
