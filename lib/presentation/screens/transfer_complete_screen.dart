import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/device_entity.dart';
import '../../providers/file_picker_provider.dart';

class TransferCompleteScreen extends StatelessWidget {
  final DeviceEntity device;

  const TransferCompleteScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with animation effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow rings
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.successGreen.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.successGreen.withOpacity(0.15),
                    ),
                  ),
                  // Main icon container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.successGreen.withOpacity(0.3),
                          AppTheme.successGreen.withOpacity(0.15),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.successGreen.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 70,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Title
              Text(
                'Transfer Complete!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingSmall),
              
              // Subtitle
              Text(
                'Files sent to ${device.name} successfully.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXLarge),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FilePickerProvider>().clearSelectedFiles();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Send More'),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingMedium),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<FilePickerProvider>().clearSelectedFiles();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
