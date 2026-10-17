# CineFlix — Data Safety & Privacy Form Questionnaire Answers

This document provides exact, verified answers for both the **Google Play Data Safety Form** and the **Apple App Store App Privacy Nutrition Labels**.

---

## Part 1: Google Play Console — Data Safety Form

### 1. Data Collection and Security
- **Does your app collect or share any of the required user data types?**
  - **Answer:** **No**.
  - *Rationale:* CineFlix operates entirely client-side for browsing movie metadata and trailers. No personal user identification, account information, location, financial information, messages, contacts, or storage files are collected, uploaded, or transmitted to any proprietary server.

- **Is all of the user data collected by your app encrypted in transit?**
  - **Answer:** **Yes**.
  - *Rationale:* All network communication with TMDB, OMDb, and YouTube uses secure TLS/HTTPS endpoints.

- **Do you provide a way for users to request that their data be deleted?**
  - **Answer:** **Yes / Not Applicable** (User favorites and preferences are stored exclusively locally on device via `SharedPreferences`. Clearing app storage or uninstalling the app permanently purges 100% of local data).

### 2. Permissions Declared in AndroidManifest
- `android.permission.INTERNET`: Used exclusively to fetch movie information from TMDB/OMDb and stream YouTube trailers.
- `android.permission.ACCESS_NETWORK_STATE`: Used to verify internet reachability and display clean offline feedback instead of raw error screens.
- **Sensitive Permissions:** NONE (No location, no camera, no contacts, no microphone, no storage access, no phone state).

### 3. Ads and Tracking
- **Does your app contain advertising?**
  - **Answer:** **No**.
- **Does your app use an Advertising ID (AAID)?**
  - **Answer:** **No**.

---

## Part 2: Apple App Store Connect — App Privacy Form

### 1. Data Collection Status
- **Do you or your third-party partners collect data from this app?**
  - **Answer:** **Data Not Collected**.
  - CineFlix does not collect or track user data.

### 2. Specific Data Categories:
- **Contact Info:** None
- **Health & Fitness:** None
- **Financial Info:** None
- **Location:** None
- **Sensitive Info:** None
- **Contacts:** None
- **User Content:** None
- **Browsing History:** None
- **Search History:** None (Search queries are queried directly against TMDB API in real-time and not recorded or sent to any personal tracking profile)
- **Identifiers:** None (No IDFA, no user account IDs)
- **Usage Data:** None
- **Diagnostics:** None

### 3. Tracking Declaration
- **Does this app use data to track the user across apps and websites owned by other companies?**
  - **Answer:** **No**.
- **Does the app require App Tracking Transparency (ATT)?**
  - **Answer:** **No**.

---

## Summary Checklist for Store Reviewers
- [x] Zero user account required.
- [x] Zero proprietary analytics SDKs.
- [x] Zero third-party ad networks.
- [x] HTTPS enforced across all endpoints.
- [x] Offline storage restricted to local device `SharedPreferences`.
