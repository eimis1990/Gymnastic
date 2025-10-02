# Execution Service Contract

**Service**: ExecutionService  
**Purpose**: Manages workout execution flow, progression tracking, and completion  
**Layer**: Business Logic / Service Layer

---

## Protocol Definition

```swift
import Foundation
import Combine

protocol ExecutionServiceProtocol {
    // MARK: - Execution Control
    
    /// Starts workout execution
    /// - Parameter workout: Workout to execute
    /// - Returns: ExecutionSession
    /// - Throws: ValidationError if workout invalid
    func startWorkout(_ workout: Workout) async throws -> ExecutionSession
    
    /// Advances to next item in workout
    /// - Parameter session: Active execution session
    /// - Returns: Updated session
    /// - Throws: ExecutionError if cannot advance
    func nextItem(session: ExecutionSession) async throws -> ExecutionSession
    
    /// Pauses workout execution
    /// - Parameter session: Active execution session
    func pauseWorkout(session: ExecutionSession) async
    
    /// Resumes paused workout
    /// - Parameter session: Paused execution session
    func resumeWorkout(session: ExecutionSession) async
    
    /// Stops workout execution
    /// - Parameter session: Active execution session
    /// - Returns: Completion summary
    func stopWorkout(session: ExecutionSession) async -> WorkoutSummary
    
    /// Completes workout execution
    /// - Parameter session: Execution session
    /// - Returns: Final summary with stats
    func completeWorkout(session: ExecutionSession) async -> WorkoutSummary
    
    // MARK: - Progress Tracking
    
    /// Gets current progress
    /// - Parameter session: Execution session
    /// - Returns: Progress information
    func getProgress(for session: ExecutionSession) -> WorkoutProgress
    
    /// Gets upcoming items
    /// - Parameters:
    ///   - session: Execution session
    ///   - count: Number of upcoming items to return
    /// - Returns: Array of upcoming items
    func getUpcomingItems(for session: ExecutionSession, count: Int) -> [WorkoutSequenceItem]
    
    /// Checks if workout is complete
    /// - Parameter session: Execution session
    /// - Returns: True if all items completed
    func isWorkoutComplete(session: ExecutionSession) -> Bool
}
```

---

## Data Models

### ExecutionSession
```swift
struct ExecutionSession: Identifiable {
    let id: UUID
    let workout: Workout
    let startTime: Date
    var currentItemIndex: Int
    var completedItemIndices: [Int]
    var status: ExecutionStatus
    var pausedAt: Date?
    
    // Set tracking for repetition-based exercises
    var currentSet: Int? // Current set number (1-based)
    var isOnSetBreak: Bool // True when resting between sets
    var setBreakStartTime: Date? // When the break between sets started
    var setBreakDuration: Int? // Duration in seconds for the current set break
    
    // Break tracking for regular breaks between exercises
    var regularBreakStartTime: Date? // When a regular break item started
    
    var currentItem: WorkoutSequenceItem? {
        let sequence = workout.orderedSequence
        guard currentItemIndex < sequence.count else { return nil }
        return sequence[currentItemIndex]
    }
    
    var elapsedTime: TimeInterval {
        if let pausedAt = pausedAt {
            return pausedAt.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var remainingBreakTime: Int? {
        guard isOnSetBreak,
              let breakStart = setBreakStartTime,
              let duration = setBreakDuration else {
            return nil
        }
        let elapsed = Date().timeIntervalSince(breakStart)
        let remaining = max(0, duration - Int(elapsed))
        return remaining
    }
    
    var remainingRegularBreakTime: Int? {
        guard case .break(let breakItem) = currentItem,
              let breakStart = regularBreakStartTime else {
            return nil
        }
        let elapsed = Date().timeIntervalSince(breakStart)
        let remaining = max(0, breakItem.durationSeconds - Int(elapsed))
        return remaining
    }
}

enum ExecutionStatus {
    case active
    case paused
    case completed
    case stopped
}
```

### WorkoutProgress
```swift
struct WorkoutProgress {
    let currentIndex: Int
    let totalItems: Int
    let completedItems: Int
    let remainingItems: Int
    let percentComplete: Double
    let elapsedTime: TimeInterval
    let estimatedRemainingTime: TimeInterval
    
    var progressText: String {
        "Exercise \(currentIndex + 1) of \(totalItems)"
    }
}
```

