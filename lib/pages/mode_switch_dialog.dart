import 'package:flutter/material.dart';

import '../models/document.dart';
import '../models/doc_mode.dart';

enum ModeSwitchResult { cancel, loadOld, regenerate }

/// 普通写作 → 排版模式：已有旧排版版本时
Future<ModeSwitchResult?> showModeVersionConflictDialog(BuildContext context) {
  return showDialog<ModeSwitchResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('检测到历史排版版本'),
      content: const Text('此文档存在旧排版版本，切换前请选择：'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, ModeSwitchResult.cancel), child: const Text('取消')),
        OutlinedButton(onPressed: () => Navigator.pop(ctx, ModeSwitchResult.loadOld), child: const Text('加载旧排版')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, ModeSwitchResult.regenerate), child: const Text('用当前文本重新生成')),
      ],
    ),
  );
}

/// 排版模式 → 普通写作：分页、背景、交互组件失效提示
Future<bool> showLayoutToNormalSwitchDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('切换到普通写作模式'),
          content: const Text(
            '以下排版元素将失效：分页标记、单页背景、交互组件。\n\n'
            '排版数据保留在原字段不会被清空，下次切回排版仍可恢复。',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定切换')),
          ],
        ),
      ) ??
      false;
}
