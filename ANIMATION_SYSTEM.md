# Pet Task Animation System Documentation

## 🎯 Overview

The Pet Task Animation System provides contextual visual feedback when users complete tasks (CLEAN, PLAY, FEED) and return to the MyPage. The system triggers appropriate animations that match the task context using existing pet evolution images.

## 🏗️ Architecture

### Animation Package Choice: Flutter Built-in AnimatedSwitcher + Custom Sequences

**Why This Choice:**
- ✅ **No External Dependencies** - Works with existing pet assets
- ✅ **Lightweight** - Built into Flutter framework, minimal performance impact
- ✅ **Flexible Control** - Custom animations for each task type
- ✅ **Easy Integration** - Seamless with Riverpod state management
- ✅ **Asset Reuse** - Leverages existing `egg_state0.png` to `egg_state6.png`

### System Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Task Pages    │    │   Pet Model     │    │  Animation UI   │
│  (Clean/Play/   │───▶│  (State Track)  │───▶│   (Visual FX)   │
│   Feed)         │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐             │
         └──────────────▶│  PetNotifier    │◀────────────┘
                        │ (State Manager) │
                        └─────────────────┘
```

## 🎬 Animation Flow

### Trigger Sequence
1. **User Completes Task** → Task page (CleanPage/PlayPage/FeedPage)
2. **PetNotifier Updates State** → Sets `lastCompletedTask` + `animationTriggerTime`
3. **Navigator.pop()** → Returns to MyPage
4. **MyPage Detects Animation** → Checks `pet.shouldShowTaskAnimation`
5. **Animation Plays** → Contextual animation based on `pet.currentAnimationType`
6. **Animation Completes** → `PetNotifier.clearAnimationState()` resets trigger

### Animation Types

#### CLEAN Animation (Attendance Check)
```yaml
Name: "cleaning"
Duration: 2.5 seconds
Effects:
  - Sparkle effect with yellow/white glow
  - Scale pulse animation (1.0 → 1.15)
  - Auto-awesome icon overlay
Context: "Pet is clean and attended"
```

#### PLAY Animation (Daily Diary)
```yaml
Name: "playing" 
Duration: 2.0 seconds
Effects:
  - Bounce animation (1.0 → 1.2)
  - Gentle rotation (-0.1 → 0.1)
  - Floating pink hearts
Context: "Pet is happy and playful"
```

#### FEED Animation (Reflection)
```yaml
Name: "eating"
Duration: 2.2 seconds  
Effects:
  - Orange/red glow effect
  - Scale pulse animation (1.0 → 1.15)
  - Warm satisfaction glow
Context: "Pet is fed and satisfied"
```

## 🛠️ Technical Implementation

### Pet Model Extensions
```dart
// Animation state fields
final String? lastCompletedTask;        // 'clean'|'play'|'feed'|null
final DateTime? animationTriggerTime;   // When animation should trigger

// Animation logic methods
bool get shouldShowTaskAnimation        // Check if animation should play
String? get currentAnimationType        // Get animation type identifier
Pet clearAnimationState()              // Reset animation state
```

### PetNotifier Integration
```dart
// Task completion methods updated to trigger animations
void performCleanAction() {
  _updatePet(state.copyWith(
    // ... existing logic ...
    lastCompletedTask: 'clean',
    animationTriggerTime: DateTime.now(),
  ));
}

void clearAnimationState() {
  state = state.clearAnimationState();
  _savePetData();
}
```

### Animation Widget Structure
```dart
PetAnimationOverlay
├── PetTaskAnimationWidget
│   ├── AnimationControllers (bounce, scale, rotation, sparkle)
│   ├── Task-specific animation methods
│   ├── Visual effect builders (sparkle, glow, hearts)
│   └── Animation lifecycle management
└── AnimatedSwitcher integration
```

## 🎨 Visual Effects

### Effect Library
- **Sparkle Effect**: Circular glow with auto-awesome icon (CLEAN)
- **Glow Effect**: Warm orange/red radial glow (FEED)  
- **Bounce Animation**: Elastic scale transformation (PLAY)
- **Rotation Effect**: Gentle pendulum rotation (PLAY)
- **Floating Hearts**: Rising pink heart icons (PLAY)
- **Scale Pulse**: Rhythmic size changes (CLEAN, FEED)

### Asset Integration
- Uses existing `assets/images/egg_state0.png` to `egg_state6.png`
- Growth stage determines base pet image
- Animation effects overlay on top of base image
- No additional image assets required

## 🔄 State Management

### Animation Triggers
```dart
// When task is completed (in PetNotifier)
lastCompletedTask: 'clean'|'play'|'feed'
animationTriggerTime: DateTime.now()

// Animation display logic (in Pet model)  
shouldShowTaskAnimation: animationTriggerTime within last 10 seconds
currentAnimationType: maps task to animation identifier
```

### Lifecycle Management
- **Trigger**: Set when task completes
- **Detection**: Checked on MyPage rebuild
- **Display**: Animation plays automatically
- **Cleanup**: State cleared after animation completes
- **Persistence**: State survives app restarts via Firebase

## 🚀 Usage Examples

### Testing Animation System
1. **Run App**: `flutter run -d chrome`
2. **Go to CleanPage**: Tap "Clean" button → Complete attendance
3. **Return to MyPage**: Should see sparkle animation
4. **Go to PlayPage**: Write diary entry → Submit
5. **Return to MyPage**: Should see bounce + hearts animation  
6. **Go to FeedPage**: Select reflection topic → Submit
7. **Return to MyPage**: Should see glow animation

### Integration Code
```dart
// In MyPage screen
PetAnimationOverlay(
  pet: pet,
  basePetImagePath: getPetImagePath(pet.growthStage),
)
```

## 🏆 Benefits

### User Experience
- **Visual Feedback**: Immediate confirmation of task completion
- **Contextual Design**: Animations match task meaning (clean→sparkles, play→hearts, feed→glow)
- **Smooth Integration**: Seamless with existing UI patterns
- **Performance**: Lightweight, no external dependencies

### Technical Benefits  
- **Asset Reuse**: No additional images needed
- **State Persistence**: Animations survive app restarts
- **Clean Architecture**: Separated concerns with proper state management
- **Extensible**: Easy to add new animation types

## 🔧 Customization

### Adding New Animation Types
1. **Add Task Type**: Update `performXXXAction()` in PetNotifier
2. **Add Animation Case**: Update `currentAnimationType` getter in Pet model
3. **Implement Animation**: Add new case in `_startTaskAnimation()` 
4. **Create Visual Effects**: Add effect builder methods

### Animation Timing Adjustments
```dart
// In PetTaskAnimationWidget
static const Duration cleanDuration = Duration(milliseconds: 2500);
static const Duration playDuration = Duration(milliseconds: 2000);
static const Duration feedDuration = Duration(milliseconds: 2200);
```

### Visual Effect Customization
```dart
// Color themes
Colors.yellow + Colors.white    // CLEAN sparkle
Colors.pink + Colors.red        // PLAY hearts  
Colors.orange + Colors.red      // FEED glow
```

The animation system provides rich visual feedback that enhances user engagement while maintaining excellent performance and clean architecture integration.