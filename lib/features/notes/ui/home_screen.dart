import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stats_screen.dart';
import '../../../core/constants/subjects.dart';

import '../provider/notes_provider.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

// Subject badge colors — add more entries to match your subjects list
const _subjectColors = {
  'Mathematics': (bg: Color(0x336366f1), text: Color(0xffa5b4fc)),
  'Physics': (bg: Color(0x2614b8a6), text: Color(0xff5eead4)),
  'History': (bg: Color(0x26fbbf24), text: Color(0xfffde68a)),
  'Biology': (bg: Color(0x26ec4899), text: Color(0xfff9a8d4)),
  'Literature': (bg: Color(0x26f97316), text: Color(0xfffed7aa)),
  'Chemistry': (bg: Color(0x2622c55e), text: Color(0xff86efac)),
};

({Color bg, Color text}) _badgeColors(String subject) =>
    _subjectColors[subject] ??
    (bg: const Color(0x266366f1), text: const Color(0xffa5b4fc));

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String searchText = '';
  String selectedFilter = 'All';

  static const _bg = Color(0xff0f172a);
  static const _surface = Color(0xff1e293b);
  static const _surfaceHover = Color(0xff1a2744);
  static const _border = Color(0x14ffffff);
  static const _indigo = Color(0xff6366f1);
  static const _textPrimary = Color(0xfff1f5f9);
  static const _textSecondary = Color(0xff94a3b8);
  static const _textMuted = Color(0xff64748b);
  static const _textDim = Color(0xff475569);
  static const _amber = Color(0xfffbbf24);
  static const _pinnedBorder = Color(0x40fbbf24);
  static const _pinnedBg = Color(0x0dfbbf24);

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final filterSubjects = ['All', ...subjects];

    final pinnedNotes = notes.where((n) {
      final matchSearch =
          n.title.toLowerCase().contains(searchText.toLowerCase()) ||
          n.content.toLowerCase().contains(searchText.toLowerCase());
      final matchSubject =
          selectedFilter == 'All' || n.subject == selectedFilter;
      return n.isPinned && matchSearch && matchSubject;
    }).toList();

    final recentNotes = notes.where((n) {
      final matchSearch =
          n.title.toLowerCase().contains(searchText.toLowerCase()) ||
          n.content.toLowerCase().contains(searchText.toLowerCase());
      final matchSubject =
          selectedFilter == 'All' || n.subject == selectedFilter;
      return !n.isPinned && matchSearch && matchSubject;
    }).toList();

    final allFiltered = [...pinnedNotes, ...recentNotes];

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: const TextStyle(
                                  color: _textDim,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'My Notes',
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
                        _AppBarIconButton(
                          icon: Icons.bar_chart_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                       
                      ],
                    ),
                  ),
                ),

                // ── Search ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        hintStyle: const TextStyle(
                          color: _textDim,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _textDim,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _border,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0x806366f1),
                            width: 1,
                          ),
                        ),
                      ),
                      onChanged: (v) => setState(() => searchText = v),
                    ),
                  ),
                ),

                // ── Subject Filter Chips ──────────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filterSubjects.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final sub = filterSubjects[i];
                        final active = selectedFilter == sub;
                        return GestureDetector(
                          onTap: () => setState(() => selectedFilter = sub),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? _indigo
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? _indigo
                                    : Colors.white.withOpacity(0.12),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              sub,
                              style: TextStyle(
                                color: active ? Colors.white : _textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Notes List ───────────────────────────────────────────
                if (allFiltered.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 48,
                            color: Color(0xff334155),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No notes found',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap + to create one',
                            style: TextStyle(color: _textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (pinnedNotes.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionLabel(label: 'Pinned')),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _NoteCard(
                          note: pinnedNotes[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditNoteScreen(note: pinnedNotes[i]),
                            ),
                          ),
                          onPin: () async => await ref
                              .read(notesProvider.notifier)
                              .togglePin(pinnedNotes[i].id),
                          onDelete: () async => await ref
                              .read(notesProvider.notifier)
                              .delete(pinnedNotes[i].id),
                        ),
                        childCount: pinnedNotes.length,
                      ),
                    ),
                    if (recentNotes.isNotEmpty)
                      const SliverToBoxAdapter(child: _Divider()),
                  ],
                  if (recentNotes.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionLabel(label: 'Recent')),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _NoteCard(
                          note: recentNotes[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditNoteScreen(note: recentNotes[i]),
                            ),
                          ),
                          onPin: () async => await ref
                              .read(notesProvider.notifier)
                              .togglePin(recentNotes[i].id),
                          onDelete: () async => await ref
                              .read(notesProvider.notifier)
                              .delete(recentNotes[i].id),
                        ),
                        childCount: recentNotes.length,
                      ),
                    ),
                  ],
                  // bottom padding so FAB doesn't cover last card
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),

            // ── FAB ──────────────────────────────────────────────────────
            Positioned(
              right: 20,
              bottom: 24,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _indigo,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _indigo.withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.5),
        ),
        child: Icon(icon, color: const Color(0xff94a3b8), size: 18),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xff475569),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      color: Colors.white.withOpacity(0.06),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final dynamic note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _badgeColors(note.subject as String);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: note.isPinned
              ? const Color(0x0dfbbf24)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: note.isPinned
                ? const Color(0x40fbbf24)
                : Colors.white.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title as String,
                    style: const TextStyle(
                      color: Color(0xfff1f5f9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Pin button
                _CardActionButton(
                  icon: note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: note.isPinned
                      ? const Color(0xfffbbf24)
                      : const Color(0xff475569),
                  onTap: onPin,
                ),
                // Delete button
                _CardActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xfff87171), // Red even when not hovered
                  activeColor: const Color(0xffef4444), // Brighter red on hover
                  onTap: onDelete,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Subject badge
            Row(
              children: [
                if (note.isPinned) ...[
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xfffbbf24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.subject as String,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Content preview
            Text(
              note.content as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff64748b),
                fontSize: 13,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 10),

            // Time
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: Color(0xff334155),
                ),
                const SizedBox(width: 4),
                Text(
                  timeago.format(note.createdAt as DateTime),
                  style: const TextStyle(
                    color: Color(0xff334155),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color? activeColor;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    required this.color,
    this.activeColor,
    required this.onTap,
  });

  @override
  State<_CardActionButton> createState() => _CardActionButtonState();
}

class _CardActionButtonState extends State<_CardActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _hovered ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          widget.icon,
          size: 16,
          color: _hovered && widget.activeColor != null
              ? widget.activeColor
              : widget.color,
        ),
      ),
    );
  }
}
