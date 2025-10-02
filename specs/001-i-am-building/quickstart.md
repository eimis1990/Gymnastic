# Quickstart: Custom Workout Builder

**Feature**: 001-i-am-building  
**Purpose**: Step-by-step validation guide for testing the workout builder feature  
**Target Audience**: Developers, QA testers, reviewers

---

## Prerequisites

### Environment Setup
```bash
# Clone and open project
cd /Users/eimantaskudarauskas/gymtastic
open Gymtastic.xcodeproj

# Verify Swift version
swift --version  # Should be 5.9+

# Verify iOS deployment target
# Project Settings → General → Deployment Info → iOS 17.0
```

### Build & Run
```bash
# Build for simulator
⌘B (Command + B)

# Run on simulator
⌘R (Command + R)
# Or select iPhone 15 Pro simulator and press Run
```

### Test Execution
```bash
# Run all tests
⌘U (Command + U)

# Run specific test
# Right-click test method → Run "testName"

# View test coverage
# Product → Test → Show Code Coverage
# Target: 70%+ for business logic
```

---

## User Story 1: Create Exercise Library

**Goal**: Create multiple exercises with different configurations

### Steps

#### 1.1 Create First Exercise (Basic)
```
1. Launch app
2. Navigate to "Exercises" tab
3. Tap "+" button (top-right)
4. Fill in exercise form:
   - Title: "Push Up"
   - Description: "Classic chest exercise"
   - Muscle Groups: Select "Chest", "Triceps", "Core"
5. Tap "Save"

✅ Expected: Exercise appears in list with title and placeholder image
```

#### 1.2 Create Exercise with Image
```
1. In Exercises tab, tap "+"
2. Fill in:
   - Title: "Squat"
   - Tap "Add Image"
   - Choose "Photo Library" → select image
   - Muscle Groups: Select "Legs", "Glutes"
3. Tap "Save"

✅ Expected:
   - Exercise appears with uploaded image thumbnail
   - Image loads quickly in list (< 200ms)
   - Full image visible in detail view
```

#### 1.3 Create Exercise with YouTube Video
```
1. In Exercises tab, tap "+"
2. Fill in:
   - Title: "Burpee"
   - YouTube URL: "https://www.youtube.com/watch?v=dZgVxmf6jkA"
   - Muscle Groups: Select "Full Body"
3. Tap "Save"

✅ Expected:
   - Exercise saved with video link
   - "See Video" button visible in detail view
```

#### 1.4 Edit Existing Exercise
```
1. In Exercises list, tap "Squat"
2. Tap "Edit" button
3. Change description: "Compound leg exercise"
4. Add muscle group: "Core"
5. Tap "Save"

✅ Expected:
   - Changes saved
   - Updated at timestamp updated
   - New muscle group visible
```

#### 1.5 Delete Unused Exercise
```
1. In Exercises list, swipe left on "Burpee"
2. Tap "Delete"
3. Confirm deletion

✅ Expected:
   - Exercise removed from list
   - No warning (not used in workouts)
```

---

## User Story 2: Build Custom Workout

**Goal**: Create a workout with mixed exercise types, breaks, and reordering

### Steps

#### 2.1 Create Workout
```
1. Navigate to "Workouts" tab
2. Tap "+" button
3. Enter workout name: "Chest & Core Day"
4. Tap "Create"

✅ Expected: Empty workout builder screen with "Add Exercise" button
```

#### 2.2 Add Rep-Based Exercise
```
1. In workout builder, tap "Add Exercise"
2. Select "Push Up" from list
3. Configure:
   - Type: Repetitions (default)
   - Sets: 3
   - Reps per set: 12
   - Rest between sets: 60 seconds
4. Tap "Add"

✅ Expected:
   - Exercise appears in timeline
   - Shows "3 sets × 12 reps" summary
   - Position: 0
```

#### 2.3 Add Time-Based Exercise
```
1. Tap "Add Exercise"
2. Select "Plank" (create if needed)
3. Configure:
   - Toggle to "Time-Based"
   - Duration: 45 seconds
4. Tap "Add"

✅ Expected:
   - Exercise appears in timeline below Push Up
   - Shows "45s" summary
   - Position: 1
```

#### 2.4 Add Break Between Exercises
```
1. Tap "Add Break" button (between exercises)
2. Set duration: 120 seconds (2 minutes)
3. Tap "Add"

✅ Expected:
   - Break card appears in timeline
   - Shows "Break - 2m 0s"
   - Position: 2
```

