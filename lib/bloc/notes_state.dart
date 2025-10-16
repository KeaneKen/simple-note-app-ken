import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

// Initial state
class NotesInitial extends NotesState {
  const NotesInitial();
}

// Loading state
class NotesLoading extends NotesState {
  const NotesLoading();
}

// Loaded state with notes
class NotesLoaded extends NotesState {
  final List<Note> notes;
  final StorageType storageType;

  const NotesLoaded({
    required this.notes,
    required this.storageType,
  });

  @override
  List<Object?> get props => [notes, storageType];

  // Helper method to copy with new values
  NotesLoaded copyWith({
    List<Note>? notes,
    StorageType? storageType,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      storageType: storageType ?? this.storageType,
    );
  }
}

// Error state
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Success state for operations (create, update, delete)
class NotesOperationSuccess extends NotesState {
  final List<Note> notes;
  final StorageType storageType;
  final String message;

  const NotesOperationSuccess({
    required this.notes,
    required this.storageType,
    required this.message,
  });

  @override
  List<Object?> get props => [notes, storageType, message];
}
