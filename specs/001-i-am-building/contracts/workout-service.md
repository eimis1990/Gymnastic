# Workout Service Contract

**Service**: WorkoutService  
**Purpose**: Manages workout creation, editing, exercise/break management, and reordering  
**Layer**: Business Logic / Service Layer

---

## Protocol Definition

```swift
import Foundation
import SwiftData

protocol WorkoutServiceProtocol {
    // MARK: - CRUD Operations
    
    /// Creates a new workout
    /// - Parameter title: Workout name (required, 1-100 chars)
    /// - Returns: Created workout
    /// - Throws: ValidationError if validation fails
    func createWorkout(title: String) async throws -> Workout
    
    /// Updates workout title
    /// - Parameters:
    ///   - workout: Workout to update
    ///   - title: New title
    /// - Throws: ValidationError if validation fails
    func updateWorkoutTitle(_ workout: Workout, title: String) async throws
    
    /// Deletes a workout
    /// - Parameter workout: Workout to delete
    /// - Throws: ServiceError if deletion fails
    func deleteWorkout(_ workout: Workout) async throws
    
    /// Fetches all workouts
    /// - Returns: Array of workouts sorted by last updated
    func fetchAllWorkouts() async throws -> [Workout]
    
    /// Fetches a specific workout with its items
    /// - Parameter id: Workout ID
    /// - Returns: Workout with loaded relationships
    func fetchWorkout(byID id: UUID) async throws -> Workout?
    
    // MARK: - Exercise Management
    
    /// Adds an exercise to a workout
    /// - Parameters:
    ///   - exercise: Exercise to add
    ///   - workout: Target workout
    ///   - configurationType: Rep-based or time-based
    ///   - sets: Number of sets (if rep-based)
    ///   - repsPerSet: Reps per set (if rep-based)
    ///   - restBetweenSets: Rest between sets in seconds (if rep-based)
    ///   - duration: Exercise duration in seconds (if time-based)
    /// - Returns: Created WorkoutItem
    /// - Throws: ValidationError if configuration invalid
    func addExercise(
        _ exercise: Exercise,
        to workout: Workout,
        configurationType: ConfigurationType,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async throws -> WorkoutItem
    
    /// Removes an exercise from a workout
    /// - Parameters:
    ///   - item: WorkoutItem to remove
    ///   - workout: Parent workout
    func removeExercise(_ item: WorkoutItem, from workout: Workout) async throws
    
    /// Updates exercise configuration
    /// - Parameters:
    ///   - item: WorkoutItem to update
    ///   - sets: Updated sets
    ///   - repsPerSet: Updated reps
    ///   - restBetweenSets: Updated rest
    ///   - duration: Updated duration
    /// - Throws: ValidationError if invalid
    func updateExerciseConfiguration(
        _ item: WorkoutItem,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async throws
    
    // MARK: - Break Management
    
    /// Adds a break to a workout
    /// - Parameters:
    ///   - duration: Break duration in seconds
    ///   - workout: Target workout
    ///   - position: Position in sequence
    /// - Returns: Created Break
    /// - Throws: ValidationError if duration invalid
    func addBreak(duration: Int, to workout: Workout, at position: Int) async throws -> Break
    
    /// Removes a break from a workout
    /// - Parameters:
    ///   - break: Break to remove
    ///   - workout: Parent workout
    func removeBreak(_ break: Break, from workout: Workout) async throws
    
    /// Updates break duration
    /// - Parameters:
    ///   - break: Break to update
    ///   - duration: New duration in seconds
    /// - Throws: ValidationError if invalid
    func updateBreakDuration(_ break: Break, duration: Int) async throws
    
    // MARK: - Reordering
    
    /// Reorders items in workout sequence
    /// - Parameters:
    ///   - sourceIndices: Original positions
    ///   - destinationIndex: Target position
    ///   - workout: Workout to reorder
    func reorderSequence(
        from sourceIndices: IndexSet,
        to destinationIndex: Int,
        in workout: Workout
    ) async throws
    
    /// Moves an item to a specific position
    /// - Parameters:
    ///   - itemID: ID of item to move (WorkoutItem or Break)
    ///   - position: Target position
    ///   - workout: Parent workout
    func moveItem(withID itemID: UUID, to position: Int, in workout: Workout) async throws
    
    // MARK: - Validation
    
    /// Validates workout can be started
    /// - Parameter workout: Workout to validate
    /// - Returns: True if valid for execution
    /// - Throws: ValidationError if cannot start
    func validateWorkoutForExecution(_ workout: Workout) throws
    
    /// Calculates estimated workout duration
    /// - Parameter workout: Workout to calculate
    /// - Returns: Estimated duration in seconds
    func calculateEstimatedDuration(_ workout: Workout) -> Int
}
```

