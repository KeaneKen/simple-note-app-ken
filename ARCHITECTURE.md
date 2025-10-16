# Notes App with BLoC Architecture

A Flutter notes application implementing the BLoC (Business Logic Component) pattern with dual storage support (Local & API).

## Features

- ✅ **BLoC Architecture** - Clean separation of business logic and UI
- 📦 **Dual Storage** - Switch between Local Storage and API Storage
- 📝 **CRUD Operations** - Create, Read, Update, Delete notes
- 🔄 **State Management** - Proper state management using flutter_bloc
- 🗑️ **Bulk Delete** - Select and delete multiple notes
- 💾 **Offline Support** - Local storage using SharedPreferences
- 🌐 **API Integration** - HTTP API support for remote storage

## Architecture

This app follows the **BLoC Pattern** with a clean architecture structure:

```
lib/
├── bloc/
│   ├── notes_bloc.dart      # Business logic
│   ├── notes_event.dart     # Events
│   └── notes_state.dart     # States
├── models/
│   └── note.dart            # Note model
├── repository/
│   └── notes_repository.dart # Data abstraction layer
├── services/
│   ├── notes_api_service.dart   # HTTP API service
│   ├── notes_local_service.dart # Local storage service
│   └── notes_service.dart       # Service exports
├── screens/
│   ├── note_list_screen.dart    # Main list view
│   ├── note_detail_screen.dart  # Note details
│   ├── add_note_screen.dart     # Add new note
│   └── update_note_screen.dart  # Edit existing note
└── main.dart                # App entry point
```

### BLoC Pattern Components

#### Events (`notes_event.dart`)
- `LoadNotes` - Load all notes
- `AddNote` - Create a new note
- `UpdateNote` - Update existing note
- `DeleteNote` - Delete single note
- `DeleteMultipleNotes` - Delete multiple notes
- `SwitchStorageType` - Switch between local/API storage
- `ClearLocalNotes` - Clear all local notes

#### States (`notes_state.dart`)
- `NotesInitial` - Initial state
- `NotesLoading` - Loading state
- `NotesLoaded` - Notes loaded successfully
- `NotesOperationSuccess` - Operation completed successfully
- `NotesError` - Error occurred

#### BLoC (`notes_bloc.dart`)
Handles all business logic and state transitions based on events.

### Repository Pattern

The `NotesRepository` provides a single interface for data operations while abstracting the underlying storage mechanism:

```dart
NotesRepository(
  storageType: StorageType.local, // or StorageType.api
)
```

You can switch storage at runtime:
```dart
repository.switchStorage(StorageType.api);
```

### Services

#### Local Storage Service (`notes_local_service.dart`)
- Uses `SharedPreferences` for persistent local storage
- Auto-incrementing IDs
- JSON serialization
- No network required

#### API Service (`notes_api_service.dart`)
- HTTP REST API integration
- Endpoint: `http://localhost:8080`
- JSON communication
- Full CRUD support

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3    # State management
  equatable: ^2.0.5       # Value equality
  shared_preferences: ^2.2.2  # Local storage
  http: ^1.2.0            # API calls
```

## Usage

### Switching Storage

Tap the storage icon (📦 for local, ☁️ for API) in the app bar to switch between:
- **Local Storage** - Data stored on device
- **API Storage** - Data stored on remote server

### Creating Notes

1. Tap the ➕ button
2. Enter title and content
3. Tap "Add Note"

### Editing Notes

1. Tap on a note to view details
2. Tap the edit icon (✏️)
3. Modify and save

### Deleting Notes

**Single Delete:**
1. Open note details
2. Tap delete icon (🗑️)
3. Confirm deletion

**Bulk Delete:**
1. Tap "Select All" or long-press any note
2. Select notes to delete
3. Tap delete icon

## Running the App

### Prerequisites

1. Flutter SDK installed
2. Android Studio / Xcode (for mobile)
3. (Optional) Backend API running on `localhost:8080`

### Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk

# Build for iOS
flutter build ios
```

## API Endpoints

If using API storage, ensure your backend supports:

- `GET /notes` - Fetch all notes
- `POST /notes` - Create note
- `PATCH /notes/:id` - Update note
- `DELETE /notes/:id` - Delete note

**Expected JSON format:**
```json
{
  "ID": 1,
  "title": "Note Title",
  "body": "Note content"
}
```

## State Flow

```
User Action → Event → BLoC → Repository → Service → Data Source
                 ↓
            State Update
                 ↓
             UI Update
```

## Error Handling

- Network errors are caught and displayed as snackbars
- Loading states show progress indicators
- Failed operations can be retried
- Validation for empty titles

## Best Practices Implemented

✅ **Separation of Concerns** - UI, Business Logic, and Data layers are separate  
✅ **Single Responsibility** - Each class has one clear purpose  
✅ **Dependency Injection** - Repository injected into BLoC  
✅ **Immutability** - States and events are immutable  
✅ **Type Safety** - Strong typing throughout  
✅ **Error Handling** - Proper try-catch and error states  
✅ **Code Reusability** - Services can be swapped easily  

## License

MIT License

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
