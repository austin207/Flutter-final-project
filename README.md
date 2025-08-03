# Time Tracker Flutter App

A simple, offline-first time tracking application built with Flutter. Track time spent on different projects and tasks with local data persistence.

## Features

- ⏱️ **Track Time**: Log time entries for specific projects and tasks
- 📱 **Offline Storage**: All data saved locally using localStorage
- 📊 **Project Grouping**: View time entries organized by projects
- ✏️ **Task Management**: Create and manage projects and tasks
- 🗑️ **Data Management**: Delete entries, projects, and tasks
- 📝 **Notes Support**: Add notes to time entries
- 🔄 **Real-time Updates**: Instant UI updates with Provider state management

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Git

### Setup
```bash
# Clone the repository
git clone https://github.com/austin207/Flutter-final-project.git

# Navigate to project directory
cd Flutter-final-project

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  localstorage: ^5.0.0
  intl: ^0.19.0
  collection: ^1.18.0
  uuid: ^4.4.0
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── project.dart
│   ├── task.dart
│   └── time_entry.dart
├── providers/                   # State management
│   └── time_entry_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── add_time_entry_screen.dart
│   └── project_task_management_screen.dart
└── widgets/                     # Reusable widgets
    ├── time_entry_tile.dart
    └── project_task_dialog.dart
```

## Usage

1. **Add Projects**: Go to Settings → Add new projects
2. **Add Tasks**: Create tasks under specific projects
3. **Log Time**: Tap the + button to add time entries
4. **View Summary**: See time grouped by projects on the home screen
5. **Manage Data**: Edit or delete entries as needed

## Key Features Implemented

- **Local Data Persistence**: Uses localStorage for offline functionality
- **State Management**: Provider pattern for reactive UI updates
- **Form Validation**: Input validation for all user entries
- **Error Handling**: Graceful error handling throughout the app
- **Material Design**: Clean, intuitive UI following Material Design guidelines

## Development

Built as part of a Flutter development learning project, implementing:
- CRUD operations
- Local storage integration
- Provider state management
- Form handling and validation
- Material Design components

## License

This project is open source and available under the [MIT License](LICENSE).

**Created with Flutter 💙**

[1] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/64077789/6490d9b0-2e02-418f-b889-7cd3c1076c2a/image.jpg
[2] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/64077789/5cf791d1-1c49-48a3-8a15-bfca832992b2/image.jpg