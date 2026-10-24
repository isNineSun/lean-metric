import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../models/record_model.dart';
import '../widgets/record_card.dart';
import 'export_page.dart';
import 'preset_diet_page.dart';
import 'preset_exercise_page.dart';
import 'record_detail_page.dart';
import 'record_edit_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Record> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await RecordRepository.instance.getAllRecords();

    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _openRecordPage() async {
    final result = await Navigator.push<Record>(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordEditPage(),
      ),
    );

    if (result != null) {
      await RecordRepository.instance.insertRecord(result);
      await _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('减脂记录'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openRecordPage,
          ),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    '减脂记录',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('首页'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('数据统计'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsPage(),
                    ),
                  );
                  _loadRecords();
                },
              ),

              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('预设饮食'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PresetDietPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('训练记录'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PresetExercisePage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.file_upload_outlined),
                title: const Text('数据导出'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                  _loadRecords();
                },
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _records.isEmpty
              ? const Center(
                  child: Text(
                    '暂无减脂记录',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: RecordCard(
                          record: record,
                          onTap: () async {
                            final result = await Navigator.push<dynamic>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecordDetailPage(
                                  record: record,
                                ),
                              ),
                            );

                            if (result is Record) {
                              await RecordRepository.instance
                                  .updateRecord(result);
                              await _loadRecords();
                            } else if (result == 'DELETE') {
                              await _loadRecords();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
