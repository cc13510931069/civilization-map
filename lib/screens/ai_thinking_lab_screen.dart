import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AIThinkingLabScreen extends StatelessWidget {
  const AIThinkingLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 思维实验室')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_outlined,
                color: AppTheme.gold.withAlpha(160), size: 64),
            const SizedBox(height: 16),
            Text(
              'AI 思维实验室',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '用 AI 辅助深度思考与探索',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.paper.withAlpha(160),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
