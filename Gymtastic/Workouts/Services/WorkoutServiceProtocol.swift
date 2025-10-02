//
//  WorkoutServiceProtocol.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// Service error types for workout operations
enum WorkoutServiceError: LocalizedError, Equatable {
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
    
    static func == (lhs: WorkoutServiceError, rhs: WorkoutServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidTitle, .invalidTitle),
             (.noExercisesInWorkout, .noExercisesInWorkout),
             (.workoutNotFound, .workoutNotFound),
             (.itemNotFound, .itemNotFound):
            return true
        case let (.invalidSetsValue(lVal), .invalidSetsValue(rVal)),
             let (.invalidRepsValue(lVal), .invalidRepsValue(rVal)),
             let (.invalidRestValue(lVal), .invalidRestValue(rVal)),
             let (.invalidDurationValue(lVal), .invalidDurationValue(rVal)),
             let (.invalidBreakDuration(lVal), .invalidBreakDuration(rVal)):
            return lVal == rVal
        case let (.invalidPosition(lPos, lMax), .invalidPosition(rPos, rMax)):
            return lPos == rPos && lMax == rMax
        case let (.missingConfiguration(lType), .missingConfiguration(rType)):
            return lType == rType
        default:
            return false
        }
    }
}

/// Protocol defining workout service operations
protocol WorkoutServiceProtocol {
    // MARK: - CRUD Operations
    
    /// Creates a new workout
    func createWorkout(title: String) async throws -> Workout
    
    /// Updates workout title
    func updateWorkoutTitle(_ workout: Workout, title: String) async throws
    
    /// Deletes a workout
    func deleteWorkout(_ workout: Workout) async throws
    
    /// Fetches all workouts
    func fetchAllWorkouts() async throws -> [Workout]
    
    /// Fetches a specific workout with its items
    func fetchWorkout(byID id: UUID) async throws -> Workout?
    
    // MARK: - Exercise Management
    
    /// Adds an exercise to a workout
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
    func removeExercise(_ item: WorkoutItem, from workout: Workout) async throws
    
    /// Updates exercise configuration
    func updateExerciseConfiguration(
        _ item: WorkoutItem,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async throws
    
    // MARK: - Break Management
    
    /// Adds a break to a workout
    func addBreak(duration: Int, to workout: Workout, at position: Int) async throws -> Break
    
    /// Removes a break from a workout
    func removeBreak(_ break: Break, from workout: Workout) async throws
    
    /// Updates break duration
    func updateBreakDuration(_ break: Break, duration: Int) async throws
    
    // MARK: - Reordering
    
    /// Reorders items in workout sequence
    func reorderSequence(
        from sourceIndices: IndexSet,
        to destinationIndex: Int,
        in workout: Workout
    ) async throws
    
    /// Moves an item to a specific position
    func moveItem(withID itemID: UUID, to position: Int, in workout: Workout) async throws
    
    // MARK: - Validation
    
    /// Validates workout can be started
    func validateWorkoutForExecution(_ workout: Workout) throws
    
    /// Calculates estimated workout duration
    func calculateEstimatedDuration(_ workout: Workout) -> Int
}

