import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize core background services
  try {
    await OfflineSyncService.instance.init();
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('[main] Service initialization error: $e');
  }

  runApp(const ShikshaSaathiApp());
}

class ShikshaSaathiApp extends StatelessWidget {
  const ShikshaSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final authBloc = AuthBloc(authRepo);

    return BlocProvider<AuthBloc>(
      create: (_) => authBloc,
      child: Builder(
        builder: (context) {
          final router = createRouter(authBloc);
          return MaterialApp.router(
            title: 'Shiksha Saathi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) {
              // Global error boundary
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
