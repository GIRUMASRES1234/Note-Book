import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/note_model.dart';
import '../provider/notes_provider.dart';
import '../../../core/constants/subjects.dart';
import '../../ai/ai_service.dart';

// ── Subject colour palette (mirrors HomeScreen) ───────────────────────────────
const _subjectColors = {
  'Mathematics': Color(0xff6366f1),
  'Physics': Color(0xff0ea5e9),
  'Chemistry': Color(0xff10b981),
  'Biology': Color(0xff84cc16),
  'History': Color(0xfff59e0b),
  'Geography': Color(0xff14b8a6),
  'Literature': Color(0xffec4899),
  'Computer': Color(0xff8b5cf6),
  'Economics': Color(0xfff97316),
  'Other': Color(0xff94a3b8),
};

Color _colorFor(String subject) =>
    _subjectColors[subject] ?? const Color(0xff6366f1);

// ── Screen ────────────────────────────────────────────────────────────────────
class EditNoteScreen extends ConsumerStatefulWidget {
  final NoteModel note;
  const EditNoteScreen({super.key, required this.note});

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen>
    with SingleTickerProviderStateMixin {
  // ── colour tokens ─────────────────────────────────────────────────────────
  static const _bg = Color(0xff080c14);
  static const _surface = Color(0xff0f1624);
  static const _card = Color(0xff141c2e);
  static const _border = Color(0xff1e2d45);
  static const _textHi = Color(0xffe8eaf6);
  static const _textMid = Color(0xff8b9bc8);
  static const _textLo = Color(0xff4a5578);

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late String _subject;
  late bool _pinned;
  bool _saving = false;
  bool _summarising = false;

  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final AiService _aiService = AiService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _subject = widget.note.subject;
    _pinned = widget.note.isPinned;

    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _enterAnim.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      _showSnack('Title and content cannot be empty', isError: true);
      return;
    }
    setState(() => _saving = true);
    final updated = NoteModel(
      id: widget.note.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      subject: _subject,
      createdAt: widget.note.createdAt,
      isPinned: _pinned,
    );
    await ref.read(notesProvider.notifier).update(updated);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _summarise() async {
    setState(() => _summarising = true);
    try {
      final summary = await _aiService.summarizeNote(_contentCtrl.text);
      if (!mounted) return;
      _showSummarySheet(summary);
    } catch (_) {
      if (mounted) _showSnack('Could not generate summary', isError: true);
    } finally {
      if (mounted) setState(() => _summarising = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? const Color(0xff7f1d1d)
            : const Color(0xff14532d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  void _showSummarySheet(String summary) {
    final color = _colorFor(_subject);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SummarySheet(summary: summary, accentColor: color),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final accentColor = _colorFor(_subject);

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: _buildAppBar(accentColor),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // ── Accent line ──────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0)],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Subject picker ──────────────────────────────────
                      _SectionLabel(label: 'Subject', color: accentColor),
                      const SizedBox(height: 8),
                      _SubjectPicker(
                        selected: _subject,
                        onChanged: (v) => setState(() => _subject = v),
                      ),

                      const SizedBox(height: 24),

                      // ── Title field ─────────────────────────────────────
                      _SectionLabel(label: 'Title', color: accentColor),
                      const SizedBox(height: 8),
                      _StyledField(
                        controller: _titleCtrl,
                        hintText: 'Note title...',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        accentColor: accentColor,
                      ),

                      const SizedBox(height: 24),

                      // ── Content field ───────────────────────────────────
                      _SectionLabel(label: 'Content', color: accentColor),
                      const SizedBox(height: 8),
                      _StyledField(
                        controller: _contentCtrl,
                        hintText: 'Write your note here...',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        maxLines: null,
                        minLines: 14,
                        accentColor: accentColor,
                      ),

                      const SizedBox(height: 28),

                      // ── Action buttons ──────────────────────────────────
                      _ActionRow(
                        saving: _saving,
                        summarising: _summarising,
                        accentColor: accentColor,
                        onSummarise: _summarise,
                        onSave: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color accent) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(bottom: BorderSide(color: _border, width: 0.5)),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textMid,
            size: 16,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Note',
            style: TextStyle(
              color: _textHi,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            _subject,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // Pin toggle
        _AppBarAction(
          onTap: () => setState(() => _pinned = !_pinned),
          child: Icon(
            _pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            color: _pinned ? const Color(0xfffbbf24) : _textLo,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        // AI summary
        _AppBarAction(
          onTap: _summarising ? null : _summarise,
          child: _summarising
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xfffbbf24),
                  ),
                )
              : const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xfffbbf24),
                  size: 18,
                ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Subject Picker ────────────────────────────────────────────────────────────
class _SubjectPicker extends StatelessWidget {
  const _SubjectPicker({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(selected);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff141c2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: const Color(0xff141c2e),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 22),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(16),
          items: subjects.map((s) {
            final c = _colorFor(s);
            return DropdownMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c,
                      boxShadow: [
                        BoxShadow(color: c.withOpacity(0.5), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s,
                    style: TextStyle(
                      color: s == selected ? c : const Color(0xff8b9bc8),
                      fontSize: 14,
                      fontWeight: s == selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Styled Text Field ─────────────────────────────────────────────────────────
class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hintText,
    required this.fontSize,
    required this.fontWeight,
    required this.maxLines,
    required this.accentColor,
    this.minLines,
  });

  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final FontWeight fontWeight;
  final int? maxLines;
  final int? minLines;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff141c2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff1e2d45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        style: TextStyle(
          color: const Color(0xffe8eaf6),
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.55,
          letterSpacing: fontWeight == FontWeight.w700 ? -0.3 : 0,
        ),
        cursorColor: accentColor,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xff2e3d5c), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// ── Action Row ────────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.saving,
    required this.summarising,
    required this.accentColor,
    required this.onSummarise,
    required this.onSave,
  });

  final bool saving;
  final bool summarising;
  final Color accentColor;
  final VoidCallback onSummarise;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // AI Summary button
        Expanded(
          child: GestureDetector(
            onTap: summarising ? null : onSummarise,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xff141c2e),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xfffbbf24).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (summarising)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xfffbbf24),
                      ),
                    )
                  else
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xfffbbf24),
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    summarising ? 'Thinking...' : 'AI Summary',
                    style: const TextStyle(
                      color: Color(0xfffbbf24),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Save button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: saving ? null : onSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(saving ? 0.5 : 1),
                    Color.lerp(
                      accentColor,
                      Colors.purple,
                      0.4,
                    )!.withOpacity(saving ? 0.5 : 1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: saving
                    ? null
                    : [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (saving)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    saving ? 'Saving...' : 'Save Changes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── App Bar Action Button ─────────────────────────────────────────────────────
class _AppBarAction extends StatelessWidget {
  const _AppBarAction({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xff1a2438),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff1e2d45)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── AI Summary Bottom Sheet ───────────────────────────────────────────────────
class _SummarySheet extends StatelessWidget {
  const _SummarySheet({required this.summary, required this.accentColor});
  final String summary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: const Color(0xff141c2e),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xff1e2d45)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xff2e3d5c),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xfffbbf24).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xfffbbf24).withOpacity(0.25),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xfffbbf24),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Summary',
                      style: TextStyle(
                        color: Color(0xffe8eaf6),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Generated by Claude',
                      style: TextStyle(color: Color(0xff4a5578), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            height: 0.5,
            color: const Color(0xff1e2d45),
          ),

          // Summary text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              summary,
              style: const TextStyle(
                color: Color(0xff8b9bc8),
                fontSize: 14.5,
                height: 1.7,
              ),
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff0f1624),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xff1e2d45)),
                ),
                child: const Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xff8b9bc8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
