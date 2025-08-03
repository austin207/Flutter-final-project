import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';

class ProjectTaskDialog extends StatefulWidget {
  const ProjectTaskDialog({super.key});

  @override
  State<ProjectTaskDialog> createState() => _ProjectTaskDialogState();
}

class _ProjectTaskDialogState extends State<ProjectTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  bool isProject = true;
  String? parentProjectId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimeEntryProvider>();

    return AlertDialog(
      title: const Text('Add Project / Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<bool>(
              value: true,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: true, child: Text('Project')),
                DropdownMenuItem(value: false, child: Text('Task')),
              ],
              onChanged: (v) => setState(() => isProject = v ?? true),
            ),
            if (!isProject)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Project'),
                items: provider.projects
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                    .toList(),
                onChanged: (v) => parentProjectId = v,
                validator: (v) {
                  if (!isProject && v == null) return 'Choose project';
                  return null;
                },
              ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (v) => name = v ?? '',
              validator: (v) =>
              v == null || v.isEmpty ? 'Name required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (isProject) {
                provider.addProject(name);
              } else {
                provider.addTask(parentProjectId!, name);
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
