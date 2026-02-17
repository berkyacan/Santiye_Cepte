import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/supabase_service.dart';
import 'features/onboarding/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/jobs/presentation/providers/jobs_provider.dart';
import 'features/subscription/presentation/providers/subscription_provider.dart';
import 'features/notifications/notifications_provider.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/jobs/presentation/screens/job_feed_screen.dart';
import 'features/jobs/presentation/screens/my_jobs_screen.dart';
import 'features/bids/presentation/screens/bids_screen.dart';
import 'features/subscription/presentation/screens/subscription_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

/// Navigasyon öğesi için yardımcı sınıf
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem(this.icon, this.activeIcon, this.label);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.secondaryNavy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Ekran yönü kilidi
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Supabase'i başlat
  await SupabaseService.initialize();

  runApp(const SantiyeCepteApp());
}

/// Şantiye Cepte Ana Uygulama
class SantiyeCepteApp extends StatelessWidget {
  const SantiyeCepteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: MaterialApp(
        title: 'Şantiye Cepte',
        debugShowCheckedModeBanner: false,

        // Yerelleştirme
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],

        // Tema
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.lightTheme.textTheme),
        ),
        darkTheme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
        ),
        themeMode: ThemeMode.light,

        // Başlangıç ekranı
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Kimlik Doğrulama Wrapper'ı
/// Kullanıcının oturum durumuna göre yönlendirme yapar
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Oturum durumunu kontrol et
    await Future.delayed(const Duration(milliseconds: 500));

    final authProvider = context.read<AuthProvider>();
    await authProvider.checkCurrentUser();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          // TODO: Ana ekrana yönlendir
          return const MainScreen();
        } else {
          return const RoleSelectionScreen();
        }
      },
    );
  }
}

/// Splash Ekranı
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppShadows.orange,
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Uygulama Adı
            Text(
              'Şantiye Cepte',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'İnşaat Sektörü Pazaryeri',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray400),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              color: AppTheme.primaryOrange,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ana Ekran
/// Kullanıcı rolüne göre farklı arayüz gösterir
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProvider = context.read<NotificationsProvider>();
      if (!notifProvider.isInitialized) {
        notifProvider.loadNotifications().then((_) {
          // Eğer gerçek bildirim yoksa demo yükle
          if (notifProvider.notifications.isEmpty) {
            notifProvider.loadDemoNotifications();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole ?? UserRole.worker;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.construction_rounded, size: 24),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(userRole),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              userRole.turkishName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Bildirim butonu (okunmamış sayısı ile)
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, _) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, size: 26),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              notifProvider.unreadCount > 9
                                  ? '9+'
                                  : '${notifProvider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => _showNotifications(context),
              );
            },
          ),
          // Profil butonu
          GestureDetector(
            onTap: () => _showProfile(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  (authProvider.userName.isNotEmpty
                          ? authProvider.userName[0]
                          : 'U')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(userRole),
      bottomNavigationBar: _buildBottomNav(userRole),
    );
  }

  String _getTitle(UserRole role) {
    switch (role) {
      case UserRole.contractor:
        // Müteahhit: İş İlanlarım, Gelen Teklifler, Abonelik
        switch (_currentIndex) {
          case 0:
            return 'İş İlanlarım';
          case 1:
            return 'Gelen Teklifler';
          case 2:
            return 'Abonelik';
          default:
            return 'Şantiye Cepte';
        }
      case UserRole.subcontractor:
        // Taşeron: İş İlanları (Müteahhitten gelen), Usta Arama, Tekliflerim, Abonelik
        switch (_currentIndex) {
          case 0:
            return 'İş İlanları';
          case 1:
            return 'Usta Arama';
          case 2:
            return 'Tekliflerim';
          case 3:
            return 'Abonelik';
          default:
            return 'Şantiye Cepte';
        }
      case UserRole.worker:
        // Usta: İş İlanları (Taşerondan gelen usta arama talepleri), Başvurularım, Abonelik
        switch (_currentIndex) {
          case 0:
            return 'İş İlanları';
          case 1:
            return 'Başvurularım';
          case 2:
            return 'Abonelik';
          default:
            return 'Şantiye Cepte';
        }
    }
  }

  Widget _buildBody(UserRole role) {
    switch (role) {
      case UserRole.contractor:
        // Müteahhit Arayüzü: İş İlanlarım, Gelen Teklifler, Abonelik
        switch (_currentIndex) {
          case 0:
            return const MyJobsScreen();
          case 1:
            return const BidsScreen();
          case 2:
            return const SubscriptionScreen();
          default:
            return const SizedBox();
        }
      case UserRole.subcontractor:
        // Taşeron Arayüzü: İş İlanları (Müteahhit), Usta Arama (kendi ilanları), Tekliflerim, Abonelik
        switch (_currentIndex) {
          case 0:
            return const JobFeedScreen();
          case 1:
            return const MyJobsScreen(); // Taşeronun kendi usta arama ilanları
          case 2:
            return const BidsScreen();
          case 3:
            return const SubscriptionScreen();
          default:
            return const SizedBox();
        }
      case UserRole.worker:
        // Usta Arayüzü: İş İlanları (Taşerondan gelen), Başvurularım, Abonelik
        switch (_currentIndex) {
          case 0:
            return const JobFeedScreen(); // Taşeronların usta arama ilanları
          case 1:
            return const BidsScreen();
          case 2:
            return const SubscriptionScreen();
          default:
            return const SizedBox();
        }
    }
  }

  Widget _buildBottomNav(UserRole role) {
    List<_NavItem> navItems;

    switch (role) {
      case UserRole.contractor:
        // Müteahhit: 3 tab - Taşeron Bul kaldırıldı
        navItems = [
          _NavItem(Icons.work_outline, Icons.work, 'İlanlarım'),
          _NavItem(
            Icons.receipt_long_outlined,
            Icons.receipt_long,
            'Teklifler',
          ),
          _NavItem(
            Icons.card_membership_outlined,
            Icons.card_membership,
            'Abonelik',
          ),
        ];
        break;
      case UserRole.subcontractor:
        // Taşeron: 4 tab - Usta Bul yerine Usta Arama (iş ilanı yayınlama)
        navItems = [
          _NavItem(Icons.work_outline, Icons.work, 'İş İlanları'),
          _NavItem(
            Icons.person_search_outlined,
            Icons.person_search,
            'Usta Arama',
          ),
          _NavItem(
            Icons.receipt_long_outlined,
            Icons.receipt_long,
            'Tekliflerim',
          ),
          _NavItem(
            Icons.card_membership_outlined,
            Icons.card_membership,
            'Abonelik',
          ),
        ];
        break;
      case UserRole.worker:
        // Usta: 3 tab - Taşeron Bul yerine İş İlanları (taşeronun usta arama talepleri)
        navItems = [
          _NavItem(Icons.work_outline, Icons.work, 'İş İlanları'),
          _NavItem(
            Icons.receipt_long_outlined,
            Icons.receipt_long,
            'Başvurular',
          ),
          _NavItem(
            Icons.card_membership_outlined,
            Icons.card_membership,
            'Abonelik',
          ),
        ];
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              return _buildNavItem(
                index,
                navItems[index].icon,
                navItems[index].activeIcon,
                navItems[index].label,
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Profilim')),
          body: const ProfileScreen(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryOrange.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.gray500,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