#### 2.5 Add More Exercises
```
1. Add "Squat": 4 sets × 10 reps, 90s rest
2. Add Break: 90 seconds
3. Add "Burpee": 30 seconds (time-based)

✅ Expected:
   - Timeline shows 4 exercises + 2 breaks
   - Total estimated duration displayed at top
```

#### 2.6 Reorder Exercises via Drag-Drop
```
1. Long-press on "Plank" exercise card
2. Drag to position after "Squat"
3. Release

✅ Expected:
   - Visual feedback during drag (scale, shadow)
   - Plank moved to new position
   - Other exercises adjusted positions
   - Positions renumbered sequentially
```

#### 2.7 Remove Exercise from Workout
```
1. Swipe left on "Burpee" exercise
2. Tap "Delete"

✅ Expected:
   - Exercise removed from timeline
   - Positions updated
   - Estimated duration recalculated
```

#### 2.8 Save Workout
```
1. Tap "Save" (top-right)
2. Navigate to Workouts tab

✅ Expected:
   - "Chest & Core Day" appears in workout list
   - Shows exercise count: "3 exercises"
   - Shows estimated duration
```

---

## User Story 3: Execute Workout

**Goal**: Start and complete a workout with progress tracking

### Steps

#### 3.1 Start Workout
```
1. In Workouts tab, tap "Chest & Core Day"
2. Tap "Start Workout" button

✅ Expected:
   - Execution screen appears
   - First exercise (Push Up) displayed as active card
   - Shows: image, "3 sets × 12 reps", "See Video" button
   - Progress indicator: "Exercise 1 of 5"
   - Upcoming items list below
```

#### 3.2 View Upcoming Items
```
1. Scroll down on execution screen

✅ Expected:
   - Compact cards showing:
     - Break - 2m 0s
     - Plank
     - Squat
   - No full details (just titles)
   - Clear visual separation from active card
```

#### 3.3 Access Exercise Video
```
1. Tap "See Video" button on active card

✅ Expected:
   - SFSafariViewController opens
   - YouTube video loads
   - Can play video, read comments
   - Tap "Done" returns to execution screen
```

#### 3.4 Advance to Next Item
```
1. Complete Push Up sets
2. Tap "Next" button

✅ Expected:
   - Break becomes active card
   - Shows "Break - 2m 0s" with timer icon
   - Progress: "Exercise 2 of 5"
   - Push Up moves to completed (grayed out)
```

#### 3.5 Continue Through Break
```
1. Wait or tap "Next" to skip break

✅ Expected:
   - Plank becomes active card
   - Shows time-based configuration: "45s"
   - Progress updated
```

#### 3.6 Pause Workout
```
1. Tap pause button (top-right)
2. Confirm pause

✅ Expected:
   - Workout paused
   - Elapsed time frozen
   - "Resume" button visible
   - Cannot advance
```

#### 3.7 Resume Workout
```
1. Tap "Resume"

✅ Expected:
   - Workout resumes from same position
   - Elapsed time continues
   - Can advance normally
```

#### 3.8 Complete Final Exercise
```
1. Advance through remaining exercises
2. Complete Squat (last exercise)
3. Tap "Next" after last exercise

✅ Expected:
   - Completion summary screen appears
   - Shows:
     - "Workout Complete!"
     - Total duration: "15m 32s"
     - Completed exercises: "3 of 3"
     - "Done" button
```

#### 3.9 View Workout Summary
```
1. Review summary
2. Tap "Done"

✅ Expected:
   - Returns to workout list
   - Can start same workout again
```

---

## Accessibility Testing

### VoiceOver Validation
```
1. Enable VoiceOver: Settings → Accessibility → VoiceOver → On
2. Navigate through app using swipe gestures
3. Test critical flows:
   - Create exercise
   - Build workout
   - Start execution

✅ Expected:
   - All buttons have labels
   - Exercise/workout names announced
   - Progress updates announced
   - Actions clearly described
```

### Dynamic Type Testing
```
1. Enable largest text size: Settings → Display → Text Size → Maximum
2. Navigate through all screens

✅ Expected:
   - Text remains readable
   - No truncation of critical info
   - Layouts adjust gracefully
   - Minimum 44pt touch targets maintained
```

### Dark Mode Testing
```
1. Enable Dark Mode: Control Center → Appearance → Dark
2. Navigate through all screens

✅ Expected:
   - All screens support dark mode
   - Readable contrast maintained
   - Images display properly
   - No white flashes
```

