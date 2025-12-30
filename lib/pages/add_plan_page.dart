import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/database_helper.dart';

class AddPlanPage extends StatefulWidget {
  const AddPlanPage({super.key});

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final thighController = TextEditingController();
  final calfController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Color selectedColor = Colors.deepPurple;
  String selectedType = '脸部计划';
  bool isThighClosed = false;
  bool isCalfClosed = false;

  final List<String> planTypes = ['脸部计划', '体重计划', '腿部计划'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
          // 顶部指示条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 自定义导航栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  '新建计划',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      String iconName = 'assignment_rounded';
                      if (selectedType == '脸部计划') {
                        iconName = 'face_retouching_natural_rounded';
                      } else if (selectedType == '体重计划') {
                        iconName = 'monitor_weight_rounded';
                      } else if (selectedType == '腿部计划') {
                        iconName = 'directions_run_rounded';
                      }

                      final newPlan = Plan(
                        title: titleController.text,
                        subtitle: subtitleController.text,
                        progress: 0.0,
                        iconName: iconName,
                        colorValue: selectedColor.value,
                        planType: selectedType,
                        thighCircumference: selectedType == '腿部计划' ? double.tryParse(thighController.text) : null,
                        calfCircumference: selectedType == '腿部计划' ? double.tryParse(calfController.text) : null,
                        isThighClosed: selectedType == '腿部计划' ? isThighClosed : null,
                        isCalfClosed: selectedType == '腿部计划' ? isCalfClosed : null,
                      );
                      await _dbHelper.insertPlan(newPlan);
                      if (mounted) {
                        Navigator.pop(context, true); // 返回 true 表示已添加新计划
                      }
                    }
                  },
                  child: Text(
                    '完成',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  '计划内容',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '你想做什么？',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(
                    hintText: '添加描述或备注...',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey.withOpacity(0.5)),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '计划类型',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: planTypes.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedType = type);
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                if (selectedType == '腿部计划') ...[
                  const SizedBox(height: 32),
                  const Text(
                    '腿部资料',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: thighController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '大腿围 (cm)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: calfController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '小腿围 (cm)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('大腿是否可并合', style: TextStyle(fontSize: 15)),
                    value: isThighClosed,
                    onChanged: (val) => setState(() => isThighClosed = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: selectedColor,
                  ),
                  SwitchListTile(
                    title: const Text('小腿是否可并合', style: TextStyle(fontSize: 15)),
                    value: isCalfClosed,
                    onChanged: (val) => setState(() => isCalfClosed = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: selectedColor,
                  ),
                ],
                const SizedBox(height: 32),
                const Text(
                  '个性化',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('主题色', style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _colorOption(Colors.deepPurple),
                          _colorOption(Colors.blue),
                          _colorOption(Colors.green),
                          _colorOption(Colors.orange),
                          _colorOption(Colors.pink),
                          _colorOption(Colors.teal),
                          _colorOption(Colors.red),
                          _colorOption(Colors.indigo),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _colorOption(Color color) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
      ),
    );
  }
}
