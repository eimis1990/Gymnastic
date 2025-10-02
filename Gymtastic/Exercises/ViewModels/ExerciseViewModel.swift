//
//  ExerciseViewModel.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation
import SwiftData

/// ViewModel for exercise management
@Observable
final class ExerciseViewModel {
    // MARK: - Properties
    var exercises: [Exercise] = []
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""
    
    private let service: ExerciseServiceProtocol
    
    // MARK: - Initialization
    init(service: ExerciseServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Exercise Operations
    
    @MainActor
    func createExercise(
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let exercise = try await service.createExercise(
                title: title,
                description: description,
                imageData: imageData,
                youtubeURL: youtubeURL,
                muscleGroups: muscleGroups
            )
            exercises.insert(exercise, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateExercise(
        _ exercise: Exercise,
        title: String,
        description: String?,
        imageData: Data?,
        youtubeURL: String?,
        muscleGroups: [MuscleGroup]
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await service.updateExercise(
                exercise,
                title: title,
                description: description,
                imageData: imageData,
                youtubeURL: youtubeURL,
                muscleGroups: muscleGroups
            )
            await loadExercises()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteExercise(_ exercise: Exercise) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await service.deleteExercise(exercise)
            
            if result.usedInWorkouts {
                errorMessage = "Exercise deleted (was used in workouts)"
            }
            
            exercises.removeAll { $0.id == exercise.id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadExercises() async {
        isLoading = true
        errorMessage = nil
        
        do {
            exercises = try await service.fetchAllExercises()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchExercises(query: String) async {
        isLoading = true
        errorMessage = nil
        searchQuery = query
        
        do {
            if query.isEmpty {
                exercises = try await service.fetchAllExercises()
            } else {
                exercises = try await service.searchExercises(query: query)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func filterByMuscleGroup(_ muscleGroup: MuscleGroup) async {
        isLoading = true
        errorMessage = nil
        
        do {
            exercises = try await service.fetchExercises(byMuscleGroup: muscleGroup)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Helpers
    
    func clearError() {
        errorMessage = nil
    }
}

