import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/record_repository.dart';
import '../models/record_model.dart';

enum ExportRange {
  all,
  past7Days,
  past30Days,
  custom,
}

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  ExportRange _selectedRange = ExportRange.all;
  DateTimeRange? _customDateRange;

  List<Record> _allRecords = [];
  List<Record> _filteredRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllRecords();
  }

  Future<void> _loadAllRecords() async {
    final list = await RecordRepository.instance.getAllRecords();
    if (mounted) {
      setState(() {
        _allRecords = list;
        _isLoading = false;
        _filterRecords();
      });
    }
  }

  void _filterRecords() {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    setState(() {
      switch (_selectedRange) {
        case ExportRange.all:
          _filteredRecords = List.from(_allRecords);
          break;
        case ExportRange.past7Days:
          final start = todayEnd.subtract(const Duration(days: 7));
          _filteredRecords = _allRecords.where((r) => r.date.isAfter(start)).toList();
          break;
        case ExportRange.past30Days:
          final start = todayEnd.subtract(const Duration(days: 30));
          _filteredRecords = _allRecords.where((r) => r.date.isAfter(start)).toList();
          break;
        case ExportRange.custom:
          if (_customDateRange != null) {
            final start = DateTime(
              _customDateRange!.start.year,
              _customDateRange!.start.month,
              _customDateRange!.start.day,
              0,
              0,
              0,
            );
            final end = DateTime(
              _customDateRange!.end.year,
              _customDateRange!.end.month,
              _customDateRange!.end.day,
              23,
              59,
              59,
            );
            _filteredRecords = _allRecords.where((r) {
              return r.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                  r.date.isBefore(end.add(const Duration(seconds: 1)));
            }).toList();
          } else {
            _filteredRecords = List.from(_allRecords);
          }
          break;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedRange = ExportRange.custom;
        _filterRecords();
      });
    }
  }

  String _getRangeLabel() {
    switch (_selectedRange) {
      case ExportRange.all:
        return '全部数据';
      case ExportRange.past7Days:
        return '近 7 天';
      case ExportRange.past30Days:
        return '近 30 天';
      case ExportRange.custom:
        if (_customDateRange != null) {
          final s = _customDateRange!.start;
          final e = _customDateRange!.end;
          return '${s.year}-${s.month}-${s.day} 至 ${e.year}-${e.month}-${e.day}';
        }
        return '自定义时间段';
    }
  }

  String _generateMarkdown() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    buffer.writeln('# 减脂记录数据导出');
    buffer.writeln();
    buffer.writeln('> 导出范围：${_getRangeLabel()}');
    buffer.writeln('> 导出时间：$dateStr');
    buffer.writeln('> 记录数量：${_filteredRecords.length} 条');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final record in _filteredRecords) {
      final d = record.date;
      final rDate =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      buffer.writeln('## 📅 $rDate');
      buffer.writeln();

      buffer.writeln('### 1. 基础数据');
      buffer.writeln('- **体重**：${record.weight != null ? "${record.weight} kg" : "--"}');
      buffer.writeln('- **早晨空腹**：${record.isFasting ? "是" : "否"}');
      buffer.writeln('- **入睡时间**：${record.sleepStart ?? "--"}');
      buffer.writeln('- **起床时间**：${record.sleepEnd ?? "--"}');
      buffer.writeln('- **睡眠时长**：${_formatDuration(record.sleepDurationMinutes)}');
      buffer.writeln('- **今日步数**：${record.steps != null ? "${record.steps} 步" : "--"}');
      buffer.writeln();

      buffer.writeln('### 2. 饮食记录');
      buffer.writeln('- **早餐**：${record.breakfast.isEmpty ? "未记录" : record.breakfast.replaceAll("\n", " ; ")}');
      buffer.writeln('- **午餐**：${record.lunch.isEmpty ? "未记录" : record.lunch.replaceAll("\n", " ; ")}');
      buffer.writeln('- **晚餐**：${record.dinner.isEmpty ? "未记录" : record.dinner.replaceAll("\n", " ; ")}');
      buffer.writeln('- **其他**：${record.otherFood.isEmpty ? "未记录" : record.otherFood.replaceAll("\n", " ; ")}');
      buffer.writeln();

      buffer.writeln('### 3. 运动与活动');
      buffer.writeln(record.exercise.isEmpty ? '未记录' : record.exercise);
      buffer.writeln();

      buffer.writeln('### 4. 今日状态');
      buffer.writeln(record.status.isEmpty ? '未记录' : record.status);
      buffer.writeln();

      buffer.writeln('### 5. 特殊情况');
      if (record.specialCases.isEmpty && record.specialNote.isEmpty) {
        buffer.writeln('无');
      } else {
        if (record.specialCases.isNotEmpty) {
          buffer.writeln('- **标签**：${record.specialCases.join(", ")}');
        }
        if (record.specialNote.isNotEmpty) {
          buffer.writeln('- **具体说明**：${record.specialNote}');
        }
      }
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return '--';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h 小时';
    return '$h 小时 $m 分钟';
  }

  Future<void> _copyToClipboard() async {
    if (_filteredRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前选择范围内暂无记录可导出')),
      );
      return;
    }

    final mdText = _generateMarkdown();
    await Clipboard.setData(ClipboardData(text: mdText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制 Markdown 数据到剪贴板！'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mdPreview = _generateMarkdown();

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. 选择导出时间范围',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('全部数据'),
                        selected: _selectedRange == ExportRange.all,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRange = ExportRange.all;
                              _filterRecords();
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('近 7 天'),
                        selected: _selectedRange == ExportRange.past7Days,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRange = ExportRange.past7Days;
                              _filterRecords();
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('近 30 天'),
                        selected: _selectedRange == ExportRange.past30Days,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRange = ExportRange.past30Days;
                              _filterRecords();
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(_customDateRange == null
                            ? '自定义时间范围'
                            : '${_customDateRange!.start.month}/${_customDateRange!.start.day} ~ ${_customDateRange!.end.month}/${_customDateRange!.end.day}'),
                        selected: _selectedRange == ExportRange.custom,
                        onSelected: (selected) {
                          _selectCustomDateRange();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        '2. 导出内容预览',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        avatar: const Icon(Icons.description_outlined, size: 16),
                        label: Text('共 ${_filteredRecords.length} 条'),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          mdPreview,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text(
                        '复制 Markdown 数据到剪贴板',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
