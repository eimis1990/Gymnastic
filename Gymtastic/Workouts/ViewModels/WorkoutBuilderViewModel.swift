//
//  WorkoutBuilderViewModel.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation
import SwiftData

/// ViewModel for workout builder
@Observable
final class WorkoutBuilderViewModel {
    // MARK: - Properties
    var currentWorkout: Workout?
    var exercises: [Exercise] = []
    var isLoading = false
    var errorMessage: String?
    
    private let workoutService: WorkoutServiceProtocol
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(service: WorkoutServiceProtocol) {
        self.workoutService = service
        // Extract modelContext from service
        if let workoutService = service as? WorkoutService {
            self.modelContext = workoutService.modelContext
        } else {
            fatalError("WorkoutService must provide modelContext")
        }
    }
    
    convenience init(workoutService: WorkoutServiceProtocol, modelContext: ModelContext) {
        self.init(service: workoutService)
    }
    
    // MARK: - Workout Operations
    
    @MainActor
    func createWorkout(title: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentWorkout = try await workoutService.createWorkout(title: title)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadWorkout(_ workout: Workout) {
        currentWorkout = workout
    }
    
    @MainActor
    func updateWorkoutTitle(_ title: String) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await workoutService.updateWorkoutTitle(workout, title: title)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Exercise Management
    
    @MainActor
    func addExercise(
        _ exercise: Exercise,
        configurationType: ConfigurationType,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await workoutService.addExercise(
                exercise,
                to: workout,
                configurationType: configurationType,
                sets: sets,
                repsPerSet: repsPerSet,
                restBetweenSets: restBetweenSets,
                duration: duration
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeExercise(_ item: WorkoutItem) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await workoutService.removeExercise(item, from: workout)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Break Management
    
    @MainActor
    func addBreak(duration: Int, at position: Int) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await workoutService.addBreak(duration: duration, to: workout, at: position)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeBreak(_ breakItem: Break) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await workoutService.removeBreak(breakItem, from: workout)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Reordering
    
    @MainActor
    func reorderItems(from sourceIndices: IndexSet, to destinationIndex: Int) async {
        guard let workout = currentWorkout else { return }
        
        do {
            try await workoutService.reorderSequence(
                from: sourceIndices,
                to: destinationIndex,
                in: workout
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Validation
    
    @MainActor
    func validateWorkout() async -> Bool {
        guard let workout = currentWorkout else {
            errorMessage = "No workout selected"
            return false
        }
        
        do {
            try workoutService.validateWorkoutForExecution(workout)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    @MainActor
    func loadAvailableExercises() async {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            exercises = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Computed Properties
    
    var estimatedDuration: String {
        guard let workout = currentWorkout else { return "0m" }
        let seconds = workoutService.calculateEstimatedDuration(workout)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return remainingSeconds > 0 ? "\(minutes)m \(remainingSeconds)s" : "\(minutes)m"
    }
    
    var itemCount: Int {
        currentWorkout?.items.count ?? 0
    }
    
    // MARK: - Helpers
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Convenience Methods for Views
    
    @MainActor
    func createNewWorkout(title: String) async {
        await createWorkout(title: title)
    }
    
    @MainActor
    func addExercise(_ exercise: Exercise, configuration: ExerciseConfiguration) async {
        guard let workout = currentWorkout else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await workoutService.addExercise(
                exercise,
                to: workout,
                configurationType: configuration.type,
                sets: configuration.sets,
                repsPerSet: configuration.repsPerSet,
                restBetweenSets: configuration.restBetweenSets,
                duration: configuration.durationSeconds
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func addBreak(durationSeconds: Int) async {
        guard let workout = currentWorkout else { return }
        let position = workout.orderedSequence.count
        await addBreak(duration: durationSeconds, at: position)
    }
    
    @MainActor
    func reorderWorkoutItems(from: Int, to: Int) async {
        guard let workout = currentWorkout else { return }
        
        // Convert to IndexSet for the service method
        let indexSet = IndexSet(integer: from)
        
        do {
            try await workoutService.reorderSequence(
                from: indexSet,
                to: to,
                in: workout
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func removeWorkoutItem(at index: Int) async {
        guard let workout = currentWorkout else { return }
        guard index < workout.orderedSequence.count else { return }
        
        let item = workout.orderedSequence[index]
        
        isLoading = true
        errorMessage = nil
        
        do {
            switch item {
            case .exercise(let workoutItem):
                try await workoutService.removeExercise(workoutItem, from: workout)
            case .break(let breakItem):
                try await workoutService.removeBreak(breakItem, from: workout)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - ExerciseConfiguration

struct ExerciseConfiguration {
    let type: ConfigurationType
    let sets: Int
    let repsPerSet: Int
    let restBetweenSets: Int
    let durationSeconds: Int
}

