 # MY PAGE Egg Nurturing Demo (Local Version)

This project is a demo application designed to lower the psychological burden of "failure/mistake reflection," which can be a high-barrier activity, and encourage consistent user participation through "egg nurturing" game elements. This version manages all data and states in local memory using Flutter's Riverpod, without a backend service like Firebase. This code will serve as a **skeleton code** for the MY PAGE development next week.

## 1. Project Goals

* **Core Goal:** To help users develop a habit of analyzing their failures and mistakes through journaling/reflection, and establishing plans for improvement.

* **Role of Game Elements:** To reduce the psychological burden of writing reflections and to motivate consistent record-keeping through the pet's growth and visual rewards.

## 2. Project Structure

```
lib/
├── main.dart             # Application entry point and global theme settings
├── models/
│   ├── pet.dart          # Pet data model definition
│   └── reflection.dart   # Reflection record data model definition
├── providers/
│   └── pet_notifier.dart # Riverpod StateNotifier managing pet state and reflection records
└── screens/
    ├── my_page.dart      # Initial MY PAGE screen (pet image, status bars, 3 buttons)
    ├── clean_page.dart   # 'CLEAN' action page (attendance check)
    ├── play_page.dart    # 'PLAY' action page (diary writing)
    ├── play_history_page.dart # 'PLAY'/'FEED' record history page
    └── feed_page.dart    # 'FEED' action page (topic reflection)
```

## 3. Getting Started

### 3.1. Prerequisites

