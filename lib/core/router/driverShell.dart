import 'package:aklatna/features/orders/presentation/pages/driverHomePage.dart';
import 'package:aklatna/features/orders/presentation/pages/driverOrderPage.dart';
import 'package:aklatna/features/orders/presentation/pages/driverProfile.dart';
import 'package:flutter/material.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _index = 0;

  Widget _currentPage() {
    switch (_index) {
      case 0:
        return const DriverHomePage();
      case 1:
        return const DriverOrdersPage();
      default:
        return const DriverProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'المتاحة',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'توصيلاتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}