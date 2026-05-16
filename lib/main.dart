import 'package:coffee_shop_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
import 'repositories/base_auth_repository.dart';
import 'providers/language_provider.dart';
import 'providers/coffee_provider.dart';
import 'providers/profile_provider.dart';
import 'repositories/auth_repository.dart';
import 'blocs/auth_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  final authRepository = AuthRepository();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: RepositoryProvider<BaseAuthRepository>(
        create: (_) => authRepository,
        child: const CoffeeShopApp(),
      ),
    ),
  );
}

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CoffeeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()), // أضف هذا
      ],
      child: BlocProvider(
        create: (context) =>
            AuthCubit(authRepository: context.read<BaseAuthRepository>()),
        child: Consumer2<ThemeProvider, LanguageProvider>(
          // استخدم Consumer2
          builder: (context, themeProvider, languageProvider, child) {
            return MaterialApp(
              title: 'Coffee Shop',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.brown,
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Colors.black),
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.brown,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.grey[900],
                appBarTheme: AppBarTheme(
                  elevation: 0,
                  backgroundColor: Colors.grey[900],
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                cardColor: Colors.grey[800],
              ),
              themeMode: themeProvider.themeMode,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: languageProvider.locale,
              routes: {
                '/login': (_) => const LoginScreen(),
                '/signup': (_) => const SignUpScreen(),
              },
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
