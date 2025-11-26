import 'package:flutter/material.dart';
import '../../domain/entities/file_entity.dart';
import '../../core/theme/app_theme.dart';

class FileTypeIcon extends StatelessWidget {
  final FileType type;
  final double size;

  const FileTypeIcon({
    super.key,
    required this.type,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case FileType.image:
        icon = Icons.image_rounded;
        color = const Color(0xFFEF4444); // Red
        break;
      case FileType.video:
        icon = Icons.videocam_rounded;
        color = const Color(0xFF3B82F6); // Blue
        break;
      case FileType.audio:
        icon = Icons.music_note_rounded;
        color = const Color(0xFFF59E0B); // Orange
        break;
      case FileType.document:
        icon = Icons.description_rounded;
        color = const Color(0xFF3B82F6); // Blue
        break;
      case FileType.archive:
        icon = Icons.folder_zip_rounded;
        color = const Color(0xFF8B5CF6); // Purple
        break;
      case FileType.other:
        icon = Icons.insert_drive_file_rounded;
        color = AppTheme.textSecondary;
        break;
    }

    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}
