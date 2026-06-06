import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/thought.dart';
import '../providers/thought_provider.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import '../widgets/empty_state.dart';
import 'thought_detail_screen.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  String _getMonthText() {
    return DateFormat('yyyy年M月').format(_currentMonth);
  }

  // 获取当月第一天是周几（1=周一, 7=周日）
  int _firstWeekdayOfMonth() {
    return DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
  }

  // 获取当月天数
  int _daysInMonth() {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  // 构建日历网格的日期列表（包含前面的空位）
  List<int?> _calendarDays() {
    final firstWeekday = _firstWeekdayOfMonth();
    final daysInMonth = _daysInMonth();
    final List<int?> days = [];
    // 前面填充空位（周一=1，所以偏移 firstWeekday-1 个空位）
    for (int i = 0; i < firstWeekday - 1; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(i);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              '时间线',
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 28),
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 月份选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month - 1);
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.chevron_left_rounded,
                        size: 20, color: c.textSecondary),
                  ),
                ),
                const Spacer(),
                Text(
                  _getMonthText(),
                  style: TextStyle(
                    fontSize: AppFont.scale(context, ref, 17),
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month + 1);
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 20, color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 星期标题行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['一', '二', '三', '四', '五', '六', '日'].map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: AppFont.scale(context, ref, 12),
                        color: c.textTertiary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // 日历网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendarGrid(),
          ),
          const SizedBox(height: 16),
          // 选中日期显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              DateFormat('M月d日').format(_selectedDate),
              style: TextStyle(
                fontSize: AppFont.scale(context, ref, 14),
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 当天记录
          Expanded(
            child: thoughtsAsync.when(
              loading: () => Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.accent,
                  ),
                ),
              ),
              error: (e, _) => Center(child: Text('出错了: $e')),
              data: (allThoughts) {
                final startOfDay = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day);
                final endOfDay = startOfDay.add(const Duration(days: 1));
                final dayThoughts = allThoughts
                    .where((t) =>
                        t.createdAt.isAfter(startOfDay) &&
                        t.createdAt.isBefore(endOfDay))
                    .toList();

                if (dayThoughts.isEmpty) {
                  return const EmptyState(
                    title: '这一天还没有留下想法',
                    subtitle: '',
                    icon: Icons.calendar_today_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: dayThoughts.length,
                  itemBuilder: (context, index) {
                    final thought = dayThoughts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          buildSlideRoute(
                              ThoughtDetailScreen(thought: thought)),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 44,
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('HH:mm')
                                      .format(thought.createdAt),
                                  style: TextStyle(
                                    fontSize: AppFont.scale(context, ref, 11),
                                    color: c.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: c.accent
                                        .withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 竖线
                          Container(
                            width: 1,
                            height: 48,
                            color: c.divider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (thought.tag != null &&
                                      thought.tag!.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.getTagColor(
                                                thought.tag!)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        thought.tag!,
                                        style: TextStyle(
                                          fontSize: AppFont.scale(context, ref, 11),
                                          color: AppColors.getTagColor(
                                              thought.tag!),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    thought.content,
                                    style: TextStyle(
                                      fontSize: AppFont.scale(context, ref, 14),
                                      height: 1.6,
                                      color: c.textPrimary,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 统计当月每天的想法数量
  Map<int, int> _thoughtCountByDay(List<Thought> allThoughts) {
    final Map<int, int> counts = {};
    for (final t in allThoughts) {
      if (t.createdAt.year == _currentMonth.year &&
          t.createdAt.month == _currentMonth.month) {
        counts[t.createdAt.day] = (counts[t.createdAt.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  // 根据想法数量返回填充色透明度（0条=无填充，1条=0.08，逐级递增）
  double _fillOpacity(int count) {
    if (count <= 0) return 0;
    if (count == 1) return 0.08;
    if (count == 2) return 0.15;
    if (count <= 4) return 0.25;
    if (count <= 7) return 0.38;
    return 0.5;
  }

  Widget _buildCalendarGrid() {
    final c = AppColors.of(context);
    final days = _calendarDays();
    final now = DateTime.now();
    final rows = <Widget>[];

    // 获取当前 provider 中的想法列表来统计每日数量
    final thoughtsAsync = ref.read(thoughtListProvider);
    final allThoughts = thoughtsAsync.valueOrNull ?? [];
    final dayCounts = _thoughtCountByDay(allThoughts);

    for (int i = 0; i < days.length; i += 7) {
      final weekDays = days.sublist(i, (i + 7).clamp(0, days.length));
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: List.generate(7, (col) {
              if (col < weekDays.length && weekDays[col] != null) {
                final day = weekDays[col]!;
                final date = DateTime(
                    _currentMonth.year, _currentMonth.month, day);
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;
                final isToday = date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
                final count = dayCounts[day] ?? 0;
                final opacity = _fillOpacity(count);

                // 背景色：选中 > 今天 > 有记录 > 无记录
                Color bgColor;
                if (isSelected) {
                  bgColor = c.accent;
                } else if (isToday) {
                  bgColor = opacity > 0
                      ? c.accent.withValues(alpha: opacity + 0.08)
                      : c.accent.withValues(alpha: 0.1);
                } else if (opacity > 0) {
                  bgColor = c.accent.withValues(alpha: opacity);
                } else {
                  bgColor = Colors.transparent;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = date);
                    },
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: AppFont.scale(context, ref, 14),
                            fontWeight: isSelected || isToday
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? c.background
                                : isToday
                                    ? c.accent
                                    : c.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox(height: 42));
              }
            }),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
