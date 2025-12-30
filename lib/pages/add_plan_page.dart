import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/database_helper.dart';

class AddPlanPage extends StatefulWidget {
  final Plan? plan;
  const AddPlanPage({super.key, this.plan});

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  late TextEditingController thighController;
  late TextEditingController calfController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController targetThighController;
  late TextEditingController targetCalfController;
  late TextEditingController targetWeightController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Color selectedColor;
  late String selectedType;
  late bool isThighClosed;
  late bool isCalfClosed;
  late bool isThighHard;
  late bool isCalfHard;
  TimeOfDay? reminderTime;
  late String selectedTargetShape;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.plan?.title ?? '');
    subtitleController = TextEditingController(text: widget.plan?.subtitle ?? '');
    thighController = TextEditingController(text: widget.plan?.thighCircumference?.toString() ?? '');
    calfController = TextEditingController(text: widget.plan?.calfCircumference?.toString() ?? '');
    weightController = TextEditingController(text: widget.plan?.weight?.toString() ?? '');
    heightController = TextEditingController(text: widget.plan?.height?.toString() ?? '');
    targetThighController = TextEditingController(text: widget.plan?.targetThighCircumference?.toString() ?? '');
    targetCalfController = TextEditingController(text: widget.plan?.targetCalfCircumference?.toString() ?? '');
    targetWeightController = TextEditingController(text: widget.plan?.targetWeight?.toString() ?? '');
    
    selectedColor = widget.plan != null ? Color(widget.plan!.colorValue) : Colors.deepPurple;
    selectedType = widget.plan?.planType ?? '脸部计划';
    isThighClosed = widget.plan?.isThighClosed ?? false;
    isCalfClosed = widget.plan?.isCalfClosed ?? false;
    isThighHard = widget.plan?.isThighHard ?? false;
    isCalfHard = widget.plan?.isCalfHard ?? false;
    selectedTargetShape = widget.plan?.targetLegShape ?? '匀称';
    
    if (widget.plan?.reminderTime != null) {
      final parts = widget.plan!.reminderTime!.split(':');
      if (parts.length == 2) {
        reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    thighController.dispose();
    calfController.dispose();
    weightController.dispose();
    heightController.dispose();
    targetThighController.dispose();
    targetCalfController.dispose();
    targetWeightController.dispose();
    super.dispose();
  }

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
                Text(
                  widget.plan == null ? '新建计划' : '编辑计划',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      try {
                        String iconName = 'assignment_rounded';
                        if (selectedType == '脸部计划') {
                          iconName = 'face_retouching_natural_rounded';
                        } else if (selectedType == '体重计划') {
                          iconName = 'monitor_weight_rounded';
                        } else if (selectedType == '腿部计划') {
                          iconName = 'directions_run_rounded';
                        }

                        final newPlan = Plan(
                          id: widget.plan?.id,
                          title: titleController.text,
                          subtitle: subtitleController.text,
                          progress: widget.plan?.progress ?? 0.0,
                          iconName: iconName,
                          colorValue: selectedColor.value,
                          planType: selectedType,
                          thighCircumference: selectedType == '腿部计划' ? double.tryParse(thighController.text) : null,
                          calfCircumference: selectedType == '腿部计划' ? double.tryParse(calfController.text) : null,
                          isThighClosed: selectedType == '腿部计划' ? isThighClosed : null,
                          isCalfClosed: selectedType == '腿部计划' ? isCalfClosed : null,
                          isThighHard: selectedType == '腿部计划' ? isThighHard : null,
                          isCalfHard: selectedType == '腿部计划' ? isCalfHard : null,
                          weight: selectedType == '腿部计划' ? double.tryParse(weightController.text) : null,
                          height: selectedType == '腿部计划' ? double.tryParse(heightController.text) : null,
                          reminderTime: reminderTime != null 
                            ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}' 
                            : null,
                          currentDay: widget.plan?.currentDay ?? 1,
                          targetLegShape: selectedType == '腿部计划' ? selectedTargetShape : null,
                          targetThighCircumference: selectedType == '腿部计划' ? double.tryParse(targetThighController.text) : null,
                          targetCalfCircumference: selectedType == '腿部计划' ? double.tryParse(targetCalfController.text) : null,
                          targetWeight: (selectedType == '体重计划' || selectedType == '腿部计划') ? double.tryParse(targetWeightController.text) : null,
                        );

                        if (widget.plan == null) {
                          await _dbHelper.insertPlan(newPlan);
                        } else {
                          await _dbHelper.updatePlan(newPlan);
                        }
                        if (mounted) {
                          Navigator.pop(context, true); // 返回 true 表示已添加新计划
                        }
                      } catch (e) {
                        debugPrint('Error saving plan: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('保存失败: $e')),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请输入计划标题')),
                      );
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
                if (selectedType == '体重计划') ...[
                  const SizedBox(height: 32),
                  const Text(
                    '体重资料',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '当前体重 (kg)',
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
                          controller: targetWeightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '目标体重 (kg)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (selectedType == '腿部计划') ...[
                  const SizedBox(height: 32),
                  const Text(
                    '目标腿形',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['匀称', '细长', '力量', '矫正'].map((shape) {
                      final isSelected = selectedTargetShape == shape;
                      return ChoiceChip(
                        label: Text(shape),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => selectedTargetShape = shape);
                          }
                        },
                        selectedColor: selectedColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? selectedColor : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
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
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '体重 (kg)',
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
                          controller: targetWeightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '目标体重 (kg)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
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
                          controller: targetThighController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '目标大腿围 (cm)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
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
                  Row(
                    children: [
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: targetCalfController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '目标小腿围 (cm)',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
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
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '身高 (cm)',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                  SwitchListTile(
                    title: const Text('发力时大腿是否坚硬', style: TextStyle(fontSize: 15)),
                    subtitle: const Text('判断是肌肉型还是脂肪型', style: TextStyle(fontSize: 12)),
                    value: isThighHard,
                    onChanged: (val) => setState(() => isThighHard = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: selectedColor,
                  ),
                  SwitchListTile(
                    title: const Text('发力时小腿是否坚硬', style: TextStyle(fontSize: 15)),
                    subtitle: const Text('判断是肌肉型还是脂肪型', style: TextStyle(fontSize: 12)),
                    value: isCalfHard,
                    onChanged: (val) => setState(() => isCalfHard = val),
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
                      if (selectedType == '腿部计划') ...[
                        const Divider(height: 32),
                        const Text('计划提醒设置', style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('每日提醒时间', style: TextStyle(fontSize: 14)),
                          subtitle: Text(reminderTime != null 
                            ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}' 
                            : '未设置 (点击选择)'),
                          trailing: Icon(Icons.access_time, color: selectedColor),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: reminderTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => reminderTime = picked);
                            }
                          },
                        ),
                      ],
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
