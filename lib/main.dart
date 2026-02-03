import 'package:emu_infodam/features/auth/auth_controller.dart';
import 'package:emu_infodam/features/auth/auth_repository.dart';
import 'package:emu_infodam/ui/auth_screen.dart';
import 'package:emu_infodam/ui/create_article_screen.dart';
import 'package:emu_infodam/ui/home_screen.dart';
import 'package:emu_infodam/utility/firebase_tools/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utility/error_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  void _getData(User data) async {
    final person = await ref.read(authRepositoryProvider).getPersonData(data.uid).first;
    ref.read(personProvider.notifier).update((state) => person);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Information Dam",
      //TODO color choice
      // theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: ref.watch(colorChangerProvider).goodColor), useMaterial3: false),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: false),
    
      home: ref
          .watch(authStateChangeProvider)
          .when(
            data: (data) {
              if (data != null) {
                _getData(data);
                return const HomePage();
              }

              return const AuthScreen();
            },
            error: (error, stackTrace) => ErrorPage(error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
