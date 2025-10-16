import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../services/notes_service.dart';

enum StorageType { local, api }

class NotesRepository {
  static const String _storageKey = 'notes_storage_type';

  final NotesLocalService _localService;
  final NotesApiService _apiService;
  StorageType _currentStorage;

  NotesRepository._internal({
    NotesLocalService? localService,
    NotesApiService? apiService,
    StorageType storageType = StorageType.local,
  })  : _localService = localService ?? NotesLocalService(),
        _apiService = apiService ?? NotesApiService(),
        _currentStorage = storageType;

  /// Async factory that loads persisted storage preference (if any)
  static Future<NotesRepository> create({
    NotesLocalService? localService,
    NotesApiService? apiService,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      final storageType = _stringToStorageType(stored) ?? StorageType.local;
      return NotesRepository._internal(
        localService: localService,
        apiService: apiService,
        storageType: storageType,
      );
    } catch (_) {
      // If anything goes wrong, fall back to defaults
      return NotesRepository._internal(
        localService: localService,
        apiService: apiService,
        storageType: StorageType.local,
      );
    }
  }

  // Switch between local and API storage and persist the choice
  Future<void> switchStorage(StorageType storageType) async {
    _currentStorage = storageType;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, storageType == StorageType.local ? 'local' : 'api');
    } catch (_) {
      // ignore persistence errors
    }
  }

  StorageType get currentStorage => _currentStorage;

  // Fetch all notes
  Future<List<Note>> fetchNotes() async {
    try {
      if (_currentStorage == StorageType.local) {
        return await _localService.fetchNotes();
      } else {
        return await _apiService.fetchNotes();
      }
    } catch (e) {
      throw Exception('Repository: Failed to fetch notes - $e');
    }
  }

  // Create a new note
  Future<Note> createNote(Note note) async {
    try {
      if (_currentStorage == StorageType.local) {
        return await _localService.createNote(note);
      } else {
        return await _apiService.createNote(note);
      }
    } catch (e) {
      throw Exception('Repository: Failed to create note - $e');
    }
  }

  // Update an existing note
  Future<Note> updateNote(Note note) async {
    try {
      if (_currentStorage == StorageType.local) {
        return await _localService.updateNote(note);
      } else {
        return await _apiService.updateNote(note);
      }
    } catch (e) {
      throw Exception('Repository: Failed to update note - $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      if (_currentStorage == StorageType.local) {
        await _localService.deleteNote(id);
      } else {
        await _apiService.deleteNote(id);
      }
    } catch (e) {
      throw Exception('Repository: Failed to delete note - $e');
    }
  }

  // Delete multiple notes
  Future<void> deleteNotes(List<int> ids) async {
    try {
      if (_currentStorage == StorageType.local) {
        await _localService.deleteNotes(ids);
      } else {
        await _apiService.deleteNotes(ids);
      }
    } catch (e) {
      throw Exception('Repository: Failed to delete notes - $e');
    }
  }

  // Clear all local notes (local storage only)
  Future<void> clearLocalNotes() async {
    try {
      await _localService.clearAll();
    } catch (e) {
      throw Exception('Repository: Failed to clear local notes - $e');
    }
  }
}

StorageType? _stringToStorageType(String? s) {
  if (s == null) return null;
  switch (s) {
    case 'local':
      return StorageType.local;
    case 'api':
      return StorageType.api;
    default:
      return null;
  }
}
