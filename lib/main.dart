import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'repositories/product_repository.dart';
import 'services/api_service.dart';
import 'views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const NgemartApp());
}

class NgemartApp extends StatelessWidget {
  const NgemartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductRepository>(
          create: (_) => ProductRepository(ApiService()),
          dispose: (_, repository) => repository.dispose(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(context.read<ProductRepository>()),
        ),
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Ngemart.id',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
