# LocalShare

A lightweight offline file-sharing Flutter app that works when two devices are on the same Wi-Fi router/hotspot. No internet, no login, no cloud required.

## Features

### ✨ Core Functionality
- **Send Mode**: Pick files and discover nearby devices on the same network
- **Receive Mode**: Turn on receiver to accept files from other devices
- **Transfer Progress**: Real-time progress tracking with speed and ETA
- **Transfer History**: View all sent and received files with search and filters

### 🎨 UI/UX Highlights
- Dark theme with modern, clean design
- Bottom navigation with 3 tabs: Send, Receive, History
- Smooth animations and transitions
- File type icons for images, videos, audio, documents, archives
- Real-time device discovery simulation
- Mock transfer progress with speed/ETA calculations

### 📱 Screens Implemented
1. **Send Home Screen** - File picker with recent files carousel
2. **Nearby Devices Screen** - Scans and displays available devices
3. **Send Details Screen** - Review selected files and target device
4. **Transfer Progress Screen** - Live progress with pause/cancel
5. **Transfer Complete Screen** - Success confirmation
6. **Receive Screen** - Toggle receiver ON/OFF with IP display
7. **History Screen** - Searchable list with filters (All/Sent/Received)

## Project Structure

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart          # Dark/Light themes, colors, spacing
├── domain/
│   └── entities/
│       ├── device_entity.dart      # Device model
│       ├── file_entity.dart        # File model with type detection
│       ├── transfer_entity.dart    # Transfer state with progress
│       └── history_entity.dart     # History record model
├── providers/
│   ├── device_discovery_provider.dart  # Mock device scanning
│   ├── file_picker_provider.dart       # File selection management
│   ├── transfer_provider.dart          # Mock transfer simulation
│   ├── history_provider.dart           # Transfer history with filters
│   └── receive_provider.dart           # Receiver mode toggle
├── presentation/
│   ├── screens/
│   │   ├── root_scaffold.dart          # Bottom nav container
│   │   ├── send_home_screen.dart       # Main send screen
│   │   ├── nearby_devices_screen.dart  # Device discovery
│   │   ├── send_details_screen.dart    # File review before send
│   │   ├── transfer_progress_screen.dart # Live transfer tracking
│   │   ├── transfer_complete_screen.dart # Success screen
│   │   ├── receive_screen.dart         # Receive mode
│   │   └── history_screen.dart         # Transfer history
│   └── widgets/
│       └── file_type_icon.dart         # File type icon component
└── main.dart                           # App entry with providers

## Technologies Used

- **Flutter SDK**: ^3.7.2
- **State Management**: Provider
- **File Picker**: file_picker
- **Storage**: shared_preferences
- **Network**: network_info_plus
- **Permissions**: permission_handler

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code with Flutter extensions
- Windows/macOS/Linux for desktop, or Android/iOS emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Rihabz1/Local-Share-App.git
cd local_share
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Windows
flutter run -d windows

# For Android
flutter run -d <device_id>

# For web
flutter run -d chrome
```

## Current Status

✅ **Completed**:
- Full UI implementation matching design mockups
- Dark theme with custom colors and styling
- Mock device discovery with progressive device addition
- Mock file transfer with realistic progress simulation
- History management with search and filters
- File type detection and icons
- All navigation flows

🚧 **To Be Implemented** (Future Enhancements):
- Real Wi-Fi device discovery using network scanning
- Actual socket-based file transfer (TCP/UDP)
- Real-time transfer speed calculation
- File encryption for secure transfers
- Multi-file queue management
- Persistent storage of history
- Notification support for received files
- Cross-platform testing (iOS, Android, Web)

## Design

The app follows a modern dark theme design with:
- **Primary Color**: #3B82F6 (Blue)
- **Success Color**: #22C55E (Green)
- **Background**: #0B1220 (Dark)
- **Cards**: #121A2B (Dark Card)
- **Border Radius**: 12-16px for rounded corners
- **Typography**: Clear hierarchy with proper contrast

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
