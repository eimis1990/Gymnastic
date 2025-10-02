//
//  ExerciseService.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation
import SwiftData

/// Service for managing exercise operations
final class ExerciseService: ExerciseServiceProtocol {
    private let modelContext: ModelContext
    private let imageStorage: ImageStorageService
    
    init(modelContext: ModelContext, imageStorage: ImageStorageService = ImageStorageService()) {
        self.modelContext = modelContext
        self.imageStorage = imageStorage
    }
    
    // MARK: - CRUD Operations
    
    func createExercise(
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws -> Exercise {
        // Validate input
        try validateExercise(title: title, youtubeURL: youtubeURL, muscleGroups: muscleGroups)
        
        // Process image if provided
        var processedImageData: Data?
        var thumbnailData: Data?
        
        if let imageData = imageData {
            guard validateImageSize(imageData) else {
                throw ExerciseServiceError.imageTooLarge(size: imageData.count, maxSize: 2_000_000)
            }
            processedImageData = imageData
            thumbnailData = try await generateThumbnail(from: imageData)
        }
        
        // Create exercise
        let exercise = Exercise(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description,
            youtubeURL: youtubeURL,
            imageData: processedImageData,
            thumbnailData: thumbnailData,
            muscleGroups: muscleGroups
        )
        
        modelContext.insert(exercise)
        try modelContext.save()
        
        return exercise
    }
    
    func updateExercise(
        _ exercise: Exercise,
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async throws {
        // Validate input
        try validateExercise(title: title, youtubeURL: youtubeURL, muscleGroups: muscleGroups)
        
        // Update properties
        exercise.title = title.trimmingCharacters(in: .whitespaces)
        exercise.exerciseDescription = description
        exercise.youtubeURL = youtubeURL
        exercise.muscleGroups = muscleGroups.map { $0.rawValue }
        
        // Update image if provided
        if let imageData = imageData {
            guard validateImageSize(imageData) else {
                throw ExerciseServiceError.imageTooLarge(size: imageData.count, maxSize: 2_000_000)
            }
            exercise.imageData = imageData
            exercise.thumbnailData = try await generateThumbnail(from: imageData)
        }
        
        exercise.updatedAt = Date()
        try modelContext.save()
    }
    
    func deleteExercise(_ exercise: Exercise) async throws -> (success: Bool, usedInWorkouts: Bool) {
        let isUsed = exercise.isUsedInWorkouts
        
        modelContext.delete(exercise)
        try modelContext.save()
        
        return (true, isUsed)
    }
    
    func fetchAllExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchExercises(byMuscleGroup muscleGroup: MuscleGroup) async throws -> [Exercise] {
        let allExercises = try await fetchAllExercises()
        return allExercises.filter { exercise in
            exercise.muscleGroupsEnum.contains(muscleGroup)
        }
    }
    
    func searchExercises(query: String) async throws -> [Exercise] {
        let allExercises = try await fetchAllExercises()
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedQuery.isEmpty else {
            return allExercises
        }
        
        return allExercises.filter { exercise in
            exercise.title.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
    
    // MARK: - Image Operations
    
    func generateThumbnail(from imageData: Data) async throws -> Data {
        return try await imageStorage.generateThumbnail(from: imageData)
    }
    
    func validateImageSize(_ imageData: Data) -> Bool {
        return imageData.count <= 2_000_000 // 2MB
    }
    
    // MARK: - Validation
    
    func validateExercise(
        title: String,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) throws {
        // Validate title
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty && trimmedTitle.count <= 100 else {
            throw ExerciseServiceError.invalidTitle
        }
        
        // Validate YouTube URL if provided
        if let url = youtubeURL, !url.isEmpty {
            guard isValidYouTubeURL(url) else {
                throw ExerciseServiceError.invalidYouTubeURL
            }
        }
        
        // Validate muscle groups
        guard !muscleGroups.isEmpty else {
            throw ExerciseServiceError.noMuscleGroupsSelected
        }
    }
    
    func isValidYouTubeURL(_ url: String) -> Bool {
        let youtubePattern = "(youtube\\.com/watch\\?v=|youtu\\.be/)[\\w-]+"
        let regex = try? NSRegularExpression(pattern: youtubePattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: url.utf16.count)
        return regex?.firstMatch(in: url, options: [], range: range) != nil
    }
}

