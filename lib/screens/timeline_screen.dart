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
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              '时间线',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ),
                const Spacer(),
                Text(
                  _getMonthText(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.textSecondary),
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 当天记录
          Expanded(
            child: thoughtsAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
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
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent
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
                            color: AppColors.divider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
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
                                          fontSize: 11,
                                          color: AppColors.getTagColor(
                                              thought.tag!),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    thought.content,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: AppColors.textPrimary,
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

  Widget _buildCalendarGrid() {
    final days = _calendarDays();
    final now = DateTime.now();
    final rows = <Widget>[];

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

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = date);
                    },
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : isToday
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.background
                                : isToday
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
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
