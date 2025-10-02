# Exercise Service Contract

**Service**: ExerciseService  
**Purpose**: Manages exercise CRUD operations, image storage, and validation  
**Layer**: Business Logic / Service Layer

---

## Protocol Definition

```swift
import Foundation
import SwiftData

protocol ExerciseServiceProtocol {
    // MARK: - CRUD Operations
    
    /// Creates a new exercise
    /// - Parameters:
    ///   - title: Exercise name (required, 1-100 chars)
    ///   - description: Optional description
    ///   - imageData: Optional image data (max 2MB)
    ///   - youtubeURL: Optional YouTube URL
    ///   - muscleGroups: Selected muscle groups (min 1)
    /// - Returns: Created exercise
    /// - Throws: ValidationError if validation fails
    func createExercise(
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws -> Exercise
    
    /// Updates an existing exercise
    /// - Parameters:
    ///   - exercise: Exercise to update
    ///   - title: Updated title
    ///   - description: Updated description
    ///   - imageData: Updated image data
    ///   - youtubeURL: Updated YouTube URL
    ///   - muscleGroups: Updated muscle groups
    /// - Throws: ValidationError if validation fails
    func updateExercise(
        _ exercise: Exercise,
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws
    
    /// Deletes an exercise
    /// - Parameter exercise: Exercise to delete
    /// - Returns: Success status and warning if used in workouts
    /// - Throws: ServiceError if deletion fails
    func deleteExercise(_ exercise: Exercise) async throws -> (success: Bool, usedInWorkouts: Bool)
    
    /// Fetches all exercises
    /// - Returns: Array of all exercises sorted by creation date
    func fetchAllExercises() async throws -> [Exercise]
    
    /// Fetches exercises by muscle group
    /// - Parameter muscleGroup: Target muscle group
    /// - Returns: Filtered exercises
    func fetchExercises(byMuscleGroup muscleGroup: MuscleGroup) async throws -> [Exercise]
    
    /// Searches exercises by title
    /// - Parameter query: Search string
    /// - Returns: Matching exercises
    func searchExercises(query: String) async throws -> [Exercise]
    
    // MARK: - Image Operations
    
    /// Generates thumbnail from image data
    /// - Parameter imageData: Full image data
    /// - Returns: Compressed thumbnail data
    /// - Throws: ImageError if generation fails
    func generateThumbnail(from imageData: Data) async throws -> Data
    
    /// Validates image size
    /// - Parameter imageData: Image data to validate
    /// - Returns: True if valid (< 2MB)
    func validateImageSize(_ imageData: Data) -> Bool
    
    // MARK: - Validation
    
    /// Validates exercise data before save
    /// - Throws: ValidationError with specific field errors
    func validateExercise(
        title: String,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) throws
    
    /// Validates YouTube URL format
    /// - Parameter url: URL string to validate
    /// - Returns: True if valid YouTube URL
    func isValidYouTubeURL(_ url: String) -> Bool
}
```

---

## Error Types

```swift
enum ExerciseServiceError: LocalizedError {
    case invalidTitle
    case invalidYouTubeURL
    case noMuscleGroupsSelected
    case imageTooLarge(size: Int, maxSize: Int)
    case thumbnailGenerationFailed
    case exerciseNotFound
    case deletionFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Exercise name must be between 1 and 100 characters"
        case .invalidYouTubeURL:
            return "Please enter a valid YouTube URL"
        case .noMuscleGroupsSelected:
            return "Please select at least one muscle group"
        case .imageTooLarge(let size, let maxSize):
            return "Image size (\(size / 1_000_000)MB) exceeds maximum (\(maxSize / 1_000_000)MB)"
        case .thumbnailGenerationFailed:
            return "Failed to generate image thumbnail"
        case .exerciseNotFound:
            return "Exercise not found"
        case .deletionFailed(let reason):
            return "Failed to delete exercise: \(reason)"
        }
    }
}
```

---

## Test Scenarios

### Success Cases

#### TC-E01: Create Exercise with Valid Data
```swift
// Given
let title = "Push Up"
let description = "Classic bodyweight exercise"
let muscleGroups = [MuscleGroup.chest, MuscleGroup.triceps]

// When
let exercise = try await service.createExercise(
    title: title,
    description: description,
    imageData: nil,
    youtubeURL: nil,
    muscleGroups: muscleGroups
)

// Then
XCTAssertEqual(exercise.title, title)
XCTAssertEqual(exercise.exerciseDescription, description)
XCTAssertEqual(exercise.muscleGroupsEnum, muscleGroups)
XCTAssertNotNil(exercise.id)
XCTAssertNotNil(exercise.createdAt)
```

#### TC-E02: Create Exercise with Image
```swift
// Given
let imageData = UIImage(named: "pushup")!.jpegData(compressionQuality: 0.8)!

// When
let exercise = try await service.createExercise(
    title: "Push Up",
    description: nil,
    imageData: imageData,
    youtubeURL: nil,
    muscleGroups: [.chest]
)

// Then
XCTAssertNotNil(exercise.imageData)
XCTAssertNotNil(exercise.thumbnailData)
XCTAssertLessThan(exercise.thumbnailData!.count, 100_000) // < 100KB
```

