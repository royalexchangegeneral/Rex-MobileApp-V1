# Implementation Plan: Agent Dashboard

## Overview

This implementation plan breaks down the Agent Dashboard feature into incremental coding tasks. The approach follows a bottom-up strategy: first establishing data models and core services, then building state management providers, and finally implementing UI screens with navigation. Each task builds on previous work, ensuring no orphaned code and enabling early validation through testing.

## Tasks

- [ ] 1. Set up data models and enums
  - [ ] 1.1 Create UserType enum and User model
    - Create `lib/models/user.dart` with UserType enum (agent, customer)
    - Implement User class with id, name, email, userType, and optional agentId
    - Add isAgent() and isCustomer() helper methods
    - Implement fromJson() and toJson() serialization methods
    - _Requirements: 2.1, 2.5, 11.1_
  
  - [ ]* 1.2 Write property test for User model
    - **Property 12: Session Persistence Round Trip**
    - **Validates: Requirements 10.1, 10.2, 10.4**
    - Test that User.toJson() followed by User.fromJson() produces equivalent user data
  
  - [ ] 1.3 Create PolicyStatus enum and Policy model
    - Create `lib/models/policy.dart` with PolicyStatus enum (active, pending, expired, cancelled)
    - Implement Policy class with id, policyNumber, policyType, clientName, renewalDate, status, premium
    - Implement fromJson() and toJson() serialization methods
    - _Requirements: 8.2, 8.3_
  
  - [ ]* 1.4 Write property test for Policy model
    - **Property 8: Policy List Item Completeness**
    - **Validates: Requirements 8.2, 8.3**
    - Test that all required policy fields are present after deserialization
  
  - [ ] 1.5 Create AgentStatistics model
    - Create `lib/models/agent_statistics.dart`
    - Implement AgentStatistics class with totalCommission, commissionChangePercent, totalClients, newClientsThisWeek, activePolicies, newPoliciesThisWeek, pendingClaims, newClaimsThisWeek
    - Implement fromJson() and toJson() serialization methods
    - _Requirements: 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 6.1, 6.2_
  
  - [ ]* 1.6 Write property test for AgentStatistics model
    - **Property 6: Complete Statistics Display**
    - **Validates: Requirements 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 6.1, 6.2**
    - Test that all statistics fields are correctly deserialized from JSON

- [ ] 2. Implement mock data service
  - [ ] 2.1 Create MockAgentService
    - Create `lib/services/mock_agent_service.dart`
    - Implement getAgentStatistics() method returning mock AgentStatistics with realistic values
    - Implement getPolicies() method returning list of 5-7 mock Policy objects with varied statuses
    - Add simulated delays (500ms) to mimic network calls
    - Include sample data with positive and negative commission changes for testing
    - _Requirements: 3.1, 3.2, 3.4, 8.2_
  
  - [ ]* 2.2 Write unit tests for MockAgentService
    - Test getAgentStatistics returns valid AgentStatistics object
    - Test getPolicies returns non-empty list of Policy objects
    - Test methods complete within reasonable time (< 2 seconds)

- [ ] 3. Enhance AuthProvider for user type detection
  - [ ] 3.1 Add user type properties to AuthProvider
    - Open `lib/providers/auth_provider.dart`
    - Add `String? _userType` private field
    - Add `String? getUserType()` getter method
    - Add `bool isAgent()` method returning `_userType == 'agent'`
    - Add `bool isCustomer()` method returning `_userType == 'customer'`
    - _Requirements: 2.1, 2.5, 11.1_
  
  - [ ] 3.2 Update login method to detect user type
    - Modify login() method to determine user type from credentials
    - Set _userType to 'agent' for agent credentials (e.g., emails ending with @rexinsurance.com)
    - Set _userType to 'customer' for customer credentials
    - Store user type in SharedPreferences with key 'userType'
    - _Requirements: 2.1, 2.5, 11.1_
  
  - [ ]* 3.3 Write property test for authentication type detection
    - **Property 1: Agent Authentication Type Detection**
    - **Validates: Requirements 2.1, 2.5, 11.1**
    - Test that valid agent credentials always set userType to 'agent'
  
  - [ ] 3.4 Update checkAuthStatus to restore user type
    - Modify checkAuthStatus() method to read 'userType' from SharedPreferences
    - Restore _userType field when session is restored
    - _Requirements: 10.1, 10.2, 10.4_
  
  - [ ] 3.5 Update logout method to clear user type
    - Modify logout() method to remove 'userType' from SharedPreferences
    - Clear _userType field
    - _Requirements: 10.3_
  
  - [ ]* 3.6 Write property test for session persistence
    - **Property 12: Session Persistence Round Trip**
    - **Validates: Requirements 10.1, 10.2, 10.4**
    - Test that login followed by checkAuthStatus restores equivalent state
  
  - [ ]* 3.7 Write property test for logout session clearing
    - **Property 13: Logout Session Clearing**
    - **Validates: Requirements 10.3**
    - Test that logout clears all session data including user type

