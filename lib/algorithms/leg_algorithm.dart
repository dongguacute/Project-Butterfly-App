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
    if (!isThighClosed) suggestions.add('建议加强大腿内侧肌肉训练');
    if (!isCalfClosed) suggestions.add('建议通过拉伸改善小腿外翻');
    
    if (muscleType == '脂肪型') {
      suggestions.add('建议增加全身有氧运动以减少腿部脂肪');
      if (bmiStatus == '超重' || bmiStatus == '肥胖') {
        suggestions.add('当前 BMI 为 ${bmi.toStringAsFixed(1)} ($bmiStatus)，建议配合全身减脂饮食');
      }
    } else if (muscleType == '肌肉型') {
      suggestions.add('建议运动后加强拉伸，避免肌肉过度肥大');
    } else {
      suggestions.add('建议结合有氧和拉伸，平衡腿部线条');
    }

    if (ratio > 1.6 && muscleType == '脂肪型') {
      suggestions.add('重点进行减脂运动，改善大腿脂肪堆积');
    }

    if (suggestions.isEmpty) suggestions.add('保持现状，继续维持！');

    // 5. 获取今日任务
    List<String> dailyTasks = LegRoutines.getDailyTasks(
      muscleType,
      legShapeStatus,
      plan.currentDay,
    );

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
      }
    };
  }
}