---

## Error Types

```swift
enum WorkoutServiceError: LocalizedError {
    case invalidTitle
    case noExercisesInWorkout
    case invalidSetsValue(value: Int)
    case invalidRepsValue(value: Int)
    case invalidRestValue(value: Int)
    case invalidDurationValue(value: Int)
    case invalidBreakDuration(value: Int)
    case invalidPosition(position: Int, maxPosition: Int)
    case workoutNotFound
    case itemNotFound
    case missingConfiguration(type: ConfigurationType)
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Workout name must be between 1 and 100 characters"
        case .noExercisesInWorkout:
            return "Add at least one exercise to start the workout"
        case .invalidSetsValue(let value):
            return "Sets (\(value)) must be between 1 and 99"
        case .invalidRepsValue(let value):
            return "Reps (\(value)) must be between 1 and 999"
        case .invalidRestValue(let value):
            return "Rest (\(value)s) must be between 0 and 600 seconds"
        case .invalidDurationValue(let value):
            return "Duration (\(value)s) must be between 1 and 3600 seconds"
        case .invalidBreakDuration(let value):
            return "Break duration (\(value)s) must be between 1 and 600 seconds"
        case .invalidPosition(let position, let maxPosition):
            return "Position \(position) is invalid (max: \(maxPosition))"
        case .workoutNotFound:
            return "Workout not found"
        case .itemNotFound:
            return "Workout item not found"
        case .missingConfiguration(let type):
            return "Missing configuration for \(type) exercise"
        }
    }
}
```

---

## Test Scenarios

### Success Cases

#### TC-W01: Create Empty Workout
```swift
// Given
let title = "Chest Day"

// When
let workout = try await service.createWorkout(title: title)

// Then
XCTAssertEqual(workout.title, title)
XCTAssertEqual(workout.items.count, 0)
XCTAssertEqual(workout.breaks.count, 0)
XCTAssertNotNil(workout.id)
```

#### TC-W02: Add Rep-Based Exercise to Workout
```swift
// Given
let workout = createWorkout()
let exercise = createExercise(title: "Push Up")

// When
let item = try await service.addExercise(
    exercise,
    to: workout,
    configurationType: .repetitions,
    sets: 3,
    repsPerSet: 10,
    restBetweenSets: 60,
    duration: nil
)

// Then
XCTAssertEqual(item.sets, 3)
XCTAssertEqual(item.repsPerSet, 10)
XCTAssertEqual(item.restBetweenSetsSeconds, 60)
XCTAssertEqual(item.position, 0)
XCTAssertEqual(workout.items.count, 1)
```

#### TC-W03: Add Time-Based Exercise to Workout
```swift
// Given
let workout = createWorkout()
let exercise = createExercise(title: "Plank")

// When
let item = try await service.addExercise(
    exercise,
    to: workout,
    configurationType: .time,
    sets: nil,
    repsPerSet: nil,
    restBetweenSets: nil,
    duration: 60
)

// Then
XCTAssertEqual(item.durationSeconds, 60)
XCTAssertEqual(item.configurationType, .time)
```

#### TC-W04: Add Break to Workout
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, at: 0)

// When
let breakItem = try await service.addBreak(
    duration: 120,
    to: workout,
    at: 1
)

// Then
XCTAssertEqual(breakItem.durationSeconds, 120)
XCTAssertEqual(breakItem.position, 1)
XCTAssertEqual(workout.breaks.count, 1)
```

#### TC-W05: Reorder Exercises in Workout
```swift
// Given
let workout = createWorkout()
let item1 = addExercise(to: workout, at: 0) // Position 0
let item2 = addExercise(to: workout, at: 1) // Position 1
let item3 = addExercise(to: workout, at: 2) // Position 2

// When (move item at index 0 to index 2)
try await service.reorderSequence(
    from: IndexSet(integer: 0),
    to: 2,
    in: workout
)

// Then
XCTAssertEqual(workout.items[0].id, item2.id) // Was at 1
XCTAssertEqual(workout.items[1].id, item3.id) // Was at 2
XCTAssertEqual(workout.items[2].id, item1.id) // Was at 0
```

#### TC-W06: Remove Exercise from Workout
```swift
// Given
let workout = createWorkout()
let item1 = addExercise(to: workout, at: 0)
let item2 = addExercise(to: workout, at: 1)

