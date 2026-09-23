import 'package:flutter/material.dart';

import '../../../core/theme/tena_colors.dart';

/// Five tabs like the web: Home and Map are live, the rest are visible but
/// disabled placeholders for the roadmap (Heartbeat, Saved, Profile).
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const tabs = <_NavTab>[
    _NavTab(label: 'Home', icon: Icons.home_rounded, branchIndex: 0),
    _NavTab(label: 'Map', icon: Icons.map_rounded, branchIndex: 1),
    _NavTab(label: 'Heartbeat', icon: Icons.favorite_rounded),
    _NavTab(label: 'Saved', icon: Icons.bookmark_rounded),
    _NavTab(label: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TenaColors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: TenaColors.stone)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8C502C19),
            offset: Offset(0, -18),
            blurRadius: 40,
            spreadRadius: -30,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              for (final tab in tabs)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    active: tab.branchIndex == currentIndex,
                    onTap: tab.branchIndex == null
                        ? null
                        : () => onSelect(tab.branchIndex!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon, this.branchIndex});

  final String label;
  final IconData icon;

  /// `null` for tabs that are not wired up yet.
  final int? branchIndex;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.active, this.onTap});

  final _NavTab tab;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = active ? TenaColors.orange : TenaColors.muted;

    return Semantics(
      button: true,
      selected: active,
      enabled: enabled,
      label: tab.label,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