- [ ] 4. Create AgentDataProvider
  - [ ] 4.1 Implement AgentDataProvider class
    - Create `lib/providers/agent_data_provider.dart`
    - Extend ChangeNotifier
    - Add private fields: _statistics, _policies, _isLoading, _errorMessage
    - Add getter methods for all fields
    - Inject MockAgentService in constructor
    - _Requirements: 3.1, 8.1_
  
  - [ ] 4.2 Implement fetchAgentStatistics method
    - Add fetchAgentStatistics() async method
    - Set _isLoading to true before fetch
    - Call MockAgentService.getAgentStatistics()
    - Store result in _statistics
    - Handle errors and store in _errorMessage
    - Set _isLoading to false after completion
    - Call notifyListeners() to update UI
    - _Requirements: 3.1, 3.2, 4.1, 4.2, 5.1, 5.2, 6.1, 6.2_
  
  - [ ] 4.3 Implement fetchPolicies method
    - Add fetchPolicies() async method
    - Set _isLoading to true before fetch
    - Call MockAgentService.getPolicies()
    - Store result in _policies
    - Handle errors and store in _errorMessage
    - Set _isLoading to false after completion
    - Call notifyListeners() to update UI
    - _Requirements: 8.1, 8.2_
  
  - [ ] 4.4 Implement refreshData method
    - Add refreshData() async method
    - Call both fetchAgentStatistics() and fetchPolicies()
    - Use Future.wait to fetch in parallel
    - _Requirements: 3.1, 8.1_
  
  - [ ]* 4.5 Write unit tests for AgentDataProvider
    - Test fetchAgentStatistics updates _statistics and notifies listeners
    - Test fetchPolicies updates _policies and notifies listeners
    - Test error handling sets _errorMessage
    - Test loading state transitions correctly

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Update UserPortalScreen to add Agent Portal button
  - [ ] 6.1 Add Agent Portal button to UserPortalScreen
    - Open `lib/screens/user_portal_screen.dart`
    - Add "Agent Portal" button below or alongside existing customer portal button
    - Style button to visually distinguish from customer portal option (use navy blue color)
    - Wire button to navigate to '/login' route with agent context flag
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [ ]* 6.2 Write widget test for UserPortalScreen
    - Test that Agent Portal button is displayed
    - Test that button tap navigates to login screen
    - Test visual distinction between agent and customer buttons

- [ ] 7. Update LoginScreen for user type routing
  - [ ] 7.1 Modify LoginScreen to handle user type routing
    - Open `lib/screens/login_screen.dart`
    - After successful login, check authProvider.isAgent()
    - If isAgent() is true, navigate to AgentDashboardScreen
    - If isCustomer() is true, navigate to existing CustomerDashboardScreen
    - Use Navigator.pushReplacement to prevent back navigation to login
    - _Requirements: 2.2, 2.3, 11.2, 11.3_
  
  - [ ] 7.2 Add error handling for invalid credentials
    - Display SnackBar with error message for invalid credentials
    - Ensure error message matches requirement: "Invalid email or password"
    - _Requirements: 2.4_
  
  - [ ]* 7.3 Write property test for user type based routing
    - **Property 2: User Type Based Routing**
    - **Validates: Requirements 2.2, 2.3, 11.2, 11.3**
    - Test that agent credentials route to AgentDashboard
    - Test that customer credentials route to CustomerDashboard
  
  - [ ]* 7.4 Write property test for invalid credentials error handling
    - **Property 3: Invalid Credentials Error Handling**
    - **Validates: Requirements 2.4**
    - Test that invalid credentials display error and prevent authentication

- [ ] 8. Create reusable statistics card widget
  - [ ] 8.1 Create StatisticsCard widget
    - Create `lib/widgets/statistics_card.dart`
    - Accept parameters: title, value, weeklyChange, backgroundColor, icon
    - Display value in large bold text (24px)
    - Display title in smaller text (12px) with 70% opacity
    - Display weekly change in small text (10px) with 60% opacity
    - Apply background color from parameter
    - Add padding and rounded corners matching design
    - _Requirements: 4.1, 4.2, 5.1, 5.2, 6.1, 6.2_
  
  - [ ]* 8.2 Write property test for positive weekly change formatting
    - **Property 7: Positive Weekly Change Formatting**
    - **Validates: Requirements 4.4, 5.4, 6.4**
    - Test that positive values are formatted with plus sign prefix
  
  - [ ]* 8.3 Write widget test for StatisticsCard
    - Test that all parameters are displayed correctly
    - Test background color is applied
    - Test text styling matches design specifications

