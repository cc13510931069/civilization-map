import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/evidence_type.dart';

/// 证据标记对话框
///
/// 学生选中文本后弹出，选择证据类型并添加备注。
/// 确认后将证据保存到阅读进度中。
class EvidenceMarker extends StatefulWidget {
  final String selectedText;
  final ValueChanged<EvidenceType> onConfirm;

  const EvidenceMarker({
    super.key,
    required this.selectedText,
    required this.onConfirm,
  });

  @override
  State<EvidenceMarker> createState() => _EvidenceMarkerState();
}

class _EvidenceMarkerState extends State<EvidenceMarker> {
  EvidenceType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.divider, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 标题 ──
            Row(children: [
              Icon(Icons.auto_awesome, color: AppTheme.gold, size: 18),
              const SizedBox(width: 8),
              Text('标记为证据',
                  style: TextStyle(
                    color: AppTheme.paper,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                  )),
            ]),
            const SizedBox(height: 12),
            // ── 选中文本预览 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.selectedText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.gold.withAlpha(200),
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'PingFang SC',
                  )),
            ),
            const SizedBox(height: 16),
            // ── 选择证据类型 ──
            Text('选择证据类型',
                style: TextStyle(
                  color: AppTheme.paper.withAlpha(180),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                )),
            const SizedBox(height: 10),
            ...EvidenceType.values.map((type) => _buildTypeOption(type)),
            const SizedBox(height: 20),
            // ── 按钮 ──
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: _selectedType == null
                    ? null
                    : () => widget.onConfirm(_selectedType!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.background,
                  disabledBackgroundColor: AppTheme.surfaceLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('确认标记',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(EvidenceType type) {
    final selected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.shimmerGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.gold.withAlpha(100) : AppTheme.divider,
              width: 0.5,
            ),
          ),
          child: Row(children: [
            Text(type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.label,
                      style: TextStyle(
                        color: selected ? AppTheme.gold : AppTheme.paper,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PingFang SC',
                      )),
                  Text(type.description,
                      style: TextStyle(
                        color: AppTheme.paper.withAlpha(100),
                        fontSize: 11,
                        fontFamily: 'PingFang SC',
                      )),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppTheme.gold, size: 18),
          ]),
        ),
      ),
    );
  }
}
