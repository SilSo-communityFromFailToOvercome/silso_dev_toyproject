# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter "Tamagotchi-style" pet app called "Hatching the Egg of Failure" where users grow a virtual pet by recording reflections and failures. The pet evolves through different stages based on experience points gained from various activities.

## Development Commands

- **Run app**: `flutter run -d chrome` (web) or `flutter run -d macos` (desktop)
- **Install dependencies**: `flutter pub get`
- **Clean build**: `flutter clean && flutter pub get`
- **Build for web**: `flutter build web`
- **Run tests**: `flutter test`
- **Format code**: `dart format .`
- **Analyze code**: `flutter analyze`

## Architecture

### State Management
- Uses **Riverpod** for state management throughout the app
- Core state is managed in `lib/providers/pet_notifier.dart` with `PetNotifier` class
- Authentication state managed via `authStateChangesProvider` in `auth_wrapper.dart`

### Data Models
- **Pet** (`lib/models/pet.dart`): Core pet data including experience, growth stage, hunger, happiness, cleanliness
- **Reflection** (`lib/models/reflection.dart`): User reflection/diary entries with type, question, answer, timestamp

### Authentication Flow
- Firebase Authentication with email/password
- `AuthWrapper` component handles login state and routing
- Authenticated users go to `MyPageScreen`, unauthenticated users see login/signup screens

### Core App Logic
- **Growth System**: Pet evolves through 4 stages (0-3) based on experience points:
  - Stage 0: Initial egg (0+ EXP)
  - Stage 1: Cracked egg (20+ EXP) 
  - Stage 2: Pre-hatch egg (40+ EXP)
  - Stage 3: Hatched pet (60+ EXP)

- **Action System**: Three main actions that affect pet stats and grant EXP:
  - **CLEAN** (attendance): +5 EXP, +20 cleanliness (once per day)
  - **PLAY** (diary writing): +10 EXP, +20 happiness
  - **FEED** (topic reflection): +15 EXP, +20 hunger

### File Structure
```
lib/
├── main.dart                 # App entry point with Firebase setup
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── providers/                # Riverpod state management
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── my_page.dart         # Main pet screen (post-login)
│   ├── clean_page.dart      # Attendance/cleaning action
│   ├── feed_page.dart       # Topic reflection action  
│   ├── play_page.dart       # Diary writing action
│   └── history_page.dart    # View past reflections
└── services/                # Business logic services
```

### Design System
- Uses **Google Fonts** (Pixelify Sans) for pixel-art aesthetic
- Material Design with custom theme in `main.dart`
- Pet evolution visualized through 4 egg state images in `assets/images/`

### Firebase Integration
- **Firebase Auth**: Email/password authentication
- **Cloud Firestore**: Pet data and reflection storage (though current code uses local state)
- **Firebase Hosting**: Web deployment target

## Team Context
This is a 10-day sprint toy project by a 3-person team learning Flutter development, with defined roles for UI/UX, backend/data, and integration.