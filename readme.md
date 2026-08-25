# Aprende Más

> Una aplicación móvil para organizar materias, estudiar contenidos y reforzar el aprendizaje con evaluaciones e inteligencia artificial.

## Descripción breve

**Aprende Más** es una plataforma educativa multiplataforma creada con Flutter. Nació para acompañar una sola materia y evolucionó a un espacio flexible donde cada persona puede instalar, crear y estudiar varias materias desde una misma aplicación.

## Descripción completa

Aprende Más reúne en una sola experiencia el material de estudio, la práctica y el seguimiento del progreso. Su contenido se organiza como un árbol ilimitado: una materia puede contener temas, subtemas y tantos niveles adicionales como hagan falta. Así, se adapta tanto a cursos breves como a programas completos de formación.

La aplicación guarda el contenido y el avance de forma local para que el estudio continúe aun sin conexión. También permite importar y actualizar materias en JSON, consultar tiendas de contenido —incluidas fuentes externas de la comunidad— y usar herramientas de IA para conversar sobre un módulo o generar cuestionarios a partir de su contenido.

El usuario puede configurar su propia llave y modelo de Groq desde Ajustes. Si no usa una llave personal, puede iniciar sesión y utilizar el servicio de IA disponible mediante Joss Red.

## La aplicación

### ¿Qué es?

Es una biblioteca personal de aprendizaje para dispositivos móviles. Cada materia tiene su propia estructura, material y evaluaciones, sin imponer un límite de profundidad al contenido.

### ¿Qué hace?

- Organiza múltiples materias en árboles de contenido ilimitados.
- Permite navegar entre temas, subtemas y módulos de estudio.
- Genera cuestionarios de opción múltiple y conserva los intentos realizados.
- Muestra calificaciones, resultados y revisión de respuestas.
- Incluye un chat de IA contextual para resolver dudas sobre el módulo actual.
- Permite importar, actualizar y respaldar materias mediante JSON.
- Descarga contenido desde Joss Red y desde tiendas externas configuradas por la comunidad.
- Funciona con datos locales para estudiar sin depender de una conexión permanente.
- Permite usar una API key y un modelo de Groq elegidos por el usuario.
- Ofrece temas claro y oscuro con interfaz basada en Material Design 3.

## Funciones principales

### Biblioteca multi-materia

La pantalla principal reúne todas las materias instaladas. Desde ahí se pueden abrir, importar, actualizar o eliminar, preservando cada estructura de contenido de forma independiente.

### Árbol de aprendizaje ilimitado

El contenido no está restringido a la antigua jerarquía de materia → módulo → tema. Cada nodo puede tener hijos, lo que permite representar programas, unidades, lecciones, apartados y niveles adicionales sin límites prácticos.

### IA para estudiar y evaluar

Dentro de un módulo se puede abrir el chat de IA o generar preguntas basadas en el contenido. La app consulta los modelos disponibles de Groq para que el usuario elija el que prefiera junto con su propia llave. Como alternativa, los usuarios autenticados pueden usar el servicio de IA de Joss Red.

### Evaluaciones y progreso

Los cuestionarios se almacenan localmente junto con los intentos, las respuestas y la retroalimentación. Esto permite retomar evaluaciones, revisar resultados y consultar el avance académico.

### Tiendas de contenido

Además del catálogo de Joss Red, se pueden añadir tiendas externas compatibles para descubrir e instalar materias compartidas por la comunidad.

### Datos locales, importación y respaldo

La información de estudio se guarda en SQLite. Las materias se pueden importar o actualizar desde archivos JSON y la base de datos puede respaldarse y restaurarse desde la aplicación.

## Stack tecnológico

| Área | Tecnología |
| --- | --- |
| Aplicación | [Flutter](https://flutter.dev/) y [Dart](https://dart.dev/) |
| Estado | [Riverpod](https://riverpod.dev/) |
| Datos locales | SQLite mediante `sqflite` |
| Red | [Dio](https://pub.dev/packages/dio) |
| IA | API compatible con Groq y servicio de Joss Red |
| Interfaz | Material Design 3, `google_fonts`, `dynamic_color` y `flutter_animate` |

## Configuración

La aplicación no incluye llaves privadas en el código. Crea un archivo `.env` local —no se versiona— si necesitas personalizar la conexión con Joss Red:

```env
# URL del servidor Joss Red. Si se omite, se usa https://joss.red/
JOSSRED=https://joss.red/

# Token opcional para las rutas públicas del repositorio.
JOSSRED_API=
```

La llave y el modelo personal de Groq se configuran desde la pantalla de Ajustes y permanecen en el dispositivo del usuario.

## Empezar a desarrollar

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible con Dart `^3.10.3`.
- Android Studio o VS Code con las extensiones de Flutter y Dart.
- Un emulador o dispositivo físico, si se ejecutará en móvil.

### Instalación

```bash
git clone https://github.com/josprox/Aprende-mas.git
cd aprende-mas
flutter pub get
flutter run
```

### Comprobaciones útiles

```bash
flutter analyze
flutter test
```

## Compilación y publicación

Para firmar una compilación Android, crea `android/key.properties` a partir del archivo de ejemplo y añade las credenciales de tu keystore. Este archivo no se sube al repositorio.

```bash
flutter build apk --release
# o
flutter build appbundle --release
```

La pantalla de carga se genera con `flutter_native_splash`. Si cambias el logo de `assets/img/logo.png`, ejecútalo de nuevo:

```bash
dart run flutter_native_splash:create
```

## Estructura del proyecto

```text
lib/
├── models/         # Entidades de materias, contenido, IA, importación y API
├── repositories/   # Acceso y sincronización de datos de estudio
├── services/       # Base local, red, IA, actualizaciones y tiendas
├── viewmodels/     # Estado y lógica de presentación con Riverpod
├── views/          # Pantallas de biblioteca, árbol, chat, quizzes y ajustes
├── widgets/        # Componentes visuales reutilizables
└── theme/          # Tema Material 3 de la aplicación
```

---

Desarrollado para hacer que el material de estudio crezca al ritmo de quien aprende.
