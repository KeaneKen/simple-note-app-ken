# BLoC Architecture Diagram

## Overall Architecture Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ NoteList     │  │ NoteDetail   │  │ AddNote      │          │
│  │ Screen       │  │ Screen       │  │ Screen       │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                  │
│         └──────────────────┴──────────────────┘                  │
│                            │                                     │
│                    ┌───────▼────────┐                           │
│                    │  BlocConsumer  │                           │
│                    │  BlocBuilder   │                           │
│                    │  BlocListener  │                           │
│                    └───────┬────────┘                           │
└────────────────────────────┼──────────────────────────────────┘
                             │
                             │ Events/States
                             │
┌────────────────────────────▼──────────────────────────────────┐
│                      BUSINESS LOGIC LAYER                      │
│                                                                 │
│                    ┌─────────────────┐                         │
│                    │   NotesBloc     │                         │
│                    │                 │                         │
│                    │  Events:        │                         │
│                    │  • LoadNotes    │                         │
│                    │  • AddNote      │                         │
│    ┌───────────────┤  • UpdateNote   │───────────────┐        │
│    │               │  • DeleteNote   │               │        │
│    │               │  • Switch       │               │        │
│    │               │                 │               │        │
│    │               │  States:        │               │        │
│    │               │  • Initial      │               │        │
│    │               │  • Loading      │               │        │
│    │               │  • Loaded       │               │        │
│    │               │  • Error        │               │        │
│    │               └────────┬────────┘               │        │
│    │                        │                        │        │
│    │                        │                        │        │
│    │ Events           Repository Calls         States │      │
│    │                        │                        │        │
└────┼────────────────────────┼────────────────────────┼────────┘
     │                        │                        │
     │                        │                        │
┌────▼────────────────────────▼────────────────────────▼────────┐
│                        DATA LAYER                              │
│                                                                 │
│                  ┌───────────────────┐                         │
│                  │  NotesRepository  │                         │
│                  │                   │                         │
│                  │  • fetchNotes()   │                         │
│                  │  • createNote()   │                         │
│                  │  • updateNote()   │                         │
│                  │  • deleteNote()   │                         │
│                  │  • switchStorage()│                         │
│                  └─────────┬─────────┘                         │
│                            │                                    │
│              ┌─────────────┴─────────────┐                     │
│              │                           │                     │
│      ┌───────▼────────┐         ┌───────▼────────┐           │
│      │  LocalService  │         │   ApiService   │           │
│      │                │         │                │           │
│      │ • fetchNotes() │         │ • fetchNotes() │           │
│      │ • createNote() │         │ • createNote() │           │
│      │ • updateNote() │         │ • updateNote() │           │
│      │ • deleteNote() │         │ • deleteNote() │           │
│      └───────┬────────┘         └───────┬────────┘           │
│              │                           │                     │
└──────────────┼───────────────────────────┼─────────────────────┘
               │                           │
               │                           │
┌──────────────▼───────────┐   ┌──────────▼──────────┐
│  SharedPreferences       │   │  HTTP REST API      │
│  (Local Storage)         │   │  (localhost:8080)   │
│                          │   │                     │
│  JSON Serialization      │   │  JSON over HTTP     │
│  Auto-increment IDs      │   │  CRUD endpoints     │
│  Offline-first           │   │  Network-dependent  │
└──────────────────────────┘   └─────────────────────┘
```

## Event Flow Example: Adding a Note

```
User Action                                         UI Update
    │                                                   ▲
    │                                                   │
    ▼                                                   │
[1] User taps "Add Note"                              [8]
    │                                                   │
    ▼                                                   │
[2] AddNoteScreen                                      │
    │ - User enters title & body                       │
    │ - User taps "Save"                               │
    ▼                                                   │
[3] Create Note object                                 │
    │ Note(title: "...", body: "...")                  │
    ▼                                                   │
[4] Dispatch Event                                     │
    │ context.read<NotesBloc>()                        │
    │   .add(AddNote(note))                            │
    ▼                                                   │
[5] NotesBloc receives event                           │
    │ _onAddNote() handler                             │
    │ emit(NotesLoading())                             │
    │ repository.createNote(note)                      │
    ▼                                                   │
[6] Repository delegates to service                    │
    │ if (local): _localService.createNote()           │
    │ if (api):   _apiService.createNote()             │
    ▼                                                   │
[7] Service saves data                                 │
    │ Local: SharedPreferences                         │
    │ API:   HTTP POST /notes                          │
    │                                                   │
    │ ◄─────────────────────────────────────────────── │
    │                                                   │
    ▼                                                   │
[8] BLoC emits new state                              │
    │ emit(NotesOperationSuccess(...))                 │
    │ emit(NotesLoaded(...))                           │
    └──────────────────────────────────────────────────┘
```

## State Transitions

```
┌──────────────┐
│ NotesInitial │
└──────┬───────┘
       │
       │ LoadNotes event
       ▼
┌──────────────┐
│ NotesLoading │
└──────┬───────┘
       │
       │ Success
       ▼
┌──────────────┐     AddNote event      ┌──────────────┐
│ NotesLoaded  │────────────────────────>│ NotesLoading │
└──────┬───────┘                         └──────┬───────┘
       │                                        │
       │                                        │ Success
       │                                        ▼
       │                              ┌─────────────────────┐
       │<─────────────────────────────│NotesOperationSuccess│
       │                              └─────────────────────┘
       │
       │ UpdateNote event
       ▼
