# Next Development Steps

## Immediate Next Screens

### 1. Login/Signup Screen
**Priority**: High
**Files to create**:
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/signup_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`

**Features**:
- Email/password login
- Social login buttons (Google, Apple)
- Form validation
- Remember me checkbox
- Biometric login option
- Navigate to dashboard on success

**Provider**: Already created (`AuthProvider`)

---

### 2. Dashboard/Home Screen
**Priority**: High
**Files to create**:
- `lib/screens/home/dashboard_screen.dart`
- `lib/widgets/insurance_category_card.dart`
- `lib/widgets/policy_summary_card.dart`
- `lib/models/insurance_category.dart`

**Features**:
- Welcome message with user name
- Insurance categories grid:
  - Motor Insurance
  - Health Insurance
  - Travel Insurance
  - Home Insurance
  - Life Insurance
- Active policies summary
- Quick actions (Renew, Claim, Buy)
- Bottom navigation bar

**New Providers Needed**:
- `lib/providers/policy_provider.dart`
- `lib/providers/dashboard_provider.dart`

---

### 3. Policy Purchase Flow
**Priority**: High
**Files to create**:
- `lib/screens/policy/policy_categories_screen.dart`
- `lib/screens/policy/policy_details_screen.dart`
- `lib/screens/policy/quote_form_screen.dart`
- `lib/screens/policy/quote_result_screen.dart`
- `lib/screens/policy/payment_screen.dart`
- `lib/models/policy_model.dart`
- `lib/models/quote_model.dart`

**Features**:
- Multi-step form (Vehicle details, Coverage, Personal info)
- Dynamic premium calculation
- Coverage comparison
- Payment integration (mock)
- Policy document generation

**New Providers Needed**:
- `lib/providers/quote_provider.dart`
- `lib/providers/payment_provider.dart`

---

### 4. My Policies Screen
**Priority**: Medium
**Files to create**:
- `lib/screens/policy/my_policies_screen.dart`
- `lib/screens/policy/policy_detail_view.dart`
- `lib/widgets/policy_card.dart`

**Features**:
- List of active policies
- Policy details view
- Download policy document
- Renew policy button
- Policy status indicators

---

### 5. Claims Screen
**Priority**: Medium
**Files to create**:
- `lib/screens/claims/claims_list_screen.dart`
- `lib/screens/claims/new_claim_screen.dart`
- `lib/screens/claims/claim_detail_screen.dart`
- `lib/models/claim_model.dart`
- `lib/widgets/claim_status_card.dart`

**Features**:
- Submit new claim
- Upload documents/photos
- Track claim status
- Claim history
- Status updates (Pending, Approved, Settled)

**New Providers Needed**:
- `lib/providers/claim_provider.dart`

---

### 6. Profile & Settings
**Priority**: Medium
**Files to create**:
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/edit_profile_screen.dart`
- `lib/screens/settings/settings_screen.dart`
- `lib/screens/settings/notifications_settings_screen.dart`

**Features**:
- User profile info
- Edit profile
- Change password
- Notification preferences
- Theme toggle (dark mode)
- Language selection
- Logout

---

### 7. Notifications
**Priority**: Low
**Files to create**:
- `lib/screens/notifications/notifications_screen.dart`
- `lib/models/notification_model.dart`
- `lib/services/notification_service.dart`

**Features**:
- Notification list
- Mark as read
- Policy expiry reminders
- Claim status updates
- Payment reminders

**New Providers Needed**:
- `lib/providers/notification_provider.dart`

---

## Additional Components to Build

### Reusable Widgets
Create in `lib/widgets/`:
- `custom_button.dart` - Branded buttons
- `custom_text_field.dart` - Form inputs
- `loading_indicator.dart` - Loading states
- `empty_state.dart` - Empty list states
- `error_widget.dart` - Error handling
- `bottom_nav_bar.dart` - Navigation bar
- `app_bar_custom.dart` - Custom app bar

### Services
Create in `lib/services/`:
- `api_service.dart` - API calls (mock for now)
- `storage_service.dart` - Local storage wrapper
- `mock_data.dart` - Mock data for testing
- `validation_service.dart` - Form validation

### Models
Create in `lib/models/`:
- `user_model.dart`
- `policy_model.dart`
- `claim_model.dart`
- `quote_model.dart`
- `payment_model.dart`
- `notification_model.dart`

### Utils
Create in `lib/utils/`:
- `constants.dart` - App constants
- `validators.dart` - Input validators
- `formatters.dart` - Date, currency formatters
- `routes.dart` - Route definitions

---

## Recommended Development Order

1. ✅ Splash Screen (Done)
2. ✅ Onboarding (Done)
3. 🔄 Login/Signup
4. 🔄 Dashboard
5. 🔄 Policy Categories
6. 🔄 Quote Form
7. 🔄 My Policies
8. 🔄 Claims
9. 🔄 Profile
10. 🔄 Notifications

---

## Mock Data Structure

### Example Policy
```dart
class Policy {
  final String id;
  final String type; // 'motor', 'health', 'travel'
  final String policyNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double premium;
  final String status; // 'active', 'expired', 'pending'
  final Map<String, dynamic> details;
}
```

### Example Claim
```dart
class Claim {
  final String id;
  final String policyId;
  final String type;
  final DateTime dateSubmitted;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected', 'settled'
  final List<String> documents;
}
```

---

## Testing Strategy

1. **Unit Tests**: Test providers and models
2. **Widget Tests**: Test individual screens
3. **Integration Tests**: Test complete flows
4. **Mock Services**: Use mock data for all API calls

---

## Performance Considerations

- Lazy load images
- Cache network responses
- Optimize list rendering with `ListView.builder`
- Use `const` constructors where possible
- Implement pagination for long lists

---

## Accessibility

- Add semantic labels
- Support screen readers
- Ensure proper contrast ratios
- Support text scaling
- Keyboard navigation

---

## Ready to Continue?

When you're ready to build the next screen, just let me know which one you'd like to tackle first! I recommend starting with the Login/Signup screen.
