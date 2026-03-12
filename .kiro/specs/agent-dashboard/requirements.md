# Requirements Document

## Introduction

The Agent Dashboard feature enables insurance agents to access a dedicated portal within the Rex Insurance mobile app. This feature introduces agent-specific authentication and a comprehensive dashboard that allows agents to manage their clients, track policies, monitor commissions, and handle claims. The feature extends the existing customer-focused app to support agent workflows.

## Glossary

- **Agent**: An insurance agent who sells and manages insurance policies for clients
- **Customer**: An individual who purchases insurance policies
- **User_Portal_Screen**: The initial screen that allows users to choose between customer and agent portals
- **Login_Screen**: The authentication screen that accepts email and password credentials
- **Agent_Dashboard**: The main dashboard screen displayed to authenticated agents
- **Customer_Dashboard**: The main dashboard screen displayed to authenticated customers
- **Auth_Provider**: The authentication service that validates credentials and manages user sessions
- **Commission**: The monetary compensation earned by agents for selling policies
- **Policy**: An insurance contract between the company and a client
- **Claim**: A formal request for compensation under an insurance policy
- **Client**: A customer managed by a specific agent
- **Navigation_Router**: The system component that determines which dashboard to display based on user type

## Requirements

### Requirement 1: Agent Portal Entry Point

**User Story:** As an insurance agent, I want to access the agent portal from the user portal screen, so that I can log in to my agent dashboard.

#### Acceptance Criteria

1. WHEN the User_Portal_Screen is displayed, THE User_Portal_Screen SHALL display an "Agent Portal" button
2. WHEN the "Agent Portal" button is clicked, THE Navigation_Router SHALL navigate to the Login_Screen
3. THE User_Portal_Screen SHALL visually distinguish the agent portal option from the customer portal option

### Requirement 2: Agent Authentication

**User Story:** As an insurance agent, I want to log in with my agent credentials, so that I can access agent-specific features.

#### Acceptance Criteria

1. WHEN an agent enters valid agent credentials on the Login_Screen, THE Auth_Provider SHALL authenticate the user as an agent
2. WHEN the Auth_Provider authenticates a user as an agent, THE Navigation_Router SHALL navigate to the Agent_Dashboard
3. WHEN the Auth_Provider authenticates a user as a customer, THE Navigation_Router SHALL navigate to the Customer_Dashboard
4. WHEN an agent enters invalid credentials, THE Login_Screen SHALL display an error message
5. THE Auth_Provider SHALL store the user type (agent or customer) in the session data

### Requirement 3: Commission Display

**User Story:** As an insurance agent, I want to view my total commission and recent changes, so that I can track my earnings.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the total commission amount in Nigerian Naira format
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the percentage change in commission
3. THE Agent_Dashboard SHALL format commission amounts with thousand separators and two decimal places
4. THE Agent_Dashboard SHALL display positive percentage changes with a positive indicator and negative changes with a negative indicator

### Requirement 4: Client Statistics Display

**User Story:** As an insurance agent, I want to view my total client count and recent additions, so that I can monitor my client base growth.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the total number of clients
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the number of new clients added this week
3. THE Agent_Dashboard SHALL display the client statistics in a navy blue card
4. THE Agent_Dashboard SHALL format the weekly change with a plus sign for positive values

### Requirement 5: Active Policies Statistics Display

**User Story:** As an insurance agent, I want to view the count of active policies and recent additions, so that I can track policy sales performance.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the total number of active policies
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the number of new policies added this week
3. THE Agent_Dashboard SHALL display the active policies statistics in an orange card
4. THE Agent_Dashboard SHALL format the weekly change with a plus sign for positive values

### Requirement 6: Pending Claims Statistics Display

**User Story:** As an insurance agent, I want to view the count of pending claims and recent additions, so that I can prioritize claim processing.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the total number of pending claims
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display the number of new claims added this week
3. THE Agent_Dashboard SHALL display the pending claims statistics in a green card
4. THE Agent_Dashboard SHALL format the weekly change with a plus sign for positive values

### Requirement 7: Quick Access Actions

**User Story:** As an insurance agent, I want quick access buttons for common tasks, so that I can efficiently perform frequent actions.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display an "Add Client" button
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a "New Policy" button
3. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a "File a Claim" button
4. WHEN the "Add Client" button is clicked, THE Navigation_Router SHALL navigate to the add client screen
5. WHEN the "New Policy" button is clicked, THE Navigation_Router SHALL navigate to the new policy screen
6. WHEN the "File a Claim" button is clicked, THE Navigation_Router SHALL navigate to the file claim screen

### Requirement 8: My Policies Section

**User Story:** As an insurance agent, I want to view a list of policies with their status, so that I can monitor policy renewals and details.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a "My Policies" section
2. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a list of policies with policy type, policy number, and renewal date
3. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display status badges for each policy
4. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a "View All" link in the My Policies section
5. WHEN a policy item is clicked, THE Navigation_Router SHALL navigate to the policy details screen for that policy
6. WHEN the "View All" link is clicked, THE Navigation_Router SHALL navigate to the complete policies list screen

### Requirement 9: Bottom Navigation

**User Story:** As an insurance agent, I want a bottom navigation bar with key sections, so that I can quickly navigate between different areas of the agent portal.

#### Acceptance Criteria

1. WHEN the Agent_Dashboard is displayed, THE Agent_Dashboard SHALL display a bottom navigation bar with five tabs
2. THE Agent_Dashboard SHALL display a "Home" tab in the bottom navigation bar
3. THE Agent_Dashboard SHALL display a "Policy" tab in the bottom navigation bar
4. THE Agent_Dashboard SHALL display a "Clients" tab in the bottom navigation bar
5. THE Agent_Dashboard SHALL display a "Reports" tab in the bottom navigation bar
6. THE Agent_Dashboard SHALL display a "Profile" tab in the bottom navigation bar
7. WHEN a navigation tab is clicked, THE Navigation_Router SHALL navigate to the corresponding screen
8. THE Agent_Dashboard SHALL highlight the currently active tab in the bottom navigation bar

### Requirement 10: Agent Session Management

**User Story:** As an insurance agent, I want my session to persist across app restarts, so that I don't have to log in repeatedly.

#### Acceptance Criteria

1. WHEN an agent successfully logs in, THE Auth_Provider SHALL store the agent session data locally
2. WHEN the app is restarted, THE Auth_Provider SHALL restore the agent session if valid
3. WHEN an agent logs out, THE Auth_Provider SHALL clear all session data
4. THE Auth_Provider SHALL include user type (agent or customer) in the stored session data

### Requirement 11: User Type Routing

**User Story:** As a system administrator, I want the app to route users to the correct dashboard based on their credentials, so that agents and customers see appropriate interfaces.

#### Acceptance Criteria

1. WHEN the Auth_Provider authenticates a user, THE Auth_Provider SHALL determine the user type from the credentials
2. WHEN the user type is agent, THE Navigation_Router SHALL route to the Agent_Dashboard
3. WHEN the user type is customer, THE Navigation_Router SHALL route to the Customer_Dashboard
4. THE Navigation_Router SHALL prevent agents from accessing customer-only screens
5. THE Navigation_Router SHALL prevent customers from accessing agent-only screens
