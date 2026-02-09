import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;
          return GestureDetector(
            onTap: () => widget.onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
                    size: 24,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      width: isSelected ? null : 0,
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