- [ ] 9. Create commission card widget
  - [ ] 9.1 Create CommissionCard widget
    - Create `lib/widgets/commission_card.dart`
    - Accept parameters: totalCommission, changePercent
    - Format commission with Nigerian Naira symbol (₦), thousand separators, two decimal places
    - Display commission in large text (28px, bold, white)
    - Display "Total Commission" label (12px, white70)
    - Display percentage change with appropriate indicator (green for positive, red for negative)
    - Use navy blue background (#1E2D64)
    - _Requirements: 3.1, 3.3, 3.4_
  
  - [ ]* 9.2 Write property test for commission amount formatting
    - **Property 4: Commission Amount Formatting**
    - **Validates: Requirements 3.1, 3.3**
    - Test that any commission amount is formatted with ₦, thousand separators, and two decimals
  
  - [ ]* 9.3 Write property test for percentage change indicator
    - **Property 5: Percentage Change Indicator**
    - **Validates: Requirements 3.4**
    - Test that positive values show positive indicator and negative values show negative indicator
  
  - [ ]* 9.4 Write widget test for CommissionCard
    - Test commission formatting with various amounts
    - Test positive percentage change displays with green color
    - Test negative percentage change displays with red color

- [ ] 10. Create policy list item widget
  - [ ] 10.1 Create PolicyListItem widget
    - Create `lib/widgets/policy_list_item.dart`
    - Accept Policy object as parameter
    - Display policy type icon (based on policy type)
    - Display policy type in bold (13px)
    - Display policy number in gray (10px)
    - Display status badge with appropriate color (active=green, pending=orange, expired=gray, cancelled=red)
    - Display renewal date in orange (10px)
    - Add onTap callback for navigation
    - _Requirements: 8.2, 8.3_
  
  - [ ]* 10.2 Write widget test for PolicyListItem
    - Test all policy information is displayed
    - Test status badge color matches policy status
    - Test onTap callback is triggered

- [ ] 11. Create quick action button widget
  - [ ] 11.1 Create QuickActionButton widget
    - Create `lib/widgets/quick_action_button.dart`
    - Accept parameters: label, icon, color, onTap callback
    - Display icon above label
    - Apply color to icon and border
    - Add rounded corners and padding
    - Make button tappable with ripple effect
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ]* 11.2 Write widget test for QuickActionButton
    - Test button displays icon and label
    - Test button applies correct color
    - Test onTap callback is triggered

- [ ] 12. Implement AgentDashboardScreen
  - [ ] 12.1 Create AgentDashboardScreen scaffold
    - Create `lib/screens/agent_dashboard_screen.dart`
    - Set up Scaffold with AppBar
    - Add menu icon, Rex Insurance logo, and notification bell to AppBar
    - Set up ScrollView for main content
    - Add MultiProvider to provide AgentDataProvider
    - _Requirements: 3.1, 4.1, 5.1, 6.1, 7.1, 8.1, 9.1_
  
  - [ ] 12.2 Add commission card to dashboard
    - Use Consumer<AgentDataProvider> to access statistics
    - Add CommissionCard widget with totalCommission and commissionChangePercent
    - Position at top of scrollable content
    - _Requirements: 3.1, 3.2, 3.3, 3.4_
  
  - [ ] 12.3 Add statistics grid to dashboard
    - Create 3-column grid below commission card
    - Add StatisticsCard for Clients (navy blue, totalClients, newClientsThisWeek)
    - Add StatisticsCard for Active Policies (orange, activePolicies, newPoliciesThisWeek)
    - Add StatisticsCard for Pending Claims (green, pendingClaims, newClaimsThisWeek)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 6.1, 6.2, 6.3, 6.4_
  
  - [ ] 12.4 Add quick actions row to dashboard
    - Create row with 3 QuickActionButton widgets
    - Add "Add Client" button (person_add icon, navy blue)
    - Add "New Policy" button (description icon, orange)
    - Add "File a Claim" button (assignment icon, green)
    - Wire buttons to navigate to respective screens (placeholder navigation for now)
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  
  - [ ] 12.5 Add My Policies section to dashboard
    - Add section header "My Policies" with "View All" link
    - Use Consumer<AgentDataProvider> to access policies list
    - Display first 3-5 policies using PolicyListItem widget
    - Wire "View All" link to navigate to complete policies screen
    - Wire policy item taps to navigate to policy details screen
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ]* 12.6 Write property test for policy item navigation
    - **Property 9: Policy Item Navigation**
    - **Validates: Requirements 8.5**
    - Test that clicking any policy navigates with correct policy identifier
  
  - [ ] 12.7 Add bottom navigation bar to dashboard
    - Create BottomNavigationBar with 5 tabs
    - Add Home tab (home_outlined icon)
    - Add Policies tab (description_outlined icon)
    - Add Clients tab (people_outlined icon)
    - Add Reports tab (bar_chart_outlined icon)
    - Add Profile tab (person_outlined icon)
    - Set current index to 0 (Home) for dashboard screen
    - Wire onTap to navigate to corresponding screens
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_
  
  - [ ]* 12.8 Write property test for bottom navigation tab routing
    - **Property 10: Bottom Navigation Tab Routing**
    - **Validates: Requirements 9.7**
    - Test that clicking any tab navigates to corresponding screen
  
  - [ ]* 12.9 Write property test for active tab highlighting
    - **Property 11: Active Tab Highlighting**
    - **Validates: Requirements 9.8**
    - Test that exactly one tab is highlighted and matches current screen
  
  - [ ] 12.10 Add loading and error states to dashboard
    - Display CircularProgressIndicator when _isLoading is true
    - Display error message with retry button when _errorMessage is not null
    - Call refreshData() in initState to load initial data
    - _Requirements: 3.1, 8.1_
  
  - [ ]* 12.11 Write widget test for AgentDashboardScreen
    - Test all sections are displayed when data is loaded
    - Test loading state displays progress indicator
    - Test error state displays error message
    - Test quick action buttons are tappable
    - Test bottom navigation is displayed

