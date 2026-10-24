import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../models/preset_food_model.dart';

class PresetDietPage extends StatefulWidget {
  const PresetDietPage({super.key});

  @override
  State<PresetDietPage> createState() => _PresetDietPageState();
}

class _PresetDietPageState extends State<PresetDietPage> {
  List<PresetFood> _presetFoods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresetFoods();
  }

  Future<void> _loadPresetFoods() async {
    final list = await RecordRepository.instance.getAllPresetFoods();
    if (mounted) {
      setState(() {
        _presetFoods = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddOrEditDialog({PresetFood? food}) async {
    final isEditing = food != null;
    final titleController = TextEditingController(text: food?.title ?? '');
    final descController = TextEditingController(text: food?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? '编辑预设餐食' : '新增预设餐食'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '餐食/食物名称',
                  hintText: '如：蛋白粉、鸡胸肉',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '份量/描述（可选）',
                  hintText: '如：30g、生重200g 空炸',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
                    const SnackBar(content: Text('请输入餐食名称')),
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

    if (result == true) {
      final newTitle = titleController.text.trim();
      final newDesc = descController.text.trim();

      if (isEditing) {
        final updated = food.copyWith(
          title: newTitle,
          description: newDesc,
        );
        await RecordRepository.instance.updatePresetFood(updated);
      } else {
        final newFood = PresetFood(
          title: newTitle,
          description: newDesc,
        );
        await RecordRepository.instance.insertPresetFood(newFood);
      }
      _loadPresetFoods();
    }
  }

  Future<void> _deleteFood(PresetFood food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除预设词条“${food.title}”吗？'),
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

    if (confirm == true && food.id != null) {
      await RecordRepository.instance.deletePresetFood(food.id!);
      _loadPresetFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预设饮食'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新增预设',
            onPressed: () => _showAddOrEditDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _presetFoods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无预设饮食词条',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击右上角“+”号添加常用词条',
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
                  itemCount: _presetFoods.length,
                  itemBuilder: (context, index) {
                    final food = _presetFoods[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          food.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: food.description.isNotEmpty
                            ? Text(
                                food.description,
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
                              onPressed: () => _showAddOrEditDialog(food: food),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _deleteFood(food),
                            ),
                          ],
                        ),
                        onTap: () => _showAddOrEditDialog(food: food),
                      ),
                    );
                  },
                ),
    );
  }
}
