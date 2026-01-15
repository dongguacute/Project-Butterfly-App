import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../main.dart';
import '../pages/plan_detail_page.dart';
import '../services/database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 初始化时区数据
    tz.initializeTimeZones();
    try {
      final dynamic timeZone = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = timeZone.toString();
      
      // 修复：处理某些平台返回的非标准时区字符串
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // 进一步处理，例如 macOS 可能返回 "Asia/Shanghai (CST)" 这种格式
        if (timeZoneName.contains(' ')) {
          timeZoneName = timeZoneName.split(' ')[0];
          try {
            tz.setLocalLocation(tz.getLocation(timeZoneName));
          } catch (_) {
            tz.setLocalLocation(tz.getLocation('UTC'));
          }
        } else {
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      }
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('Could not get local timezone: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    // 修复：添加 macOS 初始化设置，防止在 macOS 平台上运行报错
    const DarwinInitializationSettings initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS, // 必须添加这个参数
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null) {
          final int? planId = int.tryParse(details.payload!);
          if (planId != null) {
            final plan = await DatabaseHelper().getPlanById(planId);
            if (plan != null && MyApp.navigatorKey.currentState != null) {
              MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (context) => PlanDetailPage(plan: plan),
                ),
              );
            }
          }
        }
      },
    );
  }

  /// 请求通知权限 (针对 iOS 和 Android 13+)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool? result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  /// 安排每日提醒通知
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    // 获取当前时间（基于本地时区）
    final now = tz.TZDateTime.now(tz.local);
    
    // 构建目标时间
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 如果目标时间早于当前时间，说明今天的提醒时间已过，推迟到明天
    // 注意：这对于 DateTimeComponents.time 来说很重要，确保第一次触发是正确的
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'butterfly_plan_reminders',
          '计划提醒',
          channelDescription: '每日训练计划提醒',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: id.toString(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 发送一个即时测试通知
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'test_channel',
      '测试通知',
      channelDescription: '用于测试通知功能',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// 取消指定 ID 的通知
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
