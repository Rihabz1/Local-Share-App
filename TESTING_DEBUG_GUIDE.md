# Testing Guide - Debugging Device Discovery & File Transfer

## How to Test and Debug

### Step 1: Run the App on Your Phone
```bash
flutter run -d <your-device-id>
```

Watch the debug console output carefully!

---

## What to Look For in Debug Logs

### 1. **Receive Mode (Device A - Receiver)**

When you enable "Receive Mode", you should see:

```
=== INITIALIZING RECEIVE PROVIDER ===
Device name: Redmi Note 12
=== STARTING RECEIVE MODE ===
Local IP: 192.168.1.105
Port: 37822
Starting TCP server...
✓ TCP server started
Starting network discovery broadcast...
Discovery started on 192.168.1.105:37821
Broadcasting: Redmi Note 12 @ 192.168.1.105:37822 (XXX bytes)
✓ Broadcasting presence
✓ Server fully started on 192.168.1.105:37822
```

**If you see this, Device A is ready to receive!**

---

### 2. **Scanning for Devices (Device B - Sender)**

When you tap "Find Devices", you should see:

```
=== STARTING DEVICE SCAN ===
Device name: M2006C3MII
Initializing network service...
Local IP: 192.168.1.108
Starting UDP discovery...
Discovery started on 192.168.1.108:37821
Broadcasting: M2006C3MII @ 192.168.1.108:37822 (XXX bytes)
✓ Started scanning for devices
```

**Then, within 2-3 seconds, you should see:**

```
Received UDP packet: {"type":"discovery","deviceName":"Redmi Note 12","ipAddress":"192.168.1.105","port":37822,"timestamp":...}
Discovery packet from: Redmi Note 12 @ 192.168.1.105
✓ Device added to list: Redmi Note 12 (1 total)
Devices stream update: 1 device(s)
  - Redmi Note 12 @ 192.168.1.105:37822
✓ Discovered device: Redmi Note 12 at 192.168.1.105
```

**If you see this, device discovery is working!**

---

### 3. **Sending Files (Device B → Device A)**

When you send a file, you should see:

```
=== STARTING FILE TRANSFER ===
Target device: Redmi Note 12
Target IP: 192.168.1.105:37822
Files to send: 1
Attempting to connect...
✓ Connected to Redmi Note 12 at 192.168.1.105:37822
Sending file: photo.jpg (2.5 MB)
```

**On Device A (receiver), you should see:**

```
Client connected: 192.168.1.108
Receiving 1 file(s)
Receiving file 1/1: photo.jpg (2621440 bytes)
Receive progress: 25.0% at 5.24 MB/s
Receive progress: 50.0% at 6.18 MB/s
Receive progress: 75.0% at 5.87 MB/s
Receive progress: 100.0% at 6.02 MB/s
File received: /storage/emulated/0/Download/LocalShare/photo.jpg
✓ File received: photo.jpg
✓ All files received
```

---

## Common Issues & Solutions

### ❌ Problem 1: No Devices Appearing

**Logs show:**
```
✓ Started scanning for devices
Broadcasting: ...
(but no "Received UDP packet" messages)
```

**Causes:**
1. **Not on same WiFi** - Both devices must be on same network
2. **Router blocks multicast** - Some routers block UDP multicast
3. **Firewall/Security** - Phone firewall or router security blocking
4. **Mobile hotspot** - Hotspots often don't support multicast

**Solutions:**
- Verify both devices show same WiFi SSID
- Check router settings (disable AP isolation if present)
- Try different WiFi network
- Use router WiFi, not mobile hotspot

---

### ❌ Problem 2: Transfer Stuck at "Sending"

**Logs show:**
```
=== STARTING FILE TRANSFER ===
Attempting to connect...
(then nothing or timeout)
```

**Causes:**
1. **Receiver not in receive mode** - Device A didn't enable receive
2. **Port blocked** - Firewall blocking TCP port 37822
3. **Wrong IP** - IP address changed (DHCP)
4. **Network timeout** - Poor WiFi connection

**Solutions:**
- Ensure Device A shows "✓ Server fully started"
- Check if both devices still on same network
- Move closer to WiFi router
- Try restarting receive mode

---

### ❌ Problem 3: "Failed to apply plugin" Error

**This is the Gradle issue from before.**

**Solution:**
```bash
# Clear Gradle cache
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches

# Rebuild
flutter clean
flutter pub get
flutter run
```

---

## Testing Checklist

### ✅ Device A (Receiver)
1. [ ] Open app
2. [ ] Go to "Receive" tab
3. [ ] Enable "Receive Mode" toggle
4. [ ] Verify logs show "✓ Server fully started"
5. [ ] Note the IP address displayed (e.g., 192.168.1.105)
6. [ ] Leave app open and on Receive screen

### ✅ Device B (Sender)
1. [ ] Open app
2. [ ] Go to "Send" tab
3. [ ] Tap "Pick Files" and select a small file (< 5MB for testing)
4. [ ] Tap "Find Devices"
5. [ ] Wait 3-5 seconds
6. [ ] **Check logs** - Should see "Discovered device: ..."
7. [ ] **Check UI** - Device A should appear in list with name and IP
8. [ ] Tap on Device A
9. [ ] Tap "Send Files"
10. [ ] Watch progress bar

### ✅ Expected Results
- [ ] Device B shows Device A's name (not "Android Device")
- [ ] Progress bar moves smoothly
- [ ] Transfer completes in reasonable time
- [ ] Device A shows notification or success
- [ ] File appears in Downloads/LocalShare folder on Device A
- [ ] Both devices show transfer in History tab

---

## Debug Commands

### View Real-Time Logs
```bash
flutter logs
```

### Filter Logs
```bash
# Show only discovery logs
flutter logs | Select-String "Discovery|Broadcast|device"

# Show only transfer logs
flutter logs | Select-String "TRANSFER|Sending|Receiving"
```

---

## What to Report Back

Please share:

1. **Device A logs** when enabling receive mode
2. **Device B logs** when scanning for devices
3. **Both devices' logs** when attempting transfer
4. **Screenshots** of what you see in the UI
5. **WiFi details** - Same network? Router model?

This will help identify exactly where the issue is!

---

## Quick Test (Localhost)

If you want to test file transfer logic without two devices:

1. Run app on Windows
2. Enable Receive Mode (Device acts as both sender & receiver)
3. Send file to yourself (127.0.0.1 or your IP)
4. This tests if file transfer code works

Note: Device discovery won't work this way (UDP multicast needs two devices).
