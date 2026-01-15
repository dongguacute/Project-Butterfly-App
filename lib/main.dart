import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/plan_page.dart';
import 'pages/settings_page.dart';
import 'widgets/custom_app_bar.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化通知服务
  await NotificationService().init();
  
  // 设置系统 UI 样式，实现沉浸式体验
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent, // 必须透明
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // 允许内容延伸到系统栏区域
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();

  // 提供一个静态方法方便子组件获取状态并修改主题
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get themeMode => _themeMode;

  void changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void changeSeedColor(Color color) {
    setState(() {
      _seedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 修复：不在这里使用 MediaQuery.of(context)，因为它在 MaterialApp 之外会报错导致黑屏
    // 我们将系统 UI 样式的逻辑移到 MaterialApp 的 builder 中或让其自动处理
    
    return MaterialApp(
      title: 'Project Butterfly',
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // 在 MaterialApp 内部，我们可以安全地使用 MediaQuery
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
        
        return child!;
      },
      home: const MainNavigationScreen(title: 'ProjectButterflyApp'),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.title});

  final String title;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final GlobalKey<PlanPageState> _planPageKey = GlobalKey<PlanPageState>();

  List<Widget> get _pages => [
        PlanPage(key: _planPageKey),
        SettingsPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 允许 body 延伸到 bottomNavigationBar 下方
      appBar: CustomAppBar(title: widget.title),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  }
                  return TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return IconThemeData(
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    );
                  }
                  return IconThemeData(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 24,
                  );
                }),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.assignment_rounded),
                    selectedIcon: Icon(Icons.assignment_rounded),
                    label: '计划',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_rounded),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: '设置',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80), // 避开底部栏
              child: FloatingActionButton(
                onPressed: () {
                  _planPageKey.currentState?.showAddPlanDialog();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 4,
                child: const Icon(Icons.add_rounded, size: 32),
              ),
            )
          : null,
    );
  }
}
