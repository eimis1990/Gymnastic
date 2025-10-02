//
//  ExerciseServiceProtocol.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// Service error types for exercise operations
enum ExerciseServiceError: LocalizedError, Equatable {
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
    
    static func == (lhs: ExerciseServiceError, rhs: ExerciseServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidTitle, .invalidTitle),
             (.invalidYouTubeURL, .invalidYouTubeURL),
             (.noMuscleGroupsSelected, .noMuscleGroupsSelected),
             (.thumbnailGenerationFailed, .thumbnailGenerationFailed),
             (.exerciseNotFound, .exerciseNotFound):
            return true
        case let (.imageTooLarge(lSize, lMax), .imageTooLarge(rSize, rMax)):
            return lSize == rSize && lMax == rMax
        case let (.deletionFailed(lReason), .deletionFailed(rReason)):
            return lReason == rReason
        default:
            return false
        }
    }
}

/// Protocol defining exercise service operations
protocol ExerciseServiceProtocol {
    // MARK: - CRUD Operations
    
    /// Creates a new exercise
    func createExercise(
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws -> Exercise
    
    /// Updates an existing exercise
    func updateExercise(
        _ exercise: Exercise,
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws
    
    /// Deletes an exercise
    func deleteExercise(_ exercise: Exercise) async throws -> (success: Bool, usedInWorkouts: Bool)
    
    /// Fetches all exercises
    func fetchAllExercises() async throws -> [Exercise]
    
    /// Fetches exercises by muscle group
    func fetchExercises(byMuscleGroup muscleGroup: MuscleGroup) async throws -> [Exercise]
    
    /// Searches exercises by title
    func searchExercises(query: String) async throws -> [Exercise]
    
    // MARK: - Image Operations
    
    /// Generates thumbnail from image data
    func generateThumbnail(from imageData: Data) async throws -> Data
    
    /// Validates image size
    func validateImageSize(_ imageData: Data) -> Bool
    
    // MARK: - Validation
    
    /// Validates exercise data before save
    func validateExercise(
        title: String,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) throws
    
    /// Validates YouTube URL format
    func isValidYouTubeURL(_ url: String) -> Bool
}

