<p align="center">
  <img src="public/app-icon.png" alt="Clinical Precision App Icon" width="100"/>
</p>

# Health Chain — Patient Data Management Application

**Student Report | Flutter Mobile Application Development**

---

## 1. Introduction

### App Name
**Health Chain**

### Purpose
Health Chain is a mobile application designed to help clinical staff — doctors, nurses, and other healthcare professionals — manage patient records digitally and efficiently. The app replaces paper-based or fragmented record-keeping by providing a centralised, offline-first platform where staff can register patients, record visit history, track medications, manage allergy data, and monitor overall patient health trends through an analytics dashboard.

### Target Users
The primary users of Clinical Precision are clinical staff working in outpatient clinics, small hospitals, or private practices. This includes general practitioners, nurses, and medical officers who need a fast and reliable tool to retrieve patient information and record new clinical data during or after a consultation.

---

## 2. System Design

### App Structure — Widgets, Screens, and Navigation

The application is built around a bottom navigation shell (`AppShell`) that hosts four top-level sections. Authentication screens are public; all other screens require a valid session.

**Authentication Flow:**
- `LoginScreen` — Email and password login with inline error feedback
- `CreateAccountScreen` — Staff registration collecting full name, email, clinical identifier, role, and password

**Main Shell (Bottom Navigation — 4 tabs):**
1. **Dashboard** (`DashboardScreen`) — Analytics and statistics overview
2. **Patients** (`PatientListScreen`) — Searchable list of all registered patients
3. **Profile** (`ProfileScreen`) — Logged-in user details and credential management

**Patient Sub-screens (pushed onto the navigation stack):**
- `AddPatientScreen` — Full patient registration form
- `PatientDetailsScreen` — Detailed view of a single patient's record
- `NewVisitScreen` — Record a new clinical visit for an existing patient
- `VisitDetailsScreen` — Read-only view of a single past visit
- `VisitHistoryScreen` — Chronological list of all visits for a patient

**Bottom Sheets (modal overlays):**
- `PrescribeMedicationSheet` — Prescribe a new medication from the patient details page
- `ManageAllergiesSheet` — Add or update allergy records from the patient details page

### Navigation Flowchart

> **[SCREENSHOT]** — Take a screenshot of the **Login Screen** (`LoginScreen`) to place here as an entry point illustration.

```
App Start
    │
    ├── Not logged in ──▶ LoginScreen ──▶ CreateAccountScreen
    │                          │
    │                    Successful login
    │                          │
    └── Logged in ─────────────▼
                           AppShell (Bottom Nav)
                          ┌────────┬──────────┬─────────┐
                       Dashboard  Patients   Profile
                                    │
                          ┌─────────┴──────────┐
                    PatientListScreen     AddPatientScreen
                          │
                    PatientDetailsScreen
                    ┌─────┴────────────────────────────┐
              NewVisitScreen   PrescribeMedicationSheet
              VisitHistoryScreen   ManageAllergiesSheet
              VisitDetailsScreen
```

> **[SCREENSHOT]** — Take a screenshot of the **Patient List Screen** (`PatientListScreen`) to show the main navigation shell and bottom bar.

---

## 3. Implementation Details

### Programming Language and Tools

| Technology | Purpose |
|---|---|
| **Dart / Flutter** | Cross-platform UI framework and application logic |
| **sqflite + sqflite_common_ffi** | Local SQLite database (mobile and desktop support) |
| **shared_preferences** | Persistent session token storage |
| **crypto** | SHA-256 password hashing with salt |
| **uuid** | Unique identifier generation for all records |
| **google_fonts** | Manrope and Inter typefaces for typography |
| **fl_chart** | Pie and bar charts on the analytics dashboard |

### Key Classes and Objects

**`User` (lib/models/user.dart)**
Represents an authenticated staff member. Stores `id`, `fullName`, `email`, `passwordHash`, `clinicalIdentifier`, and `role`. The model includes `toMap()` and `fromMap()` for database serialisation.

