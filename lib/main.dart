import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'bloc/notes_event.dart';
import 'repository/notes_repository.dart';
import 'screens/note_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repository with persisted storage choice
  final repository = await NotesRepository.create();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final NotesRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Taking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => NotesBloc(
          repository: repository,
        )..add(const LoadNotes()),
        child: const NoteListScreen(),
      ),
    );
  }
}
