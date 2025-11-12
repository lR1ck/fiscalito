import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/navigation_provider.dart';
import 'home/dashboard_screen.dart';
import 'chat/chat_screen.dart';
import 'cfdi/cfdi_list_screen.dart';
import 'profile/profile_screen.dart';

/// Pantalla principal con Bottom Navigation Bar
///
/// Envuelve las 4 pantallas principales de la app y maneja
/// la navegación entre ellas usando Provider para state management.
///
/// Pantallas:
/// - 0: Dashboard (Inicio)
/// - 1: Chat con AI
/// - 2: Facturas (CFDI)
/// - 3: Perfil
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: const _MainScreenContent(),
    );
  }
}

class _MainScreenContent extends StatelessWidget {
  const _MainScreenContent();

  /// Lista de pantallas que se mostrarán en el Bottom Navigation
  static const List<Widget> _screens = [
    DashboardScreen(),
    ChatScreen(),
    CfdiListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          // Usar IndexedStack para mantener el estado de cada pantalla
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: _screens,
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.setIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Facturas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
