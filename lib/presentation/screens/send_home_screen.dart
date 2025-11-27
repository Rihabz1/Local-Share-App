import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/file_picker_provider.dart';
import '../../domain/entities/file_entity.dart';
import '../widgets/file_type_icon.dart';
import 'nearby_devices_screen.dart';

class SendHomeScreen extends StatelessWidget {
  const SendHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalShare'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.15),
                  AppTheme.successGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: AppTheme.successGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi,
                  size: 16,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'My-WiFi-SSID',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<FilePickerProvider>(
        builder: (context, fileProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pick Files Card with gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.1),
                              AppTheme.primaryBlue.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingXLarge),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryBlue.withOpacity(0.3),
                                        AppTheme.primaryBlue.withOpacity(0.15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLarge,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.upload_file_rounded,
                                    size: 40,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingLarge),
                                Text(
                                  'Pick Files to Send',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingSmall),
                                Text(
                                  'Select photos, videos, documents, or any other file.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.textSecondary,
                                        height: 1.5,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingXLarge),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      fileProvider.pickFiles();
                                    },
                                    icon: const Icon(Icons.folder_open_rounded, size: 22),
                                    label: const Text('Select Files', style: TextStyle(fontSize: 16, letterSpacing: 0.5)),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4,
                                      shadowColor: AppTheme.primaryBlue.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLarge),
                      
                      // Wi-Fi Info
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryBlue.withOpacity(0.12),
                              AppTheme.primaryBlue.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            Expanded(
                              child: Text(
                                'Connected to My-WiFi-SSID\nFor best results, ensure all devices are connected to the same Wi-Fi network.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLarge),
                      
                      // Recent Files
                      if (fileProvider.recentFiles.isNotEmpty) ...[
                        Text(
                          'Recent files',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: fileProvider.recentFiles.length,
                            separatorBuilder: (context, index) => 
                                const SizedBox(width: AppTheme.spacingMedium),
                            itemBuilder: (context, index) {
                              final file = fileProvider.recentFiles[index];
                              return _RecentFileChip(file: file);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Bottom CTA
              if (fileProvider.selectedFiles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NearbyDevicesScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Scan Nearby Devices (${fileProvider.selectedFiles.length})',
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentFileChip extends StatelessWidget {
  final FileEntity file;

  const _RecentFileChip({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.darkCardElevated,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FileTypeIcon(type: file.type, size: 28),
          const SizedBox(height: 4),
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
          ),
          Text(
            file.sizeFormatted,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
