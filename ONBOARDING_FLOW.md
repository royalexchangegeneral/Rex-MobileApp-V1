# Onboarding Flow - Correct Order

## Screen Sequence

### 1️⃣ First Screen (2.png → onboarding2.png)
**Image**: Car, plane, and animals in field  
**Title**: "Instant Coverage Delivered Right to Your Fingertips"  
**Description**: "Say goodbye to paperwork and long waits — buy, manage, and renew policies quickly and securely from your mobile device."  
**Button**: "Continue"  
**Skip**: Available (top-right)

---

### 2️⃣ Second Screen (3.png → onboarding3.png)
**Image**: Professional woman with phone in city  
**Title**: "Into a Future Built on Security and Confidence"  
**Description**: "No matter where life takes you, we provide the foundation you need to grow, explore, and thrive without fear."  
**Button**: "Get Started"  
**Skip**: Available (top-right)

---

### 3️⃣ Third Screen (4.png → onboarding1.png)
**Image**: Glowing world map  
**Title**: "Protect What Matters Most with Comprehensive Coverage"  
**Description**: "We offer personalized insurance solutions tailored to every stage of your life."  
**Button**: "Next"  
**Skip**: Available (top-right)

---

## Image File Mapping

| Screen Order | Source File | Save As | Content |
|--------------|-------------|---------|---------|
| Screen 1 | 2.png | onboarding2.png | Car/plane/animals |
| Screen 2 | 3.png | onboarding3.png | Woman with phone |
| Screen 3 | 4.png | onboarding1.png | World map |
| Splash | 1.png | logo.png | Rex logo |

---

## User Flow

```
Splash Screen (1.png - logo)
    ↓ (2.5 seconds)
Onboarding Screen 1 (2.png - car/plane)
    ↓ (swipe or Continue)
Onboarding Screen 2 (3.png - woman)
    ↓ (swipe or Get Started)
Onboarding Screen 3 (4.png - world map)
    ↓ (swipe or Next)
[Next: Login/Home Screen]
```

---

## Features

✅ Swipeable pages with smooth transitions  
✅ Page indicators (dots) at bottom  
✅ Skip button on all screens  
✅ Different CTA buttons per screen  
✅ Gradient overlay on images  
✅ Completion tracking (won't show again)  

---

## Implementation Details

- **File**: `lib/screens/onboarding_screen.dart`
- **State**: Managed by `OnboardingProvider`
- **Navigation**: PageView with PageController
- **Persistence**: SharedPreferences stores completion status
- **Animation**: Smooth page indicator with worm effect

---

## Testing

1. First launch → Shows onboarding
2. Complete onboarding → Saves to SharedPreferences
3. Relaunch app → Skips onboarding (goes directly to next screen)
4. Reset: Call `OnboardingProvider.resetOnboarding()` for testing
