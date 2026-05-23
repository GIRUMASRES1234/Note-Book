import 'package:hive/hive.dart';
import '../model/note_model.dart';

class NotesService {
  final Box notesBox = Hive.box('notesBox');

  List<NoteModel> getNotes() {
    final data = notesBox.values.toList();

    return data
        .map((note) => NoteModel.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> updateNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }
}
