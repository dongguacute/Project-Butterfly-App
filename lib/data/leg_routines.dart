class LegRoutines {
  static const Map<String, List<String>> fatTypeTasks = {
    '1': ['开合跳 30秒 x 3组', '原地高抬腿 30秒 x 3组', '深蹲 15次 x 3组', '侧卧抬腿 每侧 20次 x 2组', '跳绳 5分钟'],
    '2': ['波比跳 10次 x 3组', '箭步蹲 每侧 12次 x 3组', '靠墙蹲 45秒 x 2组', '空中自行车 50次', '快走 20分钟'],
    '3': ['慢跑 30分钟', '大腿前侧拉伸 30秒 x 2组', '小腿拉伸 30秒 x 2组'],
    '4': ['开合跳 40秒 x 3组', '深蹲跳 12次 x 3组', '保加利亚分腿蹲 每侧 10次 x 2组', '登山者 30秒 x 3组', '跳绳 8分钟'],
    '5': ['侧步蹲 15次 x 3组', '单腿硬拉 每侧 12次 x 3组', '臀桥 20次 x 3组', '波比跳 12次 x 3组', '快走 25分钟'],
    '6': ['游泳 40分钟 或 骑行 40分钟', '全身拉伸 10分钟'],
    '7': ['休息日', '进行简单的腿部揉捏放松'],
  };

  static const Map<String, List<String>> muscleTypeTasks = {
    '1': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '2': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '3': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '4': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '5': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '6': ['小腿后侧 + 跟腱拉伸', '小腿外侧放松', '脚踝活动拉伸'],
    '7': ['休息日'],
  };

  static const Map<String, List<String>> mixedTypeTasks = {
    '1': ['开合跳 30秒 x 2组', '深蹲 12次 x 3组', '泡沫轴大腿放松 2分钟', '小腿拉伸 45秒 x 2组'],
    '2': ['慢跑 20分钟', '箭步蹲 10次 x 2组', '空中自行车 30次', '静态拉伸 5分钟'],
    '3': ['侧卧抬腿 20次 x 2组', '内收肌训练 15次 x 3组', '鸽子式拉伸 每侧 1分钟'],
    '4': ['波比跳 8次 x 2组', '靠墙蹲 30秒 x 2组', '足底放松 3分钟', '全身拉伸 10分钟'],
    '5': ['快走 30分钟', '臀桥 15次 x 3组', '保加利亚分腿蹲 每侧 8次 x 2组', '大腿后侧拉伸 45秒'],
    '6': ['游泳 30分钟', '泡沫轴全身放松 5分钟'],
    '7': ['休息日', '轻微揉捏腿部'],
  };

  static const Map<String, List<String>> oShapeCorrection = {
    'extra': ['鸭子坐拉伸 1分钟', '内收肌加强练习 20次 x 3组', '侧卧并腿 15次 x 3组'],
  };

  static const Map<String, List<String>> xShapeCorrection = {
    'extra': ['蝴蝶式拉伸 2分钟', '外展肌加强练习 20次 x 3组', '单腿站立平衡 每侧 30秒'],
  };

  static const Map<String, List<String>> targetShapeExtras = {
    '细长': ['空中自行车 100次', '靠墙竖腿 10分钟', '剪刀腿 30次 x 3组'],
    '力量': ['负重深蹲 12次 x 4组', '保加利亚分腿蹲 每侧 12次 x 3组', '提踵训练 20次 x 4组'],
    '匀称': ['慢跑 15分钟', '综合拉伸 10分钟', '瑜伽腿部流 15分钟'],
    '矫正': ['足底放松 5分钟', '靠墙站立 5分钟 (保持腿部并拢)', '盆底肌激活 15次 x 3组'],
  };

  static List<String> getDailyTasks(String muscleType, String shapeStatus, int day, {String? targetShape}) {
    int cycleDay = ((day - 1) % 7) + 1;
    String dayKey = cycleDay.toString();
    
    List<String> tasks = [];
    
    // 基础计划
    if (muscleType == '脂肪型') {
      tasks.addAll(fatTypeTasks[dayKey] ?? []);
    } else if (muscleType == '肌肉型') {
      tasks.addAll(muscleTypeTasks[dayKey] ?? []);
    } else {
      tasks.addAll(mixedTypeTasks[dayKey] ?? []);
    }

    // 针对腿型的额外练习
    if (shapeStatus.contains('O型腿倾向')) {
      tasks.add('【纠偏】' + oShapeCorrection['extra']![ (day - 1) % oShapeCorrection['extra']!.length ]);
    } else if (shapeStatus.contains('X型腿倾向')) {
      tasks.add('【纠偏】' + xShapeCorrection['extra']![ (day - 1) % xShapeCorrection['extra']!.length ]);
    }

    // 针对目标腿形的额外练习
    if (targetShape != null && targetShapeExtras.containsKey(targetShape)) {
      final extras = targetShapeExtras[targetShape]!;
      tasks.add('【目标】' + extras[(day - 1) % extras.length]);
    }

    return tasks;
  }
}