// When
try await service.removeExercise(item1, from: workout)

// Then
XCTAssertEqual(workout.items.count, 1)
XCTAssertEqual(workout.items[0].id, item2.id)
XCTAssertEqual(workout.items[0].position, 0) // Position updated
```

#### TC-W07: Calculate Workout Duration
```swift
// Given
let workout = createWorkout()
addExercise(to: workout, sets: 3, reps: 10, rest: 60) // ~270s
addBreak(to: workout, duration: 120) // 120s
addExercise(to: workout, duration: 60) // 60s

// When
let duration = service.calculateEstimatedDuration(workout)

// Then
XCTAssertEqual(duration, 450) // 270 + 120 + 60
```

### Error Cases

#### TC-W08: Create Workout with Empty Title
```swift
// When/Then
await XCTAssertThrowsError(
    try await service.createWorkout(title: "")
) { error in
    XCTAssertEqual(error as? WorkoutServiceError, .invalidTitle)
}
```

#### TC-W09: Add Exercise with Invalid Sets
```swift
// Given
let workout = createWorkout()
let exercise = createExercise()

// When/Then
await XCTAssertThrowsError(
    try await service.addExercise(
        exercise,
        to: workout,
        configurationType: .repetitions,
        sets: 0, // Invalid
        repsPerSet: 10,
        restBetweenSets: 60,
        duration: nil
    )
) { error in
    guard case .invalidSetsValue = error as? WorkoutServiceError else {
        XCTFail("Wrong error type")
        return
    }
}
```

#### TC-W10: Validate Empty Workout for Execution
```swift
// Given
let workout = createWorkout() // No exercises

// When/Then
XCTAssertThrowsError(
    try service.validateWorkoutForExecution(workout)
) { error in
    XCTAssertEqual(error as? WorkoutServiceError, .noExercisesInWorkout)
}
```

#### TC-W11: Add Break with Invalid Duration
```swift
// Given
let workout = createWorkout()

// When/Then
await XCTAssertThrowsError(
    try await service.addBreak(duration: 0, to: workout, at: 0)
) { error in
    guard case .invalidBreakDuration = error as? WorkoutServiceError else {
        XCTFail("Wrong error type")
        return
    }
}
```

---

## Behavioral Requirements

### BR-W01: Title Validation
- **MUST** trim whitespace
- **MUST** reject empty or > 100 characters
- **MUST** allow special characters

### BR-W02: Exercise Configuration Validation
- **Rep-based**: MUST have sets (1-99), reps (1-999), rest (0-600s)
- **Time-based**: MUST have duration (1-3600s)
- **MUST** reject null values for required fields

### BR-W03: Break Validation
- **MUST** validate duration (1-600 seconds)
- **MUST** allow 0 breaks per workout
- **MUST** position breaks correctly in sequence

### BR-W04: Position Management
- **MUST** assign sequential positions starting from 0
- **MUST** update positions after reorder
- **MUST** update positions after deletion
- **MUST** maintain order integrity (no gaps)

### BR-W05: Reordering Behavior
- **MUST** support drag-drop reordering
- **MUST** update all affected positions
- **MUST** maintain relative order of non-moved items
- **MUST** work with mixed exercises and breaks

### BR-W06: Deletion Behavior
- **MUST** cascade delete WorkoutItems when workout deleted
- **MUST** cascade delete Breaks when workout deleted
- **MUST** update positions of remaining items after item deletion

### BR-W07: Execution Validation
- **MUST** require at least 1 exercise
- **MUST** allow workout with 0 breaks
- **MUST** validate all exercise configurations are complete

---

## Implementation Notes

### Dependencies
- SwiftData `ModelContext` for persistence
- Exercise and WorkoutItem models
- Break model

### Position Management Strategy
```swift
// After deletion at position 2:
// Before: [0, 1, 2, 3, 4]
// After:  [0, 1, 2, 3] (positions renumbered)

// After reorder from 0 to 3:
// Before: [A:0, B:1, C:2, D:3]
// After:  [B:0, C:1, D:2, A:3]
```

### Performance Considerations
- Batch position updates in single transaction
- Use in-memory sorting before saving
- Avoid unnecessary saves during reordering

### Thread Safety
- All operations async with actor isolation
- SwiftData handles concurrent access

---

**Contract Status**: ✅ Complete - Ready for test-first implementation

