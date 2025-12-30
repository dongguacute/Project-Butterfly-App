import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/database_helper.dart';
import 'add_plan_page.dart';

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

  Widget _colorOption(Color color, Color selectedColor, Function(Color) onSelect) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
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
              title: plan.title,
              subtitle: plan.subtitle,
              progress: plan.progress,
              icon: _getIconData(plan.iconName),
              color: Color(plan.colorValue),
              planType: plan.planType,
              thighCircumference: plan.thighCircumference,
              calfCircumference: plan.calfCircumference,
              isThighClosed: plan.isThighClosed,
              isCalfClosed: plan.isCalfClosed,
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

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color color,
    String? planType,
    double? thighCircumference,
    double? calfCircumference,
    bool? isThighClosed,
    bool? isCalfClosed,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
    );
  }
}
