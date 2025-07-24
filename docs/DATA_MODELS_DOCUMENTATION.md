# SilSo Flutter App - Data Models Documentation

## 🏗️ Backend Data Architecture Overview

The SilSo app implements a sophisticated backend data architecture with Firebase Firestore integration, complex business logic encapsulation, and real-time synchronization patterns. The data layer demonstrates production-ready patterns for mobile app backends with clean separation between data access, business logic, and state management.

### **Backend Architecture Highlights**
- **Firebase Firestore Integration**: Production-ready document-based data storage
- **Real-time Data Streams**: Live updates using Firestore snapshots
- **Complex Business Logic**: Advanced timer systems and game mechanics in data models
- **Offline-First Patterns**: Local state preservation with backend synchronization
- **Type Safety**: Comprehensive null handling and Firebase serialization patterns

---

## 📋 Core Models

### 🐣 Pet Model (`lib/models/pet.dart`)
**Purpose**: Central game entity representing the user's virtual pet with growth mechanics and real-time state management.

#### **Core Properties**
```dart
class Pet {
  final String name;                    // Pet's name
  final int experience;                 // Current XP (0-∞)
  final int growthStage;               // Growth level (0-3)
  final DateTime? lastReflectionDate;  // Last reflection entry
  final int hunger;                    // Hunger stat (0-100)
  final int happiness;                 // Happiness stat (0-100) 
  final int cleanliness;              // Cleanliness stat (0-100)
  final DateTime? lastAttendanceDate; // Last check-in date
  final DateTime lastUpdateTime;      // For decay calculations
}
```

#### **Growth System Implementation**
- **Stage 0**: Initial egg (0+ EXP)
- **Stage 1**: Cracked egg (20+ EXP) 
- **Stage 2**: Pre-hatch egg (40+ EXP)
- **Stage 3**: Hatched pet (60+ EXP)

#### **Advanced Features**

##### **Real-Time Stat Decay System**
```dart
// Decay rates (points per hour) - TESTING values
static const double hungerDecayRate = 1200.0;     // -10 points every 30s
static const double happinessDecayRate = 1200.0;  // -10 points every 30s  
static const double cleanlinessDecayRate = 1200.0; // -10 points every 30s

Pet applyDecay() {
  final now = DateTime.now();
  final timeDifference = now.difference(lastUpdateTime);
  final hoursElapsed = timeDifference.inSeconds / 3600.0;
  
  // Apply decay with clamping to 0-100 range
  final newHunger = (hunger - (hoursElapsed * hungerDecayRate)).round().clamp(0, 100);
  // ... similar for happiness and cleanliness
}
```

##### **Follow Button Timer System**
Complex real-time timer implementation with millisecond precision:

```dart
// Timer constants
static const int followButtonActiveDurationSeconds = 15;   // Active period
static const int followButtonInactiveDurationSeconds = 30; // Inactive period

// Precise timer state calculation
Map<String, dynamic> getFollowButtonState() {
  final now = DateTime.now();
  final timeSinceActivation = now.difference(followButtonLastActivated!);
  final totalCycleDurationMs = (followButtonActiveDurationSeconds + followButtonInactiveDurationSeconds) * 1000;
  final cycleTimeElapsedMs = timeSinceActivation.inMilliseconds % totalCycleDurationMs;
  
  // Returns: isActive, remainingMilliseconds, remainingSeconds, totalCycleSeconds
}
```

##### **Pet Animation System**
Task-completion triggered animations:

```dart
// Animation trigger fields
final String? lastCompletedTask;    // 'clean', 'play', 'feed'
final DateTime? animationTriggerTime; // When to trigger animation

// Animation logic
bool get shouldShowTaskAnimation {
  if (lastCompletedTask == null || animationTriggerTime == null) return false;
  final timeSinceAnimation = DateTime.now().difference(animationTriggerTime!);
  return timeSinceAnimation.inSeconds <= 10; // 10-second window
}

String? get currentAnimationType {
  if (!shouldShowTaskAnimation) return null;
  switch (lastCompletedTask) {
    case 'clean': return 'cleaning';
    case 'play': return 'playing';  
    case 'feed': return 'eating';
    default: return null;
  }
}
```

#### **Backend Code Review Focus Points**
- **Production Firebase Patterns**: Robust `fromFirestore()` and `toFirestore()` serialization
- **Complex Business Logic**: Advanced timer coordination and state calculations
- **Data Consistency**: Immutable updates with `copyWith()` ensuring thread safety
- **Performance Optimization**: Efficient calculations with clamping and validation
- **Real-time Coordination**: Multiple timer systems working without conflicts
- **Backend Scalability**: Patterns that support thousands of concurrent users

#### **Frontend Integration Points**
- **State Management**: How complex backend data integrates with Riverpod providers
- **UI Reactivity**: Real-time timer updates flowing to frontend components
- **Performance**: Efficient backend calculations supporting smooth frontend animations
- **User Experience**: Backend state changes triggering appropriate frontend feedback

---

### 📝 Reflection Model (`lib/models/reflection.dart`)
**Purpose**: User-generated content model for diary entries and topic reflections.

#### **Core Properties**
```dart
class Reflection {
  final String id;          // Firebase document ID
  final String type;        // "play" or "feed" 
  final String question;    // Prompt question
  final String answer;      // User response
  final DateTime timestamp; // Creation time
}
```

#### **Action Type Mapping**
- **"play"**: Diary writing (happiness action, +10 EXP)
- **"feed"**: Topic reflection (hunger action, +15 EXP)

