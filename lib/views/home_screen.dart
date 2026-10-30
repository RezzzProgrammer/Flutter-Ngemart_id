import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../repositories/product_repository.dart';
import '../widgets/cart_sheet.dart';
import '../widgets/circle_icon_button.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_skeleton.dart';
import '../widgets/promo_banner.dart';
import '../widgets/selectable_pill.dart';
import '../widgets/state_view.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _backToTopThreshold = 600;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);
  Timer? _debounce;
  bool _wishlistOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > _backToTopThreshold;
    if (show != _showBackToTop.value) _showBackToTop.value = show;
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(value));
  }

  void _search(String value) {
    if (!mounted) return;
    if (_wishlistOnly) setState(() => _wishlistOnly = false);
    context.read<ProductProvider>().search(value);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _search('');
  }

  void _selectCategory(String slug) {
    _debounce?.cancel();
    _searchController.clear();
    if (_wishlistOnly) setState(() => _wishlistOnly = false);
    context.read<ProductProvider>().selectCategory(slug);
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(AppRoutes.fade(DetailScreen(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (_, show, child) => AnimatedScale(
          scale: show ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
        child: FloatingActionButton.small(
          tooltip: 'Kembali ke atas',
          onPressed: _scrollToTop,
          backgroundColor: AppColors.primaryInk,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryInk,
          onRefresh: context.read<ProductProvider>().refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  wishlistOnly: _wishlistOnly,
                  onToggleWishlist: () =>
                      setState(() => _wishlistOnly = !_wishlistOnly),
                  onOpenCart: () => showCartSheet(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      _search(value);
                    },
                    onClear: _clearSearch,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: PromoBanner(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _CategoryRow(onSelected: _selectCategory),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(wishlistOnly: _wishlistOnly),
              ),
              _ProductSliver(
                wishlistOnly: _wishlistOnly,
                onOpen: _openDetail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.wishlistOnly,
    required this.onToggleWishlist,
    required this.onOpenCart,
  });

  final bool wishlistOnly;
  final VoidCallback onToggleWishlist;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.greeting(DateTime.now())} 👋',
                  style: AppText.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text('Mau belanja apa\nhari ini?', style: AppText.headlineXL),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Selector<WishlistProvider, int>(
            selector: (_, wishlist) => wishlist.count,
            builder: (_, count, __) => Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: CircleIconButton(
                tooltip: 'Tampilkan wishlist',
                active: wishlistOnly,
                icon: wishlistOnly ? Icons.favorite : Icons.favorite_border,
                onTap: onToggleWishlist,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Selector<CartProvider, int>(
            selector: (_, cart) => cart.totalQuantity,
            builder: (_, count, __) => Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: CircleIconButton(
                tooltip: 'Buka keranjang',
                icon: Icons.shopping_bag_outlined,
                onTap: onOpenCart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: AppText.titleMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.bodyText,
        ),
        decoration: InputDecoration(
          hintText: 'Cari produk…',
          hintStyle: AppText.bodyMedium,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryInk,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final slugs = <String>[kAllCategory, ...provider.categories];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        itemCount: slugs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final slug = slugs[index];
          return SelectablePill(
            label: slug == kAllCategory
                ? 'Semua'
                : Formatters.categoryLabel(slug),
            selected: slug == provider.selectedCategory,
            onTap: () => onSelected(slug),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.wishlistOnly});

  final bool wishlistOnly;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final String title;
    final String? trailing;

    if (wishlistOnly) {
      title = 'Wishlist kamu';
      trailing = '${context.watch<WishlistProvider>().count} produk';
    } else if (provider.query.isNotEmpty) {
      title = 'Hasil untuk "${provider.query}"';
      trailing =
          provider.status == LoadStatus.success ? '${provider.products.length} produk' : null;
    } else {
      title = provider.selectedCategory == kAllCategory
          ? 'Pilihan untuk kamu'
          : Formatters.categoryLabel(provider.selectedCategory);
      trailing =
          provider.status == LoadStatus.success ? '${provider.products.length} produk' : null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.headlineMedium,
            ),
          ),
          if (trailing != null) Text(trailing, style: AppText.bodyMedium),
        ],
      ),
    );
  }
}

class _ProductSliver extends StatelessWidget {
  const _ProductSliver({required this.wishlistOnly, required this.onOpen});

  final bool wishlistOnly;
  final ValueChanged<Product> onOpen;

  @override
  Widget build(BuildContext context) {
    if (wishlistOnly) {
      final items = context.watch<WishlistProvider>().items;
      if (items.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: StateView(
            icon: Icons.favorite_border,
            title: 'Wishlist masih kosong',
            message: 'Ketuk ikon hati pada produk untuk menyimpannya di sini.',
          ),
        );
      }
      return _grid(items);
    }

    final provider = context.watch<ProductProvider>();
    return switch (provider.status) {
      LoadStatus.idle || LoadStatus.loading => const ProductGridSkeleton(),
      LoadStatus.error => SliverFillRemaining(
          hasScrollBody: false,
          child: StateView(
            icon: Icons.wifi_off_rounded,
            title: 'Gagal memuat produk',
            message: provider.errorMessage ?? 'Terjadi kesalahan tak terduga.',
            actionLabel: 'Coba lagi',
            onAction: provider.retry,
          ),
        ),
      LoadStatus.empty => SliverFillRemaining(
          hasScrollBody: false,
          child: StateView(
            icon: Icons.search_off_rounded,
            title: 'Produk tidak ditemukan',
            message: provider.query.isEmpty
                ? 'Belum ada produk di kategori ini.'
                : 'Tidak ada hasil untuk "${provider.query}". Coba kata kunci lain.',
          ),
        ),
      LoadStatus.success => _grid(provider.products),
    };
  }

  Widget _grid(List<Product> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      sliver: SliverGrid(
        gridDelegate: kProductGridDelegate,
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final product = items[index];
            return ProductCard(
              key: ValueKey<int>(product.id),
              product: product,
              onTap: () => onOpen(product),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
