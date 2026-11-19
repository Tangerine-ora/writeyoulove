import 'package:isar/isar.dart';

part 'component_template.g.dart';

/// 开发者注册的自定义组件模板
/// 仅开发者模式可编写；排版/开发者模式均可一键调用
@collection
class ComponentTemplate {
  ComponentTemplate({
    required this.id,
    required this.name,
    required this.htmlTemplate,
    required this.createdAt,
  });

  Id id;
  String name;

  /// 模板 HTML（已通过白名单校验，不含 script/iframe）
  String htmlTemplate;

  /// 模板描述 / 使用提示
  String description = '';

  /// 是否内置（内置模板不可删除）
  bool isBuiltin = false;

  int createdAt;
  int updatedAt = 0;
}
