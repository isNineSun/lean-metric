import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/record_repository.dart';
import '../models/record_model.dart';

enum ChartTimeRange {
  days30,
  days90,
  all,
}

enum ChartDataType {
  raw, // 原始数据
  smoothed, // 平滑水肿 (7天移动平均)
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Record> _allRecords = [];
  bool _isLoading = true;

  ChartTimeRange _timeRange = ChartTimeRange.days30;
  ChartDataType _dataType = ChartDataType.raw;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await RecordRepository.instance.getAllRecords();
    if (mounted) {
      setState(() {
        _allRecords = list;
        _isLoading = false;
      });
    }
  }

  // =========================
  // 数据计算逻辑
  // =========================

  // 获取按时间顺序排列（旧 -> 新）的有效体重记录
  List<Record> _getWeightRecords() {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    List<Record> filtered;
    switch (_timeRange) {
      case ChartTimeRange.days30:
        final start = todayEnd.subtract(const Duration(days: 30));
        filtered =
            _allRecords.where((r) => r.date.isAfter(start) && r.weight != null).toList();
        break;
      case ChartTimeRange.days90:
        final start = todayEnd.subtract(const Duration(days: 90));
        filtered =
            _allRecords.where((r) => r.date.isAfter(start) && r.weight != null).toList();
        break;
      case ChartTimeRange.all:
        filtered = _allRecords.where((r) => r.weight != null).toList();
        break;
    }

    // 按日期正序排列（过去的在前，现在的在后）
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  // 计算平滑水肿（7天移动平均）
  List<double> _calculateMovingAverage(List<Record> weightRecords) {
    List<double> result = [];
    for (int i = 0; i < weightRecords.length; i++) {
      final currentDate = weightRecords[i].date;
      final windowStart = currentDate.subtract(const Duration(days: 6));

      // 找出当前日期及前 6 天（共 7 天窗口）内的所有体重记录
      final windowRecords = weightRecords
          .where((r) =>
              r.date.isAfter(windowStart.subtract(const Duration(seconds: 1))) &&
              r.date.isBefore(currentDate.add(const Duration(days: 1))))
          .map((r) => r.weight!)
          .toList();

      if (windowRecords.isNotEmpty) {
        final avg =
            windowRecords.reduce((a, b) => a + b) / windowRecords.length;
        result.add(avg);
      } else {
        result.add(weightRecords[i].weight!);
      }
    }
    return result;
  }

  // 计算本周 vs 上周的数据
  _WeeklySummary _calculateWeeklySummary() {
    final now = DateTime.now();
    // 找到本周一的 00:00:00
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));

    // 本周记录
    final thisWeekRecords = _allRecords
        .where((r) =>
            r.date.isAfter(thisMonday.subtract(const Duration(seconds: 1))))
        .toList();

    // 上周记录
    final lastWeekRecords = _allRecords
        .where((r) =>
            r.date.isAfter(lastMonday.subtract(const Duration(seconds: 1))) &&
            r.date.isBefore(thisMonday))
        .toList();

    // 本周平均体重
    final thisWeekWeights =
        thisWeekRecords.where((r) => r.weight != null).map((r) => r.weight!).toList();
    final thisWeekAvgWeight = thisWeekWeights.isNotEmpty
        ? thisWeekWeights.reduce((a, b) => a + b) / thisWeekWeights.length
        : null;

    // 上周平均体重
    final lastWeekWeights =
        lastWeekRecords.where((r) => r.weight != null).map((r) => r.weight!).toList();
    final lastWeekAvgWeight = lastWeekWeights.isNotEmpty
        ? lastWeekWeights.reduce((a, b) => a + b) / lastWeekWeights.length
        : null;

    // 本周日均步数
    final thisWeekSteps =
        thisWeekRecords.where((r) => r.steps != null).map((r) => r.steps!).toList();
    final thisWeekAvgSteps = thisWeekSteps.isNotEmpty
        ? (thisWeekSteps.reduce((a, b) => a + b) / thisWeekSteps.length).round()
        : null;

    // 本周平均睡眠
    final thisWeekSleep = thisWeekRecords
        .where((r) => r.sleepDurationMinutes != null)
        .map((r) => r.sleepDurationMinutes!)
        .toList();
    final thisWeekAvgSleep = thisWeekSleep.isNotEmpty
        ? (thisWeekSleep.reduce((a, b) => a + b) / thisWeekSleep.length).round()
        : null;

    return _WeeklySummary(
      thisWeekAvgWeight: thisWeekAvgWeight,
      lastWeekAvgWeight: lastWeekAvgWeight,
      thisWeekAvgSteps: thisWeekAvgSteps,
      thisWeekAvgSleep: thisWeekAvgSleep,
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightRecords = _getWeightRecords();
    final weeklySummary = _calculateWeeklySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无统计数据',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '请先在首页新增减脂记录',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 本周数据汇总卡片
                      _buildWeeklySummaryCard(weeklySummary),

                      const SizedBox(height: 20),

                      // 2. 体重趋势图表卡片
                      _buildWeightChartCard(weightRecords),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  // =========================
  // 1. 周汇总卡片 UI
  // =========================

  Widget _buildWeeklySummaryCard(_WeeklySummary summary) {
    final weightDiff = (summary.thisWeekAvgWeight != null &&
            summary.lastWeekAvgWeight != null)
        ? summary.thisWeekAvgWeight! - summary.lastWeekAvgWeight!
        : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.teal, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '本周数据汇总',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 体重对比区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本周平均体重',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        summary.thisWeekAvgWeight != null
                            ? summary.thisWeekAvgWeight!.toStringAsFixed(1)
                            : '--',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),

                      // 对比趋势 Chip
                      if (weightDiff != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: weightDiff <= 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: weightDiff <= 0
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                weightDiff <= 0
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                size: 16,
                                color: weightDiff <= 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '较上周 ${weightDiff > 0 ? "+" : ""}${weightDiff.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: weightDiff <= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          '暂无上周对比数据',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 步数与睡眠汇总
            Row(
              children: [
                Expanded(
                  child: _buildSummarySubItem(
                    icon: Icons.directions_walk,
                    iconColor: Colors.blue,
                    title: '本周日均步数',
                    value: summary.thisWeekAvgSteps != null
                        ? '${summary.thisWeekAvgSteps} 步'
                        : '--',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummarySubItem(
                    icon: Icons.bedtime_outlined,
                    iconColor: Colors.indigo,
                    title: '平均睡眠时长',
                    value: summary.formatSleep(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySubItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 2. 体重趋势图表卡片 UI
  // =========================

  Widget _buildWeightChartCard(List<Record> weightRecords) {
    final smoothedValues = _calculateMovingAverage(weightRecords);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.teal, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '体重变化趋势',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 模式与时间切换按钮组
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 数据模式切换：原始数据 vs 平滑水肿
                SegmentedButton<ChartDataType>(
                  segments: const [
                    ButtonSegment(
                      value: ChartDataType.raw,
                      label: Text('原始数据'),
                      icon: Icon(Icons.timeline, size: 16),
                    ),
                    ButtonSegment(
                      value: ChartDataType.smoothed,
                      label: Text('平滑水肿'),
                      icon: Icon(Icons.waves, size: 16),
                    ),
                  ],
                  selected: {_dataType},
                  onSelectionChanged: (set) {
                    setState(() {
                      _dataType = set.first;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // 时间范围切换：30天 / 90天 / 全部
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('近 30 天'),
                      selected: _timeRange == ChartTimeRange.days30,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _timeRange = ChartTimeRange.days30;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('近 90 天'),
                      selected: _timeRange == ChartTimeRange.days90,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _timeRange = ChartTimeRange.days90;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('全部'),
                      selected: _timeRange == ChartTimeRange.all,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _timeRange = ChartTimeRange.all;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 图表展示区域
            weightRecords.isEmpty
                ? const SizedBox(
                    height: 180,
                    child: Center(
                      child: Text('选定时间范围内暂无体重记录'),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 1.6,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, top: 12),
                      child: LineChart(
                        _buildLineChartData(weightRecords, smoothedValues),
                      ),
                    ),
                  ),

            const SizedBox(height: 12),

            // 图表说明文字
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _dataType == ChartDataType.smoothed
                        ? '说明：平滑水肿采用 7 天移动平均计算，可有效平滑体内水分抖动。'
                        : '说明：原始数据展示每日真实打卡体重。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建 fl_chart 的 LineChartData
  LineChartData _buildLineChartData(
    List<Record> weightRecords,
    List<double> smoothedValues,
  ) {
    final isSmoothed = _dataType == ChartDataType.smoothed;

    // 获取 y 轴数值点
    final values = isSmoothed
        ? smoothedValues
        : weightRecords.map((r) => r.weight!).toList();

    double minY = values.reduce((a, b) => a < b ? a : b) - 1.5;
    double maxY = values.reduce((a, b) => a > b ? a : b) + 1.5;

    if (minY < 0) minY = 0;

    List<FlSpot> spots = [];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: (weightRecords.length / 4).clamp(1.0, 100.0),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < weightRecords.length) {
                final date = weightRecords[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (weightRecords.length - 1).toDouble().clamp(0.0, 1000.0),
      minY: minY,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.x.toInt();
              if (idx >= 0 && idx < weightRecords.length) {
                final date = weightRecords[idx].date;
                final dateStr = '${date.year}-${date.month}-${date.day}';
                final valStr = spot.y.toStringAsFixed(1);
                return LineTooltipItem(
                  '$dateStr\n$valStr kg',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: isSmoothed,
          color: isSmoothed ? Colors.teal : Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: weightRecords.length <= 30,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: (isSmoothed ? Colors.teal : Colors.green).withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

// 辅助数据结构
class _WeeklySummary {
  final double? thisWeekAvgWeight;
  final double? lastWeekAvgWeight;
  final int? thisWeekAvgSteps;
  final int? thisWeekAvgSleep;

  _WeeklySummary({
    this.thisWeekAvgWeight,
    this.lastWeekAvgWeight,
    this.thisWeekAvgSteps,
    this.thisWeekAvgSleep,
  });

  String formatSleep() {
    if (thisWeekAvgSleep == null) return '--';
    final h = thisWeekAvgSleep! ~/ 60;
    final m = thisWeekAvgSleep! % 60;
    if (m == 0) return '$h 小时';
    return '$h 小时 $m 分钟';
  }
}
