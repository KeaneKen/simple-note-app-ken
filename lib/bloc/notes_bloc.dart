import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import '../repository/notes_repository.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repository;

  NotesBloc({required this.repository}) : super(const NotesInitial()) {
    // Handle LoadNotes event
    on<LoadNotes>(_onLoadNotes);

    // Handle AddNote event
    on<AddNote>(_onAddNote);

    // Handle UpdateNote event
    on<UpdateNote>(_onUpdateNote);

    // Handle DeleteNote event
    on<DeleteNote>(_onDeleteNote);

    // Handle DeleteMultipleNotes event
    on<DeleteMultipleNotes>(_onDeleteMultipleNotes);

    // Handle SwitchStorageType event
    on<SwitchStorageType>(_onSwitchStorageType);

    // Handle ClearLocalNotes event
    on<ClearLocalNotes>(_onClearLocalNotes);
  }

  // Load all notes
  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());
    try {
      final notes = await repository.fetchNotes();
      emit(NotesLoaded(
        notes: notes,
        storageType: repository.currentStorage,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  // Add a new note
  Future<void> _onAddNote(
    AddNote event,
    Emitter<NotesState> emit,
  ) async {
    if (state is NotesLoaded) {
      emit(const NotesLoading());
      try {
        await repository.createNote(event.note);
        final notes = await repository.fetchNotes();
        emit(NotesOperationSuccess(
          notes: notes,
          storageType: repository.currentStorage,
          message: 'Note added successfully',
        ));
        // Transition to loaded state
        emit(NotesLoaded(
          notes: notes,
          storageType: repository.currentStorage,
        ));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    }
  }

  // Update an existing note
  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NotesState> emit,
  ) async {
    if (state is NotesLoaded) {
      emit(const NotesLoading());
      try {
        await repository.updateNote(event.note);
        final notes = await repository.fetchNotes();
        emit(NotesOperationSuccess(
          notes: notes,
          storageType: repository.currentStorage,
          message: 'Note updated successfully',
        ));
        // Transition to loaded state
        emit(NotesLoaded(
          notes: notes,
          storageType: repository.currentStorage,
        ));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    }
  }

  // Delete a single note
  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    if (state is NotesLoaded) {
      emit(const NotesLoading());
      try {
        await repository.deleteNote(event.noteId);
        final notes = await repository.fetchNotes();
        emit(NotesOperationSuccess(
          notes: notes,
          storageType: repository.currentStorage,
          message: 'Note deleted successfully',
        ));
        // Transition to loaded state
        emit(NotesLoaded(
          notes: notes,
          storageType: repository.currentStorage,
        ));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    }
  }

  // Delete multiple notes
  Future<void> _onDeleteMultipleNotes(
    DeleteMultipleNotes event,
    Emitter<NotesState> emit,
  ) async {
    if (state is NotesLoaded) {
      emit(const NotesLoading());
      try {
        await repository.deleteNotes(event.noteIds);
        final notes = await repository.fetchNotes();
        emit(NotesOperationSuccess(
          notes: notes,
          storageType: repository.currentStorage,
          message: '${event.noteIds.length} notes deleted successfully',
        ));
        // Transition to loaded state
        emit(NotesLoaded(
          notes: notes,
          storageType: repository.currentStorage,
        ));
      } catch (e) {
        emit(NotesError(e.toString()));
      }
    }
  }

  // Switch storage type
  Future<void> _onSwitchStorageType(
    SwitchStorageType event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());
    try {
      await repository.switchStorage(event.storageType);
      final notes = await repository.fetchNotes();
      emit(NotesLoaded(
        notes: notes,
        storageType: repository.currentStorage,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  // Clear all local notes
  Future<void> _onClearLocalNotes(
    ClearLocalNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());
    try {
      await repository.clearLocalNotes();
      final notes = await repository.fetchNotes();
      emit(NotesOperationSuccess(
        notes: notes,
        storageType: repository.currentStorage,
        message: 'All local notes cleared',
      ));
      // Transition to loaded state
      emit(NotesLoaded(
        notes: notes,
        storageType: repository.currentStorage,
      ));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
}