* Flutter SDK installed (https://flutter.dev/docs/get-started/install)

* Preferred IDE (VS Code, Android Studio, etc.)

### 3.2. Project Setup and Execution

1.  **Clone (or Create) the Project:**

    ```
    git clone [YOUR_REPOSITORY_URL] toy_project
    cd toy_project
    ```

    Or, create a new Flutter project:

    ```
    flutter create toy_project
    cd toy_project
    ```

2.  **Update `pubspec.yaml`:**
    Open the `pubspec.yaml` file in the project root and add the following dependencies.

    ```
    dependencies:
      flutter:
        sdk: flutter
      flutter_riverpod: ^2.x.x
      table_calendar: ^3.0.9
      google_fonts: ^6.x.x
      uuid: ^4.x.x
    
    flutter:
      uses-material-design: true
      assets:
        - assets/images/ # Folder for pixel art images to be prepared by GwakgwaK (required)
      fonts:
        - family: PixelFont # Optional: If using a pixel art font
          fonts:
            - asset: assets/fonts/YourPixelFont.ttf # Font file path
    ```

3.  **Get Packages:**
    Run the following command in the terminal to download the packages.

    ```
    flutter pub get
    ```

4.  **Prepare Assets (GwakgwaK's responsibility):**
    Create an `assets/images/` folder and place pixel art image files such as `egg_stage0.png`, `egg_stage1.png`, `egg_stage2.png`, `baby_pet.png` in this folder. (If using SVG files, `Image.asset` should be changed to `SvgPicture.asset` from the `flutter_svg` package.)

5.  **Run the App:**
    Connect a simulator or a physical device and run the app with the following command.

    ```
    flutter run
    ```

## 4. Key Packages Used

The main packages currently utilized in the skeleton code and listed in `pubspec.yaml` are as follows. These packages are used to implement specific functionalities beyond Flutter's basic features.

* **`flutter_riverpod`**: `^2.x.x`
    * **Purpose:** A framework for state management in Flutter applications. It efficiently manages pet state and reflection record data across the app and links it with the UI.
* **`table_calendar`**: `^3.0.9`
    * **Purpose:** Implements the calendar UI for the attendance check feature on the 'CLEAN' page.
* **`google_fonts`**: `^6.x.x`
    * **Purpose:** Easily applies various fonts provided by Google Fonts to Flutter apps. It is used to apply a pixel art-friendly font theme.
* **`uuid`**: `^4.x.x`
    * **Purpose:** Generates unique IDs for data such as reflection records (`Reflection`) locally.

## 5. Team Roles and Next Week's Tasks

This code is a skeleton for next week's MY PAGE development. Each team member should deeply consider and proceed with implementation based on the following.

### 5.1. GwakgwaK (UI/UX Authority Designer 🎨)

* **Key Tasks and Future Improvements:**
    * **Creation of Diverse Pixel Art Assets:** Beyond the current 4 stages of egg/pet images, there is a need to design and create pixel art assets for more growth stages (e.g., various evolutions of adult pets), expressions/poses to convey pet emotions (happiness, sadness, hunger, etc.), and pet customization items (hats, backgrounds, etc.).
    * **Addition of Detailed Animations:** In addition to pet growth animations, animations for pet reactions during `CLEAN`, `PLAY`, and `FEED` actions (e.g., sparkling when clean, jumping when played with, happy expressions when fed) should be added to enhance user interaction satisfaction.
    * **UI/UX Consistency and Detail:** All UI elements of the app, including modals, buttons, input fields, and status bars, need to have a consistent pixel art style, and a user-friendly layout and navigation should be designed.
* **Currently Utilized Code:**
    * The basic framework for UI layout using fundamental Flutter widgets (`Container`, `Column`, `Row`, `Image.asset`, `ElevatedButton`, etc.) is implemented.
    * The basic structure for pet image transition animation using `AnimatedSwitcher` is in place.
    * An example of applying a global font and UI style via `ThemeData` is included.
    * Official Flutter documentation - LAYOUT: https://docs.flutter.dev/ui/layout
* **Reference Materials:**
    * **In-depth Flutter UI and Animations:**
        * Official Flutter Documentation - Animations: https://docs.flutter.dev/ui/animations
    * **In-depth Pixel Art Design:**
        * Pixel Art Tutorial (MortMort YouTube): https://www.youtube.com/playlist?list=PLR3g_Ew-rK_V0w22XN30kXy2q4iP_1wTz
        * Piskel or Aseprite Usage (official documentation/tutorials for each tool)
    * **Using SVG Images (`flutter_svg`):**
        * `flutter_svg` package documentation: https://pub.dev/packages/flutter_svg

### 5.2. YeYe (Access Control System Designer 🔐)

* **Key Tasks and Future Improvements:**
    * **Actual DB Modeling and Rule Design:** Instead of local dummy data, the final data models for `users`, `pets`, and `reflections` collections need to be designed for integration with a real database like Firebase Firestore, and clearly defined like a relational database schema.
    * **Advanced Game Logic:** Automatic decrease logic for pet states (hunger, happiness, cleanliness) over time (e.g., timer-based), special pet evolution conditions or bonus experience grants based on specific criteria (e.g., 3 consecutive reflections), and more should be added.
    * **Data Validation and Integrity:** Data validation rules for user input (reflection content) such as minimum/maximum length limits, profanity filtering, and data format validation need to be defined.
* **Currently Utilized Code:**
    * Basic data structures for pets and reflection records are defined in `lib/models/pet.dart` and `lib/models/reflection.dart`.
    * The initial draft of core game logic, including experience acquisition rules, growth stage change conditions, pet state changes based on actions, and daily attendance check limits, is implemented within the `PetNotifier` class in `lib/providers/pet_notifier.dart`.
* **Reference Materials:**
    * **In-depth Dart Language:**
        * Dart Official Documentation: https://dart.dev/guides
    * **Game Logic Design Principles:**
        * Materials related to 'Game Balancing', 'Progression Systems', 'Reward Mechanisms' (search online)
        * State Machine concepts
    * **Database Modeling (for future Firebase integration):**
        * Firebase Firestore Data Modeling Guide: https://firebase.google.com/docs/firestore/data-model
        * Firestore Security Rules: https://firebase.google.com/docs/firestore/security/overview

### 5.3. JangJang (Feature and State Integration Manager 🔗)

* **Key Tasks and Future Improvements:**
    * **Real DB Integration and Synchronization:** Implement logic for real-time synchronization of app state with a real database like Firebase Firestore (data loading, saving, updating, deleting) instead of local `StateNotifier`.
    * **User Authentication System Development:** Implement an authentication system (Firebase Authentication, etc.) for user registration, login (email/password, social login, etc.), and password recovery to manage actual users.
    * **Deployment Strategy Establishment:** Establish deployment procedures for providing the developed app to actual users via mobile app stores (Google Play Store, Apple App Store) and web deployment (Firebase Hosting, etc.).
    * **Overall Service Connection and Project Schedule Management:** Coordinate the integration of each team member's work, ensure seamless connection of overall service features, and perform PM roles such as project scheduling, progress tracking, and issue tracking.
* **Currently Utilized Code:**
    * The basic structure of the state management system, utilizing `flutter_riverpod`'s `StateNotifierProvider` for local state management and UI update integration, is in place.
    * Logic for screen transitions using `Navigator` and user feedback (`SnackBar`) via `ScaffoldMessenger` is included.
    * The `uuid` package is used to generate unique IDs locally.
* **Reference Materials:**
    * **In-depth Riverpod:**
        * Riverpod Official Documentation: https://riverpod.dev/
    * **Flutter State Management Patterns:**
        * Official Flutter Documentation - State Management: https://docs.flutter.dev/data-and-backend/state-mgmt/options
    * **Data Persistence (for future implementation):**
        * `shared_preferences` (key-value data): https://pub.dev/packages/shared_preferences
        * `Hive` (NoSQL local DB): https://pub.dev/packages/hive
        * `sqflite` (SQLite local DB): https://pub.dev/packages/sqflite
    * **Project Management and Collaboration Tools:**
        * Git/GitHub Flow (branching strategy, PR, code review)
        * Agile Methodologies (Scrum, Kanban)

## 6. Future Expansion and Improvement Ideas (Overall Project Perspective)

* **User Authentication:** For a real service, user login/registration features using Firebase Authentication, etc., need to be added.
* **Data Persistence:** Integrate with local storage or a cloud database (Firebase Firestore, etc.) to permanently store and manage user data.
* **Pet Customization:** Add user customization features such as changing pet names and equipping customization items.
* **Additional Game Elements:** Add elements such as warnings when the pet's condition deteriorates, or increasing happiness through interaction with the pet (stroking, talking).
* **Detailed Reflection Records:** Enhance reflection records with emotion tags, keyword analysis, and statistical graphs to aid self-reflection.
* **Notification Features:** Add push notification features such as reflection reminder alarms and pet status alerts to encourage user engagement.
