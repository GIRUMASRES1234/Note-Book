import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/note_model.dart';
import '../service/notes_service.dart';

final notesServiceProvider = Provider<NotesService>((ref) {
  return NotesService();
});

final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>((
  ref,
) {
  return NotesNotifier(ref.read(notesServiceProvider));
});

class NotesNotifier extends StateNotifier<List<NoteModel>> {
  final NotesService service;

  NotesNotifier(this.service) : super([]) {
    loadNotes();
  }

  void loadNotes() {
    final notes = service.getNotes();

    // sort pinned first + latest
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = notes;
  }

  Future<void> add(NoteModel note) async {
    await service.addNote(note);
    loadNotes();
  }

  Future<void> delete(String id) async {
    await service.deleteNote(id);
    loadNotes();
  }

  Future<void> update(NoteModel note) async {
    await service.updateNote(note);
    loadNotes();
  }

  Future<void> togglePin(String id) async {
    final note = state.firstWhere((n) => n.id == id);

    final updatedNote = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      subject: note.subject, // ✅ IMPORTANT
      createdAt: note.createdAt,
      isPinned: !note.isPinned,
    );

    await service.updateNote(updatedNote);
    loadNotes();
  }
}
