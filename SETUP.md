# Setup Instructions

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Add Image Assets

You need to add 4 images to the `assets/images/` folder:

#### Required Images:
1. **logo.png** - Rex Insurance logo (white background)
   - Extract from: 1.png
   - Recommended size: 512x512px

2. **onboarding1.png** - World map with glowing network
   - Extract from: 2.png (full screen image)
   - Recommended size: 1080x1920px

3. **onboarding2.png** - Car, plane, and dog scene
   - Extract from: 3.png (full screen image)
   - Recommended size: 1080x1920px

4. **onboarding3.png** - Professional woman with phone
   - Extract from: 4.png (full screen image)
   - Recommended size: 1080x1920px

### 3. Run the App
```bash
flutter run
```

## App Flow

1. **Splash Screen** (2.5 seconds)
   - Animated Rex Insurance logo
   - Fade in + scale animation
   - Auto-navigates to onboarding

2. **Onboarding** (3 screens)
   - Screen 1: "Protect What Matters Most" → Continue button
   - Screen 2: "Into a Future Built on Security" → Get Started button
   - Screen 3: "Instant Coverage Delivered" → Next button
   - Skip button available on all screens
   - Smooth page indicators at bottom

3. **Next Steps** (To be implemented)
   - Login/Signup screen
   - Dashboard
   - Policy management
   - Claims

## Troubleshooting

### Images not showing?
1. Ensure images are in `assets/images/` folder
2. Run `flutter clean` then `flutter pub get`
3. Restart the app

### Provider errors?
1. Ensure all providers are registered in `main.dart`
2. Check import statements

### Build errors?
```bash
flutter clean
flutter pub get
flutter run
```

## Testing Without Images

The app includes fallback UI for missing images:
- Splash screen shows a custom-painted logo
- Onboarding screens show colored placeholders

This allows you to test the app flow before adding actual images.

## State Management

The app uses Provider for state management:

- **OnboardingProvider**: Tracks onboarding completion
- **AuthProvider**: Manages user authentication
- **ThemeProvider**: Handles light/dark mode

All state is persisted using SharedPreferences.

## Customization

### Change Colors
Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryBlue = Color(0xFF3D5A9E);
static const Color accentOrange = Color(0xFFF47920);
```

### Modify Onboarding Content
Edit `lib/screens/onboarding_screen.dart`:
```dart
final List<OnboardingModel> _pages = [
  OnboardingModel(
    title: 'Your Title',
    description: 'Your Description',
    imagePath: 'assets/images/your_image.png',
    buttonText: 'Your Button',
  ),
];
```

### Adjust Animation Duration
Edit `lib/screens/splash_screen.dart`:
```dart
// Animation duration
duration: const Duration(milliseconds: 1500),

// Screen display time
Timer(const Duration(milliseconds: 2500), () { ... });
```
