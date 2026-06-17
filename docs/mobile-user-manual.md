# Maize Watch Mobile App — User Manual

**Version 2.0**
**Platform: iOS & Android**

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [First Launch — Splash Screen](#2-first-launch--splash-screen)
3. [Landing Screen](#3-landing-screen)
4. [Creating an Account](#4-creating-an-account)
5. [Logging In](#5-logging-in)
6. [Setting Up Your Farm](#6-setting-up-your-farm)
7. [Home Screen Overview](#7-home-screen-overview)
8. [Live Monitoring](#8-live-monitoring)
9. [Farm Detail View](#9-farm-detail-view)
10. [Prescriptions](#10-prescriptions)
11. [Account & Settings](#11-account--settings)
12. [Notifications](#12-notifications)
13. [Language Settings](#13-language-settings)
14. [Logging Out](#14-logging-out)
15. [Troubleshooting](#15-troubleshooting)

---

## 1. Introduction

**Maize Watch** is an IoT-powered agriculture monitoring app for corn farmers. It connects to physical sensors on your farm — measuring temperature, humidity, soil moisture, pH, and light intensity — and delivers real-time data, growth stage tracking, weekly trend charts, and actionable crop prescriptions directly to your phone.

### Key Features

| Feature | Description |
|---|---|
| Live Monitoring | Real-time sensor readings, weather, and farm overview |
| Farm Detail | In-depth view per field: Overview, Historical, and Growth Stage tabs |
| Prescriptions | Prioritized care recommendations with step-by-step instructions |
| Growth Tracking | Visual 9-stage corn growth progress (VE → R6) |
| Weekly Trends | 7-day line charts for all sensor parameters |
| Alerts | Push notifications for out-of-range conditions |
| Multi-language | English and Filipino (Tagalog) |

---

## 2. First Launch — Splash Screen

When you open the app, the **Splash Screen** appears:

- A **static frame logo** surrounds a **rotating corn logo** at the center of the screen.
- Status messages appear at the bottom as the app loads:
  - *"Initializing..."*
  - *"Checking authentication"*
  - *"Loading your farm"* / *"Loading your farms"*
  - *"Welcome back"* (if already logged in)
  - *"Setting up your farm"* (if no farm registered yet)
- The **Novu logo** is shown at the very bottom.

After loading, the app navigates automatically:
- **Not logged in** → Landing Screen
- **Logged in, farm exists** → Home Screen
- **Logged in, no farm** → Farm Registration Screen

---

## 3. Landing Screen

The Landing Screen is the entry point for new and returning users.

**What you see:**
- The **Maize Watch logo** at the top center
- **"MAIZE WATCH"** title below the logo
- A short app description
- A **language toggle** in the top-right corner
- Two buttons at the bottom:
  - **Login** (primary button)
  - **Register** (secondary button)
- App version **"v.2.0"** at the very bottom

---

## 4. Creating an Account

Tap **Register** on the Landing Screen to begin.

---

### Page 1 — Personal Information

Fill in:

| Field | Description |
|---|---|
| First Name | Your given name |
| Last Name | Your family name |
| Contact Number | Philippine mobile number (e.g. 09XXXXXXXXX) |

Tap **Next** to proceed.

---

### Phone Verification Screen

After entering your contact number, the **Phone Verification Screen** appears:

- Your contact number is displayed in a box for confirmation.
- Tap **"Continue to Registration"** — the app sends a **6-digit SMS code** to your number.

---

### Two-Factor Verification Screen

- Enter the **6-digit code** received via SMS.
- The code verifies automatically once all 6 digits are entered.
- If the code does not arrive, wait for the countdown timer to expire and tap **Resend Code**.

---

### Page 2 — Account Details

After verification, fill in:

| Field | Description |
|---|---|
| Username | Your unique login name |
| Password | A secure password (min. 8 characters) |
| Region | Select from all Philippine regions |
| Province | Filtered by selected region |
| Municipality | Filtered by selected province |
| Barangay | Filtered by selected municipality |

> Address dropdowns are **cascading** — each selection automatically narrows the next dropdown.

Tap **Register** to submit.

---

### Registration Success Screen

- Your name appears with the message: *"{Your Name}, your account has been created successfully."*
- Next steps are listed:
  - Register your farm details
  - Connect your IoT device
  - Monitor crop growth stages
- Tap **"Continue to Field Registration"** to proceed to farm setup.

---

## 5. Logging In

Tap **Login** on the Landing Screen.

A **Login Overlay** slides up with:
- **Username** field
- **Password** field
- **Login** button
- **Forgot Password** link

After a successful login:
- If a farm is registered → **Home Screen**
- If no farm registered → **Farm Registration Screen**

### Forgot Password
Tap the **Forgot Password** link to request a reset code sent to your registered contact number.

---

## 6. Setting Up Your Farm

The Farm Registration screen has **3 pages**, each shown with a step progress indicator at the top.

---

### Page 1 — Field Name

Enter the name of your farm field (e.g. *"North Plot"*).

Tap **Next**.

---

### Page 2 — Planting Date

Tap the date picker to select the **date your corn was planted**. This is used to calculate your crop's current growth stage and progress.

Tap **Next**.

---

### Page 3 — Device Registration

Register the IoT sensor device connected to this field:

| Field | Description |
|---|---|
| Device Name | A label for this device (e.g. "Main Sensor") |
| Device ID | The Prototype ID of your IoT hardware |
| Channel ID | The ThingSpeak channel ID for this device |

Tap **"Add Device"** to register additional devices for the same field.

Tap **Submit** when done. A **summary modal** appears — review all details and confirm.

---

### Farm Registration Success Screen

- Message: *"Congratulations! {Field Name} on {Farm Name} has been registered."*
- Features highlighted: Monitor crop health, Get real-time analytics, Receive alerts & recommendations
- Tap **"Continue to Dashboard"** to go to the Home Screen.

---

## 7. Home Screen Overview

The Home Screen uses a **Curved Bottom Navigation Bar** with 3 tabs:

| Position | Icon | Screen |
|---|---|---|
| Left | Checklist | Prescriptions |
| Center | Agriculture (plant) | Live Monitoring *(default on login)* |
| Right | Person | Account & Settings |

Tap any icon to switch between the three main sections. The **Live Monitoring tab (center)** is the default when you first log in.

> Pressing the **back button** from the Home Screen shows a logout confirmation dialog.

---

## 8. Live Monitoring

The **Live Monitoring** screen (center tab) is the main dashboard. It shows your farm's weather, active tasks, and registered fields.

---

### 8.1 Weather Overlay

At the top of the screen, a weather card displays:

- **Location chip** — shows your municipality and province
- **Greeting** — *"Good morning/afternoon/evening, {Your Name}"*
- **Large temperature display** — current weather temperature
- **Weather description** with an appropriate weather icon
- **Current time** — shown as "HH:MM | Month DD"
- Three weather stat chips:
  - Wind speed (km/h)
  - Humidity (%)
  - Pressure (hPa, if available)

---

### 8.2 Task Cards (Horizontal Scroll)

Below the weather section, a **horizontally scrollable row of prescription/task cards** appears. Each card shows:

- **Urgency badge** (color-coded)
- **Task title** (up to 4 lines)
- **Field name** with a location icon
- **Deadline badge** with a timer icon
- **Status** — Done (green background) or Pending

Swipe left or right to browse all active tasks.

---

### 8.3 Farm Fields Section

Below the task cards, your farm's fields are listed:

- **Farm name** as the section header, with a **"{number} fields registered"** count
- An **Add Field button** (+ icon) to register a new field
- **Field cards**, one per registered field, each showing:
  - A corn **growth stage animation** (Lottie)
  - **Field name**
  - **Growth stage badge** (colored by stage)
  - Grass icon with **growth status text**
  - Sensors icon with **activity count**

Tap any field card to open the **Farm Detail View** for that field.

---

## 9. Farm Detail View

Tapping a field card opens the **Farm Detail View**, which slides up and covers the screen. The bottom navigation bar is hidden while this view is open.

---

### Header

- **Back button** (top left) — closes the Farm Detail View and returns to the field list
- **Refresh button** (top right) — reloads all data for this field
- **"~X days" chip** — shows estimated days to the next growth stage

---

### Hero Section

A blue gradient card shows the corn growth progress:

- **Corn Lottie animation** — animated to reflect the current growth stage
- **Stage badge** — e.g. *"Stage: V6"*
- **Day counter** — e.g. *"Day 24"* (days since planting)
- **9-stage progress bar** showing: VE → V3 → V6 → V8 → V12 → VT → R1 → R3 → R6
  - The current active stage is highlighted with a larger circle and border

---

### Field Details Card

Below the hero section, a card shows:

- **Field name** (large title)
- **Location** — Municipality, Province
- Info chips showing:
  - Soil type (if available)
  - Planting date (D/M/YYYY)
  - Prototype/device IDs
  - Total sensor count
- **Crop Condition status card**:
  - Color-coded circle icon (Green / Orange / Red)
  - "Corn Condition" label
  - Status: **Healthy / Moderate / Warning / Critical**
  - A short description message

---

### Tab Navigation

Three tabs provide different views of the field data:

| Tab | Content |
|---|---|
| Overview | Current sensor readings |
| Historical | Weekly trend charts |
| Growth Stage | Detailed stage breakdown |

---

### Overview Tab

The **Overview Tab** shows current live readings from your sensors.

- **Last Updated** indicator — e.g. *"Last Updated: 5 minutes ago"*
- **5 Metric Cards** arranged in a grid:
  - Row 1: Soil pH + Soil Moisture
  - Row 2: Temperature + Humidity
  - Row 3: Light Intensity (full width)
- Each metric card shows:
  - A **status badge**: Good / Warning / Attention / Urgent
  - An **icon** in a colored circle
  - The **metric name**
  - The **current value with unit**
  - Color coding by stress level (green → orange → red)

**Optimal ranges for corn:**

| Parameter | Unit | Optimal Range |
|---|---|---|
| Temperature | °C | 20–30 |
| Humidity | % | 40–80 |
| Soil Moisture | % | 30–70 |
| Soil pH | — | 6.0–7.5 |
| Light Intensity | lux | 400–800 |

---

### Historical Tab

The **Historical Tab** shows 7-day trend charts for all 5 sensor parameters.

**Week Navigation:**
- **Left / Right arrow buttons** to go back or forward one week
- Center header shows **"This Week"** or **"Weekly Overview"**
- Date range subtitle — e.g. *"Jun. 7 – Jun. 13"*

**5 Parameter Sections** (Temperature, Humidity, Soil Moisture, Soil pH, Light Intensity):

Each parameter section contains:
- **Header row**: icon, parameter name, optimal range label, visibility toggle, trend arrow (up/down/flat)
- **Current value card** — latest reading
- **7-Day Average card** — average over the selected week
- **Weekly trend line chart**:
  - Smooth line graph with filled area underneath
  - Days on X-axis: Sun, Mon, Tue, Wed, Thu, Fri, Sat
  - Min/max value labels on Y-axis
  - Threshold lines showing the optimal range boundaries
  - Tap the **visibility toggle** to show or hide the chart

---

### Growth Stage Tab

The **Growth Stage Tab** gives a detailed breakdown of your crop's development.

**Current Stage Card:**
- Stage code (e.g. V6) displayed prominently
- **"X% Complete"** within this stage
- Progress bar
- Stage description text

**Growth Stage Progress Table:**
- Lists 6 key growth stages with checkmarks for completed stages
- Stage descriptions and day counts for each stage

**Expected Harvest Card:**
- Calendar icon
- **Estimated harvest date** (D/M/YYYY)
- Days remaining message

---

## 10. Prescriptions

Tap the **left tab (checklist icon)** to open the Prescriptions screen.

---

### 10.1 Header

- Background image header with:
  - Title: **"Farm Prescriptions"**
  - Subtitle: *"View complete prescriptions"*
  - A **filter button** (funnel icon) at the top right

---

### 10.2 Filter Chips

Three quick filter chips appear at the top of the list:

| Chip | Shows |
|---|---|
| All | Total prescription count |
| Pending | Uncompleted prescriptions only |
| Urgent | Urgent-priority prescriptions only |

If additional filters are active, a filter indicator bar appears with a close button to clear them.

---

### 10.3 Prescription Cards

Prescriptions are **grouped by date**: Today, Yesterday, This Week, Last Week, This Month, Last Month.

Each card shows:
- **Checkbox** — tap to mark as done (or undo)
- **Title** — with strikethrough when completed
- **Urgency badge** (color-coded by priority)
- **Description** (2 lines)
- **Field name chip** with location icon
- **Deadline chip** with timer icon
- **Delete button** — only appears on completed prescriptions

**Urgency colors:**

| Level | Color |
|---|---|
| URGENT | Red |
| HIGH | Orange |
| MEDIUM | Yellow |
| LOW | Green |

---

### 10.4 Detailed Prescription Screen

Tap any prescription card to open the full detail view.

**App Bar:**
- Back button
- Field name as the title
- **Mark Complete** button (top right, text changes based on current state)

**Completion Banner** (if completed):
- Green banner: *"This prescription is completed"* with a checkmark icon

**Content Sections:**

| Section | Content |
|---|---|
| Title | Large prescription title (strikethrough if completed) |
| Deadline chip | "Deadline: X hours/days left" |
| Send time chip | When the prescription was created |
| Description | Full explanation of the issue |
| Field Information | Growth stage card (left) + Soil type card (right) |
| Instructions | Expandable "Step by Step Instructions (X steps)" with numbered steps |

**Bottom Action Buttons:**
- **Back** button (outlined)
- **Mark Complete** button (filled, with icon) — toggles completion status

---

### 10.5 Pull-to-Refresh

Pull down anywhere on the prescription list to refresh and load the latest recommendations from the server.

---

## 11. Account & Settings

Tap the **right tab (person icon)** to open the Account screen.

---

### Header

- Background image showing a farmer
- Title: **"Menu"**
- Subtitle: *"Manage your account settings"*

---

### 11.1 Profile

Tap your **full name** (top menu item) to open the Profile Screen.

**View Mode shows:**
- **@{username}** — your username
- First Name
- Last Name
- Contact Number — shown as *"+63 XXXXXXXXXX"*
- Full address (region, province, municipality, barangay)

Tap **Edit Profile** to switch to edit mode.

**Edit Mode:**
- First Name field
- Last Name field
- Contact Number field (with +63 prefix)
- Cascading address dropdowns: Region → Province → Municipality → Barangay (free text)
- **Save** button to apply changes
- **Cancel** button to discard

---

### 11.2 Sensor Status

Menu item: **"Sensor Status"** — *"Monitor sensor condition"*

This screen shows the health of each individual sensor:

**Status Check Banner:**
- Informs you that the app is checking whether sensors are actively sending data to ThingSpeak.

**Sleep Mode Indicator** (appears when active):
- Orange banner: *"Sleep Mode Active"*
- Message: *"Sensors are sleeping from 8pm to 3am PH time"*

**Registered Prototypes Section:**
- Lists all devices linked to your account with their Prototype ID, field name, and Active/Inactive status.

**5 Individual Sensor Status Items:**

| Sensor | Icon |
|---|---|
| Temperature Sensor | Thermostat |
| Humidity Sensor | Water drop |
| Soil Moisture Sensor | Grass |
| Soil pH Sensor | Science flask |
| Light Intensity Sensor | Light mode |

Each sensor shows:
- Icon in a **green circle** (active) or **red circle** (inactive)
- Sensor name
- Status badge
- Description: *"Sensor is actively sending data..."* or *"Sensor is not sending data or offline"*

**Status Legend:**
- Green = Active, sending data to ThingSpeak
- Red = Inactive, offline or not sending data

**Refresh Status** button at the bottom reloads all sensor statuses.

---

### 11.3 Prototype Management

Menu item: **"Prototype Management"** — *"Manage and unsync prototypes from fields"*

Lists all IoT devices registered to your account. Each entry shows:
- **Prototype ID**
- **Channel ID**
- **Registered date** (D/M/YYYY)
- **Status badge**: Active (green) or Inactive (red)
- **Unsync button** (link-off icon) — removes the device from the field

**Unsyncing a device:**
1. Tap the unsync icon next to the device.
2. A confirmation dialog appears.
3. Confirm to disconnect the device.
4. A success or error message appears.

> **Warning:** Unsyncing a device stops data collection for the linked field.

If no devices are registered, an empty state is shown with the message *"No prototypes found."*

---

### 11.4 Language

Menu item: **"Language"** — shows current value (*"English"* or *"Filipino"*)

Tapping opens a language settings dialog. Two options:
- **English (en)**
- **Filipino / Tagalog (tl)**

The app switches language immediately and saves your preference. The language toggle is also available on the Landing Screen before logging in.

---

### 11.5 Notifications

Menu item: **"Notifications"** — shows current value (*"On"*, *"Off"*, or *"Vibration Only"*)

Tapping opens the Notification Settings screen.

**Header:**
- Title: **"Notifications"**
- Subtitle: *"Manage your app preferences"*

**Notification Settings:**

| Toggle | Description |
|---|---|
| Enable Notifications | Master on/off for all notifications |
| Vibration Only | Silent mode with vibration only (visible when notifications are on) |

**Notification Types** (individually togglable):

| Type | Icon | Description |
|---|---|---|
| Farm Alerts | Agriculture | Alerts when sensor values go out of range |
| Sensor Status | Sensor | Alerts when a sensor goes offline or enters sleep mode |
| Prescription Updates | Medical | Alerts when new prescriptions are generated |

**Debug Section** — tap "Check Notification Status" to see the current notification state in a snackbar.

---

### 11.6 About

Menu item: **"About"** — *"Know more about Maize Watch's objective and socials"*

Displays:
- App name and version
- App description
- Key features list
- Contact support details (email, phone, website)
- Social media links (Instagram, GitHub, LinkedIn, Twitter)

All links open in your phone's browser.

---

### 11.7 Help

Menu item: **"Help"** — *"Learn how to use the Maize Watch app"*

Sections:
- **Getting Started** — setting up your farm and connecting sensors
- **Features Guide** — how to use live monitoring, analytics, and reports
- **Troubleshooting** — common issues and fixes
- **FAQ** — frequently asked questions

All items link to external documentation.

---

### 11.8 Log Out

At the bottom of the Account screen, tap the red **"Log Out"** button.

A confirmation dialog appears. Confirm to log out and return to the Landing Screen.

> Your farm data and prescriptions are stored on the server and will be available when you log back in.

---

## 12. Notifications

### Requesting Permission

The first time you open the Home Screen, the app prompts you to allow push notifications. Tap **Allow** to enable them.

### Notification Types

| Type | Trigger |
|---|---|
| Farm Alerts | A sensor reading goes outside the safe range for corn |
| Sensor Status | A sensor goes offline, reconnects, or enters sleep mode |
| Prescription Updates | New recommendations are generated for your farm |

### Background Processing

Notifications are processed in the background even when the app is closed. Multiple alerts are delivered as separate notifications.

### Managing Notifications

Go to **Account → Notifications** to disable all notifications, switch to vibration-only, or toggle individual alert types.

---

## 13. Language Settings

The app supports:

| Language | Code |
|---|---|
| English | en |
| Filipino (Tagalog) | tl |

**To switch before login:** Use the language toggle (globe icon) in the top-right corner of the Landing Screen or Phone Verification Screen.

**To switch after login:** Go to **Account (right tab) → Language**.

The entire app switches language immediately — all labels, buttons, messages, and content update at once.

---

## 14. Logging Out

**Method 1 — Account Screen:**
1. Tap the right tab (person icon).
2. Scroll to the bottom.
3. Tap the red **"Log Out"** button.
4. Confirm in the dialog.

**Method 2 — Back Button:**
- Press the back button from the Home Screen. A logout confirmation dialog appears.

After logging out, you are returned to the Landing Screen.

---

## 15. Troubleshooting

### "Connection Timeout" when logging in
- Make sure your phone has an active Wi-Fi or mobile data connection.
- If using a local server, ensure your phone is on the same Wi-Fi network as the server.
- The server IP in the app may have changed — contact your administrator.

### Sensor readings not updating
- Open **Account → Sensor Status** and check if sensors are Active or Inactive.
- If **Sleep Mode Active** is shown, sensors are resting between 8 PM and 3 AM PH time — data will resume automatically.
- If sensors show as Inactive, check that the physical IoT device is powered on and connected to the internet.
- Pull down on the Farm Detail screen to force a refresh.

### Weekly chart shows gaps (missing days)
- Days with no sensor data are not plotted — this is expected if the device was offline or in sleep mode on those days.

### OTP / verification code not received
- Wait up to 60 seconds.
- Confirm your contact number is correct.
- Tap **Resend Code** after the timer expires.
- Ensure your number can receive SMS.

### Prescription list is empty
- Pull down to refresh.
- Prescriptions are generated from sensor data. If all readings are within safe ranges, the list may be empty.
- Check that your sensors are active and sending data.

### App is in the wrong language
- Go to **Account → Language** and select your preferred language.

### Farm Detail not loading data
- Tap the **Refresh button** (top right of Farm Detail).
- Check your internet connection.
- Check **Sensor Status** to confirm your device is online.

---

*Maize Watch v2.0 — User Manual*
*For support: maizewatch@gmail.com*
