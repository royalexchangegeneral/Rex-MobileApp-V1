# App Icon Setup Instructions

## Steps to Set Up the App Icon

Since the loginicon.svg needs to be converted to PNG format for the app icon, follow these steps:

### Option 1: Manual Conversion (Recommended)

1. **Convert SVG to PNG:**
   - Open `assets/icons/loginicon.svg` in a design tool (Figma, Adobe Illustrator, Inkscape, or online converter like https://cloudconvert.com/svg-to-png)
   - Export as PNG with these dimensions:
     - **1024x1024 pixels** (high resolution for best quality)
   - Save the PNG as `assets/icons/app_icon.png`

2. **Generate App Icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild the app:**
   ```bash
   flutter clean
   flutter run
   ```

### Option 2: Quick Setup with Existing Icon

If you already have a PNG version of the logo:
1. Place it in `assets/icons/app_icon.png` (1024x1024 recommended)
2. Run the commands from step 2 above

### What This Does

The `flutter_launcher_icons` package will automatically:
- Generate all required icon sizes for Android (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Create adaptive icons for Android 8.0+ with white background
- Update the Android manifest to use the new icons

### Current Configuration

The app icon configuration in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

### Notes

- The icon will have a white background for adaptive icons (Android 8.0+)
- Make sure the PNG has transparent background or the logo is centered
- The icon should be square (1:1 aspect ratio)
- Minimum recommended size: 512x512px, but 1024x1024px is better

### Troubleshooting

If the icon doesn't update:
1. Run `flutter clean`
2. Uninstall the app from your device
3. Run `flutter run` again
