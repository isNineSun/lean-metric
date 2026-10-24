import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../models/record_model.dart';
import 'record_edit_page.dart';

class RecordDetailPage extends StatefulWidget {
  final Record record;

  const RecordDetailPage({
    super.key,
    required this.record,
  });

  @override
  State<RecordDetailPage> createState() =>
      _RecordDetailPageState();
}

class _RecordDetailPageState
    extends State<RecordDetailPage> {
  late Record _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _editRecord() async {
    final result = await Navigator.push<Record>(
      context,
      MaterialPageRoute(
        builder: (context) => RecordEditPage(
          record: _record,
        ),
      ),
    );

    if (result != null) {
      await RecordRepository.instance.updateRecord(result);
      if (mounted) {
        setState(() {
          _record = result;
        });
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条减脂记录吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _record.id != null) {
      await RecordRepository.instance.deleteRecord(_record.id!);
      if (mounted) {
        Navigator.pop(context, 'DELETE');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _record);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('减脂记录详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _record);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '删除',
              onPressed: _deleteRecord,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: '编辑',
              onPressed: _editRecord,
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateHeader(),

              const SizedBox(height: 16),

              _buildBasicSection(),

              const SizedBox(height: 16),

              _buildFoodSection(),

              const SizedBox(height: 16),

              _buildTextSection(
                title: '3. 运动与活动',
                content: _record.exercise,
              ),

              const SizedBox(height: 16),

              _buildTextSection(
                title: '4. 今日状态',
                content: _record.status,
              ),

              const SizedBox(height: 16),

              _buildSpecialSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 36,
            ),

            const SizedBox(height: 12),

            Text(
              _formatDate(_record.date),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              '减脂记录',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSection() {
    return _buildSectionCard(
      title: '1. 基础数据',
      children: [
        _buildInfoRow(
          icon: Icons.monitor_weight_outlined,
          label: '体重',
          value: _record.weight == null
              ? '--'
              : '${_record.weight} kg',
        ),

        _buildInfoRow(
          icon: Icons.check_circle_outline,
          label: '早晨空腹',
          value: _record.isFasting ? '是' : '否',
        ),

        _buildInfoRow(
          icon: Icons.bedtime_outlined,
          label: '入睡时间',
          value: _record.sleepStart ?? '--',
        ),

        _buildInfoRow(
          icon: Icons.wb_sunny_outlined,
          label: '起床时间',
          value: _record.sleepEnd ?? '--',
        ),

        _buildInfoRow(
          icon: Icons.timelapse,
          label: '睡眠时长',
          value: _formatSleepDuration(),
        ),

        _buildInfoRow(
          icon: Icons.directions_walk,
          label: '今日步数',
          value: _record.steps == null
              ? '--'
              : '${_record.steps} 步',
        ),
      ],
    );
  }

  Widget _buildFoodSection() {
    return _buildSectionCard(
      title: '2. 饮食记录',
      children: [
        _buildTextContent(
          title: '早餐',
          content: _record.breakfast,
        ),

        _buildTextContent(
          title: '午餐',
          content: _record.lunch,
        ),

        _buildTextContent(
          title: '晚餐',
          content: _record.dinner,
        ),

        _buildTextContent(
          title: '其他',
          content: _record.otherFood,
        ),
      ],
    );
  }

  Widget _buildTextSection({
    required String title,
    required String content,
  }) {
    return _buildSectionCard(
      title: title,
      children: [
        _buildTextContent(
          title: '记录',
          content: content,
        ),
      ],
    );
  }

  Widget _buildSpecialSection() {
    return _buildSectionCard(
      title: '5. 特殊情况',
      children: [
        if (_record.specialCases.isEmpty)
          const Text('无')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _record.specialCases
                .map(
                  (item) => Chip(
                    label: Text(item),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: 16),

        _buildTextContent(
          title: '具体情况',
          content: _record.specialNote,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
          ),

          const SizedBox(width: 12),

          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            content.isEmpty ? '未记录' : content,
            style: TextStyle(
              fontSize: 15,
              color: content.isEmpty ? Colors.grey : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSleepDuration() {
    final minutes = _record.sleepDurationMinutes;

    if (minutes == null) {
      return '--';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours 小时';
    }

    return '$hours 小时 $remainingMinutes 分钟';
  }
}
