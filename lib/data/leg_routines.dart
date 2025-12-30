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
    '1': ['泡沫轴大腿前侧放松 2分钟', '泡沫轴小腿放松 2分钟', '静态拉伸大腿后侧 45秒 x 3组', '足背屈练习 15次 x 3组'],
    '2': ['瑜伽：下犬式 1分钟 x 3组', '战士一式 每侧 45秒', '鸽子式拉伸 每侧 1分钟', '猫牛式 15次'],
    '3': ['慢走 30分钟 (保持足底受力均匀)', '足底筋膜球放松 5分钟', '小腿深度拉伸 1分钟 x 2组'],
    '4': ['泡沫轴大腿内侧放松 2分钟', '泡沫轴大腿外侧放松 2分钟', '坐姿体前屈 1分钟 x 3组', '靠墙拉伸小腿 1分钟 x 2组'],
    '5': ['普拉提：侧卧抬腿(慢速) 每侧 15次', '内收肌拉伸 1分钟 x 2组', '仰卧单腿拉伸 每侧 45秒 x 3组'],
    '6': ['温水泡脚 20分钟', '腿部手动按摩 10分钟', '简单的腿部线条勾勒运动'],
    '7': ['休息日', '保持良好的步态意识'],
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

  static List<String> getDailyTasks(String muscleType, String shapeStatus, int day) {
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
    if (shapeStatus == 'O型腿倾向') {
      tasks.add('【专项】' + oShapeCorrection['extra']![ (day - 1) % oShapeCorrection['extra']!.length ]);
    } else if (shapeStatus == 'X型腿倾向') {
      tasks.add('【专项】' + xShapeCorrection['extra']![ (day - 1) % xShapeCorrection['extra']!.length ]);
    }

    return tasks;
  }
}