- [ ] 13. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 14. Add route definitions and navigation guards
  - [ ] 14.1 Register AgentDashboardScreen route
    - Open `lib/main.dart` or route configuration file
    - Add '/agent-dashboard' route pointing to AgentDashboardScreen
    - _Requirements: 2.2, 11.2_
  
  - [ ] 14.2 Implement route guard for agent-only screens
    - Create route guard middleware that checks authProvider.isAgent()
    - Apply guard to agent-only routes (agent-dashboard, clients, reports)
    - Redirect to login if not authenticated
    - Redirect to appropriate dashboard if wrong user type
    - _Requirements: 11.4, 11.5_
  
  - [ ]* 14.3 Write property test for role-based access control
    - **Property 14: Role-Based Access Control**
    - **Validates: Requirements 11.4, 11.5**
    - Test that agents cannot access customer-only screens
    - Test that customers cannot access agent-only screens
  
  - [ ] 14.3 Update app initialization to check auth status
    - Modify main app initialization to call authProvider.checkAuthStatus()
    - Route to appropriate dashboard if session exists
    - Route to user portal if no session
    - _Requirements: 10.1, 10.2_

- [ ] 15. Create placeholder screens for navigation targets
  - [ ] 15.1 Create placeholder screens
    - Create `lib/screens/add_client_screen.dart` with basic scaffold
    - Create `lib/screens/new_policy_screen.dart` with basic scaffold
    - Create `lib/screens/file_claim_screen.dart` with basic scaffold
    - Create `lib/screens/all_policies_screen.dart` with basic scaffold
    - Create `lib/screens/policy_details_screen.dart` with basic scaffold
    - Create `lib/screens/clients_screen.dart` with basic scaffold and bottom nav
    - Create `lib/screens/reports_screen.dart` with basic scaffold and bottom nav
    - Create `lib/screens/agent_profile_screen.dart` with basic scaffold and bottom nav
    - Each screen should display a title and "Coming Soon" message
    - _Requirements: 7.4, 7.5, 7.6, 8.5, 8.6, 9.7_
  
  - [ ] 15.2 Register placeholder screen routes
    - Add routes for all placeholder screens in route configuration
    - Wire navigation from AgentDashboardScreen to these routes
    - _Requirements: 7.4, 7.5, 7.6, 8.5, 8.6, 9.7_

- [ ] 16. Final integration and testing
  - [ ] 16.1 Wire all providers in main.dart
    - Ensure AuthProvider is provided at app root
    - Ensure AgentDataProvider is provided where needed
    - Verify provider dependencies are correctly set up
    - _Requirements: 2.1, 3.1_
  
  - [ ]* 16.2 Write integration test for complete agent login flow
    - Test navigation from UserPortalScreen → LoginScreen → AgentDashboardScreen
    - Test that statistics are loaded and displayed
    - Test that all interactive elements work correctly
    - _Requirements: 1.2, 2.2, 3.1, 4.1, 5.1, 6.1, 7.1, 8.1, 9.1_
  
  - [ ]* 16.3 Write integration test for session persistence
    - Test login, app restart simulation, and session restoration
    - Verify user remains authenticated with correct user type
    - _Requirements: 10.1, 10.2, 10.4_

- [ ] 17. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties from the design document
- Unit and widget tests validate specific examples and edge cases
- The implementation follows Flutter best practices with Provider state management
- Mock data service allows development and testing without backend dependencies
- Placeholder screens enable complete navigation flow testing
- Route guards ensure proper role-based access control
