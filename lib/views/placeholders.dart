import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubjectListScreen extends ConsumerWidget {
  const SubjectListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Subject List"));
}

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Test Screen"));
}

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Grades Screen"));
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Settings Screen"));
}

class ModuleListScreen extends ConsumerWidget {
  final int subjectId;
  const ModuleListScreen({super.key, required this.subjectId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Center(child: Text("Module List $subjectId"));
}

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;
  const ModuleDetailScreen({super.key, required this.moduleId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Center(child: Text("Module Detail $moduleId"));
}

class QuizScreen extends ConsumerWidget {
  final int moduleId;
  final int attemptId;
  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.attemptId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Center(child: Text("Quiz $moduleId, Attempt $attemptId"));
}

class TestReviewScreen extends ConsumerWidget {
  final int attemptId;
  const TestReviewScreen({super.key, required this.attemptId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Center(child: Text("Review $attemptId"));
}

class ChatScreen extends ConsumerWidget {
  final int moduleId;
  const ChatScreen({super.key, required this.moduleId});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Center(child: Text("Chat $moduleId"));
}

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Backup/Restore"));
}

class LegalInfoScreen extends ConsumerWidget {
  const LegalInfoScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const Center(child: Text("Legal Info"));
}
