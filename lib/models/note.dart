import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;
  final String title;
  final String body;

  const Note({
    this.id,
    required this.title,
    required this.body,
  });

  // Create a Note from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['ID'] ?? json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }

  // Convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'ID': id,
      'title': title,
      'body': body,
    };
  }

  // Create a copy with optional new values
  Note copyWith({
    int? id,
    String? title,
    String? body,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [id, title, body];

  @override
  String toString() => 'Note { id: $id, title: $title, body: $body }';
}
