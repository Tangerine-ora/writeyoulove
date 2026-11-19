/// 叙事交互组件 —— 由排版模式一键生成，自动分配 ID
/// 底层会渲染为带预设 class 的 HTML 节点（如 wy-expand / wy-shatter）
class InteractionComponent {
  final String id;                    // 自动生成，如 "expand_001"
  final InteractionType type;
  final String label;                 // 组件标题/提示文字
  final String triggerText;           // 触发前可见文字（如"点击展开"）
  final String hiddenContent;         // 触发后显示内容（expand=正文，shatter=后续文本）

  InteractionComponent({
    required this.id,
    required this.type,
    this.label = '',
    this.triggerText = '点击继续',
    this.hiddenContent = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'label': label,
        'triggerText': triggerText,
        'hiddenContent': hiddenContent,
      };

  factory InteractionComponent.fromJson(Map<String, dynamic> j) =>
      InteractionComponent(
        id: j['id'] as String,
        type: InteractionType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => InteractionType.expand,
        ),
        label: j['label'] as String? ?? '',
        triggerText: j['triggerText'] as String? ?? '点击继续',
        hiddenContent: j['hiddenContent'] as String? ?? '',
      );
}

enum InteractionType {
  expand,   // 点击展开隐藏文本
  shatter,  // 点击文字碎裂，展示后文
  pageBreakRef, // 翻页锚点引用
}

extension InteractionTypeX on InteractionType {
  String get label => switch (this) {
        InteractionType.expand => '点击展开隐藏文本',
        InteractionType.shatter => '点击文字碎裂',
        InteractionType.pageBreakRef => '翻页锚点',
      };

  String get cssClass => switch (this) {
        InteractionType.expand => 'wy-expand',
        InteractionType.shatter => 'wy-shatter',
        InteractionType.pageBreakRef => 'wy-pagebreak',
      };
}
