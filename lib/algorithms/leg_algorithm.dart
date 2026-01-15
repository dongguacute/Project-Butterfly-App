import '../models/plan_model.dart';
import '../data/leg_routines.dart';

class LegAlgorithm {
  /// 腿部评分结果模型
  static Map<String, dynamic> analyzeLegData(Plan plan) {
    if (plan.planType != '腿部计划') {
      return {'status': 'error', 'message': '非腿部计划数据'};
    }

    final double thigh = plan.thighCircumference ?? 0;
    final double calf = plan.calfCircumference ?? 0;
    final bool isThighClosed = plan.isThighClosed ?? false;
    final bool isCalfClosed = plan.isCalfClosed ?? false;
    final bool isThighHard = plan.isThighHard ?? false;
    final bool isCalfHard = plan.isCalfHard ?? false;
    final bool isLegBoneStraight = plan.isLegBoneStraight ?? true;
    final double weight = plan.weight ?? 0;
    final double height = plan.height ?? 0;

    // 0. 计算 BMI 和 基础分析
    double bmi = 0;
    String bmiStatus = '';
    if (weight > 0 && height > 0) {
      double heightInMeters = height / 100;
      bmi = weight / (heightInMeters * heightInMeters);
      if (bmi < 18.5) {
        bmiStatus = '偏瘦';
      } else if (bmi < 24) {
        bmiStatus = '标准';
      } else if (bmi < 28) {
        bmiStatus = '超重';
      } else {
        bmiStatus = '肥胖';
      }
    }

    // 1. 计算大腿/小腿比例 (理想比例约为 1.5:1)
    double ratio = calf > 0 ? thigh / calf : 0;
    String ratioDescription = '';
    if (ratio > 1.6) {
      ratioDescription = '大腿相对偏粗';
    } else if (ratio < 1.4 && ratio > 0) {
      ratioDescription = '小腿相对偏粗';
    } else {
      ratioDescription = '比例匀称';
    }

    // 2. 肌肉/脂肪类型判断
    String muscleType = '';
    if (isThighHard && isCalfHard) {
      muscleType = '肌肉型';
    } else if (!isThighHard && !isCalfHard) {
      muscleType = '脂肪型';
    } else {
      muscleType = '混合型';
    }

    // 3. 综合评估腿型状态与成因
    String cause = !isLegBoneStraight ? '骨骼型' : muscleType;
    String legShapeStatus = '';
    
    if (isThighClosed && isCalfClosed) {
      legShapeStatus = isLegBoneStraight ? '标准腿型' : '骨骼不正 (建议矫正)';
    } else if (isThighClosed && !isCalfClosed) {
      legShapeStatus = 'O型腿倾向 ($cause)';
    } else if (!isThighClosed && isCalfClosed) {
      legShapeStatus = 'X型腿倾向 ($cause)';
    } else {
      legShapeStatus = '整体不匀称 ($cause)';
    }

    final String targetShape = plan.targetLegShape ?? '匀称';

    // 4. 获取今日任务
    List<String> dailyTasks = LegRoutines.getDailyTasks(
      muscleType,
      legShapeStatus,
      plan.currentDay,
      targetShape: targetShape,
    );

    // 5. 检查目标达成情况
    bool isGoalAchieved = false;
    List<String> achievedGoals = [];
    
    // 优先检查腿形目标
    bool shapeGoalReached = false;
    if (plan.planType == '腿部计划') {
      switch (targetShape) {
        case '矫正':
          if (legShapeStatus == '标准腿型') {
            shapeGoalReached = true;
            achievedGoals.add('腿型矫正目标已达成');
          }
          break;
        case '匀称':
          if (ratioDescription == '比例匀称') {
            shapeGoalReached = true;
            achievedGoals.add('身材比例匀称目标已达成');
          }
          break;
        case '细长':
          if (ratioDescription == '比例匀称' && (bmiStatus == '标准' || bmiStatus == '偏瘦')) {
            shapeGoalReached = true;
            achievedGoals.add('细长美腿目标已达成');
          }
          break;
        case '力量':
          if (muscleType == '肌肉型' && ratioDescription == '比例匀称') {
            shapeGoalReached = true;
            achievedGoals.add('健美力量目标已达成');
          }
          break;
      }
    }

    // 如果设置了腿形目标，则以腿形目标达成作为核心判据
    if (plan.planType == '腿部计划') {
      isGoalAchieved = shapeGoalReached;
    }

    // 6. 计算建议改进建议
    List<String> suggestions = [];
    suggestions.add('训练目标：$targetShape');

    if (cause == '骨骼型') {
      suggestions.add('⚠️ 判定为骨骼型问题，单纯运动效果有限，强烈建议咨询专业矫正机构');
    } else if (cause == '肌肉型') {
      suggestions.add('💡 判定为假性腿型问题（肌肉代偿导致），请执行专项调整方案：');
      suggestions.add('• 小腿后侧 + 跟腱拉伸 (核心)');
      suggestions.add('• 小腿外侧放松 (纠正腿型)');
      suggestions.add('• 脚踝活动拉伸 (重建方向感)');
    } else if (cause == '脂肪型') {
      suggestions.add('💡 判定为脂肪堆积导致，重点在于全身减脂和局部线条勾勒：');
      suggestions.add('• 高强度有氧/HIIT (核心：燃烧全身脂肪)');
      suggestions.add('• 针对性腿部塑形 (深蹲、箭步蹲，轻重量多次数)');
      suggestions.add('• 饮食管理 (低油低糖，维持热量缺口)');
      suggestions.add('• 睡前揉捏按摩 (促进循环，改善浮肿)');

      if (bmiStatus == '超重' || bmiStatus == '肥胖') {
        suggestions.add('• 建议配合全身减脂饮食，当前 BMI 为 ${bmi.toStringAsFixed(1)} ($bmiStatus)');
      }
      if (targetShape == '细长') {
        suggestions.add('• 增加有氧时长，加速腿部围度缩小');
      }
    } else if (cause == '混合型') {
      suggestions.add('💡 判定为混合型，建议平衡减脂与拉伸：');
      suggestions.add('• 结合中等强度有氧与肌肉拉伸');
      suggestions.add('• 重点放松僵硬肌肉，同时控制脂肪比例');
    }

    // 针对性局部建议
    if (!isThighClosed) {
      suggestions.add(cause == '脂肪型' ? '• 针对大腿内侧：加强内收肌训练，减少内侧脂肪堆积' : '建议加强大腿内侧肌肉训练');
    }
    if (!isCalfClosed) {
      suggestions.add(cause == '脂肪型' ? '• 针对小腿线条：配合拉伸改善外翻，使视觉更直' : '建议通过拉伸改善小腿外翻');
    }
    if (ratio > 1.6 && cause == '脂肪型') {
      suggestions.add('• 针对比例问题：重点加强大腿减脂，平衡腿部比例');
    }

    if (!isLegBoneStraight && cause != '骨骼型') {
      suggestions.add('检测到骨骼不平直，建议配合专业矫正训练');
    }
    
    if (targetShape == '矫正' && (legShapeStatus.contains('倾向') || legShapeStatus == '整体不匀称')) {
      suggestions.add('目标为矫正，建议重点关注日常步态和专项纠偏训练');
    }

    if (suggestions.length <= 1) suggestions.add('保持现状，继续维持！');

    return {
      'status': 'success',
      'data': {
        'bmi': bmi > 0 ? bmi.toStringAsFixed(1) : '未知',
        'bmiStatus': bmiStatus,
        'ratio': ratio.toStringAsFixed(2),
        'ratioDescription': ratioDescription,
        'muscleType': muscleType,
        'legShapeStatus': legShapeStatus,
        'suggestions': suggestions,
        'dailyTasks': dailyTasks,
        'targetShape': targetShape,
        'isGoalAchieved': isGoalAchieved,
        'achievedGoals': achievedGoals,
      }
    };
  }
}
