import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/history_provider.dart';
import '../../domain/entities/transfer_entity.dart';
import '../widgets/file_type_icon.dart';
import '../../domain/entities/file_entity.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transfers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  onChanged: (value) {
                    provider.setSearchQuery(value);
                  },
                ),
              ),
              
              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: 'All',
                        isSelected: provider.filter == HistoryFilter.all,
                        onTap: () => provider.setFilter(HistoryFilter.all),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: _FilterChip(
                        label: 'Sent',
                        isSelected: provider.filter == HistoryFilter.sent,
                        onTap: () => provider.setFilter(HistoryFilter.sent),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: _FilterChip(
                        label: 'Received',
                        isSelected: provider.filter == HistoryFilter.received,
                        onTap: () => provider.setFilter(HistoryFilter.received),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingMedium),
              
              // History List
              Expanded(
                child: provider.history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppTheme.spacingMedium),
                            Text(
                              'No transfer history',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        itemCount: provider.history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppTheme.spacingSmall),
                        itemBuilder: (context, index) {
                          final item = provider.history[index];
                          return _HistoryTile(
                            item: item,
                            onDelete: () {
                              provider.removeHistory(item.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue
              : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic item; // HistoryEntity
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileType = _getFileType(item.fileName);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          children: [
            FileTypeIcon(type: fileType, size: 24),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        item.direction == TransferDirection.send
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: item.direction == TransferDirection.send
                            ? AppTheme.primaryBlue
                            : AppTheme.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.direction == TransferDirection.send
                            ? 'To ${item.deviceName}'
                            : 'From ${item.deviceName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.fileSizeFormatted,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.timeAgo,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppTheme.dangerRed),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  FileType _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return FileType.fromExtension(ext);
  }
}
