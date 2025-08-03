import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';
import '../widgets/time_entry_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectTaskManagementScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {

          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No time entries yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first entry',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }


          final entriesByProject = provider.entriesByProject;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.load();
            },
            child: ListView.builder(
              itemCount: entriesByProject.length,
              itemBuilder: (context, index) {
                final project = entriesByProject.keys.elementAt(index);
                final entries = entriesByProject[project]!;
                final totalMins = entries.fold<int>(0, (sum, e) => sum + e.minutes);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ExpansionTile(
                    key: ValueKey('${project.id}_${entries.length}_$totalMins'),
                    title: Text(
                      '${project.name} • ${_formatHours(totalMins)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${entries.length} entries'),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    children: entries.map((entry) {
                      return TimeEntryTile(
                        key: ValueKey(entry.id),
                        entry: entry,
                        onDelete: () => _deleteEntry(context, provider, entry.id),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTimeEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, TimeEntryProvider provider, String entryId) async {
    try {
      await provider.deleteEntry(entryId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatHours(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    } else {
      return '${m}m';
    }
  }
}
