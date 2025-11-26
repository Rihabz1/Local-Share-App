import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/file_picker_provider.dart';
import 'providers/device_discovery_provider.dart';
import 'providers/transfer_provider.dart';
import 'providers/history_provider.dart';
import 'providers/receive_provider.dart';
import 'presentation/screens/root_scaffold.dart';

void main() {
  runApp(const LocalShareApp());
}

class LocalShareApp extends StatelessWidget {
  const LocalShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilePickerProvider()),
        ChangeNotifierProvider(create: (_) => DeviceDiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ReceiveProvider()),
      ],
      child: MaterialApp(
        title: 'LocalShare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark theme
        home: const RootScaffold(),
      ),
    );
  }
}
