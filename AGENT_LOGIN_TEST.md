# Agent Login Testing Guide

## How to Test Agent Dashboard

The agent dashboard will now appear when you log in with agent credentials.

### Test Credentials

To access the **Agent Dashboard**, use any email that:
- Ends with `@rexinsurance.com`, OR
- Contains the word `agent` anywhere in the email

**Example Agent Emails:**
- `agent@rexinsurance.com`
- `john.agent@gmail.com`
- `agent123@example.com`
- `sales@rexinsurance.com`

**Password:** Any password with 6+ characters (e.g., `password123`)

### Test Flow

1. **Step 1:** Open the app and click "Agent Portal Login" button
2. **Step 2:** Enter agent credentials (use one of the example emails above)
3. **Step 3:** Click "Log in"
4. **Step 4:** You should see the Agent Dashboard with:
   - Total Commission card (₦430,000.00)
   - Statistics cards (Total Client, Active Policies, Pending claims)
   - Quick Access buttons (Add Client, New Policy, File a Claim)
   - My Policies section
   - Bottom navigation (Home, Policy, Clients, Reports, Profile)

### Customer Login (for comparison)

To access the **Customer Dashboard**, use any email that:
- Does NOT end with `@rexinsurance.com`
- Does NOT contain the word `agent`

**Example Customer Emails:**
- `customer@gmail.com`
- `john.doe@yahoo.com`
- `test@example.com`

## Implementation Details

### What Changed:

1. **AuthProvider Enhanced:**
   - Added `_userType` field to track if user is 'agent' or 'customer'
   - Added `isAgent()` and `isCustomer()` helper methods
   - Login method now detects user type based on email
   - User type is stored in SharedPreferences for session persistence

2. **Login Screen Updated:**
   - Now routes to AgentDashboardScreen for agents
   - Routes to CustomerDashboardScreen for customers
   - Routing happens automatically based on email used

3. **Agent Dashboard Created:**
   - New screen matching the design guide
   - Commission card with gradient background
   - Statistics cards for clients, policies, and claims
   - Quick access buttons
   - Policy list with status badges
   - Bottom navigation bar

4. **Routes Added:**
   - `/agent-dashboard` route registered in main.dart

## Notes

- The user type detection is automatic based on email
- Session persistence works - if you close and reopen the app, you'll stay logged in as the same user type
- All data shown is currently mock data for demonstration