**`Patient` (lib/models/patient.dart)**
The central domain object. Stores demographics (`fullName`, `dateOfBirth`, `gender`, `phone`, `bloodGroup`) alongside computed properties such as `age`, `initials`, `avatarColor`, `activeAllergies`, and `activeMedications`. Holds a `List<Visit>`, `List<Allergy>`, and `List<Medication>` when fully loaded.

**`Visit` (lib/models/patient.dart)**
Records a single clinical encounter. Fields include `diagnosis`, `chiefComplaint`, `heartRate`, `temperature`, `bloodPressure`, `weight`, `notes`, and `patientStatus` (an enum: `stable`, `observation`, `critical`).

**`Allergy` (lib/models/patient.dart)**
Represents an allergy record with `allergenName`, `severity` (enum: `mild`, `moderate`, `critical`), `reactionDescription`, and `status` (enum: `active`, `resolved`).

**`Medication` (lib/models/patient.dart)**
Represents a prescription with `medicationName`, `dosage`, `frequency`, `startDate`, optional `endDate`, `status` (enum: `active`, `completed`, `expired`, `discontinued`), and optional `notes`.

**`DatabaseHelper` (lib/core/database/database_helper.dart)**
A singleton class that manages the SQLite database (`clinical_precision.db`). On first run it creates five tables: `users`, `patients`, `visits`, `allergies`, and `medications`. Foreign keys with `ON DELETE CASCADE` ensure that deleting a patient automatically removes all their associated records.

**`AuthService` (lib/core/auth/auth_service.dart)**
A singleton service handling all authentication logic. Passwords are never stored in plain text — instead the app computes `SHA256(salt + email + password)` before persisting. The service exposes `login()`, `register()`, `logout()`, `updateCredentials()`, and `isLoggedIn()`. The session is persisted via `SharedPreferences`.

**`PatientService` (lib/services/patient_service.dart)**
The data access layer for patient operations. Key methods include `createPatient()` (wraps a multi-table insert in a single SQL transaction), `getFullPatient(id)` (loads a patient with all related visits, allergies, and medications), `addVisit()`, `addAllergy()`, `addMedication()`, and `getAnalytics()` which aggregates counts and distributions for the dashboard.

### Code Snippet — Password Hashing

```dart
String _hashPassword(String email, String password) {
  const salt = 'clinical_precision_salt_2024';
  final bytes = utf8.encode('$salt:$email:$password');
  return sha256.convert(bytes).toString();
}
```

> **[SCREENSHOT]** — Take a screenshot of the **Add Patient Screen** (`AddPatientScreen`) showing the allergy or medication toggle form to illustrate the dynamic form design.

---

## 4. Functionality Description

### How the App Works — Step by Step

**Step 1 — Account Creation and Login**
A new staff member opens the app and taps *Create Account*. They enter their full name, email address, clinical identifier (e.g., `DR-001`), role, and a password. The app validates all fields and stores a salted hash of the password. On subsequent launches the user signs in with their email and password.

**Step 2 — Dashboard Overview**
After login the user lands on the Dashboard, which shows total registered patients, counts by status (stable, observation, critical), a gender distribution pie chart, and an age group bar chart. All statistics are computed in real time from the database.

> **[SCREENSHOT]** — Take a screenshot of the **Dashboard Screen** (`DashboardScreen`) showing the analytics charts.

**Step 3 — Registering a New Patient**
Tapping the *+* button on the Patient List screen opens the Add Patient form. The form is divided into sections:
- **Demographics** — Full name, date of birth (date picker), gender, phone number, blood group
- **Vitals** — Heart rate (slider), temperature (dropdown range), blood pressure, weight
- **Visit Details** — Reason for visit, diagnosis, clinical notes, patient status
- **Allergies** — Toggle an inline form to add allergy records one at a time (allergen name, severity, reaction)
- **Medications** — Toggle an inline form to add prescriptions one at a time (name, dosage, frequency, dates, notes)

