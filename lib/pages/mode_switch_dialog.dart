import 'package:flutter/material.dart';

import '../models/document.dart';

/// 模式切换结果
enum ModeSwitchResult { cancel, loadOld, regenerate }

/// 普通写作 → 排版模式：检测到旧排版版本时的版本提示
Future<ModeSwitchResult?> showModeVersionConflictDialog(
  BuildContext context, {
  required Document doc,
  required DocMode sourceMode,
  required DocMode targetMode,
}) async {
  return showDialog<ModeSwitchResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('检测到历史排版版本'),
      content: Text(
        '此文档存在旧排版版本，切换到排版模式前请选择处理方式：',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, ModeSwitchResult.cancel),
          child: const Text('取消'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, ModeSwitchResult.loadOld),
          child: const Text('加载旧排版'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, ModeSwitchResult.regenerate),
          child: const Text('用当前文本重新生成'),
        ),
      ],
    ),
  );
}

/// 排版模式 → 普通写作：提示分页、背景、交互组件失效
Future<bool> showLayoutToNormalSwitchDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('切换到普通写作模式'),
          content: const Text(
            '切换后以下排版元素将失效：\n'
            '  • 分页标记\n'
            '  • 单页背景\n'
            '  • 交互组件（点击展开/碎裂等）\n\n'
            '排版数据保留在原字段不会被清空，下次切回排版模式仍可恢复。\n\n'
            '确定继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确定切换'),
            ),
          ],
        ),
      ) ??
      false;
}
