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

    // 3. 综合评估腿型状态
    String legShapeStatus = '';
    if (isThighClosed && isCalfClosed) {
      legShapeStatus = '标准腿型';
    } else if (isThighClosed && !isCalfClosed) {
      legShapeStatus = 'O型腿倾向';
    } else if (!isThighClosed && isCalfClosed) {
      legShapeStatus = 'X型腿倾向';
    } else {
      legShapeStatus = '整体不匀称';
    }

    // 4. 计算建议改进建议
    List<String> suggestions = [];
    final String targetShape = plan.targetLegShape ?? '匀称';
    suggestions.add('训练目标：$targetShape');

    if (!isThighClosed) suggestions.add('建议加强大腿内侧肌肉训练');
    if (!isCalfClosed) suggestions.add('建议通过拉伸改善小腿外翻');
    
    if (muscleType == '脂肪型') {
      if (targetShape == '细长') {
        suggestions.add('建议增加高强度有氧运动，加速腿部脂肪燃烧');
      } else {
        suggestions.add('建议增加全身有氧运动以减少腿部脂肪');
      }
      if (bmiStatus == '超重' || bmiStatus == '肥胖') {
        suggestions.add('当前 BMI 为 ${bmi.toStringAsFixed(1)} ($bmiStatus)，建议配合全身减脂饮食');
      }
    } else if (muscleType == '肌肉型') {
      if (targetShape == '力量') {
        suggestions.add('建议在拉伸的同时，增加抗阻训练以强化线条');
      } else {
        suggestions.add('建议运动后加强拉伸，避免肌肉过度肥大');
      }
    } else {
      suggestions.add('建议结合有氧和拉伸，平衡腿部线条');
    }

    if (targetShape == '矫正' && (legShapeStatus.contains('倾向') || legShapeStatus == '整体不匀称')) {
      suggestions.add('目标为矫正，建议重点关注日常步态和专项纠偏训练');
    }

    if (ratio > 1.6 && muscleType == '脂肪型') {
      suggestions.add('重点进行减脂运动，改善大腿脂肪堆积');
    }

    if (suggestions.length <= 1) suggestions.add('保持现状，继续维持！');

    // 5. 获取今日任务
    List<String> dailyTasks = LegRoutines.getDailyTasks(
      muscleType,
      legShapeStatus,
      plan.currentDay,
      targetShape: targetShape,
    );

    // 6. 检查目标达成情况
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

    // 如果设置了数值目标，也进行检查
    if (plan.targetWeight != null && plan.weight != null) {
      if (plan.weight! <= plan.targetWeight!) {
        achievedGoals.add('体重目标已达成');
      }
    }
    
    if (plan.planType == '腿部计划') {
      if (plan.targetThighCircumference != null && plan.thighCircumference != null) {
        if (plan.thighCircumference! <= plan.targetThighCircumference!) {
          achievedGoals.add('大腿围目标已达成');
        }
      }
      if (plan.targetCalfCircumference != null && plan.calfCircumference != null) {
        if (plan.calfCircumference! <= plan.targetCalfCircumference!) {
          achievedGoals.add('小腿围目标已达成');
        }
      }
    }
    
    // 判定逻辑：如果设置了腿形目标，则以腿形目标达成作为核心判据
    // 如果没有明确的数值目标，只要腿形目标达成就算整体达成
    if (plan.planType == '腿部计划') {
      isGoalAchieved = shapeGoalReached;
    } else if (plan.planType == '体重计划' && plan.targetWeight != null && plan.weight != null) {
      isGoalAchieved = plan.weight! <= plan.targetWeight!;
    }

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
