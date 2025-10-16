import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class NotesApiService {
  final String baseUrl;

  NotesApiService({this.baseUrl = 'http://localhost:8080'});

  // Fetch all notes
  Future<List<Note>> fetchNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notes'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Create a new note
  Future<Note> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 201) {
        return Note.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // Update an existing note
  Future<Note> updateNote(Note note) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notes/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 200) {
        return Note.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Delete multiple notes
  Future<void> deleteNotes(List<int> ids) async {
    for (final id in ids) {
      await deleteNote(id);
    }
  }
}
