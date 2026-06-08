import 'package:flutter/material.dart';

import 'package:aklatna/features/auth/presentation/widgets/auth_content.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_tabs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AuthTab _activeTab = AuthTab.signUp;

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
