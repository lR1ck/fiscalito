import 'package:flutter/material.dart';

/// Provider para manejar el estado de navegación del Bottom Navigation Bar
///
/// Controla qué pantalla está actualmente visible en el MainScreen
/// usando un índice (0-3 para las 4 pantallas principales).
class NavigationProvider extends ChangeNotifier {
  /// Índice actual de la pantalla seleccionada
  int _currentIndex = 0;

  /// Getter del índice actual
  int get currentIndex => _currentIndex;

  /// Cambia el índice actual y notifica a los listeners
  ///
  /// [index] - Nuevo índice (0: Inicio, 1: Chat, 2: Facturas, 3: Perfil)
  void setIndex(int index) {
    if (index >= 0 && index <= 3) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navega a la pantalla de inicio (Dashboard)
  void goToHome() => setIndex(0);

  /// Navega a la pantalla de chat
  void goToChat() => setIndex(1);

  /// Navega a la pantalla de facturas
  void goToFacturas() => setIndex(2);

  /// Navega a la pantalla de perfil
  void goToProfile() => setIndex(3);
}
