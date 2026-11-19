/// 三模式枚举
enum DocMode { normalWrite, layout, developer }

extension DocModeX on DocMode {
  String get name => switch (this) {
        DocMode.normalWrite => 'normalWrite',
        DocMode.layout => 'layout',
        DocMode.developer => 'developer',
      };

  String get label => switch (this) {
        DocMode.normalWrite => '普通写作',
        DocMode.layout => '排版模式',
        DocMode.developer => '开发者模式',
      };

  static DocMode fromString(String s) => switch (s) {
        'layout' => DocMode.layout,
        'developer' => DocMode.developer,
        _ => DocMode.normalWrite,
      };
}
