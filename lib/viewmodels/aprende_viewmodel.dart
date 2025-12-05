import 'package:flutter_riverpod/flutter_riverpod.dart';

class AprendeUiState {
  final String titulo;
  final String tarjetaTitulo;
  final String tarjetaDescripcion;
  final String botonTexto;

  const AprendeUiState({
    this.titulo = "Sistemas de trabajo con conocimientos",
    this.tarjetaTitulo = "Aprende del tema",
    this.tarjetaDescripcion =
        "Explora los conceptos fundamentales del Modelo OSI para entender cómo se comunican las redes.",
    this.botonTexto = "Ver Modelo OSI",
  });
}

class AprendeViewModel extends StateNotifier<AprendeUiState> {
  AprendeViewModel() : super(const AprendeUiState());

  void onBotonOsiClicked() {
    print("Botón OSI clickeado. Lógica de negocio aquí.");
  }
}

final aprendeViewModelProvider =
    StateNotifierProvider<AprendeViewModel, AprendeUiState>((ref) {
      return AprendeViewModel();
    });