### WorkoutSummary
```swift
struct WorkoutSummary {
    let workoutTitle: String
    let startTime: Date
    let endTime: Date
    let totalDuration: TimeInterval
    let completedExercises: Int
    let totalExercises: Int
    let wasCompleted: Bool // true if finished, false if stopped early
    
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return "\(minutes)m \(seconds)s"
    }
}
```

---

## Error Types

```swift
enum ExecutionServiceError: LocalizedError {
    case workoutNotValid
    case sessionNotActive
    case alreadyCompleted
    case cannotAdvance
    case noCurrentItem
    
    var errorDescription: String? {
        switch self {
        case .workoutNotValid:
            return "Workout cannot be started (no exercises)"
        case .sessionNotActive:
            return "Session is not active"
        case .alreadyCompleted:
            return "Workout already completed"
        case .cannotAdvance:
            return "Cannot advance to next item"
        case .noCurrentItem:
            return "No current item in session"
        }
    }
}
```

---

## Test Scenarios

### Success Cases

#### TC-X01: Start Workout Execution
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, title: "Push Up")
addExercise(to: workout, title: "Squat")

// When
let session = try await service.startWorkout(workout)

// Then
XCTAssertEqual(session.workout.id, workout.id)
XCTAssertEqual(session.currentItemIndex, 0)
XCTAssertEqual(session.status, .active)
XCTAssertNotNil(session.startTime)
XCTAssertEqual(session.completedItemIndices.count, 0)
```

#### TC-X02: Advance to Next Item
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)
addExercise(to: workout, at: 1)
var session = try await service.startWorkout(workout)

// When
session = try await service.nextItem(session: session)

// Then
XCTAssertEqual(session.currentItemIndex, 1)
XCTAssertEqual(session.completedItemIndices, [0])
```

#### TC-X03: Complete Workout
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)
var session = try await service.startWorkout(workout)
session = try await service.nextItem(session: session)

// When
let summary = await service.completeWorkout(session: session)

// Then
XCTAssertTrue(summary.wasCompleted)
XCTAssertEqual(summary.completedExercises, 1)
XCTAssertEqual(summary.totalExercises, 1)
XCTAssertEqual(summary.workoutTitle, workout.title)
XCTAssertGreaterThan(summary.totalDuration, 0)
```

#### TC-X04: Get Progress
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)
addExercise(to: workout, at: 1)
addExercise(to: workout, at: 2)
var session = try await service.startWorkout(workout)
session = try await service.nextItem(session: session)

// When
let progress = service.getProgress(for: session)

// Then
XCTAssertEqual(progress.currentIndex, 1)
XCTAssertEqual(progress.totalItems, 3)
XCTAssertEqual(progress.completedItems, 1)
XCTAssertEqual(progress.remainingItems, 2)
XCTAssertEqual(progress.percentComplete, 0.333, accuracy: 0.01)
```

#### TC-X05: Get Upcoming Items
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0, title: "Push Up")
addBreak(to: workout, at: 1, duration: 60)
addExercise(to: workout, at: 2, title: "Squat")
addExercise(to: workout, at: 3, title: "Plank")
let session = try await service.startWorkout(workout)

// When
let upcoming = service.getUpcomingItems(for: session, count: 3)

// Then
XCTAssertEqual(upcoming.count, 3)
// Should return break, squat, plank (items 1, 2, 3)
```

#### TC-X06: Pause and Resume Workout
```swift
// Given
let workout = createWorkout()
addExercise(to: workout)
var session = try await service.startWorkout(workout)

// When
await service.pauseWorkout(session: session)

// Then
XCTAssertEqual(session.status, .paused)
XCTAssertNotNil(session.pausedAt)

// When
await service.resumeWorkout(session: session)

// Then
XCTAssertEqual(session.status, .active)
XCTAssertNil(session.pausedAt)
```

#### TC-X07: Stop Workout Early
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)
addExercise(to: workout, at: 1)
var session = try await service.startWorkout(workout)

// When (stop after first exercise)
let summary = await service.stopWorkout(session: session)

// Then
XCTAssertFalse(summary.wasCompleted)
XCTAssertEqual(summary.completedExercises, 0) // Only current, not completed
XCTAssertEqual(summary.totalExercises, 2)
```

