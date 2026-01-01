import '../models/adjustment_model.dart';

class AdjustmentData {
  static final List<LegAdjustment> muscleLegAdjustments = [
    LegAdjustment(
      title: '小腿后侧 + 跟腱拉伸',
      subtitle: '减少脚踝“向内/向前塌”的拉力',
      howToDo: '1. 面对墙\n2. 一脚在前，一脚在后\n3. 后脚脚跟踩实地面\n4. 身体微微前倾',
      sensation: '小腿下半段 & 跟腱有拉伸感，不痛、不抖',
      timing: '每边 30–40 秒 × 2 次',
      effect: '直接减少脚踝“向内/向前塌”的拉力',
    ),
    LegAdjustment(
      title: '小腿外侧放松',
      subtitle: '把膝盖和脚从“被拉向一侧”的状态放出来',
      howToDo: '1. 坐下\n2. 一条腿搭在另一条腿上\n3. 用手轻轻揉 + 推小腿外侧\n4. 找到紧的地方，停 10 秒呼吸',
      sensation: '酸、胀、热都正常，不要按到疼皱眉',
      timing: '每边 1 分钟',
      effect: '纠正“看起来脚歪 / 膝盖偏”的问题',
    ),
    LegAdjustment(
      title: '脚踝活动拉伸',
      subtitle: '重建脚踝的方向感，让关节“记得能回正”',
      howToDo: '1. 坐着或躺着\n2. 脚尖慢慢画圈\n3. 顺时针 10 圈，逆时针 10 圈\n4. 全程慢、顺、不卡',
      sensation: '想象脚踝在“找中间位置”，不要用力',
      timing: '每只脚 1 分钟',
      effect: '重建脚踝的方向感，而不是强行纠正',
    ),
  ];
}
