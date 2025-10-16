import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

// Event to load all notes
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

// Event to add a new note
class AddNote extends NotesEvent {
  final Note note;

  const AddNote(this.note);

  @override
  List<Object?> get props => [note];
}

// Event to update an existing note
class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

// Event to delete a single note
class DeleteNote extends NotesEvent {
  final int noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

// Event to delete multiple notes
class DeleteMultipleNotes extends NotesEvent {
  final List<int> noteIds;

  const DeleteMultipleNotes(this.noteIds);

  @override
  List<Object?> get props => [noteIds];
}

// Event to switch storage type
class SwitchStorageType extends NotesEvent {
  final StorageType storageType;

  const SwitchStorageType(this.storageType);

  @override
  List<Object?> get props => [storageType];
}

// Event to clear all local notes
class ClearLocalNotes extends NotesEvent {
  const ClearLocalNotes();
}
