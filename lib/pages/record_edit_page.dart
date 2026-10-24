import 'package:flutter/material.dart';
import '../data/record_repository.dart';
import '../models/preset_exercise_model.dart';
import '../models/record_model.dart';
import 'preset_diet_page.dart';
import 'preset_exercise_page.dart';

class RecordEditPage extends StatefulWidget {
  final Record? record;

  const RecordEditPage({
    super.key,
    this.record,
  });

  @override
  State<RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends State<RecordEditPage> {

  bool get _isEditing => widget.record != null;

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value == '--:--') {
      return null;
    }

    final parts = value.split(':');

    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    // 如果是编辑模式，就把原来的数据填入输入框
    if (record != null) {
      _weightController.text =
          record.weight?.toString() ?? '';

      _stepsController.text =
          record.steps?.toString() ?? '';

      _isFasting = record.isFasting;

      _breakfastController.text =
          record.breakfast;

      _lunchController.text =
          record.lunch;

      _dinnerController.text =
          record.dinner;

      _otherFoodController.text =
          record.otherFood;

      _exerciseController.text =
          record.exercise;

      _statusController.text =
          record.status;

      _specialCases.addAll(
        record.specialCases,
      );

      _specialNoteController.text =
          record.specialNote;

      _sleepStart =
          _parseTime(record.sleepStart);

      _sleepEnd =
          _parseTime(record.sleepEnd);

      if (record.sleepDurationMinutes != null) {
        final hours = record.sleepDurationMinutes! / 60.0;
        _sleepDurationController.text = hours % 1 == 0
            ? hours.toInt().toString()
            : hours.toStringAsFixed(1);
      }
    }
  }

  // =========================
  // 基础数据
  // =========================

  final TextEditingController _weightController =
  TextEditingController();

  final TextEditingController _sleepDurationController =
  TextEditingController();

  final TextEditingController _stepsController =
  TextEditingController();

  bool _isFasting = true;

  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;

  // =========================
  // 饮食
  // =========================

  final TextEditingController _breakfastController =
  TextEditingController();

  final TextEditingController _lunchController =
  TextEditingController();

  final TextEditingController _dinnerController =
  TextEditingController();

  final TextEditingController _otherFoodController =
  TextEditingController();

  // =========================
  // 运动与状态
  // =========================

  final TextEditingController _exerciseController =
  TextEditingController();

  final TextEditingController _statusController =
  TextEditingController();

  // =========================
  // 特殊情况
  // =========================

  final Set<String> _specialCases = {};

  final TextEditingController _specialNoteController =
  TextEditingController();

  static const List<String> _specialCaseOptions = [
    '加班',
    '出差',
    '聚餐',
    '计划外高热量食物',
    '其他',
  ];

  // =========================
  // 页面销毁时释放控制器
  // =========================

  @override
  void dispose() {
    _weightController.dispose();
    _sleepDurationController.dispose();
    _stepsController.dispose();

    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _otherFoodController.dispose();

    _exerciseController.dispose();
    _statusController.dispose();

    _specialNoteController.dispose();

    super.dispose();
  }

  // =========================
  // 时间选择
  // =========================

  Future<void> _selectSleepStart() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _sleepStart ?? const TimeOfDay(hour: 23, minute: 0),
    );

    if (result != null) {
      setState(() {
        _sleepStart = result;
        _updateDurationFromTimes();
      });
    }
  }

  Future<void> _selectSleepEnd() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _sleepEnd ?? const TimeOfDay(hour: 7, minute: 30),
    );

    if (result != null) {
      setState(() {
        _sleepEnd = result;
        _updateDurationFromTimes();
      });
    }
  }

  void _updateDurationFromTimes() {
    final minutes = _calculateSleepDurationMinutes();
    if (minutes != null) {
      final hours = minutes / 60.0;
      _sleepDurationController.text = hours % 1 == 0
          ? hours.toInt().toString()
          : hours.toStringAsFixed(1);
    }
  }



  // =========================
  // 时间显示
  // =========================

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '--:--';
    }

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  int? _calculateSleepDurationMinutes() {
    if (_sleepStart == null || _sleepEnd == null) {
      return null;
    }

    int startMinutes =
        _sleepStart!.hour * 60 + _sleepStart!.minute;

    int endMinutes =
        _sleepEnd!.hour * 60 + _sleepEnd!.minute;

    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60;
    }

    return endMinutes - startMinutes;
  }

  // =========================
  // 录入
  // =========================

  void _saveRecord() {
    final hoursInput = double.tryParse(_sleepDurationController.text);
    final sleepMinutes = hoursInput != null
        ? (hoursInput * 60).round()
        : _calculateSleepDurationMinutes();

    final record = Record(
      id: widget.record?.id,
      date: widget.record?.date ?? DateTime.now(),

      weight: double.tryParse(
        _weightController.text,
      ),

      isFasting: _isFasting,

      sleepStart: _formatTime(_sleepStart),
      sleepEnd: _formatTime(_sleepEnd),

      sleepDurationMinutes: sleepMinutes,

      steps: int.tryParse(
        _stepsController.text,
      ),

      breakfast: _breakfastController.text,
      lunch: _lunchController.text,
      dinner: _dinnerController.text,
      otherFood: _otherFoodController.text,

      exercise: _exerciseController.text,
      status: _statusController.text,

      specialCases: List<String>.from(
        _specialCases,
      ),

      specialNote: _specialNoteController.text,
    );

    Navigator.pop(context, record);
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _saveRecord();
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? '编辑减脂记录' : '新建减脂记录',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_isEditing) {
                _saveRecord();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: _saveRecord,
              child: Text(
                _isEditing ? '保存' : '录入',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBasicSection(),

              const SizedBox(height: 16),

              _buildFoodSection(),

              const SizedBox(height: 16),

              _buildExerciseSection(),

              const SizedBox(height: 16),

              _buildStatusSection(),

              const SizedBox(height: 16),

              _buildSpecialSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 1. 基础数据
  // =========================

  Widget _buildBasicSection() {
    final bool hasBothSleepTimes = _sleepStart != null && _sleepEnd != null;

    return _buildSectionCard(
      title: '1. 基础数据',
      children: [
        _buildDateRow(),

        const SizedBox(height: 20),

        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: '体重',
            suffixText: 'kg',
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 8),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('早晨空腹'),
          value: _isFasting,
          onChanged: (value) {
            setState(() {
              _isFasting = value ?? false;
            });
          },
        ),

        const SizedBox(height: 12),

        // 1. 睡眠时长（若入睡/起床时间均有选则自动锁定不可手动编辑）
        TextField(
          controller: _sleepDurationController,
          readOnly: hasBothSleepTimes,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '睡眠时长',
            hintText: '例：8 或 7.5',
            suffixText: '小时',
            prefixIcon: const Icon(Icons.bedtime_outlined),
            suffixIcon: hasBothSleepTimes
                ? const Tooltip(
                    message: '已由入睡/起床时间自动计算',
                    child: Icon(Icons.lock_outline, size: 18),
                  )
                : null,
            helperText: hasBothSleepTimes ? '已由入睡与起床时间自动计算' : null,
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        // 2. 入睡时间与起床时间
        Row(
          children: [
            Expanded(
              child: _buildTimeButton(
                label: '入睡时间',
                time: _sleepStart,
                onPressed: _selectSleepStart,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildTimeButton(
                label: '起床时间',
                time: _sleepEnd,
                onPressed: _selectSleepEnd,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _stepsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '今日步数',
            suffixText: '步',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    final displayDate = widget.record?.date ?? DateTime.now();

    final date =
        '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-'
        '${displayDate.day.toString().padLeft(2, '0')}';

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined),

        const SizedBox(width: 12),

        const Text(
          '记录日期',
          style: TextStyle(
            fontSize: 16,
          ),
        ),

        const Spacer(),

        Text(
          date,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
      child: Column(
        children: [
          Text(label),

          const SizedBox(height: 4),

          Text(
            _formatTime(time),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPresetPicker(TextEditingController controller) async {
    final presets = await RecordRepository.instance.getAllPresetFoods();

    if (!mounted) return;

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('暂无预设餐食词条，可前往侧边栏“预设饮食”添加'),
          action: SnackBarAction(
            label: '去添加',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PresetDietPage(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      '点击选择要插入的词条',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: presets.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final food = presets[index];
                    return ListTile(
                      title: Text(
                        food.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: food.description.isNotEmpty
                          ? Text(food.description)
                          : null,
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onTap: () {
                        final insertText = food.displayText;
                        if (controller.text.isEmpty) {
                          controller.text = insertText;
                        } else {
                          controller.text = '${controller.text}\n$insertText';
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // 2. 饮食
  // =========================

  Widget _buildFoodSection() {
    return _buildSectionCard(
      title: '2. 饮食记录',
      children: [
        _buildMultiLineInput(
          label: '早餐',
          controller: _breakfastController,
          onAddPreset: () => _showPresetPicker(_breakfastController),
        ),

        const SizedBox(height: 16),

        _buildMultiLineInput(
          label: '午餐',
          controller: _lunchController,
          onAddPreset: () => _showPresetPicker(_lunchController),
        ),

        const SizedBox(height: 16),

        _buildMultiLineInput(
          label: '晚餐',
          controller: _dinnerController,
          onAddPreset: () => _showPresetPicker(_dinnerController),
        ),

        const SizedBox(height: 16),

        _buildMultiLineInput(
          label: '其他',
          controller: _otherFoodController,
          onAddPreset: () => _showPresetPicker(_otherFoodController),
        ),
      ],
    );
  }

  Future<void> _showExercisePresetPicker(TextEditingController controller) async {
    final exercises = await RecordRepository.instance.getAllPresetExercises();

    if (!mounted) return;

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('暂无训练预设，可前往侧边栏“训练记录”添加'),
          action: SnackBarAction(
            label: '去添加',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PresetExercisePage(),
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      '点击选择要插入的训练项',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: exercises.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isStrength = exercise.type == ExerciseType.strength;

                    return ListTile(
                      leading: Icon(
                        isStrength ? Icons.fitness_center : Icons.directions_run,
                        color: isStrength ? Colors.orange : Colors.blue,
                      ),
                      title: Text(
                        exercise.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: exercise.capacity.isNotEmpty
                          ? Text(exercise.capacity)
                          : null,
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onTap: () {
                        final insertText = exercise.displayText;
                        if (controller.text.isEmpty) {
                          controller.text = insertText;
                        } else {
                          controller.text = '${controller.text}\n$insertText';
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // 3. 运动
  // =========================

  Widget _buildExerciseSection() {
    return _buildSectionCard(
      title: '3. 运动与活动',
      children: [
        _buildMultiLineInput(
          label: '今天进行了哪些运动或活动？',
          controller: _exerciseController,
          minLines: 4,
          onAddPreset: () => _showExercisePresetPicker(_exerciseController),
        ),
      ],
    );
  }

  // =========================
  // 4. 今日状态
  // =========================

  Widget _buildStatusSection() {
    return _buildSectionCard(
      title: '4. 今日状态',
      children: [
        _buildMultiLineInput(
          label: '今天的身体、精神、饥饿感等状态',
          controller: _statusController,
          minLines: 4,
        ),
      ],
    );
  }

  // =========================
  // 5. 特殊情况
  // =========================

  Widget _buildSpecialSection() {
    return _buildSectionCard(
      title: '5. 特殊情况',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _specialCaseOptions.map((item) {
            return FilterChip(
              label: Text(item),
              selected: _specialCases.contains(item),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _specialCases.add(item);
                  } else {
                    _specialCases.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        _buildMultiLineInput(
          label: '具体情况',
          controller: _specialNoteController,
          minLines: 4,
        ),
      ],
    );
  }

  // =========================
  // 通用 Card
  // =========================

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

            const SizedBox(height: 20),

            ...children,
          ],
        ),
      ),
    );
  }

  // =========================
  // 通用多行输入框
  // =========================

  Widget _buildMultiLineInput({
    required String label,
    required TextEditingController controller,
    int minLines = 3,
    VoidCallback? onAddPreset,
    String hintText = '可换行分隔多项......',
  }) {
    if (onAddPreset != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                  size: 22,
                ),
                tooltip: '插入预设词条',
                onPressed: onAddPreset,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: hintText,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      );
    }

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}