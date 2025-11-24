# Running the Rex Insurance App

## 🚀 Current Status

**Building**: The app is currently being built and will launch on your Samsung A346E device.

**First Build**: Takes 2-5 minutes (subsequent builds will be much faster)

---

## 📱 What You'll See

### 1. Splash Screen (2.5 seconds)
- Rex Insurance logo (orange & blue arcs)
- Smooth fade-in and scale animation
- White background
- Auto-navigates to onboarding

### 2. Onboarding Flow (3 Screens)

#### Screen 1: Instant Coverage
- **Image**: Car, plane, and animals (placeholder if image not added)
- **Title**: "Instant Coverage Delivered Right to Your Fingertips"
- **Description**: "Say goodbye to paperwork and long waits — buy, manage, and renew policies quickly and securely from your mobile device."
- **Button**: Blue "Continue" button with arrow
- **Skip**: White outlined button (top-right)

#### Screen 2: Security & Confidence
- **Image**: Professional woman with phone (placeholder if image not added)
- **Title**: "Into a Future Built on Security and Confidence"
- **Description**: "No matter where life takes you, we provide the foundation you need to grow, explore, and thrive without fear."
- **Button**: Blue "Get Started" button with arrow
- **Skip**: White outlined button (top-right)

#### Screen 3: Comprehensive Coverage
- **Image**: Glowing world map (placeholder if image not added)
- **Title**: "Protect What Matters Most with Comprehensive Coverage"
- **Description**: "We offer personalized insurance solutions tailored to every stage of your life."
- **Button**: Blue "Next" button with arrow
- **Skip**: White outlined button (top-right)

---

## 🎨 UI Features You'll See

✅ **Smooth Animations**
- Splash screen fade-in and scale
- Page transitions with swipe gestures

✅ **Page Indicators**
- Animated dots at bottom
- Worm effect when swiping

✅ **Gradient Overlays**
- Dark gradients on images for text readability
- Different opacity per screen

✅ **Responsive Design**
- Adapts to your screen size
- Safe area handling for notch/status bar

✅ **Brand Colors**
- Primary Blue: #3D5A9E
- Accent Orange: #F47920
- Clean white text

---

## 🔄 Interactions

### Swipe Gestures
- Swipe left/right to navigate between screens
- Smooth page transitions

### Buttons
- **Skip**: Jumps to end (shows snackbar for now)
- **Continue/Get Started/Next**: Goes to next screen
- **Last screen**: Marks onboarding as complete

### State Persistence
- Onboarding completion is saved
- Won't show again on next launch (unless reset)

---

## 🐛 Known Behavior

### Image Placeholders
Since actual images haven't been added yet, you'll see:
- Colored placeholder boxes
- Different colors per screen
- Icon placeholder in center

### Navigation End
After completing onboarding, you'll see a snackbar saying "Navigate to Login/Home" since those screens aren't built yet.

---

## 🎯 Testing Checklist

Once the app launches, try:

- [ ] Watch splash screen animation
- [ ] Swipe through all 3 onboarding screens
- [ ] Test Skip button
- [ ] Test Continue/Get Started/Next buttons
- [ ] Check page indicators animation
- [ ] Close and reopen app (should skip onboarding)

---

## 🔧 Hot Reload

Once the app is running, you can make code changes and press:
- **r** in terminal: Hot reload (fast)
- **R** in terminal: Hot restart (full restart)
- **q** in terminal: Quit

---

## 📊 Performance

Expected performance:
- **60 FPS** animations
- **Instant** page transitions
- **Smooth** swipe gestures
- **Fast** button responses

---

## 🎉 Next Steps

After testing the onboarding:

1. **Add Real Images**
   - Save images to `assets/images/`
   - Hot reload to see them

2. **Build Login Screen**
   - Authentication UI
   - Form validation
   - Mock login

3. **Build Dashboard**
   - Insurance categories
   - Policy summary
   - Quick actions

---

## 📱 Device Info

**Running on**: Samsung SM A346E
**OS**: Android 16 (API 36)
**Build Mode**: Debug
**Hot Reload**: Enabled

---

The app should launch on your device any moment now! 🚀
