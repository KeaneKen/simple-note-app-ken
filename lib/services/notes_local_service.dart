import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesLocalService {
  static const String _notesKey = 'notes_list';
  static const String _idCounterKey = 'notes_id_counter';

  // Fetch all notes from local storage
  Future<List<Note>> fetchNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString(_notesKey);
      
      if (notesJson == null || notesJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonData = jsonDecode(notesJson);
      return jsonData.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch local notes: $e');
    }
  }

  // Save all notes to local storage
  Future<void> _saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notesJson = jsonEncode(notes.map((note) => note.toJson()).toList());
      await prefs.setString(_notesKey, notesJson);
    } catch (e) {
      throw Exception('Failed to save notes: $e');
    }
  }

  // Get next ID for new notes
  Future<int> _getNextId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int currentId = prefs.getInt(_idCounterKey) ?? 0;
      final int nextId = currentId + 1;
      await prefs.setInt(_idCounterKey, nextId);
      return nextId;
    } catch (e) {
      throw Exception('Failed to get next ID: $e');
    }
  }

  // Create a new note
  Future<Note> createNote(Note note) async {
    try {
      final notes = await fetchNotes();
      final int newId = await _getNextId();
      final newNote = note.copyWith(id: newId);
      notes.add(newNote);
      await _saveNotes(notes);
      return newNote;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // Update an existing note
  Future<Note> updateNote(Note note) async {
    try {
      if (note.id == null) {
        throw Exception('Note ID cannot be null for update');
      }
      
      final notes = await fetchNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      
      if (index == -1) {
        throw Exception('Note not found');
      }
      
      notes[index] = note;
      await _saveNotes(notes);
      return note;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      final notes = await fetchNotes();
      notes.removeWhere((note) => note.id == id);
      await _saveNotes(notes);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Delete multiple notes
  Future<void> deleteNotes(List<int> ids) async {
    try {
      final notes = await fetchNotes();
      notes.removeWhere((note) => note.id != null && ids.contains(note.id));
      await _saveNotes(notes);
    } catch (e) {
      throw Exception('Failed to delete notes: $e');
    }
  }

  // Clear all notes
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notesKey);
      await prefs.remove(_idCounterKey);
    } catch (e) {
      throw Exception('Failed to clear notes: $e');
    }
  }
}
