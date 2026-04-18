import 'package:flutter/material.dart';
import '../models/verse.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onDelete;

  const VerseCard({super.key, required this.verse, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u201c${verse.text}\u201d',
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Color(0xFF2D2D2D),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '— ${verse.reference}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C6BC0),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Color(0xFFBDBDBD)),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            if (verse.categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: verse.categories
                    .map((cat) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5C6BC0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}

