class LegRoutines {
  static const Map<String, List<String>> fatTypeTasks = {
    '1': ['HIIT: 开合跳 45秒 + 休息15秒 x 4组', '深蹲 (自重) 20次 x 3组', '登山者 30秒 x 3组', '侧卧抬腿 每侧 25次 x 2组', '跳绳 5-10分钟'],
    '2': ['HIIT: 波比跳 12次 + 休息20秒 x 4组', '箭步蹲 每侧 15次 x 3组', '靠墙静蹲 60秒 x 2组', '空中自行车 100次 (慢速控制)', '快走 25分钟 (保持心率)'],
    '3': ['主动恢复: 慢跑/椭圆机 35分钟', '大腿前侧拉伸 45秒 x 2组', '小腿后侧拉伸 45秒 x 2组', '全身放松 5分钟'],
    '4': ['HIIT: 跳跃箭步蹲 20次 + 休息15秒 x 4组', '保加利亚分腿蹲 每侧 12次 x 3组', '仰卧开合腿 40次 x 3组', '登山者 45秒 x 3组', '跳绳 12分钟'],
    '5': ['侧步蹲 (塑形大腿内侧) 20次 x 3组', '单腿硬拉 (收紧后侧) 每侧 12次 x 3组', '臀桥 30次 x 3组', 'HIIT: 交叉波比跳 10次 x 3组', '快走 30分钟'],
    '6': ['低强度有氧: 游泳 45分钟 或 骑行 45分钟', '泡沫轴大腿/小腿筋膜放松 10分钟', '深呼吸放松'],
    '7': ['休息日', '温水泡脚 + 腿部向上推拿按摩 15分钟 (消除浮肿)'],
  };

  static const Map<String, List<String>> muscleTypeTasks = {
    '1': ['泡沫轴松解: 小腿后侧 (腓肠肌/比目鱼肌) 3分钟', '深度拉伸: 下犬式 (维持) 1分钟 x 2组', '足底筋膜滚球放松 2分钟', '脚踝灵活性练习 (勾脚背) 30次'],
    '2': ['泡沫轴松解: 大腿外侧 (髂胫束) 3分钟', '深度拉伸: 鸽子式 每侧 90秒', '靠墙拉伸小腿 (跟腱处) 60秒 x 2组', '仰卧空中自行车 (极慢速) 50次'],
    '3': ['按摩: 手部由下往上提拉小腿 10分钟', '瑜伽: 战士一式 (拉伸髋屈肌) 每侧 1分钟', '猫式伸展 (放松脊柱与骨盆) 5组', '温水足浴 15分钟'],
    '4': ['泡沫轴松解: 大腿前侧 (四头肌) 3分钟', '深度拉伸: 跪姿大腿前侧拉伸 每侧 1分钟', '下犬式交替踩脚跟 40次', '静态勾脚背拉伸 60秒'],
    '5': ['筋膜枪/手动按摩: 敲打放松小腿肌肉 5分钟', '深度拉伸: 坐姿分腿前屈 (拉伸内侧) 2分钟', '脚踝环绕 每侧 20圈', '空中竖腿 (靠墙) 15分钟'],
    '6': ['低强度恢复: 慢走 20分钟 (平底鞋)', '全身阴瑜伽 (重点腿部) 20分钟', '深度呼吸冥想'],
    '7': ['完全休息日', '穿压力袜 (若有水肿倾向)', '避免长时间站立或穿高跟鞋'],
  };

  static const Map<String, List<String>> mixedTypeTasks = {
    '1': ['HIIT: 开合跳 30秒 x 3组', '泡沫轴松解大腿外侧 2分钟', '深蹲 15次 x 3组', '小腿深度拉伸 45秒 x 2组'],
    '2': ['中速跑 20分钟', '箭步蹲 12次 x 3组', '鸽子式拉伸 每侧 1分钟', '空中自行车 60次'],
    '3': ['侧卧抬腿 25次 x 2组', '内收肌夹球训练 20次 x 3组', '泡沫轴小腿放松 3分钟', '足底放松 2分钟'],
    '4': ['HIIT: 波比跳 8次 x 3组', '靠墙静蹲 45秒 x 2组', '下犬式拉伸 1分钟', '全身静态拉伸 10分钟'],
    '5': ['快走 30分钟', '臀桥 20次 x 3组', '保加利亚分腿蹲 每侧 10次 x 2组', '大腿后侧拉伸 60秒'],
    '6': ['游泳/瑜伽 40分钟', '泡沫轴全身滚压放松 8分钟'],
    '7': ['休息日', '腿部向上提拉按摩 10分钟', '温水足浴'],
  };

  static const Map<String, List<String>> oShapeCorrection = {
    'extra': [
      '【纠偏】内收肌加强: 双膝夹书微蹲 20次 x 3组',
      '【纠偏】调整走姿: 重心放在脚掌内侧训练 5分钟',
      '【纠偏】拉伸: 鸭子坐 (改善大腿内旋) 1分钟',
      '【纠偏】侧卧并腿 (强化内侧力量) 20次 x 3组',
      '【纠偏】足底激活: 抓趾练习 30次',
    ],
  };

  static const Map<String, List<String>> xShapeCorrection = {
    'extra': [
      '【纠偏】蚌式开合 (强化臀中肌) 每侧 20次 x 3组',
      '【纠偏】拉伸: 蝴蝶式 (松解内收肌) 2分钟',
      '【纠偏】侧向步行 (弹力带绕踝) 每侧 15步 x 2组',
      '【纠偏】单腿站立平衡 (重建下肢力线) 45秒 x 2组',
      '【纠偏】青蛙趴 (改善髋部开合) 2分钟',
    ],
  };

  static const Map<String, List<String>> targetShapeExtras = {
    '细长': ['【目标】空中自行车 100次 (慢速)', '【目标】靠墙竖腿 15分钟 (消除水肿)', '【目标】剪刀腿 40次 x 3组', '【目标】芭蕾式拉伸小腿 60秒'],
    '力量': ['【目标】负重深蹲 12次 x 4组', '【目标】保加利亚分腿蹲 每侧 12次 x 3组', '【目标】提踵训练 (强化脚踝) 20次 x 4组', '【目标】硬拉练习 12次 x 3组'],
    '匀称': ['【目标】慢跑 20分钟', '【目标】瑜伽腿部流 15分钟', '【目标】普拉提侧卧系列 10分钟', '【目标】综合拉伸放松 10分钟'],
    '矫正': ['【目标】足底筋膜激活 5分钟', '【目标】靠墙站立 (保持三点一线) 10分钟', '【目标】盆底肌激活/凯格尔运动 20次', '【目标】重心分配平衡练习 5分钟'],
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
