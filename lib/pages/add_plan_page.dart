import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Color selectedColor;
  late String selectedType;
  late bool isThighClosed;
  late bool isCalfClosed;
  late bool isThighHard;
  late bool isCalfHard;
  late bool isLegBoneStraight;
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
    
    selectedColor = widget.plan != null ? Color(widget.plan!.colorValue) : Colors.deepPurple;
    selectedType = widget.plan?.planType ?? '脸部计划';
    isThighClosed = widget.plan?.isThighClosed ?? false;
    isCalfClosed = widget.plan?.isCalfClosed ?? false;
    isThighHard = widget.plan?.isThighHard ?? false;
    isCalfHard = widget.plan?.isCalfHard ?? false;
    isLegBoneStraight = widget.plan?.isLegBoneStraight ?? true;
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
                      // 如果是腿部计划且勾选了腿骨不笔直，给出提示
                      if (selectedType == '腿部计划' && !isLegBoneStraight) {
                        final proceed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('温馨提示'),
                            content: const Text('检测到您的腿部问题可能涉及骨骼结构。单纯的运动计划可能无法达到理想效果，建议您前往正规机构进行专业矫正咨询。是否仍要继续保存计划？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('去咨询'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('继续保存'),
                              ),
                            ],
                          ),
                        );
                        if (proceed != true) return;
                      }

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
                          isLegBoneStraight: selectedType == '腿部计划' ? isLegBoneStraight : null,
                          weight: selectedType == '腿部计划' ? double.tryParse(weightController.text) : null,
                          height: selectedType == '腿部计划' ? double.tryParse(heightController.text) : null,
                          reminderTime: reminderTime != null 
                            ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}' 
                            : null,
                          currentDay: widget.plan?.currentDay ?? 1,
                          targetLegShape: selectedType == '腿部计划' ? selectedTargetShape : null,
                        );

                        if (widget.plan == null) {
                          final id = await _dbHelper.insertPlan(newPlan);
                          // 设置新通知
                          if (reminderTime != null) {
                            await NotificationService().scheduleDailyNotification(
                              id: id,
                              title: 'Project Butterfly: ${newPlan.title}',
                              body: '该开始今天的训练啦！点击查看计划详情。',
                              time: reminderTime!,
                            );
                          }
                        } else {
                          await _dbHelper.updatePlan(newPlan);
                          // 更新通知
                          if (reminderTime != null) {
                            await NotificationService().scheduleDailyNotification(
                              id: widget.plan!.id!,
                              title: 'Project Butterfly: ${newPlan.title}',
                              body: '该开始今天的训练啦！点击查看计划详情。',
                              time: reminderTime!,
                            );
                          } else {
                            await NotificationService().cancelNotification(widget.plan!.id!);
                          }
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
                  TextField(
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
                  TextField(
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
                  const SizedBox(height: 16),
                  TextField(
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
                  const SizedBox(height: 16),
                  TextField(
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
                    title: const Text('腿骨是否笔直', style: TextStyle(fontSize: 15)),
                    value: isLegBoneStraight,
                    onChanged: (val) => setState(() => isLegBoneStraight = val),
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
                    // 请求权限
                    await NotificationService().requestPermissions();
                    
                    if (mounted) {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => reminderTime = picked);
                      }
                    }
                  },
                ),
                TextButton.icon(
                  onPressed: () async {
                    await NotificationService().showInstantNotification(
                      id: 999,
                      title: '通知测试',
                      body: '如果您看到这条消息，说明提醒功能工作正常！',
                    );
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('发送测试通知'),
                ),
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
