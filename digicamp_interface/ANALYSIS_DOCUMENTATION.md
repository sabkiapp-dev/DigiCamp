# Upload Voices Web - Comprehensive Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture](#architecture)
4. [Features & Functionality](#features--functionality)
5. [Components & Screens](#components--screens)
6. [API Integration](#api-integration)
7. [Data Models](#data-models)
8. [State Management](#state-management)
9. [Routing](#routing)
10. [Configuration](#configuration)

---

## 1. Project Overview

**Project Name:** Upload Voices Web
**Backend API:** asterisk.sabkiapp.com
**Type:** Flutter Web Application (PWA)
**Purpose:** A telecommunications management system for managing voice recordings, SMS campaigns, contacts, and monitoring SIM card machines (SIM banks)

This is a comprehensive telecom management platform that allows users to:
- Upload and manage voice/audio files for automated calling campaigns
- Monitor SIM card machines in real-time
- Create and manage voice and SMS campaigns
- Manage contacts and contact lists
- Track missed calls and operator performance
- Generate reports and export data

---

## 2. Technology Stack

### Frontend Framework
- **Flutter** (Web)
- **Dart**

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| provider | ^6.1.0-dev.1 | State Management |
| hive / hive_flutter | ^2.2.3 / ^1.1.0 | Local Storage |
| go_router | ^13.2.0 | Navigation/Routing |
| url_strategy | ^0.2.0 | URL formatting for web |
| just_audio | ^0.9.35 | Audio playback |
| syncfusion_flutter_datagrid | - | Data tables/grids |
| fl_chart | ^0.66.2 | Charts/analytics |
| quickalert | ^1.0.2 | Alert dialogs |
| dropdown_search | ^5.0.6 | Searchable dropdowns |
| gap | ^3.0.1 | Spacing widgets |
| flutter_svg | ^2.0.9 | SVG rendering |
| font_awesome_flutter | ^10.6.0 | Icons |
| file_picker | ^6.0.0 | File selection |
| path_provider | ^2.1.1 | File paths |
| formz | ^0.6.1 | Form validation |
| http | ^1.1.0 | HTTP client |
| http_interceptor | ^2.0.0-beta.7 | HTTP interceptors |
| excel | ^2.1.0 | Excel export |
| csv | ^5.1.0 | CSV export |
| google_fonts | ^6.1.0 | Typography |
| get_it | ^7.6.0 | Dependency Injection |
| connectivity_plus | ^5.0.1 | Network status |
| package_info_plus | ^4.2.0 | App info |
| freezed_annotation | ^2.4.1 | Immutable classes |
| json_annotation | ^4.8.1 | JSON serialization |
| equatable | ^2.0.5 | Value equality |
| intl | ^0.18.1 | Internationalization |

---

## 3. Architecture

### Directory Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration with providers
└── src/
    ├── config/
    │   └── router.dart       # GoRouter configuration
    ├── providers/            # State management
    │   ├── auth_provider/
    │   ├── settings_provider/
    │   ├── navbar_provider/
    │   ├── hud_provider/
    │   └── connectivity_provider/
    ├── models/               # Data models
    ├── screens/              # UI screens
    ├── utils/                # Utilities & services
    ├── commons/             # Shared components
    ├── input_formatters/     # Input validation
    └── formz_model/         # Form validation models
```

### Entry Point (main.dart)
- Initializes Hive local storage
- Sets up URL strategy for clean web URLs
- Creates AuthProvider with Hive persistence
- Sets up HTTP interceptors with 10-minute timeout
- Connects to API at asterisk.sabkiapp.com
- Registers ApiClient as singleton via GetIt

### App Configuration (app.dart)
- Uses MultiProvider for state management
- Providers:
  - SettingsProvider - Theme management
  - NavbarProvider - Navigation state
  - ConnectivityProvider - Network monitoring
  - HudProvider - Global loading overlay
  - AuthProvider - Authentication
- MaterialApp.router with GoRouter
- Light/dark theme support
- Global loading overlay (HudProvider)

---

## 4. Features & Functionality

### 4.1 Authentication System

**Features:**
- JWT-based authentication
- User login with email/password
- User registration (create new users)
- Token persistence in Hive storage
- Two-tier access control: Regular users and Superusers
- Automatic token refresh via HTTP interceptors
- Session expiration handling with redirect to login
- User switching (superuser can login as sub-user)
- Password change functionality

**Route Protection:**
- Routes protected based on user role
- Superuser-only routes: /users, /users-hosts, /api-list
- Automatic redirect to sign-in if not authenticated

### 4.2 Audio/Voice Management

**Features:**
- Upload audio files (using file_picker)
- Play audio files (using just_audio)
- Edit audio metadata (name, description)
- Enable/disable audio status (active/inactive)
- Paginated data grid view
- Search and sort functionality
- Audio file listing with status indicators

**Files:**
- `/src/screens/audios/audios.dart`
- `/src/screens/audios/views/add_audio_page.dart`
- `/src/screens/audios/views/view_audios_page.dart`
- `/src/screens/audios/data/audio_data_source.dart`

**Audio Data:**
- Audio ID
- Voice Name
- Voice Description
- File Path
- Status (enabled/disabled)

### 4.3 Dashboard & SIM Bank Monitoring

**Features:**
- Shows active host/SIM bank machines
- Real-time status cards displaying:
  - SIMs Blocked Today
  - Ports Without SIM
  - SIMs Without Signal
  - SIMs Without Recharge
  - New SIMs
  - Waiting SIMs
  - Ready SIMs
  - Busy SIMs
  - Total SMS Balance
- Detailed port-level data table:
  - Port Number
  - Signal Strength
  - Status (Ready, Busy, Blocked, Rechargeless)
  - Phone Number
  - Operator (Jio, Airtel, Vi, BSNL, etc.)
  - Calls Made Today / Total Calls
  - Call Time Today / Total Call Time
  - Validity (expiry date)
  - SMS Balance
- Actions:
  - Test blocked SIM
  - Check for recharge
- Refresh functionality

### 4.4 Campaign Management

**Campaign Types:**
- Voice campaigns (using uploaded audio files)
- Dial plan configuration

**Features:**
- Create new campaigns
- Edit existing campaigns
- Delete campaigns
- View campaign list
- Dial plan configuration:
  - DTMF (Dual Tone Multi Frequency) options
  - SMS after call configuration
  - Call duration settings
  - Retry settings
- Campaign reporting
- Campaign summary/analytics
- Contact list association per campaign

**Routes:**
- `/add-campaign` - Create campaign
- `/view-campaigns` - List campaigns
- `/update-campaign/:id` - Edit campaign
- `/dial-plan/:campaignId` - Dial plan settings
- `/campaign-report/:id` - Campaign reports
- `/campaign-summary` - Campaign analytics

### 4.5 SMS Management

**Features:**
- SMS template creation
- SMS template editing
- SMS template viewing/listing
- SMS template selection for campaigns
- Bulk SMS campaigns
- SMS history tracking

**SMS Template Features:**
- Template name
- Template content/message
- Status (active/inactive)
- Edit/delete functionality

**Routes:**
- `/add-sms` - Create SMS template
- `/edit-sms/:id` - Edit SMS template
- `/view-sms` - List SMS templates
- `/select-sms` - Select SMS for campaigns

### 4.6 Bulk SMS Campaigns

**Features:**
- Create bulk SMS campaigns
- Edit bulk SMS campaigns
- View bulk SMS history
- Select contacts for bulk SMS
- Schedule SMS sending
- Track delivery status

**Routes:**
- `/add-bulk-sms` - Create bulk SMS campaign
- `/update-bulk-sms/:id` - Edit bulk SMS
- `/view-bulk-sms` - View bulk SMS history

### 4.7 Contact Management

**Features:**
- Add new contacts
- View contacts list
- Contact categories/filtering
- Contact import capabilities
- Contact export capabilities
- Bulk contact operations

**Contact Data:**
- Name
- Mobile number
- Category
- Associated campaigns

**Routes:**
- `/add-contacts` - Add contacts
- `/view-contacts` - View contacts list

### 4.8 Missed Call Management

**Features:**
- Missed call tracking
- Operator configuration
- Download reports (CSV/Excel)
- Missed call analytics

**Routes:**
- `/view-miss-call` - View missed calls
- `/add-operator` - Add mobile operator
- `/all-operators` - View all operators

### 4.9 User Management (Superuser Only)

**Features:**
- Create new users
- View user list
- Manage user hosts (SIM banks)
- Assign SIM banks to users
- API key generation
- Password reset for users

**Routes:**
- `/users` - User list
- `/users-hosts/:userId` - Manage user's SIM banks
- `/api-list` - API key management

### 4.10 API Key Management

**Features:**
- Generate new API keys
- View existing API keys
- Copy API key to clipboard
- API key for external integrations

### 4.11 Data Export

**Features:**
- Export to CSV format
- Export to Excel format
- Download reports
- Export functionality for:
  - Contacts
  - Missed calls
  - Campaign reports
  - SIM bank status

### 4.12 Settings & Preferences

**Features:**
- Light/Dark theme toggle
- Theme persistence (saved in Hive)
- Responsive layout (mobile/tablet/desktop)

---

## 5. Components & Screens

### 5.1 Authentication Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Sign In | `/sign-in` | Login page with email/password |

**Sign In Features:**
- Email input with validation
- Password input with show/hide toggle
- Remember me functionality (via Hive)
- Loading state during authentication
- Error handling and display

### 5.2 Dashboard

| Screen | Route | Description |
|--------|-------|-------------|
| Dashboard | `/dashboard` | Main dashboard with SIM bank status |

### 5.3 Audio Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Add Audio | `/add-audio` | Upload new audio file |
| View Audios | `/view-audio` | List all audio files |
| Select Audio | `/select-audio` | Select audio for campaign |

### 5.4 Campaign Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Add Campaign | `/add-campaign` | Create new campaign |
| View Campaigns | `/view-campaigns` | List all campaigns |
| Update Campaign | `/update-campaign/:id` | Edit campaign |
| Dial Plan | `/dial-plan/:id` | Configure dial plan |
| Campaign Report | `/campaign-report/:id` | Campaign analytics |
| Campaign Summary | `/campaign-summary` | Overall campaign stats |

### 5.5 SMS Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Add SMS | `/add-sms` | Create SMS template |
| Edit SMS | `/edit-sms/:id` | Edit SMS template |
| View SMS | `/view-sms` | List SMS templates |
| Select SMS | `/select-sms` | Select SMS for campaign |
| Add Bulk SMS | `/add-bulk-sms` | Create bulk SMS |
| Update Bulk SMS | `/update-bulk-sms/:id` | Edit bulk SMS |
| View Bulk SMS | `/view-bulk-sms` | Bulk SMS history |

### 5.6 Contact Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Add Contacts | `/add-contacts` | Add new contacts |
| View Contacts | `/view-contacts` | List contacts |

### 5.7 Missed Call Screens

| Screen | Route | Description |
|--------|-------|-------------|
| View Miss Call | `/view-miss-call` | Missed call records |
| Add Operator | `/add-operator` | Add mobile operator |
| All Operators | `/all-operators` | List operators |

### 5.8 User Management Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Users | `/users` | User list (superuser) |
| User Hosts | `/users-hosts/:userId` | Manage user SIM banks |
| API List | `/api-list` | API key management |

### 5.9 UI Components

#### Navigation
- **Drawer-based navigation** - Side menu with all routes
- **Responsive layout** - Adapts to mobile/tablet/desktop
- **Role-based menu** - Menu items filtered by user role
- **NavbarProvider** - Manages active navigation state

#### Data Display
- **Syncfusion DataGrid** - Tabular data display
- **Pagination** - Navigate through large datasets
- **Column sorting** - Sort by any column
- **Column filtering** - Filter data by column values
- **fl_chart** - Analytics charts and graphs

#### Dialogs & Overlays
- **QuickAlert** - Quick notification dialogs
- **Custom dialogs** - Confirmation dialogs
- **HudProvider** - Global loading overlay
- **Loading states** - Visual feedback during operations

#### Forms
- **Formz validation** - Robust form validation
- **Input formatters** - Input length limiting
- **Dropdown search** - Searchable dropdowns
- **File picker** - File selection for uploads

---

## 6. API Integration

### Base URL
```
https://asterisk.sabkiapp.com
```

### HTTP Configuration
- 10-minute timeout
- JWT token in Authorization header
- Interceptor for token refresh
- Error handling

### API Endpoints

#### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /sign_in | User login |
| POST | /create_user | Create new user |
| POST | /change_password | Change password |

#### Audio Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /audios | List all audios |
| GET | /audio/:id | Get audio details |
| POST | /audio | Create audio |
| PUT | /audio/:id | Update audio |
| DELETE | /audio/:id | Delete audio |

#### Campaign Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /campaigns | List campaigns |
| GET | /campaign/:id | Get campaign details |
| POST | /campaign | Create campaign |
| PUT | /campaign/:id | Update campaign |
| DELETE | /campaign/:id | Delete campaign |
| GET | /dial_plan/:campaignId | Get dial plan |
| PUT | /dial_plan/:campaignId | Update dial plan |

#### SMS Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /sms_templates | List SMS templates |
| GET | /sms/:id | Get SMS details |
| POST | /sms | Create SMS template |
| PUT | /sms/:id | Update SMS template |
| DELETE | /sms/:id | Delete SMS template |
| POST | /bulk_sms | Send bulk SMS |
| GET | /bulk_sms | List bulk SMS |

#### Contact Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /contacts | List contacts |
| POST | /contacts | Add contact |
| PUT | /contacts/:id | Update contact |
| DELETE | /contacts/:id | Delete contact |

#### SIM Bank Monitoring
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /machine_status | Get SIM machine status |
| GET | /active_host_status | Get active hosts |
| POST | /test_blocked_sim | Test blocked SIM |
| POST | /check_recharge | Check recharge status |

#### Missed Call Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /miss_calls | Get missed calls |
| GET | /operators | List operators |
| POST | /operator | Add operator |
| PUT | /operator/:id | Update operator |

#### User Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /users | List users |
| GET | /users/:id | Get user details |
| POST | /users | Create user |
| PUT | /users/:id | Update user |
| GET | /user_hosts/:userId | Get user's hosts |
| POST | /user_hosts | Assign host to user |

#### API Key Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api_key | Get API key |
| POST | /generate_api_key | Generate new API key |

---

## 7. Data Models

Located in `/src/models/`:

| Model | Description |
|-------|-------------|
| AudioResponseModel | Voice file data (id, voiceName, voiceDesc, path, status) |
| CampaignModel | Campaign configuration and settings |
| ContactsModel | Contact information |
| SmsResponseModel | SMS template data |
| BulkSmsResponse | Bulk SMS campaign data |
| MissCallResponseModel | Missed call records |
| OperatorModel | Mobile operator data |
| MachineStatusModel | SIM card machine status |
| DialPlanModel | Campaign dial plan configuration |
| CampaignReportModel | Campaign analytics data |
| TokenModel | Authentication tokens |
| RefUser | User reference data |
| ApiModel | API key data |

### Machine Status Model Fields
- Host name
- Port number
- Signal strength
- Status (Ready, Busy, Blocked, Rechargeless)
- Phone number
- Operator
- Calls made (today/total)
- Call time (today/total)
- Validity
- SMS Balance

---

## 8. State Management

### Providers Used

#### AuthProvider
- **File:** `/src/providers/auth_provider/auth_provider.dart`
- **Purpose:** User authentication
- **Features:**
  - Login/logout
  - Token management
  - User role handling
  - Hive persistence
  - Form validation using formz

#### SettingsProvider
- **File:** `/src/providers/settings_provider/settings_provider.dart`
- **Purpose:** App settings
- **Features:**
  - Theme management (light/dark)
  - Hive persistence

#### NavbarProvider
- **File:** `/src/providers/navbar_provider/navbar_provider.dart`
- **Purpose:** Navigation state
- **Features:**
  - Active route tracking
  - Menu state

#### HudProvider
- **File:** `/src/providers/hud_provider/hud_provider.dart`
- **Purpose:** Loading states
- **Features:**
  - Global loading overlay
  - Show/hide loading

#### ConnectivityProvider
- **File:** `/src/providers/connectivity_provider/connectivity_provider.dart`
- **Purpose:** Network status
- **Features:**
  - Monitor internet connectivity
  - Online/offline detection

---

## 9. Routing

### Router Configuration
- **File:** `/src/config/router.dart`
- **Library:** go_router

### Route List

| Path | Screen | Access |
|------|--------|--------|
| /sign-in | Sign In | Public |
| /dashboard | Dashboard | Authenticated |
| /add-audio | Add Audio | Authenticated |
| /view-audio | View Audios | Authenticated |
| /select-audio | Select Audio | Authenticated |
| /add-campaign | Add Campaign | Authenticated |
| /view-campaigns | View Campaigns | Authenticated |
| /update-campaign/:id | Update Campaign | Authenticated |
| /dial-plan/:id | Dial Plan | Authenticated |
| /campaign-report/:id | Campaign Report | Authenticated |
| /campaign-summary | Campaign Summary | Authenticated |
| /add-contacts | Add Contacts | Authenticated |
| /view-contacts | View Contacts | Authenticated |
| /add-sms | Add SMS | Authenticated |
| /edit-sms/:id | Edit SMS | Authenticated |
| /view-sms | View SMS | Authenticated |
| /select-sms | Select SMS | Authenticated |
| /add-bulk-sms | Add Bulk SMS | Authenticated |
| /update-bulk-sms/:id | Update Bulk SMS | Authenticated |
| /view-bulk-sms | View Bulk SMS | Authenticated |
| /add-operator | Add Operator | Authenticated |
| /view-miss-call | View Miss Call | Authenticated |
| /all-operators | All Operators | Authenticated |
| /users | Users | Superuser |
| /users-hosts/:userId | User Hosts | Superuser |
| /api-list | API List | Superuser |

### Route Guards
- Authentication check - Redirects to /sign-in if not authenticated
- Role check - Superuser routes restricted to superuser role

---

## 10. Configuration

### Theme Configuration
- **Primary Color:** #144E5A (Teal)
- **Material Design 3**
- **Light/Dark mode support**
- Custom input decoration themes

### Web Configuration (index.html)
- PWA (Progressive Web App) configuration
- Custom splash screen (purple theme #D4BBDD)
- Service worker support
- Responsive viewport

### Local Storage (Hive)
- Auth tokens
- User preferences
- Theme settings

### Form Validation (Formz)
- Name validation
- Mobile number validation (10-digit Indian format)
- Password validation
- Email validation
- URL validation

---

## 11. Additional Utilities

### Extension Methods
- String extensions
- Number extensions
- Size formatting extensions
- Response parsing extensions

### Download Utilities
- CSV export
- Excel export
- File download handling

### Common Components
- General dialogs
- Responsive layout builder
- Input formatters (length limiting)

---

## 12. Summary

This is a comprehensive **telecommunications management web application** built with Flutter. Key characteristics:

| Aspect | Details |
|--------|---------|
| **Voice/Audio Management** | Upload, play, edit, enable/disable voice files for campaigns |
| **SIM Bank Monitoring** | Real-time monitoring of multi-port SIM card machines |
| **Campaign Management** | Voice and SMS campaign creation, tracking, and reporting |
| **SMS Management** | Template creation, bulk SMS, delivery tracking |
| **Contact Management** | Add, view, import/export contacts |
| **User Management** | Multi-user with role-based access (superuser/user) |
| **API Integration** | RESTful API communication with asterisk.sabkiapp.com |
| **Data Export** | CSV and Excel export capabilities |
| **Responsive Design** | Works on desktop, tablet, and mobile |
| **Offline-First** | Local storage with Hive for persistence |
| **PWA Support** | Progressive Web App with service workers |

### User Roles

1. **Superuser**
   - Full access to all features
   - User management
   - API key management
   - Can login as sub-user

2. **Regular User**
   - Campaign management
   - Audio/SMS management
   - Contact management
   - Dashboard access

---

*Document generated from code analysis*
*Project: Upload Voices Web*
*Location: /home/ubuntu/Documents/upload_voices_web-main/upload_voices_web-main/*