---

## Performance Validation

### List Scrolling Performance
```
1. Create 50+ exercises with images
2. Scroll rapidly through exercise list

✅ Expected:
   - 60fps scrolling (no stuttering)
   - Thumbnails load instantly
   - Smooth deceleration
```

### App Launch Time
```
1. Force quit app
2. Launch app
3. Measure time to first interactive screen

✅ Expected: < 1 second on iPhone 12 or newer
```

### Image Loading
```
1. Open exercise with large image
2. Measure load time

✅ Expected:
   - Thumbnail: < 50ms
   - Full image: < 200ms
```

### Memory Usage
```
1. Instruments → Allocations
2. Navigate through app
3. Check for leaks

✅ Expected:
   - No memory leaks detected
   - Memory stable after navigation cycles
   - < 100MB memory footprint
```

---

## Edge Cases & Error Handling

### Error: Empty Exercise Title
```
1. Create exercise
2. Leave title empty
3. Tap "Save"

✅ Expected:
   - Error message: "Exercise name is required"
   - Cannot save
   - Form validation triggered
```

### Error: Invalid YouTube URL
```
1. Create exercise
2. Enter URL: "not-a-valid-url"
3. Tap "Save"

✅ Expected:
   - Error message: "Please enter a valid YouTube URL"
   - Field highlighted
   - Can correct and retry
```

### Error: Start Empty Workout
```
1. Create workout
2. Don't add exercises
3. Tap "Start Workout"

✅ Expected:
   - Alert: "Add at least one exercise to start the workout"
   - Cannot start execution
   - Stays in builder view
```

### Scenario: Delete Exercise Used in Workout
```
1. Create exercise "Test"
2. Add to workout
3. Try to delete "Test" exercise

✅ Expected:
   - Warning dialog: "This exercise is used in X workouts. Delete anyway?"
   - Options: Cancel, Delete
   - If deleted, workout item shows "Deleted Exercise"
```

### Scenario: Image Too Large
```
1. Try to upload 5MB image
2. Tap "Save"

✅ Expected:
   - Alert: "Image too large (max 2MB)"
   - Offer to compress
   - Or cancel and choose different image
```

---

## Regression Testing Checklist

Run after any code changes:

- [ ] All unit tests pass (⌘U)
- [ ] All UI tests pass
- [ ] Code coverage ≥ 70% for ViewModels and Services
- [ ] No compiler warnings
- [ ] No SwiftLint violations
- [ ] App launches without crash
- [ ] Can create exercise with all field types
- [ ] Can create workout with exercises and breaks
- [ ] Can reorder workout items via drag-drop
- [ ] Can execute workout start-to-finish
- [ ] VoiceOver announces all elements
- [ ] Dark mode renders correctly
- [ ] Dynamic Type scales properly
- [ ] No memory leaks in Instruments
- [ ] 60fps scrolling with 100+ items
- [ ] Images load within performance targets

---

## Success Criteria

### Functional Requirements Met
✅ All 38 functional requirements from spec.md implemented  
✅ Exercise CRUD with validation  
✅ Workout builder with drag-drop  
✅ Execution flow with progression  
✅ Image storage and display  
✅ YouTube video integration  

### Quality Standards Met
✅ Test coverage ≥ 70%  
✅ Zero compiler warnings  
✅ No force unwrapping without justification  
✅ MVVM architecture followed  
✅ SwiftData models properly configured  
✅ Accessibility labels on all UI elements  

### Performance Targets Met
✅ App launch < 1 second  
✅ 60fps list scrolling  
✅ Image load < 200ms  
✅ No memory leaks  

---

## Troubleshooting

### Issue: SwiftData not persisting
```
Solution:
- Check ModelContainer configuration
- Verify schema includes all @Model types
- Check for isStoredInMemoryOnly = false
- Inspect SwiftData console logs
```

### Issue: Drag-drop not working
```
Solution:
- Verify .onDrag() returns NSItemProvider
- Check .onDrop() delegate implementation
- Ensure proper UTType specified
- Test on device (not just simulator)
```

### Issue: Images not loading
```
Solution:
- Check imageData not nil
- Verify thumbnail generation logic
- Check compression quality settings
- Test with various image formats
```

---

**Quickstart Complete**: Follow these steps to validate the complete workout builder feature. All user stories and acceptance criteria should pass.

