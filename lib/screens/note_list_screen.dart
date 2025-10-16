import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';
import 'note_detail_screen.dart';
import 'add_note_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> selectedNotes = [];
  bool isSelectionMode = false;

  void _toggleSelection(Note note) {
    setState(() {
      if (selectedNotes.contains(note)) {
        selectedNotes.remove(note);
      } else {
        selectedNotes.add(note);
      }
      if (selectedNotes.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Note> notes) {
    setState(() {
      isSelectionMode = true;
      selectedNotes = List.from(notes);
    });
  }

  void _deleteSelected(BuildContext context) {
    final noteIds = selectedNotes.map((note) => note.id!).toList();
    context.read<NotesBloc>().add(DeleteMultipleNotes(noteIds));
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  void _cancelSelection() {
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode 
          ? '${selectedNotes.length} selected' 
          : 'Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!isSelectionMode)
            BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoaded) {
                  return PopupMenuButton<StorageType>(
                    icon: Icon(
                      state.storageType == StorageType.local 
                        ? Icons.storage 
                        : Icons.cloud,
                    ),
                    onSelected: (StorageType type) {
                      context.read<NotesBloc>().add(SwitchStorageType(type));
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: StorageType.local,
                        child: Row(
                          children: [
                            Icon(Icons.storage, 
                              color: state.storageType == StorageType.local 
                                ? Colors.blue 
                                : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('Local Storage'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: StorageType.api,
                        child: Row(
                          children: [
                            Icon(Icons.cloud, 
                              color: state.storageType == StorageType.api 
                                ? Colors.blue 
                                : Colors.grey),
                            const SizedBox(width: 8),
                            const Text('API Storage'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          if (!isSelectionMode)
            BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                if (state is NotesLoaded && state.notes.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () => _selectAll(state.notes),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSelected(context),
            ),
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelSelection,
            ),
        ],
      ),
      body: BlocConsumer<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotesOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesInitial) {
            return const Center(child: Text('Press + to add a note'));
          } else if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesLoaded || state is NotesOperationSuccess) {
            final notes = state is NotesLoaded 
              ? state.notes 
              : (state as NotesOperationSuccess).notes;

            if (notes.isEmpty) {
              return const Center(
                child: Text('No notes yet. Add one!'),
              );
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final isSelected = selectedNotes.contains(note);

                return ListTile(
                  leading: isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(note),
                        )
                      : null,
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    note.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    if (isSelectionMode) {
                      _toggleSelection(note);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(note: note),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      isSelectionMode = true;
                      if (!selectedNotes.contains(note)) {
                        selectedNotes.add(note);
                      }
                    });
                  },
                );
              },
            );
          } else if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotesBloc>().add(const LoadNotes());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
