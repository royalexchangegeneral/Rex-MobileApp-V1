# Rex Insurance - Flutter Mobile App

A comprehensive general insurance platform built with Flutter, featuring policy quotation, purchase, renewal, claim submission and tracking.

## 🚀 Features

- **Animated Splash Screen** - Rex Insurance logo with smooth animations
- **Onboarding Flow** - Swipeable onboarding screens with skip functionality
- **State Management** - Provider pattern for scalable state management
- **Theme Support** - Light and dark mode with persistent preferences
- **Authentication** - Mock login/signup with session management
- **Persistent Storage** - SharedPreferences for user data

## 📱 Screens Implemented

- ✅ Splash Screen (Animated Logo)
- ✅ Onboarding Screens (3 pages with swipe navigation)
- 🔄 Login/Signup (Coming next)
- 🔄 Dashboard
- 🔄 Policy Management
- 🔄 Claims
- 🔄 Profile & Settings

## 🛠️ Tech Stack

- **Flutter SDK**: 3.0+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **UI Components**: Material Design 3

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  smooth_page_indicator: ^1.1.0
  shared_preferences: ^2.2.2
```

## 🎨 Design System

### Colors
- **Primary Blue**: `#3D5A9E`
- **Accent Orange**: `#F47920`
- **Dark Background**: `#0A0E1A`

### Typography
- Font Family: Roboto
- Display: Bold, 28-32px
- Body: Regular, 14-16px

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point with Provider setup
├── screens/
│   ├── splash_screen.dart    # Animated logo screen
│   └── onboarding_screen.dart # Swipeable onboarding
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   ├── onboarding_provider.dart # Onboarding state
│   └── theme_provider.dart   # Theme management
├── models/
│   └── onboarding_model.dart # Onboarding data model
└── utils/
    └── app_theme.dart        # Theme configuration

assets/
└── images/
    ├── logo.png              # Rex Insurance logo
    ├── onboarding1.png       # World map scene
    ├── onboarding2.png       # Car/plane/dog scene
    └── onboarding3.png       # Professional woman scene
```

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd rex_insurance
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add image assets**
   - Place your images in `assets/images/` folder
   - Required images: logo.png, onboarding1.png, onboarding2.png, onboarding3.png

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Usage

### Provider Access

```dart
// Read provider (one-time access)
context.read<AuthProvider>().login(email, password);

// Watch provider (rebuilds on change)
final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

// Select specific value
final userName = context.select((AuthProvider p) => p.userName);
```

### Navigation

```dart
// Navigate to onboarding
Navigator.pushNamed(context, '/onboarding');
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🔄 Next Steps

1. Add Login/Signup screens
2. Implement Dashboard with insurance categories
3. Create Policy Purchase flow
4. Add Claims submission and tracking
5. Build Profile and Settings screens
6. Integrate push notifications
7. Add biometric authentication

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributors

- Your Team Name

## 📞 Support

For support, email support@rexinsurance.com
