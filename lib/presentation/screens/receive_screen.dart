import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/receive_provider.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Files'),
      ),
      body: Consumer<ReceiveProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Receiver Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Receiver Status',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Switch(
                              value: provider.isReceiving,
                              onChanged: (_) => provider.toggleReceiving(),
                              activeColor: AppTheme.successGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          provider.isReceiving
                              ? 'Your device is visible and ready to receive files'
                              : 'Turn on receiver to accept files from nearby devices',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (provider.isReceiving) ...[
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Device Address Card
                  Card(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.wifi,
                            size: 48,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            'Your device is visible at:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          SelectableText(
                            provider.address,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: provider.address),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy Address'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Waiting Status
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.darkCardElevated,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Text(
                          'Waiting for sender',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          'Keep this screen open to receive files. Incoming transfers will start automatically.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
