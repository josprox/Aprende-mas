# Aprende Más 📱🎓

**Aprende Más** es una aplicación móvil educativa moderna desarrollada en **Flutter (Dart)**, diseñada para ofrecer una experiencia de aprendizaje interactiva y eficiente. Esta versión marca la evolución completa del proyecto, migrando de una base nativa en Kotlin a un desarrollo multiplataforma robusto con Flutter.

## 🚀 Características Principales

*   **📚 Gestión de Materias y Módulos**: Navegación intuitiva a través de asignaturas y sus contenidos detallados.
*   **📝 Sistema de Evaluaciones**: 
    *   Toma de **Cuestionarios (Quizzes)** interactivos.
    *   Gestión de **Exámenes**.
    *   **Revisión de Intentos** y retroalimentación detallada.
*   **📊 Seguimiento de Progreso**: Visualización de calificaciones y rendimiento académico.
*   **💬 Asistente Inteligente**: Chat integrado para soporte y consultas de aprendizaje.
*   **💾 Funcionamiento Offline**: Persistencia de datos local robusta utilizando SQLite (Drift), permitiendo estudiar sin conexión constante.
*   **🎨 Interfaz Moderna**: Diseño limpio y adaptable con soporte para temas (Modo Oscuro/Claro), utilizando Material Design 3.

## 🛠️ Stack Tecnológico

El proyecto utiliza un conjunto de tecnologías modernas de Flutter para garantizar escalabilidad, mantenimiento y rendimiento:

*   **Lenguaje**: [Dart](https://dart.dev/)
*   **Framework**: [Flutter](https://flutter.dev/)
*   **Gestión de Estado**: [Riverpod](https://riverpod.dev/) (con `riverpod_generator` y `riverpod_annotation` para un código más limpio y seguro).
*   **Base de Datos Local**: [Drift](https://drift.simonbinder.eu/) (SQLite reactivo y seguro).
*   **Conectividad HTTP**: [Dio](https://pub.dev/packages/dio).
*   **Navegación**: Sistema de rutas nativo/GoRouter (según implementación).
*   **UI/UX**: `google_fonts`, `google_nav_bar`, `dynamic_color`.

## 🏁 Comenzando

Sigue estos pasos para ejecutar el proyecto en tu entorno local:

### Prerrequisitos
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
*   Un editor de código (VS Code o Android Studio) con las extensiones de Flutter/Dart.

### Instalación

1.  **Clonar el repositorio** (si aún no lo tienes):
    ```bash
    git clone <url-del-repositorio>
    cd aprende_mas_flutter
    ```

2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```

3.  **Generar código necesario** (Riverpod/Drift):
    Este proyecto utiliza generación de código. Ejecuta el siguiente comando para generar los archivos `.g.dart`:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
    *Para desarrollo continuo:* `dart run build_runner watch`

4.  **Ejecutar la App**:
    ```bash
    flutter run
    ```

## 📄 Estructura del Proyecto

*   `lib/models`: Modelos de datos y entidades de base de datos.
*   `lib/repositories`: Capa de acceso a datos (Patrón Repositorio).
*   `lib/services`: Lógica de negocio y servicios externos.
*   `lib/viewmodels`: Gestión de estado de la UI (Riverpod providers/notifiers).
*   `lib/views`: Pantallas y widgets de la interfaz de usuario.
*   `lib/widgets`: Componentes UI reutilizables.

## 🔄 Migración y Versiones

> **Nota Importante:** Esta versión representa una reescritura completa y optimización del proyecto original en Kotlin. Todo el código base ahora es **100% Dart**, aprovechando las capacidades multiplataforma de Flutter para iOS y Android desde una única base de código.

---
Desarrollado con ❤️ para el aprendizaje continuo.
