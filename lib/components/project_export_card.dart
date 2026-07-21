import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 作品导出卡片 — 右侧面板底部
///
/// 提供保存、生成作品卡和未来导出功能入口。
class ProjectExportCard extends StatelessWidget {
  final int completeness;
  final VoidCallback? onSave;
  final VoidCallback? onExportCard;

  const ProjectExportCard({
    super.key,
    required this.completeness,
    this.onSave,
    this.onExportCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题 ──
          Row(children: [
            Icon(Icons.save_outlined, color: AppTheme.gold, size: 14),
            const SizedBox(width: 6),
            Text('作品管理',
                style: TextStyle(
                  color: AppTheme.paper,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC',
                )),
          ]),
          const SizedBox(height: 14),
          // ── 完整度 ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('作品完整度',
                  style: TextStyle(
                    color: AppTheme.paper.withAlpha(140),
                    fontSize: 12,
                    fontFamily: 'PingFang SC',
                  )),
              Text('$completeness%',
                  style: TextStyle(
                    color: completeness >= 80
                        ? AppTheme.green
                        : completeness >= 50
                            ? AppTheme.gold
                            : AppTheme.paper.withAlpha(140),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.background,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: completeness / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.gold, AppTheme.green],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── 按钮 ──
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: Icon(Icons.save, size: 14, color: AppTheme.gold),
              label: Text('保存作品',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.gold.withAlpha(60)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: onExportCard,
              icon: const Icon(Icons.image_outlined, size: 14),
              label: Text('生成作品卡',
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── 未来功能 ──
          Center(
            child: Text('即将支持：分享 / 打印 / 导出 PDF',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(50),
                  fontSize: 10,
                  fontFamily: 'PingFang SC',
                )),
          ),
        ],
      ),
    );
  }
}
