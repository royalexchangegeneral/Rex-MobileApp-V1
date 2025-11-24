# Quick Start Guide

## 🚀 Get Running in 3 Steps

### Step 1: Add Images
Save these 4 images to `assets/images/`:

1. **logo.png** - Rex Insurance logo (orange & blue arcs with text)
2. **onboarding1.png** - Glowing world map on dark background
3. **onboarding2.png** - Car, plane, and animal in field
4. **onboarding3.png** - Professional woman with phone in city

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run the App
```bash
flutter run
```

---

## 📱 What You'll See

### 1. Splash Screen (2.5 seconds)
- Animated Rex Insurance logo
- Smooth fade-in and scale animation
- Auto-navigates to onboarding

### 2. Onboarding Screen 1
- **Image**: Glowing world map
- **Title**: "Protect What Matters Most with Comprehensive Coverage"
- **Description**: "We offer personalized insurance solutions tailored to every stage of your life."
- **Button**: "Continue"
- **Action**: Skip or swipe to next screen

### 3. Onboarding Screen 2
- **Image**: Car, plane, and animals
- **Title**: "Into a Future Built on Security and Confidence"
- **Description**: "No matter where life takes you, we provide the foundation you need to grow, explore, and thrive without fear."
- **Button**: "Get Started"
- **Action**: Skip or swipe to next screen

### 4. Onboarding Screen 3
- **Image**: Professional woman with phone
- **Title**: "Instant Coverage Delivered Right to Your Fingertips"
- **Description**: "Say goodbye to paperwork and long waits – buy, manage, and renew policies quickly and securely from your mobile device."
- **Button**: "Next"
- **Action**: Skip or complete onboarding

---

## 🎯 Features Working

✅ Animated splash screen  
✅ Swipeable onboarding (3 screens)  
✅ Skip button on all screens  
✅ Smooth page indicators  
✅ State persistence (onboarding completion saved)  
✅ Provider state management  
✅ Theme system ready  
✅ No errors or warnings  

---

## 🔧 Troubleshooting

### Images not showing?
1. Verify images are in `assets/images/` folder
2. Check file names match exactly (case-sensitive)
3. Run `flutter clean && flutter pub get`
4. Restart the app

### App won't run?
```bash
flutter doctor
flutter clean
flutter pub get
flutter run
```

### Want to test without images?
The app includes fallback placeholders, so it will run even without images!

---

## 📂 Project Structure

```
rex_insurance/
├── assets/
│   └── images/
│       ├── logo.png              ← Add this
│       ├── onboarding1.png       ← Add this
│       ├── onboarding2.png       ← Add this
│       └── onboarding3.png       ← Add this
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   └── onboarding_screen.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── onboarding_provider.dart
│   │   └── theme_provider.dart
│   ├── models/
│   │   └── onboarding_model.dart
│   └── utils/
│       └── app_theme.dart
└── pubspec.yaml
```

---

## 🎨 Customization

### Change Colors
Edit `lib/utils/app_theme.dart`:
```dart
static const Color primaryBlue = Color(0xFF3D5A9E);
static const Color accentOrange = Color(0xFFF47920);
```

### Change Onboarding Text
Edit `lib/screens/onboarding_screen.dart`:
```dart
final List<OnboardingModel> _pages = [
  OnboardingModel(
    title: 'Your Custom Title',
    description: 'Your custom description',
    imagePath: 'assets/images/your_image.png',
    buttonText: 'Your Button Text',
  ),
];
```

### Change Animation Speed
Edit `lib/screens/splash_screen.dart`:
```dart
// Animation duration
duration: const Duration(milliseconds: 1500),

// Display time before navigation
Timer(const Duration(milliseconds: 2500), () { ... });
```

---

## ✨ Next Steps

After testing the onboarding flow, you can:

1. **Build Login/Signup Screen**
2. **Create Dashboard**
3. **Add Policy Management**
4. **Implement Claims Flow**

See `NEXT_STEPS.md` for detailed guidance!

---

## 🎉 You're All Set!

The foundation is complete and production-ready. Just add the images and run!

```bash
flutter run
```

Enjoy building your insurance platform! 🚀