┌──────────────┐
│ NotesLoading │
└──────┬───────┘
       │
       │ Error
       ▼
┌──────────────┐     Retry (LoadNotes)
│  NotesError  │────────────────────────> (back to Loading)
└──────────────┘
```

## Data Flow Layers

```
┌─────────────────────────────────────────────────────┐
│ LAYER 1: Presentation (UI)                          │
│ ───────────────────────────────────────────────────  │
│ • Stateless/Stateful Widgets                        │
│ • BlocBuilder, BlocListener, BlocConsumer           │
│ • User interactions                                 │
│ • Visual components                                 │
└───────────────────┬─────────────────────────────────┘
                    │
                    │ Events down, States up
                    │
┌───────────────────▼─────────────────────────────────┐
│ LAYER 2: Business Logic (BLoC)                      │
│ ───────────────────────────────────────────────────  │
│ • Event handlers                                    │
│ • State management                                  │
│ • Business rules                                    │
│ • Coordination                                      │
└───────────────────┬─────────────────────────────────┘
                    │
                    │ Method calls
                    │
┌───────────────────▼─────────────────────────────────┐
│ LAYER 3: Data Abstraction (Repository)              │
│ ───────────────────────────────────────────────────  │
│ • Data source abstraction                           │
│ • Storage switching logic                           │
│ • Service delegation                                │
│ • Single data interface                             │
└───────────────────┬─────────────────────────────────┘
                    │
                    │ Service calls
                    │
┌───────────────────▼─────────────────────────────────┐
│ LAYER 4: Data Services                              │
│ ───────────────────────────────────────────────────  │
│ • Local Service (SharedPreferences)                 │
│ • API Service (HTTP)                                │
│ • Data transformation                               │
│ • Error handling                                    │
└───────────────────┬─────────────────────────────────┘
                    │
                    │ I/O operations
                    │
┌───────────────────▼─────────────────────────────────┐
│ LAYER 5: Data Sources                               │
│ ───────────────────────────────────────────────────  │
│ • SharedPreferences (Device storage)                │
│ • HTTP REST API (Network)                           │
│ • Database, Cache, etc. (extensible)                │
└─────────────────────────────────────────────────────┘
```

## Storage Type Switching

```
                  ┌────────────────┐
                  │  Repository    │
                  │                │
                  │ StorageType    │
                  └────────┬───────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
            ▼                             ▼
    ┌───────────────┐           ┌───────────────┐
    │ StorageType   │           │ StorageType   │
    │   .local      │           │    .api       │
    └───────┬───────┘           └───────┬───────┘
            │                           │
            ▼                           ▼
    ┌───────────────┐           ┌───────────────┐
    │ LocalService  │           │  ApiService   │
    └───────┬───────┘           └───────┬───────┘
            │                           │
            ▼                           ▼
    ┌───────────────┐           ┌───────────────┐
    │SharedPrefs    │           │ HTTP Client   │
    │(Device)       │           │(localhost:8080)│
    └───────────────┘           └───────────────┘
```

## Dependencies Graph

```
main.dart
  └── BlocProvider
        └── NotesBloc
              └── NotesRepository
                    ├── NotesLocalService
                    │     └── SharedPreferences
                    └── NotesApiService
                          └── HTTP package

Screens (all depend on):
  ├── flutter_bloc (BlocBuilder, BlocConsumer)
  ├── NotesBloc (via context.read)
  ├── NotesEvent (to dispatch)
  ├── NotesState (to build UI)
  └── Note model
```

## Package Structure

```
frontend/
├── lib/
│   ├── main.dart                    [Entry point]
│   │
│   ├── bloc/                        [BLoC Layer]
│   │   ├── notes_bloc.dart          • Business logic
│   │   ├── notes_event.dart         • Events
│   │   └── notes_state.dart         • States
│   │
│   ├── models/                      [Data Models]
│   │   └── note.dart                • Note entity
│   │
│   ├── repository/                  [Data Abstraction]
│   │   └── notes_repository.dart    • Repository pattern
│   │
│   ├── services/                    [Data Services]
│   │   ├── notes_api_service.dart   • HTTP service
│   │   ├── notes_local_service.dart • Local service
│   │   └── notes_service.dart       • Exports
│   │
│   └── screens/                     [UI Layer]
│       ├── note_list_screen.dart    • List view
│       ├── note_detail_screen.dart  • Detail view
│       ├── add_note_screen.dart     • Create form
│       └── update_note_screen.dart  • Edit form
│
├── pubspec.yaml                     [Dependencies]
├── README.md                        [Overview]
├── ARCHITECTURE.md                  [Detailed docs]
├── MIGRATION_SUMMARY.md             [Migration info]
├── QUICK_REFERENCE.md               [Dev guide]
└── DIAGRAM.md                       [This file]
```

---

## Key Principles

1. **Unidirectional Data Flow**: Events flow down, States flow up
2. **Single Source of Truth**: BLoC holds the app state
3. **Separation of Concerns**: Each layer has one responsibility
4. **Dependency Injection**: Dependencies injected, not created
5. **Immutability**: States and events are immutable
6. **Testability**: Each layer can be tested independently