#### TC-X08: Workout with Breaks
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0, title: "Push Up")
addBreak(to: workout, at: 1, duration: 60)
addExercise(to: workout, at: 2, title: "Squat")
var session = try await service.startWorkout(workout)

// When (advance through exercises and break)
session = try await service.nextItem(session: session) // Now at break
session = try await service.nextItem(session: session) // Now at Squat

// Then
XCTAssertEqual(session.currentItemIndex, 2)
XCTAssertEqual(session.completedItemIndices.count, 2) // Push Up + Break
```

### Error Cases

#### TC-X09: Start Empty Workout
```swift
// Given
let workout = createWorkout() // No exercises

// When/Then
await XCTAssertThrowsError(
    try await service.startWorkout(workout)
) { error in
    XCTAssertEqual(error as? ExecutionServiceError, .workoutNotValid)
}
```

#### TC-X10: Advance Beyond Last Item
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)
var session = try await service.startWorkout(workout)
session = try await service.nextItem(session: session) // At end

// When/Then
await XCTAssertThrowsError(
    try await service.nextItem(session: session)
) { error in
    XCTAssertEqual(error as? ExecutionServiceError, .cannotAdvance)
}
```

#### TC-X11: Resume Non-Paused Workout
```swift
// Given
let workout = createWorkout()
addExercise(to: workout)
let session = try await service.startWorkout(workout)

// When (resume active workout)
// Then (should handle gracefully, maybe no-op or error)
```

---

## Behavioral Requirements

### BR-X01: Session Initialization
- **MUST** validate workout before starting
- **MUST** set currentItemIndex to 0
- **MUST** record startTime
- **MUST** initialize empty completedItemIndices
- **MUST** set status to .active

### BR-X02: Progression Logic
- **MUST** advance currentItemIndex by 1
- **MUST** add previous index to completedItemIndices
- **MUST** handle both exercises and breaks
- **MUST** prevent advancing beyond last item
- **MUST** track individual sets for repetition-based exercises
- **MUST** show break countdown timer between sets
- **MUST** initialize currentSet to 1 when starting multi-set exercise
- **MUST** increment currentSet after completing a set break
- **MUST** start set break when completing a set (if not the last set)
- **MUST** move to next item when all sets are completed
- **MUST** automatically start countdown timer when moving to a regular break item
- **MUST** track regular break start time and calculate remaining time
- **MUST** display countdown for both set breaks and regular breaks

### BR-X03: Pause Behavior
- **MUST** set status to .paused
- **MUST** record pausedAt timestamp
- **MUST** preserve current position
- **MUST** allow resuming from same position

### BR-X04: Resume Behavior
- **MUST** set status to .active
- **MUST** clear pausedAt
- **MUST** maintain current position
- **MUST** adjust elapsed time calculation

### BR-X05: Completion Detection
- **MUST** detect when currentItemIndex >= totalItems
- **MUST** mark wasCompleted = true if all items done
- **MUST** calculate accurate total duration
- **MUST** count only exercise items (exclude breaks)

### BR-X06: Stop vs Complete
- **Stop**: User exits early, wasCompleted = false
- **Complete**: All items done, wasCompleted = true
- Both return WorkoutSummary

### BR-X07: Progress Calculation
- **MUST** include breaks in total item count
- **MUST** calculate percentage based on completed items
- **MUST** estimate remaining time based on configured durations
- **MUST** track elapsed time accounting for pauses

### BR-X08: Upcoming Items
- **MUST** return next N items from current position
- **MUST** return fewer items if near end
- **MUST** include both exercises and breaks
- **MUST** maintain sequence order

---

## Implementation Notes

### Dependencies
- Workout, WorkoutItem, Break models
- Foundation Date for time tracking

### State Management
- ExecutionSession is value type (struct)
- Updated copy returned on state changes
- ViewModel holds current session

### Time Tracking
```swift
// Elapsed time with pause handling
func calculateElapsedTime(session: ExecutionSession) -> TimeInterval {
    if let pausedAt = session.pausedAt {
        return pausedAt.timeIntervalSince(session.startTime)
    }
    return Date().timeIntervalSince(session.startTime)
}
```

### Performance Considerations
- No persistence during execution (keep in memory)
- Optionally save history after completion
- Lightweight progress calculations

### Thread Safety
- All operations async
- Session updates return new copy
- ViewModel publishes changes

---

**Contract Status**: ✅ Complete - Ready for test-first implementation

