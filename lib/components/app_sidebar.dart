import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/navigation_item.dart';

/// 左侧导航侧边栏 — 240px
///
/// ┌────────────────────────────────┐
/// │  ✦  文明的地图                  │
/// │  ─────────────────────         │
/// │  🌍  首页                      │
/// │  🌐  世界地图      ← active    │
/// │  ⛰️  高加索                    │
/// │  🚩  任务                      │
/// │  🧠  AI 思维                   │
/// │  📘  阅读营                    │
/// │  📍  我的文明                  │
/// │  👤  个人                      │
/// │  ─────────────────────         │
/// │  🎯  探索者  Lv.5              │
/// │  ████████░░  78%              │
/// └────────────────────────────────┘
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          right: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── 品牌标识区域 ──
            _buildBrand(),
            const SizedBox(height: 4),
            _buildDivider(),
            const SizedBox(height: 8),

            // ── 导航项列表 ──
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: NavigationItem.items.length,
                itemBuilder: (context, index) {
                  final item = NavigationItem.items[index];
                  final isActive = currentRoute == item.route;
                  return _NavItem(
                    item: item,
                    isActive: isActive,
                    onTap: () {
                      if (!isActive) context.go(item.route);
                    },
                  );
                },
              ),
            ),

            // ── 用户信息区域 ──
            _buildDivider(),
            const SizedBox(height: 8),
            _buildUserInfo(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.shimmerGold,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child:
                const Icon(Icons.auto_awesome, color: AppTheme.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '文明的地图',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'PingFang SC',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: AppTheme.divider,
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.gold, AppTheme.gold.withAlpha(180)],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '探',
                  style: TextStyle(
                    color: AppTheme.background,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '探索者',
                      style: TextStyle(
                        color: AppTheme.paper,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PingFang SC',
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Lv.5  ·  高加索探索中',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 11,
                        fontFamily: 'PingFang SC',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── 经验条 ──
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.78,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.gold, AppTheme.gold.withAlpha(200)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '78%',
            style: TextStyle(
              color: AppTheme.paper.withAlpha(120),
              fontSize: 10,
              fontFamily: 'PingFang SC',
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.shimmerGold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? const Border(
                    left: BorderSide(color: AppTheme.gold, width: 3),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppTheme.gold : AppTheme.paper.withAlpha(160),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                item.label,
                style: TextStyle(
                  color:
                      isActive ? AppTheme.gold : AppTheme.paper.withAlpha(180),
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'PingFang SC',
                ),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '探索中',
                    style: TextStyle(
                      color: AppTheme.background,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFang SC',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
