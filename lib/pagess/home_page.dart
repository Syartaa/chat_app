import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pagess/chat_page.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/chat_tie.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _authService = _getIt<AuthService>();
    _navigationService = _getIt<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();

    // Check authentication state
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not signed in, navigate to the login screen
      _navigationService.pushReplacementNamed('/login');
    } else {
      try {
        // Reload the user to ensure they're still valid
        await user.reload();
        if (FirebaseAuth.instance.currentUser == null) {
          // User is no longer valid, log them out
          _authService.logout();
          _navigationService.pushReplacementNamed('/login');
        }
      } catch (e) {
        // If an error occurs (e.g., user is deleted), log them out
        _authService.logout();
        _navigationService.pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _navigationService.pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buldUI(),
    );
  }

  Widget _buldUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load data"),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ChatTie(
                        userProfile: user,
                        onTap: () async {
                          final chatExists =
                              await _databaseService.checkChatExists(
                                  _authService.user!.uid, user.uid!);
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                                _authService.user!.uid, user.uid!);
                          }
                          _navigationService
                              .push(MaterialPageRoute(builder: (context) {
                            return ChatPage(chatUser: user);
                          }));
                        }),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
