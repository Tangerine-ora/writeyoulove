/// 开发者注册的自定义组件模板
class ComponentTemplate {
  ComponentTemplate({
    required this.id,
    required this.name,
    required this.htmlTemplate,
    required this.createdAt,
  });

  String id;
  String name;
  String htmlTemplate;
  String description = '';
  bool isBuiltin = false;
  int createdAt;
  int updatedAt = 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'htmlTemplate': htmlTemplate,
        'description': description,
        'isBuiltin': isBuiltin,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory ComponentTemplate.fromMap(Map<String, dynamic> m) => ComponentTemplate(
        id: m['id'] as String,
        name: m['name'] as String,
        htmlTemplate: m['htmlTemplate'] as String,
        createdAt: m['createdAt'] as int,
      )
        ..description = m['description'] as String? ?? ''
        ..isBuiltin = m['isBuiltin'] as bool? ?? false
        ..updatedAt = m['updatedAt'] as int? ?? 0;
}
