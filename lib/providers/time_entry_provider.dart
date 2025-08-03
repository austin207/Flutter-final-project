import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';

class TimeEntryProvider extends ChangeNotifier {
  // Fix: localstorage v6.0.0 uses a global localStorage instance
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _entries = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters - Using UnmodifiableListView for better performance
  UnmodifiableListView<Project> get projects => UnmodifiableListView(_projects);
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  UnmodifiableListView<TimeEntry> get entries => UnmodifiableListView(_entries);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Get tasks for a specific project
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  // Get project by ID
  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Grouped by project for listviews
  Map<Project, List<TimeEntry>> get entriesByProject {
    if (_projects.isEmpty || _entries.isEmpty) {
      return <Project, List<TimeEntry>>{};
    }

    return groupBy<TimeEntry, Project>(_entries, (TimeEntry entry) {
      final project = getProjectById(entry.projectId);
      return project ?? Project(id: 'unknown', name: 'Unknown Project');
    });
  }

  // Get total time for a project (in minutes)
  int getTotalTimeForProject(String projectId) {
    return _entries
        .where((entry) => entry.projectId == projectId)
        .fold<int>(0, (sum, entry) => sum + entry.minutes);
  }

  // Initialize and load data - Fixed for localstorage v6.0.0
  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fix: localstorage v6.0.0 requires initLocalStorage() to be called first
      // This should be done in main.dart before runApp()
      _projects = _decodeList<Project>('projects', Project.fromJson);
      _tasks = _decodeList<Task>('tasks', Task.fromJson);
      _entries = _decodeList<TimeEntry>('entries', TimeEntry.fromJson);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Initialize with empty lists if loading fails
      _projects = <Project>[];
      _tasks = <Task>[];
      _entries = <TimeEntry>[];
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generic decode with better error handling - Fixed for v6.0.0
  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      // Fix: Use global localStorage instance from v6.0.0
      final raw = localStorage.getItem(key);
      if (raw == null || raw.isEmpty) return <T>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map<T>((item) => fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error decoding $key: $e');
      return <T>[];
    }
  }

  // Persist data - Fixed for v6.0.0
  void _persist() {
    try {
      // Fix: setItem is now synchronous in v6.0.0, returns void
      localStorage.setItem('projects', jsonEncode(_projects.map((p) => p.toJson()).toList()));
      localStorage.setItem('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
      localStorage.setItem('entries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error persisting data: $e');
      rethrow;
    }
  }

  // CRUD operations - Fixed to use synchronous _persist()
  Future<void> addProject(String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Project name cannot be empty');
    }

    // Check for duplicate names
    if (_projects.any((p) => p.name.toLowerCase() == name.trim().toLowerCase())) {
      throw ArgumentError('Project with this name already exists');
    }

    try {
      _projects.add(Project(id: _uuid.v4(), name: name.trim()));
      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding project: $e');
      rethrow;
    }
  }

  Future<void> addTask(String projectId, String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Task name cannot be empty');
    }

    if (getProjectById(projectId) == null) {
      throw ArgumentError('Project not found');
    }

    // Check for duplicate task names within the same project
    if (_tasks.any((t) =>
    t.projectId == projectId &&
        t.name.toLowerCase() == name.trim().toLowerCase())) {
      throw ArgumentError('Task with this name already exists in this project');
    }

    try {
      _tasks.add(Task(id: _uuid.v4(), projectId: projectId, name: name.trim()));
      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> addEntry({
    required String projectId,
    required String taskId,
    required int minutes,
    required DateTime date,
    required String notes,
  }) async {
    if (minutes <= 0) {
      throw ArgumentError('Minutes must be greater than 0');
    }

    if (getProjectById(projectId) == null) {
      throw ArgumentError('Project not found');
    }

    if (getTaskById(taskId) == null) {
      throw ArgumentError('Task not found');
    }

    try {
      _entries.add(TimeEntry(
        id: _uuid.v4(),
        projectId: projectId,
        taskId: taskId,
        minutes: minutes,
        date: date,
        notes: notes.trim(),
      ));
      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      final initialLength = _entries.length;
      _entries.removeWhere((e) => e.id == entryId);

      if (_entries.length == initialLength) {
        throw ArgumentError('Entry not found');
      }

      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      // Remove all tasks and entries associated with this project
      _tasks.removeWhere((t) => t.projectId == projectId);
      _entries.removeWhere((e) => e.projectId == projectId);
      _projects.removeWhere((p) => p.id == projectId);

      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // Remove all entries associated with this task
      _entries.removeWhere((e) => e.taskId == taskId);
      _tasks.removeWhere((t) => t.id == taskId);

      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // Update methods
  Future<void> updateProject(String projectId, String newName) async {
    if (newName.trim().isEmpty) {
      throw ArgumentError('Project name cannot be empty');
    }

    try {
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex == -1) {
        throw ArgumentError('Project not found');
      }

      _projects[projectIndex] = Project(id: projectId, name: newName.trim());
      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String taskId, String newName) async {
    if (newName.trim().isEmpty) {
      throw ArgumentError('Task name cannot be empty');
    }

    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) {
        throw ArgumentError('Task not found');
      }

      final task = _tasks[taskIndex];
      _tasks[taskIndex] = Task(
        id: taskId,
        projectId: task.projectId,
        name: newName.trim(),
      );

      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      _projects.clear();
      _tasks.clear();
      _entries.clear();

      _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }
}
