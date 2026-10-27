import 'package:example/widgets/section_panel.dart';
import 'package:fl_shared_link/fl_shared_link.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 示例首页：展示各平台「被打开」事件携带的数据。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlSharedLink link = FlSharedLink();

  AndroidIntentModel? androidIntent;
  String? androidRealPath;

  IOSUniversalLinkModel? universalLink;
  IOSOpenUrlModel? openUrl;
  Map<dynamic, dynamic>? launchingOptions;
  String? copiedPath;

  HarmonyOSWantModel? want;
  HarmonyOSNewWantModel? newWant;
  List<HarmonyOSSharedRecordModel>? sharedData;
  String? harmonyCopiedPath;

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  bool get isHarmonyOS => defaultTargetPlatform.name == 'ohos';

  String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isHarmonyOS) return 'HarmonyOS';
    return defaultTargetPlatform.name;
  }

  List<String> get capabilities {
    if (isAndroid) return <String>['Intent 监听', '真实文件路径', '分享 / 打开文件'];
    if (isIOS) return <String>['URL Scheme', 'Universal Link', '文件拷贝'];
    if (isMacOS) return <String>['URL Scheme', 'Finder 打开文件', '文件拷贝'];
    if (isHarmonyOS) return <String>['Want', 'SharedData', 'URI 拷贝'];
    return <String>['当前平台暂不支持'];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      link.receiveHandler(
        onIntent: (AndroidIntentModel data) => setState(() => androidIntent = data),
        onOpenUrl: (IOSOpenUrlModel data) => setState(() => openUrl = data),
        onUniversalLink: (IOSUniversalLinkModel data) => setState(() => universalLink = data),
        onWant: (HarmonyOSNewWantModel data) async {
          setState(() => newWant = data);
          final List<HarmonyOSSharedRecordModel>? records = await link.wantSharedDataWithHarmonyOS;
          if (!mounted) return;
          setState(() => sharedData = records);
        },
      );
      loadInitialData();
    });
  }

  /// 读取本次（冷）启动携带的数据。
  Future<void> loadInitialData() async {
    if (isAndroid) {
      androidIntent = await link.intentWithAndroid;
    } else if (isIOS) {
      universalLink = await link.universalLinkWithIOS;
      openUrl = await link.openUrlWithIOS;
      launchingOptions = await link.launchingOptionsWithIOS;
    } else if (isMacOS) {
      openUrl = await link.openUrlWithIOS;
    } else if (isHarmonyOS) {
      want = await link.wantWithHarmonyOS;
      sharedData = await link.wantSharedDataWithHarmonyOS;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> refresh() async {
    await loadInitialData();
    if (!mounted) return;
    notify('已重新读取启动数据');
  }

  Future<void> clearCache() async {
    await link.clearCache();
    if (!mounted) return;
    setState(() {
      androidIntent = null;
      androidRealPath = null;
      universalLink = null;
      openUrl = null;
      launchingOptions = null;
      copiedPath = null;
      want = null;
      newWant = null;
      sharedData = null;
      harmonyCopiedPath = null;
    });
    notify('缓存已清除');
  }

  Future<void> resolveAndroidPath() async {
    final String? id = androidIntent?.id;
    if (id == null || id.isEmpty) {
      notify('暂无可解析的 Intent');
      return;
    }
    final String? path = await link.getRealFilePathWithAndroid(id);
    if (!mounted) return;
    setState(() => androidRealPath = path);
    notify(path == null ? '解析失败' : '已解析为本地路径');
  }

  Future<void> copyDarwinFile() async {
    final String? id = openUrl?.id ?? universalLink?.id;
    if (id == null || id.isEmpty) {
      notify('暂无可拷贝的外部文件');
      return;
    }
    final String? path = await link.externalFileCopyWithIOS(id);
    if (!mounted) return;
    setState(() => copiedPath = path);
    notify(path == null ? '拷贝失败' : '已拷贝到应用临时目录');
  }

  Future<void> copyHarmonyUri() async {
    final List<HarmonyOSSharedRecordModel> records = sharedData ?? <HarmonyOSSharedRecordModel>[];
    final HarmonyOSSharedRecordModel? record =
        records.where((HarmonyOSSharedRecordModel item) => item.uri != null).firstOrNull;
    final String? uri = record?.uri;
    if (uri == null || uri.isEmpty) {
      notify('暂无可拷贝的 URI');
      return;
    }
    final String? path = await link.uriCopyToCachePathWithHarmonyOS(uri);
    if (!mounted) return;
    setState(() => harmonyCopiedPath = path);
    notify(path == null ? '拷贝失败' : 'URI 已拷贝到沙盒缓存');
  }

  void notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.link_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            const Text('FlSharedLink'),
          ],
        ),
        actions: <Widget>[
          IconButton(onPressed: refresh, tooltip: '重新读取', icon: const Icon(Icons.refresh_rounded)),
          IconButton(
            onPressed: clearCache,
            tooltip: '清除缓存',
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            children: <Widget>[
              heroSection(),
              if (isAndroid) ...<Widget>[const SizedBox(height: 16), androidSection()],
              if (isIOS || isMacOS) ...<Widget>[const SizedBox(height: 16), darwinSection()],
              if (isHarmonyOS) ...<Widget>[const SizedBox(height: 16), harmonySection()],
              const SizedBox(height: 24),
              const Text(
                '冷启动数据在页面初始化时读取；热启动数据由 receiveHandler 实时更新。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget heroSection() {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '分享与打开事件',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当其他应用把文件、链接或文本分享给本应用时，'
                      '这里会展示原生回调携带的数据。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.devices_rounded, size: 15, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      platformName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: capabilities
                .map(
                  (String item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget androidSection() {
    return SectionPanel(
      icon: Icons.android_rounded,
      title: 'Android Intent',
      subtitle: '分享 / 打开文件 / URL Scheme',
      children: <Widget>[
        DataBlock(title: 'Intent 数据', data: androidIntent?.toMap(), emptyText: '尚未收到 Intent'),
        if (androidRealPath != null) ...<Widget>[
          const SizedBox(height: 12),
          DataBlock(title: '真实文件路径', data: androidRealPath),
        ],
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: resolveAndroidPath,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('解析真实文件路径'),
          ),
        ),
      ],
    );
  }

  Widget darwinSection() {
    return SectionPanel(
      icon: isMacOS ? Icons.desktop_mac_rounded : Icons.phone_iphone_rounded,
      title: isMacOS ? 'macOS 打开事件' : 'iOS 打开事件',
      subtitle: isMacOS ? 'URL Scheme / Finder 打开文件' : 'URL Scheme / Universal Link / 冷启动参数',
      children: <Widget>[
        if (isIOS) ...<Widget>[
          DataBlock(
            title: 'Launching Options',
            data: launchingOptions,
            emptyText: '本次为热启动或无启动参数',
          ),
          const SizedBox(height: 12),
          DataBlock(title: 'Universal Link', data: universalLink?.toMap(), emptyText: '尚未收到 Universal Link'),
          const SizedBox(height: 12),
        ],
        DataBlock(title: 'Open URL', data: openUrl?.toMap(), emptyText: '尚未收到打开事件'),
        if (copiedPath != null) ...<Widget>[
          const SizedBox(height: 12),
          DataBlock(title: '文件拷贝结果', data: copiedPath),
        ],
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: copyDarwinFile,
            icon: const Icon(Icons.save_alt_rounded, size: 18),
            label: const Text('拷贝外部文件到临时目录'),
          ),
        ),
        if (isMacOS) ...<Widget>[
          const SizedBox(height: 10),
          const Text(
            'macOS 暂不支持 Universal Link；URL Scheme 与 Finder 打开的文件均可读取。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget harmonySection() {
    return SectionPanel(
      icon: Icons.auto_awesome_rounded,
      title: 'HarmonyOS Want',
      subtitle: 'Want / NewWant / SharedData',
      children: <Widget>[
        DataBlock(title: 'Want 数据', data: want?.toMap(), emptyText: '尚未收到 Want'),
        const SizedBox(height: 12),
        DataBlock(title: 'NewWant 数据', data: newWant?.toMap(), emptyText: '尚未收到 NewWant'),
        const SizedBox(height: 12),
        DataBlock(
          title: 'SharedData 记录',
          data: sharedData?.map((HarmonyOSSharedRecordModel item) => item.toMap()).toList(),
          emptyText: '暂无分享数据',
        ),
        if (harmonyCopiedPath != null) ...<Widget>[
          const SizedBox(height: 12),
          DataBlock(title: 'URI 拷贝结果', data: harmonyCopiedPath),
        ],
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: copyHarmonyUri,
            icon: const Icon(Icons.content_copy_rounded, size: 18),
            label: const Text('拷贝分享 URI 到沙盒缓存'),
          ),
        ),
      ],
    );
  }
}