#### TC-E03: Update Exercise
```swift
// Given
let exercise = existingExercise
let newTitle = "Updated Push Up"

// When
try await service.updateExercise(
    exercise,
    title: newTitle,
    description: exercise.exerciseDescription,
    imageData: exercise.imageData,
    youtubeURL: exercise.youtubeURL,
    muscleGroups: exercise.muscleGroupsEnum
)

// Then
XCTAssertEqual(exercise.title, newTitle)
XCTAssertNotEqual(exercise.updatedAt, exercise.createdAt)
```

#### TC-E04: Delete Unused Exercise
```swift
// Given
let exercise = createUnusedExercise()

// When
let result = try await service.deleteExercise(exercise)

// Then
XCTAssertTrue(result.success)
XCTAssertFalse(result.usedInWorkouts)
```

#### TC-E05: Search Exercises
```swift
// Given
createExercise(title: "Push Up")
createExercise(title: "Pull Up")
createExercise(title: "Squat")

// When
let results = try await service.searchExercises(query: "up")

// Then
XCTAssertEqual(results.count, 2)
XCTAssertTrue(results.contains { $0.title == "Push Up" })
XCTAssertTrue(results.contains { $0.title == "Pull Up" })
```

### Error Cases

#### TC-E06: Create Exercise with Empty Title
```swift
// Given
let title = ""

// When/Then
await XCTAssertThrowsError(
    try await service.createExercise(
        title: title,
        description: nil,
        imageData: nil,
        youtubeURL: nil,
        muscleGroups: [.chest]
    )
) { error in
    XCTAssertEqual(error as? ExerciseServiceError, .invalidTitle)
}
```

#### TC-E07: Create Exercise with Invalid YouTube URL
```swift
// Given
let youtubeURL = "not-a-valid-url"

// When/Then
await XCTAssertThrowsError(
    try await service.createExercise(
        title: "Test",
        description: nil,
        imageData: nil,
        youtubeURL: youtubeURL,
        muscleGroups: [.chest]
    )
) { error in
    XCTAssertEqual(error as? ExerciseServiceError, .invalidYouTubeURL)
}
```

#### TC-E08: Create Exercise with No Muscle Groups
```swift
// When/Then
await XCTAssertThrowsError(
    try await service.createExercise(
        title: "Test",
        description: nil,
        imageData: nil,
        youtubeURL: nil,
        muscleGroups: []
    )
) { error in
    XCTAssertEqual(error as? ExerciseServiceError, .noMuscleGroupsSelected)
}
```

#### TC-E09: Create Exercise with Oversized Image
```swift
// Given
let largeImageData = Data(count: 3_000_000) // 3MB

// When/Then
await XCTAssertThrowsError(
    try await service.createExercise(
        title: "Test",
        description: nil,
        imageData: largeImageData,
        youtubeURL: nil,
        muscleGroups: [.chest]
    )
) { error in
    guard case .imageTooLarge = error as? ExerciseServiceError else {
        XCTFail("Wrong error type")
        return
    }
}
```

#### TC-E10: Delete Exercise Used in Workouts
```swift
// Given
let exercise = createExercise()
addExerciseToWorkout(exercise)

// When
let result = try await service.deleteExercise(exercise)

// Then
XCTAssertTrue(result.success) // Deletion succeeds
XCTAssertTrue(result.usedInWorkouts) // But warning is returned
```

---

## Behavioral Requirements

### BR-E01: Title Validation
- **MUST** trim whitespace from title
- **MUST** reject titles < 1 character or > 100 characters
- **MUST** allow special characters and emojis

### BR-E02: YouTube URL Validation
- **MUST** accept `https://www.youtube.com/watch?v=VIDEO_ID`
- **MUST** accept `https://youtu.be/VIDEO_ID`
- **MUST** accept with or without `www.`
- **MUST** reject non-YouTube URLs

### BR-E03: Image Processing
- **MUST** generate thumbnail (200x200) from full image
- **MUST** compress thumbnail to target < 50KB
- **MUST** reject images > 2MB
- **MUST** preserve aspect ratio in thumbnails

### BR-E04: Muscle Group Handling
- **MUST** require at least 1 muscle group
- **MUST** allow multiple muscle groups per exercise
- **MUST** store as array of raw values

### BR-E05: Deletion Behavior
- **MUST** check if exercise is used in workouts
- **MUST** return warning flag if used
- **MUST** allow deletion even if used (user decides)
- **MUST** set WorkoutItem.exercise to nil on delete

### BR-E06: Search Behavior
- **MUST** perform case-insensitive search
- **MUST** match partial titles
- **MUST** return results sorted by relevance (exact match first)

---

## Implementation Notes

### Dependencies
- SwiftData `ModelContext` for persistence
- UIKit `UIImage` for image processing
- Foundation `URL` for YouTube validation

### Performance Considerations
- Thumbnail generation should be async (off main thread)
- Fetch operations should use `@Query` where possible
- Image compression should target file size, not quality

### Thread Safety
- All operations are async and use actor isolation
- SwiftData `ModelContext` handles thread safety automatically

---

**Contract Status**: ✅ Complete - Ready for test-first implementation

