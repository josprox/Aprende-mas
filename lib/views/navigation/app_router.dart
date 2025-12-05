import 'package:flutter/material.dart';
import 'package:aprende_mas/views/main_screen.dart';
import 'package:aprende_mas/views/subject_list_screen.dart';
import 'package:aprende_mas/views/module_list_screen.dart';
import 'package:aprende_mas/views/module_detail_screen.dart';
import 'package:aprende_mas/views/quiz_screen.dart';
import 'package:aprende_mas/views/chat_screen.dart';
import 'package:aprende_mas/views/test_list_screen.dart';
import 'package:aprende_mas/views/test_review_screen.dart';
import 'package:aprende_mas/views/grades_screen.dart';
import 'package:aprende_mas/views/settings/settings_screen.dart';
import 'package:aprende_mas/views/settings/backup_restore_screen.dart';
import 'package:aprende_mas/views/settings/legal_info_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String subjects = '/subjects';
  static const String modules = '/modules';
  static const String moduleDetail = '/module_detail';
  static const String quiz = '/quiz';
  static const String chat = '/chat';
  static const String tests = '/tests';
  static const String testReview = '/test_review';
  static const String grades = '/grades';
  static const String settings = '/settings';
  static const String backupRestore = '/backup_restore';
  static const String legalInfo = '/legal_info';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const MainScreen(),
    subjects: (context) => const SubjectListScreen(),
    tests: (context) => const TestListScreen(),
    grades: (context) => const GradesScreen(),
    settings: (context) => const SettingsScreen(),
    backupRestore: (context) => const BackupRestoreScreen(),
    legalInfo: (context) => const LegalInfoScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    // Handle routes with arguments
    if (uri.path == modules) {
      final args = settings.arguments as int?;
      if (args != null) {
        return MaterialPageRoute(
          builder: (context) => ModuleListScreen(subjectId: args),
        );
      }
    }

    if (uri.path == moduleDetail) {
      final args = settings.arguments as int?;
      if (args != null) {
        return MaterialPageRoute(
          builder: (context) => ModuleDetailScreen(moduleId: args),
        );
      }
    }

    if (uri.path == chat) {
      final args = settings.arguments as int?;
      if (args != null) {
        return MaterialPageRoute(
          builder: (context) => ChatScreen(moduleId: args),
        );
      }
    }

    if (uri.path == quiz) {
      // Expecting arguments as a Map or custom object
      // Or parsing from query parameters if we stick to string based nav internally,
      // but better to use arguments object.
      // Let's support both for flexibility during migration.

      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => QuizScreen(
            moduleId: args['moduleId'] as int,
            attemptId: args['attemptId'] as int? ?? 0,
          ),
        );
      }
    }

    if (uri.path == testReview) {
      final args = settings.arguments as int?; // attemptId
      if (args != null) {
        return MaterialPageRoute(
          builder: (context) => TestReviewScreen(
            attemptId: args.toDouble().toInt(),
          ), // Ensure int
        );
      }
    }

    // Fallback for defined routes
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(builder: routes[settings.name]!);
    }

    return null;
  }
}
