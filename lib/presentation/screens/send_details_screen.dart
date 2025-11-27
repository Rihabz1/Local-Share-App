import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/device_entity.dart';
import '../../providers/file_picker_provider.dart';
import '../widgets/file_type_icon.dart';
import 'transfer_progress_screen.dart';

class SendDetailsScreen extends StatelessWidget {
  final DeviceEntity device;

  const SendDetailsScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Details'),
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
                      // Device Info
                      Text(
                        'Sending to:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.smartphone_rounded,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      device.address,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLarge),
                      
                      // Selected Files
                      Text(
                        'Selected Files',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fileProvider.selectedFiles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppTheme.spacingSmall),
                        itemBuilder: (context, index) {
                          final file = fileProvider.selectedFiles[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMedium),
                              child: Row(
                                children: [
                                  FileTypeIcon(type: file.type, size: 24),
                                  const SizedBox(width: AppTheme.spacingMedium),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.name,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          file.sizeFormatted,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  IconButton(
                                    onPressed: () {
                                      fileProvider.removeFile(file.id);
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppTheme.dangerRed,
                                    ),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.spacingMedium),
                      
                      // Total Size
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Size',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              fileProvider.totalSizeFormatted,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingMedium),
                      
                      // Add More Files Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            fileProvider.pickFiles();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add more files'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Send Now Button
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferProgressScreen(device: device),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send Now'),
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
