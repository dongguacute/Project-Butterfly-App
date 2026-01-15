import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../algorithms/leg_algorithm.dart';
import 'add_plan_page.dart';
import 'plan_detail_page.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Plan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final plans = await _dbHelper.getPlans();
    setState(() {
      _plans = plans;
      _isLoading = false;
    });
  }

  void showAddPlanDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddPlanPage(),
    );

    if (result == true) {
      _loadPlans();
    }
  }

  Future<void> _deletePlan(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除计划'),
        content: const Text('确定要删除这个计划吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deletePlan(id);
      await NotificationService().cancelNotification(id);
      _loadPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        if (_plans.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text('暂无计划，点击右下角添加一个吧', 
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          )
        else
          ..._plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(
              context,
              plan,
              onDelete: () => _deletePlan(plan.id!),
            ),
          )),
        ],
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'face_retouching_natural_rounded': return Icons.face_retouching_natural_rounded;
      case 'directions_run_rounded': return Icons.directions_run_rounded;
      case 'monitor_weight_rounded': return Icons.monitor_weight_rounded;
      case 'menu_book_rounded': return Icons.menu_book_rounded;
      default: return Icons.assignment_rounded;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '加油，',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '今天的计划都在这里',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLegInfoChip(BuildContext context, String label, String value, bool? isClosed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (isClosed == true) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle_outline_rounded,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegAnalysis(BuildContext context, Plan plan) {
    if (plan.planType != '腿部计划') return const SizedBox.shrink();
    
    final analysis = LegAlgorithm.analyzeLegData(plan);

    if (analysis['status'] != 'success') return const SizedBox.shrink();

    final data = analysis['data'];
    final bool isGoalAchieved = data['isGoalAchieved'] ?? false;
    final currentDay = plan.currentDay;
    final reminderTime = plan.reminderTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isGoalAchieved)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '目标已达成！太棒了！',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Text(
              '智能评估: ${data['legShapeStatus']}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data['muscleType'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            if (data['targetShape'] != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data['targetShape'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '比例分析: ${data['ratioDescription']} (比值 ${data['ratio']})',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        ...(data['suggestions'] as List<String>).map((s) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              Expanded(
                child: Text(
                  s,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日训练任务 (第 $currentDay 天)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...(data['dailyTasks'] as List<String>).map((task) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                task == '休息日' ? Icons.bedtime_outlined : Icons.fitness_center,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    Plan plan, {
    VoidCallback? onDelete,
  }) {
    final title = plan.title;
    final subtitle = plan.subtitle;
    final progress = plan.progress;
    final icon = _getIconData(plan.iconName);
    final color = Color(plan.colorValue);
    final planType = plan.planType;
    final thighCircumference = plan.thighCircumference;
    final calfCircumference = plan.calfCircumference;
    final isThighClosed = plan.isThighClosed;
    final isCalfClosed = plan.isCalfClosed;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanDetailPage(plan: plan),
            ),
          ).then((_) => _loadPlans());
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (planType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  planType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (plan.reminderTime != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.notifications_active_outlined, size: 12, color: color.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                plan.reminderTime!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (planType == '腿部计划' && (thighCircumference != null || calfCircumference != null)) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (thighCircumference != null)
                                _buildLegInfoChip(context, '大腿', '$thighCircumference cm', isThighClosed),
                              if (thighCircumference != null && calfCircumference != null)
                                const SizedBox(width: 8),
                              if (calfCircumference != null)
                                _buildLegInfoChip(context, '小腿', '$calfCircumference cm', isCalfClosed),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildLegAnalysis(context, plan),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
