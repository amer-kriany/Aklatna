import 'package:flutter/material.dart';

import 'package:aklatna/features/auth/presentation/widgets/auth_content.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_tabs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthTab _activeTab = AuthTab.signIn;

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      child: AuthContent(
        activeTab: _activeTab,
        onTabChanged: (tab) => setState(() => _activeTab = tab),
      ),
    );
  }
}
