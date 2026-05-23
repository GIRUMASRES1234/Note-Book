import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/note_model.dart';
import '../provider/notes_provider.dart';
import '../../../core/constants/subjects.dart';

// ── Shared tokens (same as home_screen.dart & stats_screen.dart) ─────────────
const _bg = Color(0xff0f172a);
const _border = Color(0x14ffffff);
const _indigo = Color(0xff6366f1);
const _indigoBg = Color(0x336366f1);
const _indigoFg = Color(0xffa5b4fc);
const _amberBg = Color(0x26fbbf24);
const _amberFg = Color(0xfffde68a);
const _textPrimary = Color(0xfff1f5f9);
const _textSecondary = Color(0xff94a3b8);
const _textDim = Color(0xff475569);

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedSubject = 'General';
  bool _isPinned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title and content cannot be empty'),
          backgroundColor: const Color(0xff1e293b),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border, width: 0.5),
          ),
        ),
      );
      return;
    }

    final note = NoteModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      subject: _selectedSubject,
      createdAt: DateTime.now(),
      isPinned: _isPinned,
    );

    await ref.read(notesProvider.notifier).add(note);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Row(
                children: [
                  // Back button
                  // Save button as text
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create',
                          style: TextStyle(
                            color: _textDim,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'New Note',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pin toggle
                  // PIN button as text
                  GestureDetector(
                    onTap: () => setState(() => _isPinned = !_isPinned),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isPinned
                            ? _amberBg
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isPinned
                              ? const Color(0x40fbbf24)
                              : Colors.white.withOpacity(0.10),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _isPinned ? 'PINNED' : 'PIN',
                        style: TextStyle(
                          color: _isPinned ? _amberFg : _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10), // ✅ SPACE BETWEEN PIN & SAVE

                  GestureDetector(
                    onTap: _saveNote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _indigoBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0x406366f1),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          color: _indigoFg,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Save button
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Note title...',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 12),

                    // Subject dropdown
                    _buildDropdown(),

                    const SizedBox(height: 12),

                    // Content field
                    Expanded(
                      child: _buildTextField(
                        controller: _contentController,
                        hint: 'Write your note here...',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double fontSize,
    required FontWeight fontWeight,
    int? maxLines,
    bool expands = false,
    TextAlignVertical? textAlignVertical,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      expands: expands,
      textAlignVertical: textAlignVertical,
      style: TextStyle(
        color: _textPrimary,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textDim, fontSize: 15),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x806366f1), width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      dropdownColor: const Color(0xff1e293b),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _textDim,
        size: 20,
      ),
      style: const TextStyle(color: _textPrimary, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x806366f1), width: 1),
        ),
      ),
      items: subjects.map((sub) {
        return DropdownMenuItem(
          value: sub,
          child: Text(
            sub,
            style: const TextStyle(color: _textPrimary, fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedSubject = value!),
    );
  }
}

// ── Reusable icon button — identical to home/stats screens ───────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? bgColor;
  final Color? borderColor;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.10),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: iconColor ?? _textSecondary, size: 16),
      ),
    );
  }
}
