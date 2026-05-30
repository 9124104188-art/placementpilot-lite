import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryCard extends StatelessWidget {
  final String iconAsset;
  final String categoryName;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.iconAsset,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentForCategory(categoryName);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 172,
        height: 114,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentColor.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, color: accentColor, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              categoryName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentForCategory(String category) {
    final normalized = category.toLowerCase();

    if (normalized.contains('aptitude')) {
      return const Color(0xff2563eb);
    }
    if (normalized.contains('python')) {
      return const Color(0xff22c55e);
    }
    if (normalized.contains('java')) {
      return const Color(0xfff97316);
    }
    if (normalized.contains('c')) {
      return const Color(0xff8b5cf6);
    }

    return const Color(0xff6d60f6);
  }
}
