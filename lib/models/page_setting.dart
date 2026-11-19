/// 单页背景配置（排版模式每页独立）
/// 与 layoutContent 中的 <page-setting> 标记对应
class PageSetting {
  final int pageIndex;
  final String bgColor;   // #RRGGBB 格式
  final String? bgImage;  // 图片文件路径
  final BgFillMode bgMode;

  PageSetting({
    required this.pageIndex,
    this.bgColor = '#FDF8F0',
    this.bgImage,
    this.bgMode = BgFillMode.cover,
  });

  Map<String, dynamic> toJson() => {
        'pageIndex': pageIndex,
        'bgColor': bgColor,
        'bgImage': bgImage,
        'bgMode': bgMode.name,
      };

  factory PageSetting.fromJson(Map<String, dynamic> j) => PageSetting(
        pageIndex: j['pageIndex'] as int? ?? 0,
        bgColor: j['bgColor'] as String? ?? '#FDF8F0',
        bgImage: j['bgImage'] as String?,
        bgMode: BgFillMode.values.firstWhere(
          (e) => e.name == j['bgMode'],
          orElse: () => BgFillMode.cover,
        ),
      );
}

enum BgFillMode { cover, contain, repeat }
