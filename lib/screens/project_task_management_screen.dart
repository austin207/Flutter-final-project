import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../widgets/project_task_dialog.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimeEntryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Projects & Tasks')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const ProjectTaskDialog(),
        ),
      ),
      body: ListView(
        children: provider.projects.map((p) {
          final tasks = provider.tasks.where((t) => t.projectId == p.id).toList();
          return ExpansionTile(
            title: Text(p.name),
            children: tasks.map((t) => ListTile(title: Text(t.name))).toList(),
          );
        }).toList(),
      ),
    );
  }
}
