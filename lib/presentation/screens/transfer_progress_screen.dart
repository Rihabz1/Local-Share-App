import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/entities/transfer_entity.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/file_picker_provider.dart';
import 'transfer_complete_screen.dart';

class TransferProgressScreen extends StatefulWidget {
  final DeviceEntity device;

  const TransferProgressScreen({
    super.key,
    required this.device,
  });

  @override
  State<TransferProgressScreen> createState() => _TransferProgressScreenState();
}

class _TransferProgressScreenState extends State<TransferProgressScreen> {
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final files = context.read<FilePickerProvider>().selectedFiles;
      context.read<TransferProvider>().startTransfer(
            files: files,
            device: widget.device,
            direction: TransferDirection.send,
          );
      
      // Check for completion
      _statusCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final transfer = context.read<TransferProvider>().activeTransfer;
        if (transfer != null && transfer.status == TransferStatus.completed) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TransferCompleteScreen(device: widget.device),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending...'),
      ),
      body: Consumer2<TransferProvider, FilePickerProvider>(
        builder: (context, transferProvider, fileProvider, child) {
          final transfer = transferProvider.activeTransfer;
          
          if (transfer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Column(
                    children: [
                      // Progress Circle with glow
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.0),
                                  AppTheme.primaryBlue.withOpacity(0.15),
                                ],
                              ),
                            ),
                          ),
                          // Progress ring
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: transfer.progress,
                              strokeWidth: 14,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AppTheme.darkCard,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          // Percentage text with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppTheme.primaryBlue,
                                AppTheme.primaryBlue.withOpacity(0.8),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '${(transfer.progress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingLarge),
                      
                      // Device Info
                      Text(
                        'to ${widget.device.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      
                      const SizedBox(height: AppTheme.spacingMedium),
                      
                      // Speed and ETA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMedium,
                              vertical: AppTheme.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.darkCard,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.speed,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  transfer.speedFormatted,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMedium,
                              vertical: AppTheme.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.darkCard,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ETA: ${transfer.etaFormatted}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingXLarge),
                      
                      // Files List
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Files (${fileProvider.selectedFiles.length}/${fileProvider.selectedFiles.length})',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
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
                          final fileProgress = index == 0 ? transfer.progress : 0.0;
                          
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMedium),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        index == 0 && transfer.progress < 1.0
                                            ? Icons.sync
                                            : Icons.check_circle,
                                        color: index == 0 && transfer.progress < 1.0
                                            ? AppTheme.primaryBlue
                                            : AppTheme.successGreen,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppTheme.spacingSmall),
                                      Expanded(
                                        child: Text(
                                          file.name,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacingSmall),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: fileProgress,
                                      backgroundColor: AppTheme.darkCard,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryBlue,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
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
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: transfer.status == TransferStatus.paused
                              ? () => transferProvider.resumeTransfer(
                                    fileProvider.selectedFiles,
                                    widget.device,
                                  )
                              : () => transferProvider.pauseTransfer(),
                          icon: Icon(
                            transfer.status == TransferStatus.paused
                                ? Icons.play_arrow
                                : Icons.pause,
                          ),
                          label: Text(
                            transfer.status == TransferStatus.paused ? 'Resume' : 'Pause',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            transferProvider.cancelTransfer();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.dangerRed,
                          ),
                        ),
                      ),
                    ],
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
