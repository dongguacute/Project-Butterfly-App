import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../algorithms/leg_algorithm.dart';
import '../services/database_helper.dart';
import '../data/adjustment_data.dart';
import 'add_plan_page.dart';
import 'leg_adjustment_detail_page.dart';

class PlanDetailPage extends StatefulWidget {
  final Plan plan;
  const PlanDetailPage({super.key, required this.plan});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  late Plan _currentPlan;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
  }

  void _editPlan() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPlanPage(plan: _currentPlan),
    );

    if (result == true) {
      // 重新从数据库加载最新数据
      final dbHelper = DatabaseHelper();
      final updatedPlans = await dbHelper.getPlans();
      final updatedPlan = updatedPlans.firstWhere((p) => p.id == _currentPlan.id);
      setState(() {
        _currentPlan = updatedPlan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_currentPlan.colorValue);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, color),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context),
                  const SizedBox(height: 32),
                  if (_currentPlan.planType == '腿部计划') _buildLegDetails(context),
                  _buildGeneralInfo(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color color) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: color,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
          onPressed: _editPlan,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Center(
            child: Icon(
              _getIconData(_currentPlan.iconName),
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context, true), // 返回 true 提示父页面刷新
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(_currentPlan.colorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentPlan.planType ?? '通用计划',
                style: TextStyle(
                  color: Color(_currentPlan.colorValue),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '第 ${_currentPlan.currentDay} 天',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentPlan.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _currentPlan.subtitle,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLegDetails(BuildContext context) {
    final analysis = LegAlgorithm.analyzeLegData(_currentPlan);
    if (analysis['status'] != 'success') return const SizedBox.shrink();
    
    final data = analysis['data'] as Map<String, dynamic>;
    final bool isGoalAchieved = data['isGoalAchieved'] ?? false;
    final List<String> achievedGoals = List<String>.from(data['achievedGoals'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isGoalAchieved)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(_currentPlan.colorValue),
                  Color(_currentPlan.colorValue).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(_currentPlan.colorValue).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text(
                  '恭喜！目标已达成',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievedGoals.join(' • '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _editPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(_currentPlan.colorValue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('设定新目标', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '腿部评估报告',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (data['targetShape'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(_currentPlan.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(_currentPlan.colorValue).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.track_changes_rounded, size: 14, color: Color(_currentPlan.colorValue)),
                    const SizedBox(width: 4),
                    Text(
                      '目标: ${data['targetShape']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(_currentPlan.colorValue),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_currentPlan.weight != null) _buildStatCard(context, '体重', '${_currentPlan.weight}kg'),
            if (_currentPlan.weight != null && _currentPlan.height != null) const SizedBox(width: 12),
            if (_currentPlan.height != null) _buildStatCard(context, '身高', '${_currentPlan.height}cm'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(context, '大腿围', '${_currentPlan.thighCircumference}cm'),
            const SizedBox(width: 12),
            _buildStatCard(context, '小腿围', '${_currentPlan.calfCircumference}cm'),
          ],
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(context, data),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '今日训练清单',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _isProcessing ? null : _completeTodayTasks,
              icon: _isProcessing 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_rounded),
              label: Text(_isProcessing ? '处理中...' : '完成今日任务'),
              style: TextButton.styleFrom(
                foregroundColor: Color(_currentPlan.colorValue),
                backgroundColor: Color(_currentPlan.colorValue).withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ... (data['dailyTasks'] as List<String>).map((task) => _buildTaskItem(context, task)).toList(),
        const SizedBox(height: 32),
      ],
    );
  }

  void _completeTodayTasks() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final newDay = _currentPlan.currentDay + 1;
      // 假设总计划周期为28天，用于计算进度
      const totalDays = 28;
      final newProgress = (newDay - 1) / totalDays;
      
      final updatedPlan = Plan(
        id: _currentPlan.id,
        title: _currentPlan.title,
        subtitle: _currentPlan.subtitle,
        progress: newProgress > 1.0 ? 1.0 : newProgress,
        iconName: _currentPlan.iconName,
        colorValue: _currentPlan.colorValue,
        planType: _currentPlan.planType,
        thighCircumference: _currentPlan.thighCircumference,
        calfCircumference: _currentPlan.calfCircumference,
        isThighClosed: _currentPlan.isThighClosed,
        isCalfClosed: _currentPlan.isCalfClosed,
        isThighHard: _currentPlan.isThighHard,
        isCalfHard: _currentPlan.isCalfHard,
        isLegBoneStraight: _currentPlan.isLegBoneStraight,
        weight: _currentPlan.weight,
        height: _currentPlan.height,
        reminderTime: _currentPlan.reminderTime,
        currentDay: newDay,
        targetLegShape: _currentPlan.targetLegShape,
      );

      final dbHelper = DatabaseHelper();
      await dbHelper.updatePlan(updatedPlan);

      if (!mounted) return;

      setState(() {
        _currentPlan = updatedPlan;
        _isProcessing = false;
      });

      // 检查阶段完成 (每7天为一个阶段，排除第1天)
      if (newDay > 1 && (newDay - 1) % 7 == 0) {
        _showStageCompleteReminder();
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('第 ${_currentPlan.currentDay - 1} 天任务已完成！'),
            backgroundColor: Color(_currentPlan.colorValue),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showStageCompleteReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('阶段性目标达成！'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('恭喜！你已经完成了本阶段的训练计划。'),
            SizedBox(height: 16),
            Text('为了让后续计划更精准，建议你现在：', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• 重新测量腿部围度\n• 更新当前身高体重\n• 重新进行智能评估'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后再说', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editPlan();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(_currentPlan.colorValue),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('立即更新数据'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(_currentPlan.colorValue).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(_currentPlan.colorValue).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Color(_currentPlan.colorValue)),
              const SizedBox(width: 8),
              const Text('深度分析结果', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          if (data['bmi'] != '未知') _buildAnalysisRow('BMI 指数', '${data['bmi']} (${data['bmiStatus']})'),
          _buildAnalysisRow('腿型比例', '${data['ratioDescription']} (${data['ratio']})'),
          _buildAnalysisRow('肌肉类型', data['muscleType']),
          _buildAnalysisRow('腿型状态', data['legShapeStatus']),
          const SizedBox(height: 16),
          const Text('建议方案：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...(data['suggestions'] as List<String>).map((s) {
            final adjustment = AdjustmentData.allAdjustments.cast<dynamic>().firstWhere(
      (a) => s.contains(a.title),
      orElse: () => null,
    );
            
            return GestureDetector(
              onTap: adjustment != null 
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LegAdjustmentDetailPage(adjustment: adjustment),
                    ),
                  )
                : null,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 13, color: Colors.black87)),
                    Expanded(
                      child: Text(
                        s, 
                        style: TextStyle(
                          fontSize: 13, 
                          color: adjustment != null ? Colors.blue : Colors.black87,
                          decoration: adjustment != null ? TextDecoration.underline : null,
                        )
                      ),
                    ),
                    if (adjustment != null)
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, String task) {
    // 检查是否是可跳转的调整方式
    final adjustment = AdjustmentData.allAdjustments.cast<dynamic>().firstWhere(
      (a) => task.contains(a.title),
      orElse: () => null,
    );

    return GestureDetector(
      onTap: adjustment != null 
        ? () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LegAdjustmentDetailPage(
                adjustment: adjustment,
                themeColor: Color(_currentPlan.colorValue),
              ),
            ),
          )
        : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              task == '休息日' ? Icons.bedtime_rounded : Icons.check_circle_outline_rounded,
              color: task == '休息日' ? Colors.orange : Color(_currentPlan.colorValue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            if (adjustment != null) ...[
              const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(_currentPlan.colorValue).withOpacity(0.3),
              ),
            ] else
              Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfo(BuildContext context) {
    if (_currentPlan.reminderTime == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          const Text('每日提醒', style: TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            _currentPlan.reminderTime!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'face_retouching_natural_rounded': return Icons.face_retouching_natural_rounded;
      case 'monitor_weight_rounded': return Icons.monitor_weight_rounded;
      case 'directions_run_rounded': return Icons.directions_run_rounded;
      default: return Icons.assignment_rounded;
    }
  }
}
