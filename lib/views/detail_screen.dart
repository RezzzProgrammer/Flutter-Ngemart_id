import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/ui_feedback.dart';
import '../core/variant_options.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/app_network_image.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/selectable_pill.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _page = ValueNotifier<int>(0);
  late final List<String> _gallery;
  late final List<String> _sizes;

  int _colorIndex = 0;
  int _sizeIndex = 0;
  late int _quantity;
  bool _expanded = false;

  Product get _product => widget.product;
  int get _maxQuantity => math.min(CartProvider.maxPerOrder, _product.stock);

  @override
  void initState() {
    super.initState();
    final gallery = _product.gallery;
    _gallery = gallery.isEmpty ? const [''] : gallery;
    _sizes = VariantOptions.sizesFor(_product.category);
    _quantity = _maxQuantity > 0 ? 1 : 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page.dispose();
    super.dispose();
  }

  void _addToCart() {
    final result = context.read<CartProvider>().add(
          _product,
          color: VariantOptions.colors[_colorIndex].name,
          size: _sizes[_sizeIndex],
          quantity: _quantity,
        );
    showCartResult(context, _product, result);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final heroHeight =
        (MediaQuery.sizeOf(context).width * 0.95).clamp(320.0, 420.0).toDouble();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(heroHeight),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Formatters.price(product.price),
                        style: AppText.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.warning,
                        label: product.rating.toStringAsFixed(1),
                      ),
                      if (product.brand.isNotEmpty)
                        _InfoChip(label: product.brand),
                      _InfoChip(label: Formatters.categoryLabel(product.category)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _StockIndicator(stock: product.stock),
                  const SizedBox(height: 24),
                  Text('Warna', style: AppText.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < VariantOptions.colors.length; i++)
                        SelectablePill(
                          label: VariantOptions.colors[i].name,
                          selected: i == _colorIndex,
                          leading: _Swatch(color: VariantOptions.colors[i].color),
                          onTap: () => setState(() => _colorIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Ukuran', style: AppText.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < _sizes.length; i++)
                        SelectablePill(
                          label: _sizes[i],
                          selected: i == _sizeIndex,
                          onTap: () => setState(() => _sizeIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  QuantityStepper(
                    value: _quantity,
                    max: _maxQuantity,
                    perOrderLimit: CartProvider.maxPerOrder,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                  const SizedBox(height: 24),
                  _buildOverview(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PurchaseDock(
        total: product.price * _quantity,
        enabled: !product.isOutOfStock && _quantity > 0,
        onAdd: _addToCart,
      ),
    );
  }

  Widget _buildHero(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.pastelPedestal,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.banner),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _gallery.length,
            onPageChanged: (index) => _page.value = index,
            itemBuilder: (_, index) {
              final image = AppNetworkImage(
                url: _gallery[index],
                memCacheWidth: 900,
              );
              return Padding(
                padding: const EdgeInsets.fromLTRB(32, 76, 32, 52),
                // Only the first image shares the Hero tag with the grid card.
                child: index == 0
                    ? Hero(tag: 'product-${_product.id}', child: image)
                    : image,
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleIconButton(
                      tooltip: 'Kembali',
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Selector<WishlistProvider, bool>(
                      selector: (_, wishlist) => wishlist.contains(_product.id),
                      builder: (context, isFavorite, _) => CircleIconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari wishlist'
                            : 'Tambah ke wishlist',
                        active: isFavorite,
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: () =>
                            context.read<WishlistProvider>().toggle(_product),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_gallery.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: ValueListenableBuilder<int>(
                valueListenable: _page,
                builder: (_, current, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _gallery.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == current ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == current
                              ? AppColors.primaryInk
                              : AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final description = _product.description;
    final canExpand = description.length > 110;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.slab),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan produk', style: AppText.titleMedium),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Text(
              description.isEmpty ? 'Belum ada deskripsi.' : description,
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: AppText.bodyMedium,
            ),
          ),
          if (canExpand) ...[
            const SizedBox(height: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _expanded ? 'Tutup' : 'Baca selengkapnya',
                  style: AppText.labelMedium.copyWith(fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.icon, this.iconColor});

  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.pastelOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? AppColors.primaryInk),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppText.labelMedium),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final (Color color, String text) = switch (stock) {
      <= 0 => (AppColors.errorRed, 'Stok habis'),
      <= 10 => (AppColors.warning, 'Tersisa $stock — segera habis'),
      _ => (AppColors.success, 'Stok tersedia ($stock)'),
    };

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppText.labelMedium.copyWith(color: color)),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceWhite, width: 1.5),
        boxShadow: AppShadows.soft,
      ),
    );
  }
}

class _PurchaseDock extends StatelessWidget {
  const _PurchaseDock({
    required this.total,
    required this.enabled,
    required this.onAdd,
  });

  final double total;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppShadows.lifted,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: AppText.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
                Text(Formatters.price(total), style: AppText.headlineMedium),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FilledButton.icon(
                onPressed: enabled ? onAdd : null,
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: Text(
                  enabled ? 'Tambah ke Keranjang' : 'Stok habis',
                  style: AppText.titleMedium.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryInk,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textSecondary,
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
