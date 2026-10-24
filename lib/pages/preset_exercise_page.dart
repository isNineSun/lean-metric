import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../models/preset_exercise_model.dart';

class PresetExercisePage extends StatefulWidget {
  const PresetExercisePage({super.key});

  @override
  State<PresetExercisePage> createState() => _PresetExercisePageState();
}

class _PresetExercisePageState extends State<PresetExercisePage> {
  List<PresetExercise> _allExercises = [];
  List<PresetExercise> _filteredExercises = [];
  bool _isLoading = true;

  // 筛选类型：null 代表全部，ExerciseType.strength 代表力量，ExerciseType.aerobic 代表有氧
  ExerciseType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final list = await RecordRepository.instance.getAllPresetExercises();
    if (mounted) {
      setState(() {
        _allExercises = list;
        _isLoading = false;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filterType == null) {
        _filteredExercises = List.from(_allExercises);
      } else {
        _filteredExercises =
            _allExercises.where((e) => e.type == _filterType).toList();
      }
    });
  }

  Future<void> _showAddOrEditDialog({PresetExercise? exercise}) async {
    final isEditing = exercise != null;
    ExerciseType selectedType = exercise?.type ?? ExerciseType.strength;
    final titleController = TextEditingController(text: exercise?.title ?? '');
    final capacityController =
        TextEditingController(text: exercise?.capacity ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? '编辑训练预设' : '新增训练预设'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '运动分类',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('力量训练')),
                            selected: selectedType == ExerciseType.strength,
                            selectedColor: Colors.orange.shade100,
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  selectedType = ExerciseType.strength;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('有氧运动')),
                            selected: selectedType == ExerciseType.aerobic,
                            selectedColor: Colors.blue.shade100,
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  selectedType = ExerciseType.aerobic;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: '训练名称',
                        hintText: selectedType == ExerciseType.strength
                            ? '如：卧推、深蹲、硬拉'
                            : '如：配速跑、慢跑、单车',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: capacityController,
                      decoration: InputDecoration(
                        labelText: '容量 & 强度',
                        hintText: selectedType == ExerciseType.strength
                            ? '如：60kg 5组x10次'
                            : '如：5公里 25分钟',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入训练名称')),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final newTitle = titleController.text.trim();
      final newCapacity = capacityController.text.trim();

      if (isEditing) {
        final updated = exercise.copyWith(
          title: newTitle,
          capacity: newCapacity,
          type: selectedType,
        );
        await RecordRepository.instance.updatePresetExercise(updated);
      } else {
        final newExercise = PresetExercise(
          title: newTitle,
          capacity: newCapacity,
          type: selectedType,
        );
        await RecordRepository.instance.insertPresetExercise(newExercise);
      }
      _loadExercises();
    }
  }

  Future<void> _deleteExercise(PresetExercise exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除训练预设“${exercise.title}”吗？'),
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

    if (confirm == true && exercise.id != null) {
      await RecordRepository.instance.deletePresetExercise(exercise.id!);
      _loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新增训练预设',
            onPressed: () => _showAddOrEditDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('全部'),
                        selected: _filterType == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filterType = null;
                              _applyFilter();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('力量训练'),
                        selected: _filterType == ExerciseType.strength,
                        selectedColor: Colors.orange.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _filterType =
                                selected ? ExerciseType.strength : null;
                            _applyFilter();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('有氧运动'),
                        selected: _filterType == ExerciseType.aerobic,
                        selectedColor: Colors.blue.shade100,
                        onSelected: (selected) {
                          setState(() {
                            _filterType =
                                selected ? ExerciseType.aerobic : null;
                            _applyFilter();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '暂无训练预设',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '点击右上角“+”号添加常见力量或有氧项目',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            final isStrength =
                                exercise.type == ExerciseType.strength;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isStrength
                                      ? Colors.orange.shade100
                                      : Colors.blue.shade100,
                                  child: Icon(
                                    isStrength
                                        ? Icons.fitness_center
                                        : Icons.directions_run,
                                    color: isStrength
                                        ? Colors.orange.shade800
                                        : Colors.blue.shade800,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  exercise.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: exercise.capacity.isNotEmpty
                                    ? Text(
                                        exercise.capacity,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => _showAddOrEditDialog(
                                          exercise: exercise),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteExercise(exercise),
                                    ),
                                  ],
                                ),
                                onTap: () =>
                                    _showAddOrEditDialog(exercise: exercise),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
