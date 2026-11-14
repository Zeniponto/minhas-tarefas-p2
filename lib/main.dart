import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/usuario.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final preferences = PreferencesService();
  await preferences.carregar();
  runApp(
    MinhasTarefasApp(
      preferences: preferences,
      auth: AuthService(),
      firebase: FirebaseService(),
    ),
  );
}

class MinhasTarefasApp extends StatefulWidget {
  const MinhasTarefasApp({
    super.key,
    required this.preferences,
    required this.auth,
    required this.firebase,
  });

  final PreferencesService preferences;
  final AuthService auth;
  final FirebaseService firebase;

  @override
  State<MinhasTarefasApp> createState() => _MinhasTarefasAppState();
}

class _MinhasTarefasAppState extends State<MinhasTarefasApp> {
  late final Stream<Usuario?> _usuario = widget.auth.usuario;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.preferences,
      builder: (context, child) => MaterialApp(
        title: 'Minhas Tarefas',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.preferences.themeMode,
        builder: (context, child) => AnnotatedRegion(
          value: Theme.of(context).appBarTheme.systemOverlayStyle!,
          child: child!,
        ),
        home: StreamBuilder<Usuario?>(
          stream: _usuario,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text('Não foi possível verificar a sessão.'),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final usuario = snapshot.data;
            if (usuario == null) return LoginScreen(auth: widget.auth);
            return HomeScreen(
              key: ValueKey(usuario.uid),
              usuario: usuario,
              auth: widget.auth,
              firebase: widget.firebase,
              preferences: widget.preferences,
            );
          },
        ),
      ),
    );
  }
}
