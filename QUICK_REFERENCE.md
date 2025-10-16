# Quick Reference Guide - BLoC Notes App

## Common Operations

### Adding a New Event

1. Add event class in `lib/bloc/notes_event.dart`:
```dart
class MyNewEvent extends NotesEvent {
  final String data;
  const MyNewEvent(this.data);
  
  @override
  List<Object?> get props => [data];
}
```

2. Handle event in `lib/bloc/notes_bloc.dart`:
```dart
on<MyNewEvent>(_onMyNewEvent);

Future<void> _onMyNewEvent(
  MyNewEvent event,
  Emitter<NotesState> emit,
) async {
  // Your logic here
}
```

### Adding a New State

In `lib/bloc/notes_state.dart`:
```dart
class MyNewState extends NotesState {
  final String message;
  const MyNewState(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

### Triggering an Event from UI

```dart
context.read<NotesBloc>().add(
  const LoadNotes()
);
```

### Listening to State Changes

```dart
BlocBuilder<NotesBloc, NotesState>(
  builder: (context, state) {
    if (state is NotesLoading) {
      return CircularProgressIndicator();
    }
    if (state is NotesLoaded) {
      return ListView(...);
    }
    return SizedBox();
  },
)
```

### Reacting to State Changes

```dart
BlocListener<NotesBloc, NotesState>(
  listener: (context, state) {
    if (state is NotesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: MyWidget(),
)
```

### Using Both Builder and Listener

```dart
BlocConsumer<NotesBloc, NotesState>(
  listener: (context, state) {
    // Side effects (navigation, snackbars, etc)
  },
  builder: (context, state) {
    // Build UI based on state
  },
)
```

## Storage Operations

### Switch to Local Storage

```dart
context.read<NotesBloc>().add(
  const SwitchStorageType(StorageType.local)
);
```

### Switch to API Storage

```dart
context.read<NotesBloc>().add(
  const SwitchStorageType(StorageType.api)
);
```

### Get Current Storage Type

```dart
final state = context.read<NotesBloc>().state;
if (state is NotesLoaded) {
  StorageType type = state.storageType;
}
```

## CRUD Operations

### Create Note

```dart
final note = Note(
  title: 'My Title',
  body: 'My Content',
);

context.read<NotesBloc>().add(AddNote(note));
```

### Update Note

```dart
final updatedNote = existingNote.copyWith(
  title: 'New Title',
);

context.read<NotesBloc>().add(UpdateNote(updatedNote));
```

### Delete Note

```dart
context.read<NotesBloc>().add(
  DeleteNote(noteId)
);
```

### Delete Multiple Notes

```dart
final ids = [1, 2, 3, 4];
context.read<NotesBloc>().add(
  DeleteMultipleNotes(ids)
);
```

### Load/Refresh Notes

```dart
context.read<NotesBloc>().add(
  const LoadNotes()
);
```

## Adding a New Service

1. Create service file in `lib/services/`:
```dart
class MyNewService {
  Future<List<Note>> fetchNotes() async {
    // Implementation
  }
  
  Future<Note> createNote(Note note) async {
    // Implementation
  }
  
  // Other CRUD methods...
}
```

2. Add to repository enum:
```dart
enum StorageType { local, api, myNew }
```

3. Integrate in repository:
```dart
class NotesRepository {
  final MyNewService _myNewService;
  
  Future<List<Note>> fetchNotes() async {
    switch (_currentStorage) {
      case StorageType.local:
        return await _localService.fetchNotes();
      case StorageType.api:
        return await _apiService.fetchNotes();
      case StorageType.myNew:
        return await _myNewService.fetchNotes();
    }
  }
}
```

## Debugging

### Print Current State

```dart
print(context.read<NotesBloc>().state);
```

### BLoC Observer (Add to main.dart)

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}
```

## Testing

### Test BLoC

```dart
blocTest<NotesBloc, NotesState>(
  'emits [NotesLoading, NotesLoaded] when LoadNotes is added',
  build: () => NotesBloc(repository: mockRepository),
  act: (bloc) => bloc.add(const LoadNotes()),
  expect: () => [
    const NotesLoading(),
    NotesLoaded(notes: [], storageType: StorageType.local),
  ],
);
```

### Test Repository

```dart
test('fetchNotes returns notes from local service', () async {
  final repository = NotesRepository(
    storageType: StorageType.local,
  );
  
  final notes = await repository.fetchNotes();
  expect(notes, isA<List<Note>>());
});
```

## Common Patterns

### Navigation After Success

```dart
BlocListener<NotesBloc, NotesState>(
  listener: (context, state) {
    if (state is NotesOperationSuccess) {
      Navigator.pop(context);
    }
  },
  child: MyWidget(),
)
```

### Show Loading During Operation

```dart
BlocBuilder<NotesBloc, NotesState>(
  builder: (context, state) {
    final isLoading = state is NotesLoading;
    
    return Stack(
      children: [
        MyContent(),
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  },
)
```

### Form Validation

```dart
void _submit() {
  if (_formKey.currentState!.validate()) {
    final note = Note(
      title: _titleController.text,
      body: _bodyController.text,
    );
    context.read<NotesBloc>().add(AddNote(note));
  }
}
```

## Pro Tips

1. **Always use const constructors** for events and states when possible
2. **Extend Equatable** for automatic equality comparison
3. **Use BlocConsumer** when you need both building and listening
4. **Keep business logic in BLoC**, not in widgets
5. **Repository abstracts data sources**, BLoC shouldn't know about services
6. **Emit loading state** before async operations
7. **Handle errors gracefully** with try-catch and error states
8. **Use copyWith** instead of creating new objects manually
9. **Close text controllers** in dispose method
10. **Navigate in listeners**, not builders

## File Templates

### New Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Screen'),
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          // Handle state changes
        },
        builder: (context, state) {
          // Build UI
          return Container();
        },
      ),
    );
  }
}
```

## Useful Commands

```bash
# Hot reload
r

# Hot restart
R

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Build APK
flutter build apk

# Build release APK
flutter build apk --release

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

---

Happy Coding! 🚀
