# Data Model: Custom Workout Builder

**Feature**: 001-i-am-building  
**Date**: 2025-10-01  
**Technology**: SwiftData (iOS 17+)

## Overview
This document defines the data model for the Gymtastic app using SwiftData's `@Model` macro. All entities are persisted locally with optional iCloud sync via CloudKit.

---

## Entity Relationship Diagram

```
┌─────────────┐
│  Exercise   │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────────┐      ┌──────────┐
│  WorkoutItem    │◄─────┤ Workout  │
└─────────────────┘  N:1 └──────────┘
                              │ 1:N
                         ┌────▼────┐
                         │  Break  │
                         └─────────┘
                         
┌──────────────┐
│ MuscleGroup  │ (Enum - not persisted)
└──────────────┘
```

---

## 1. Exercise

**Description**: Represents a single physical exercise in the user's library. Exercises are reusable across multiple workouts.

### SwiftData Model
```swift
import SwiftData
import Foundation

@Model
final class Exercise {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Core Properties
    var title: String
    var exerciseDescription: String?
    var youtubeURL: String?
    
    // MARK: - Images
    var imageData: Data?
    var thumbnailData: Data?
    
    // MARK: - Categorization
    var muscleGroups: [String] // Array of MuscleGroup.rawValue
    
    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \WorkoutItem.exercise)
    var workoutItems: [WorkoutItem]?
    
    // MARK: - Computed Properties
    var muscleGroupsEnum: [MuscleGroup] {
        muscleGroups.compactMap { MuscleGroup(rawValue: $0) }
    }
    
    var isUsedInWorkouts: Bool {
        !(workoutItems?.isEmpty ?? true)
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        youtubeURL: String? = nil,
        imageData: Data? = nil,
        thumbnailData: Data? = nil,
        muscleGroups: [MuscleGroup] = []
    ) {
        self.id = id
        self.title = title
        self.exerciseDescription = description
        self.youtubeURL = youtubeURL
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.muscleGroups = muscleGroups.map { $0.rawValue }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| `title` | Required, 1-100 characters | "Exercise name is required" |
| `youtubeURL` | Optional, valid YouTube URL format | "Invalid YouTube URL" |
| `imageData` | Optional, max 2MB | "Image too large (max 2MB)" |
| `muscleGroups` | At least 1 selected | "Select at least one muscle group" |

### Business Rules
1. **Title Uniqueness**: Recommended but not enforced (user might have variations)
2. **Image Constraints**: Max 2MB full image, 50KB thumbnail
3. **YouTube URL**: Must match pattern `youtube.com/watch?v=*` or `youtu.be/*`
4. **Deletion**: Can be deleted only if `isUsedInWorkouts == false` or with user confirmation
5. **Update Timestamp**: `updatedAt` must be set on any property change

---

## 2. Workout

**Description**: Represents a complete training sequence created by the user. Contains an ordered collection of exercises and breaks.

### SwiftData Model
```swift
import SwiftData
import Foundation

@Model
final class Workout {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Core Properties
    var title: String
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade)
    var items: [WorkoutItem]
    
    @Relationship(deleteRule: .cascade)
    var breaks: [Break]
    
    // MARK: - Computed Properties
    var totalExercises: Int {
        items.count
    }
    
    var estimatedDuration: Int {
        // Sum of all exercise durations + breaks
        let exerciseDuration = items.reduce(0) { sum, item in
            sum + item.estimatedDuration
        }
        let breakDuration = breaks.reduce(0) { $0 + $1.durationSeconds }
        return exerciseDuration + breakDuration
    }
    
    var orderedSequence: [WorkoutSequenceItem] {
        // Combine items and breaks, sorted by position
        let exerciseItems: [(position: Int, item: WorkoutSequenceItem)] = items.map { ($0.position, .exercise($0)) }
        let breakItems: [(position: Int, item: WorkoutSequenceItem)] = breaks.map { ($0.position, .break($0)) }
        return (exerciseItems + breakItems)
            .sorted { $0.position < $1.position }
            .map { $0.item }
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        items: [WorkoutItem] = [],
        breaks: [Break] = []
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.breaks = breaks
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum WorkoutSequenceItem {
    case exercise(WorkoutItem)
    case `break`(Break)
}
```

### Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| `title` | Required, 1-100 characters | "Workout name is required" |
| `items` | At least 1 exercise | "Add at least one exercise to the workout" |

### Business Rules
1. **Title Uniqueness**: Not enforced (user might have similar workout variations)
2. **Empty Workouts**: Cannot start execution if `items.isEmpty`
3. **Position Management**: Positions must be sequential starting from 0
4. **Cascade Delete**: Deleting workout removes all WorkoutItems and Breaks
5. **Update Timestamp**: `updatedAt` set when items/breaks are added, removed, or reordered

---

## 3. WorkoutItem

**Description**: Represents an instance of an exercise within a specific workout with configuration (reps/time, sets, rest).

### SwiftData Model
```swift
import SwiftData
import Foundation

@Model
final class WorkoutItem {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    
    // MARK: - Relationship
    var exercise: Exercise?
    var workout: Workout?
    
    // MARK: - Configuration
    var configurationType: ConfigurationType
    var position: Int // Order in workout sequence
    
    // For rep-based exercises
    var sets: Int?
    var repsPerSet: Int?
    var restBetweenSetsSeconds: Int?
    
    // For time-based exercises
    var durationSeconds: Int?
    
    // MARK: - Computed Properties
    var estimatedDuration: Int {
        switch configurationType {
        case .repetitions:
            let setTime = (repsPerSet ?? 0) * 3 // Estimate 3s per rep
            let restTime = (restBetweenSetsSeconds ?? 0) * (sets ?? 1)
            return (setTime * (sets ?? 1)) + restTime
        case .time:
            return durationSeconds ?? 0
        }
    }
    
    var configurationSummary: String {
        switch configurationType {
        case .repetitions:
            return "\(sets ?? 0) sets × \(repsPerSet ?? 0) reps"
        case .time:
            return "\(durationSeconds ?? 0)s"
        }
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        exercise: Exercise,
        position: Int,
        configurationType: ConfigurationType,
        sets: Int? = nil,
        repsPerSet: Int? = nil,
        restBetweenSetsSeconds: Int? = nil,
        durationSeconds: Int? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.position = position
        self.configurationType = configurationType
        self.sets = sets
        self.repsPerSet = repsPerSet
        self.restBetweenSetsSeconds = restBetweenSetsSeconds
        self.durationSeconds = durationSeconds
    }
}

enum ConfigurationType: String, Codable {
    case repetitions
    case time
}
```

### Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| `exercise` | Required (not null) | "Exercise reference is required" |
| `sets` | If reps: 1-99 | "Sets must be between 1 and 99" |
| `repsPerSet` | If reps: 1-999 | "Reps must be between 1 and 999" |
| `restBetweenSetsSeconds` | If reps: 0-600 (0-10 min) | "Rest must be between 0 and 10 minutes" |
| `durationSeconds` | If time: 1-3600 (1s-1hr) | "Duration must be between 1 second and 1 hour" |

### Business Rules
1. **Configuration Validation**:
   - If `configurationType == .repetitions`: `sets`, `repsPerSet`, `restBetweenSetsSeconds` must be non-nil
   - If `configurationType == .time`: `durationSeconds` must be non-nil
2. **Position Management**: Positions within a workout must be unique and sequential
3. **Exercise Deletion**: If exercise is deleted, WorkoutItem.exercise becomes nil (handle gracefully)

---

## 4. Break

**Description**: Represents a rest period between exercises in a workout.

### SwiftData Model
```swift
import SwiftData
import Foundation

@Model
final class Break {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    
    // MARK: - Relationship
    var workout: Workout?
    
    // MARK: - Properties
    var durationSeconds: Int
    var position: Int // Order in workout sequence
    
    // MARK: - Computed Properties
    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        durationSeconds: Int,
        position: Int
    ) {
        self.id = id
        self.durationSeconds = durationSeconds
        self.position = position
    }
}
```

### Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| `durationSeconds` | 1-600 (1s-10min) | "Break duration must be between 1 second and 10 minutes" |

### Business Rules
1. **Position Management**: Position determines where break appears in workout sequence
2. **Zero Duration**: Not allowed (use validation, min 1 second)
3. **Display**: Show as "Break - Xs" or "Break - Xm Ys" in timeline

---

## 5. MuscleGroup (Enum)

**Description**: Predefined enumeration of muscle group categories. Not persisted as a separate entity.

### Enum Definition
```swift
enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case glutes = "Glutes"
    case forearms = "Forearms"
    case calves = "Calves"
    case fullBody = "Full Body"
    
    var id: String { rawValue }
    
    var sfSymbolName: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.stand"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.strengthtraining.traditional"
        case .triceps: return "figure.strengthtraining.functional"
        case .legs: return "figure.walk"
        case .core: return "figure.core.training"
        case .glutes: return "figure.flexibility"
        case .forearms: return "hand.raised.fill"
        case .calves: return "figure.run"
        case .fullBody: return "figure.mixed.cardio"
        }
    }
}
```

### Usage
- Stored as `[String]` (rawValues) in Exercise model
- Converted to `[MuscleGroup]` enum for UI display
- Multi-select allowed (exercises can target multiple groups)

---

## SwiftData Configuration

### ModelContainer Setup
```swift
import SwiftData

@main
struct GymtasticApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Exercise.self,
                Workout.self,
                WorkoutItem.self,
                Break.self
            ])
            
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic // Enable iCloud sync
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

### Query Examples
```swift
// Fetch all exercises
@Query(sort: \Exercise.createdAt, order: .reverse) 
var exercises: [Exercise]

// Fetch exercises by muscle group
@Query(filter: #Predicate<Exercise> { exercise in
    exercise.muscleGroups.contains("Chest")
})
var chestExercises: [Exercise]

// Fetch all workouts
@Query(sort: \Workout.updatedAt, order: .reverse)
var workouts: [Workout]
```

---

## Migration Strategy

### Future Changes
- SwiftData supports automatic lightweight migrations
- For complex changes, use `VersionedSchema` and `SchemaMigrationPlan`
- Always test migrations with production-like data

### Potential Future Enhancements
1. **Workout History**: Track workout completion dates and performance
2. **Exercise Tags**: User-defined tags for custom categorization
3. **Rest Day Tracking**: Calendar integration for workout scheduling
4. **Progress Photos**: Before/after photos with date tracking
5. **Personal Records**: Track max weight, fastest time, etc.

---

## Data Integrity Rules

### Cascade Deletes
1. **Workout deleted** → All WorkoutItems and Breaks deleted
2. **Exercise deleted** → WorkoutItem.exercise set to nil (soft reference)

### Orphan Prevention
- WorkoutItems without exercise: Show "Deleted Exercise" placeholder
- Breaks without workout: Impossible (cascade delete)

### Uniqueness Constraints
- `id` fields marked with `@Attribute(.unique)`
- Titles not enforced unique (user preference)

---

## Summary

| Entity | Purpose | Key Relationships | Validation |
|--------|---------|------------------|------------|
| **Exercise** | Reusable exercise library | 1:N with WorkoutItem | Title required, image size limits |
| **Workout** | Training sequence | 1:N with WorkoutItem, Break | Title required, ≥1 exercise |
| **WorkoutItem** | Exercise instance in workout | N:1 with Exercise, Workout | Config-dependent validation |
| **Break** | Rest period | N:1 with Workout | Duration 1-600s |
| **MuscleGroup** | Category enum | Referenced by Exercise | Predefined list only |

---

**Data Model Complete**: All entities defined with validation rules, relationships, and business logic. Ready for service contract generation (Phase 1).

