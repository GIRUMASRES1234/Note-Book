import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/subjects.dart';
import '../provider/notes_provider.dart';

// ── Shared color tokens (identical to home_screen.dart) ──────────────────────
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

// Per-subject accent colors — same map as home_screen.dart
const _subjectColors = {
  'Mathematics': (
    bar: Color(0xff6366f1),
    dot: Color(0xffa5b4fc),
    text: Color(0xffa5b4fc),
  ),
  'Physics': (
    bar: Color(0xff14b8a6),
    dot: Color(0xff5eead4),
    text: Color(0xff5eead4),
  ),
  'History': (
    bar: Color(0xfff59e0b),
    dot: Color(0xfffde68a),
    text: Color(0xfffde68a),
  ),
  'Biology': (
    bar: Color(0xffec4899),
    dot: Color(0xfff9a8d4),
    text: Color(0xfff9a8d4),
  ),
  'Literature': (
    bar: Color(0xfff97316),
    dot: Color(0xfffed7aa),
    text: Color(0xfffed7aa),
  ),
  'Chemistry': (
    bar: Color(0xff22c55e),
    dot: Color(0xff86efac),
    text: Color(0xff86efac),
  ),
};

({Color bar, Color dot, Color text}) _colors(String subject) =>
    _subjectColors[subject] ?? (bar: _indigo, dot: _indigoFg, text: _indigoFg);

// ─────────────────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    final totalNotes = notes.length;
    final pinnedNotes = notes.where((n) => n.isPinned).length;

    final Map<String, int> subjectCounts = {
      for (final s in subjects) s: notes.where((n) => n.subject == s).length,
    };

    final maxCount = subjectCounts.values.fold(0, (a, b) => a > b ? a : b);

    final barGroups = subjects.asMap().entries.map((e) {
      final c = _colors(e.value);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (subjectCounts[e.value] ?? 0).toDouble(),
            width: 12,
            borderRadius: BorderRadius.circular(5),
            color: c.bar,
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar — matches home_screen style ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    _AppBarIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: TextStyle(
                            color: _textDim,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Statistics',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Metric Cards ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.notes_rounded,
                        iconBg: _indigoBg,
                        iconColor: _indigoFg,
                        label: 'Total notes',
                        value: totalNotes.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.push_pin_rounded,
                        iconBg: _amberBg,
                        iconColor: _amberFg,
                        label: 'Pinned',
                        value: pinnedNotes.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Section label: Chart ───────────────────────────────────
            const SliverToBoxAdapter(child: _SectionLabel('Notes by subject')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border, width: 0.5),
                  ),
                  child: SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        maxY: (maxCount + 2).toDouble(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withOpacity(0.05),
                            strokeWidth: 0.5,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, _) {
                                final i = value.toInt();
                                if (i >= subjects.length)
                                  return const SizedBox();
                                return Text(
                                  subjects[i].substring(0, 3),
                                  style: const TextStyle(
                                    color: _textDim,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, _, rod, __) =>
                                BarTooltipItem(
                                  '${rod.toY.toInt()} notes',
                                  const TextStyle(
                                    color: _textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Section label: Breakdown ───────────────────────────────
            const SliverToBoxAdapter(child: _SectionLabel('Breakdown')),

            // ── Subject rows — same card style as note cards ──────────
            SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                final subject = subjects[i];
                final count = subjectCounts[subject] ?? 0;
                final ratio = maxCount == 0 ? 0.0 : count / maxCount;
                final c = _colors(subject);
                return _SubjectRow(
                  subject: subject,
                  count: count,
                  ratio: ratio,
                  barColor: c.bar,
                  dotColor: c.dot,
                  countColor: c.text,
                );
              }, childCount: subjects.length),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Identical to _AppBarIconButton in home_screen.dart
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
        child: Icon(icon, color: _textSecondary, size: 16),
      ),
    );
  }
}

/// Identical uppercase section label style from home_screen.dart
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _textDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _textDim,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subject row styled like a note card from home_screen.dart
class _SubjectRow extends StatelessWidget {
  final String subject;
  final int count;
  final double ratio;
  final Color barColor;
  final Color dotColor;
  final Color countColor;

  const _SubjectRow({
    required this.subject,
    required this.count,
    required this.ratio,
    required this.barColor,
    required this.dotColor,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(
        children: [
          // Colored dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),

          // Subject name
          SizedBox(
            width: 90,
            child: Text(
              subject,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Progress track
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.07),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Count badge — same pill style as subject badges on note cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: barColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: countColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