#### **Firebase Integration Pattern**
```dart
// Standard Firebase serialization pattern used across all models
factory Reflection.fromFirestore(Map<String, dynamic> data, String id) {
  return Reflection(
    id: id,
    type: data['type'] ?? '',
    question: data['question'] ?? '',
    answer: data['answer'] ?? '',
    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

Map<String, dynamic> toFirestore() {
  return {
    'type': type,
    'question': question,
    'answer': answer,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
```

#### **Code Review Focus Points**
- **Simplicity**: Clean, focused model without business logic
- **Type Safety**: Proper null handling in Firebase conversion
- **Consistency**: Follows same patterns as other models

---

### 🏘️ Community Model (`lib/models/community.dart`)
**Purpose**: Social features supporting themed failure-sharing communities.

#### **Community Categories System**
```dart
enum FailureCategory {
  academic, career, employment, entrepreneurship, relationship,
  housing, personal, health, financial
}

extension FailureCategoryExtension on FailureCategory {
  String get displayName { /* User-friendly names */ }
  String get description { /* Detailed explanations */ }
  String get emoji { /* Category icons */ }
}
```

#### **Community Entity**
```dart
class Community {
  final String id;
  final String name;
  final FailureCategory category;    // Enum-based categorization
  final String description;
  final int memberCount;             // Aggregated member data
  final bool isActive;              // Community status
  final List<String> moderatorIds;  // User management
  final DateTime createdAt;
  final DateTime lastActivityAt;    // Activity tracking
}
```

#### **Advanced Pattern: Enum Extensions**
The enum extension pattern provides:
- **Type Safety**: Compile-time category validation
- **Localization Ready**: Easy translation support
- **UI Integration**: Direct emoji and description access
- **Extensibility**: Easy to add new categories

#### **Code Review Focus Points**
- **Enum Best Practices**: Extension methods for rich enum behavior
- **Data Modeling**: Clear business domain representation
- **Scalability**: Member count and activity tracking patterns

---

## 🔗 Model Relationships

### **Data Flow Architecture**
```
User Actions → Services → Models → State Management → UI Updates
     ↓              ↓         ↓            ↓              ↓
   Clean        PetService   Pet     PetNotifier    UI Widgets
   Play         ReflectionService Reflection  CommunityProviders
   Feed         CommunityService  Community
```

### **Key Relationships**
1. **Pet ↔ Reflection**: One-to-many (pet has multiple reflections)
2. **User ↔ Community**: Many-to-many via membership
3. **Community ↔ Post**: One-to-many (community contains posts)
4. **Post ↔ Comment**: One-to-many (post has multiple comments)

### **State Dependencies**
- **Pet state** affects UI animations and progression
- **Reflection data** influences pet experience and growth
- **Community membership** determines accessible content
- **Timer states** drive real-time UI updates

---

## 🔧 Common Patterns Analysis

### **1. Firebase Serialization Pattern**
All models implement consistent Firebase integration:
```dart
// Factory constructor for Firestore → Model
factory ModelName.fromFirestore(Map<String, dynamic> data, String id) {
  return ModelName(
    id: id,
    field: data['field'] ?? defaultValue,
    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

// Method for Model → Firestore  
Map<String, dynamic> toFirestore() {
  return {
    'field': field,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
```

### **2. Immutability Pattern**
All models use `copyWith` for state changes:
```dart
Pet copyWith({
  String? name,
  int? experience,
  // ... all fields as optional parameters
}) {
  return Pet(
    name: name ?? this.name,
    experience: experience ?? this.experience,
    // ... preserving existing values when not updated
  );
}
```

### **3. Business Logic Encapsulation**
Complex logic stays within models:
- Pet decay calculations
- Timer state management  
- Animation trigger logic
- Stat color coding

### **4. Type Safety Principles**
- Enums for categorical data
- Non-null assertions where appropriate
- Default value handling in Firebase conversion
- DateTime handling with null safety

---

## 📊 Code Quality Assessment

### **Strengths**
✅ **Consistent Patterns**: All models follow same structure  
✅ **Type Safety**: Proper null handling and type assertions  
✅ **Business Logic**: Complex calculations properly encapsulated  
✅ **Firebase Integration**: Clean serialization patterns  
✅ **Immutability**: Proper state management with copyWith  
✅ **Documentation**: Well-commented complex logic  

### **Areas for Review**
⚠️ **Testing Values**: Extreme decay rates for demo purposes  
⚠️ **Magic Numbers**: Hard-coded timer durations  
⚠️ **Complex Logic**: Follow button timer could be simplified  
⚠️ **Model Size**: Pet model handles many responsibilities  

### **Learning Opportunities**
1. **Complex State Management**: Study the Pet model's timer implementation
2. **Enum Extensions**: Learn rich enum patterns in Community model
3. **Firebase Patterns**: Understand consistent serialization approach
4. **Business Logic Placement**: See how game mechanics stay in models
5. **Immutable Updates**: Practice copyWith pattern usage

---

## 🎯 Study Questions for Code Review

### **Architecture Questions**
1. How do models maintain immutability while allowing state changes?
2. What patterns ensure consistent Firebase serialization?
3. How is business logic distributed between models and services?
4. What makes the enum extension pattern effective?

### **Implementation Questions**
1. How does the Pet model calculate real-time decay?
2. What makes the follow button timer implementation complex?
3. How do animation triggers work with state management?
4. What validation patterns are used in Firebase conversion?

### **Design Questions**
1. Why are some fields optional vs required in models?
2. How do default values ensure data consistency?
3. What trade-offs exist in the current timer implementation?
4. How could the Pet model be simplified without losing functionality?

This documentation provides a comprehensive foundation for understanding the SilSo app's data architecture and prepares you for effective code review sessions.