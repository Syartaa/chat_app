import 'package:chat_app/pagess/home_page.dart';
import 'package:chat_app/pagess/login_page.dart';
import 'package:chat_app/pagess/register_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    '/login': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/home': (context) => HomePage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }
}