A progress bar tracks how many of the seven required fields have been completed. The form cannot be submitted while an allergy or medication sub-form is still open, or if required fields are empty.

**Step 4 — Viewing Patient Details**
Tapping a patient from the list opens their detail page. The page displays a summary card (name, age, gender, blood group), latest visit information, all active allergies with severity colour-coding (red = critical, amber = moderate, blue = mild), active medications, and a button to view full visit history.

> **[SCREENSHOT]** — Take a screenshot of the **Patient Details Screen** (`PatientDetailsScreen`) showing the allergy and medication sections.

**Step 5 — Recording a New Visit**
From the patient details page, tapping *New Visit* opens a dedicated screen. The clinician records the chief complaint, diagnosis (required), vitals, and clinical notes, then sets the patient's current status. The form validates that diagnosis and blood pressure are filled before saving. On save the record is persisted to the `visits` table and the patient's status is updated.

**Step 6 — Managing Medications and Allergies**
Existing patients can have new prescriptions added via the *Prescribe Medication* bottom sheet, and new or updated allergy records via the *Manage Allergies* bottom sheet — both accessible directly from the patient details page without navigating away.

**Step 7 — Profile and Credential Management**
The Profile tab shows the logged-in user's name, role, and clinical identifier. Staff can update their clinical identifier and change their password by providing their current password alongside the new one.

### Key Features Implemented

- Secure local authentication with SHA-256 password hashing
- Full offline operation — no internet connection required
- Multi-table SQLite transactions ensuring data consistency
- Real-time analytics dashboard with charts
- Dynamic inline forms for allergies and medications with per-field validation
- Severity-coded allergy display and status tracking
- Medication lifecycle tracking (active, completed, expired, discontinued)
- Chronological visit history per patient
- Searchable patient list

---

## 5. Conclusion and Improvements

### Challenges Faced

**Cross-platform SQLite initialisation** was one of the first technical hurdles. The standard `sqflite` package does not initialise automatically on Linux and other desktop platforms. This was resolved by integrating `sqflite_common_ffi` and detecting the platform at startup to call `sqfliteFfiInit()` before any database access.

**Data integrity across related tables** required careful transaction design. When registering a new patient with visits, allergies, and medications in a single operation, all inserts had to succeed atomically or roll back completely. This was handled in `PatientService.createPatient()` using a database transaction.

**Form state management for dynamic lists** presented a UX challenge. Allowing users to add allergy and medication records one at a time — with validation per record — required introducing internal draft objects (`_AllergyDraft`, `_MedicationDraft`) inside the widget that are separate from the final persisted data. This kept the state clean and prevented partial records from being submitted.

**Enum serialisation** required consistent `toMap()` and `fromMap()` handling across all models to ensure that values like `PatientStatus.stable` stored as the string `"stable"` could be reliably deserialised back to the enum variant on retrieval.

### Possible Future Improvements

1. **Cloud synchronisation** — Integrate a backend (e.g., Firebase or a REST API) so that records are synced across devices in a clinic network.
2. **Role-based access control** — Restrict certain operations (e.g., prescribing medication or deleting records) to users with specific roles such as `doctor` vs `nurse`.
3. **Push notifications and reminders** — Alert staff when a patient's medication is due to expire or when a follow-up date is approaching.
4. **PDF report export** — Generate printable summaries of a patient's history, suitable for referral letters or discharge summaries.
5. **Biometric authentication** — Replace or supplement password login with fingerprint or face recognition for faster, more secure access on mobile devices.
6. **Multi-clinic support** — Extend the data model to support multiple clinics or departments under a single installation, with staff scoped to their assigned facility.

---

*Report prepared for the Flutter Mobile Application Development assessment.*

