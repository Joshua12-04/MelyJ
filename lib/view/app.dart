import 'package:flutter/material.dart';
import 'home.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  static final GoRouter rutas = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: "/home",
        name: "home",
        builder: (context, state) => const Home(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "playBloc",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffe7dec9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffffc79c),
        ),
      ),
      routerConfig: rutas,
    );
  }
}