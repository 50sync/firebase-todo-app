import 'package:go_router/go_router.dart';
import 'package:tasking/screens/auth/login.dart';
import 'package:tasking/screens/home/add_task.dart';
import 'package:tasking/screens/home/home.dart';
import 'package:tasking/screens/splash/splash_screen.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => Login()),
    GoRoute(path: '/home', builder: (context, state) => Home()),
    GoRoute(
      path: '/addTask',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return AddTask(todo: data?['todo']);
      },
    ),
  ],
);
