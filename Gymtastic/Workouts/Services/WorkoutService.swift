//
//  WorkoutService.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation
import SwiftData
import SwiftUI

/// Service for managing workout operations
final class WorkoutService: WorkoutServiceProtocol {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    func createWorkout(title: String) async throws -> Workout {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty && trimmedTitle.count <= 100 else {
            throw WorkoutServiceError.invalidTitle
        }
        
        let workout = Workout(title: trimmedTitle)
        modelContext.insert(workout)
        try modelContext.save()
        
        return workout
    }
    
    func updateWorkoutTitle(_ workout: Workout, title: String) async throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty && trimmedTitle.count <= 100 else {
            throw WorkoutServiceError.invalidTitle
        }
        
        workout.title = trimmedTitle
        workout.updatedAt = Date()
        try modelContext.save()
    }
    
    func deleteWorkout(_ workout: Workout) async throws {
        modelContext.delete(workout)
        try modelContext.save()
    }
    
    func fetchAllWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchWorkout(byID id: UUID) async throws -> Workout? {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - Exercise Management
    
    func addExercise(
        _ exercise: Exercise,
        to workout: Workout,
        configurationType: ConfigurationType,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async throws -> WorkoutItem {
        // Validate configuration
        try validateConfiguration(
            type: configurationType,
            sets: sets,
            repsPerSet: repsPerSet,
            restBetweenSets: restBetweenSets,
            duration: duration
        )
        
        // Calculate next position
        let nextPosition = workout.items.count + workout.breaks.count
        
        let workoutItem = WorkoutItem(
            exercise: exercise,
            position: nextPosition,
            configurationType: configurationType,
            sets: sets,
            repsPerSet: repsPerSet,
            restBetweenSetsSeconds: restBetweenSets,
            durationSeconds: duration
        )
        
        workoutItem.workout = workout
        workout.items.append(workoutItem)
        workout.updatedAt = Date()
        
        modelContext.insert(workoutItem)
        try modelContext.save()
        
        return workoutItem
    }
    
    func removeExercise(_ item: WorkoutItem, from workout: Workout) async throws {
        let removedPosition = item.position
        
        // Remove the item
        workout.items.removeAll { $0.id == item.id }
        modelContext.delete(item)
        
        // Update positions for remaining items and breaks
        updatePositionsAfterRemoval(in: workout, removedPosition: removedPosition)
        
        workout.updatedAt = Date()
        try modelContext.save()
    }
    
    func updateExerciseConfiguration(
        _ item: WorkoutItem,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) async throws {
        try validateConfiguration(
            type: item.configurationType,
            sets: sets,
            repsPerSet: repsPerSet,
            restBetweenSets: restBetweenSets,
            duration: duration
        )
        
        item.sets = sets
        item.repsPerSet = repsPerSet
        item.restBetweenSetsSeconds = restBetweenSets
        item.durationSeconds = duration
        
        item.workout?.updatedAt = Date()
        try modelContext.save()
    }
    
    // MARK: - Break Management
    
    func addBreak(duration: Int, to workout: Workout, at position: Int) async throws -> Break {
        guard duration >= 1 && duration <= 600 else {
            throw WorkoutServiceError.invalidBreakDuration(value: duration)
        }
        
        let breakItem = Break(durationSeconds: duration, position: position)
        breakItem.workout = workout
        workout.breaks.append(breakItem)
        workout.updatedAt = Date()
        
        modelContext.insert(breakItem)
        try modelContext.save()
        
        return breakItem
    }
    
    func removeBreak(_ break: Break, from workout: Workout) async throws {
        let removedPosition = `break`.position
        
        workout.breaks.removeAll { $0.id == `break`.id }
        modelContext.delete(`break`)
        
        updatePositionsAfterRemoval(in: workout, removedPosition: removedPosition)
        
        workout.updatedAt = Date()
        try modelContext.save()
    }
    
    func updateBreakDuration(_ break: Break, duration: Int) async throws {
        guard duration >= 1 && duration <= 600 else {
            throw WorkoutServiceError.invalidBreakDuration(value: duration)
        }
        
        `break`.durationSeconds = duration
        `break`.workout?.updatedAt = Date()
        try modelContext.save()
    }
    
    // MARK: - Reordering
    
    func reorderSequence(
        from sourceIndices: IndexSet,
        to destinationIndex: Int,
        in workout: Workout
    ) async throws {
        var items = workout.items.sorted { $0.position < $1.position }
        items.move(fromOffsets: sourceIndices, toOffset: destinationIndex)
        
        // Update positions
        for (index, item) in items.enumerated() {
            item.position = index
        }
        
        workout.updatedAt = Date()
        try modelContext.save()
    }
    
    func moveItem(withID itemID: UUID, to position: Int, in workout: Workout) async throws {
        // Find the item
        guard let item = workout.items.first(where: { $0.id == itemID }) else {
            throw WorkoutServiceError.itemNotFound
        }
        
        let oldPosition = item.position
        item.position = position
        
        // Adjust other items' positions
        for otherItem in workout.items where otherItem.id != itemID {
            if oldPosition < position {
                // Moving down
                if otherItem.position > oldPosition && otherItem.position <= position {
                    otherItem.position -= 1
                }
            } else {
                // Moving up
                if otherItem.position >= position && otherItem.position < oldPosition {
                    otherItem.position += 1
                }
            }
        }
        
        workout.updatedAt = Date()
        try modelContext.save()
    }
    
    // MARK: - Validation
    
    func validateWorkoutForExecution(_ workout: Workout) throws {
        guard !workout.items.isEmpty else {
            throw WorkoutServiceError.noExercisesInWorkout
        }
    }
    
    func calculateEstimatedDuration(_ workout: Workout) -> Int {
        return workout.estimatedDuration
    }
    
    // MARK: - Private Helpers
    
    private func validateConfiguration(
        type: ConfigurationType,
        sets: Int?,
        repsPerSet: Int?,
        restBetweenSets: Int?,
        duration: Int?
    ) throws {
        switch type {
        case .repetitions:
            guard let sets = sets, sets >= 1 && sets <= 99 else {
                throw WorkoutServiceError.invalidSetsValue(value: sets ?? 0)
            }
            guard let reps = repsPerSet, reps >= 1 && reps <= 999 else {
                throw WorkoutServiceError.invalidRepsValue(value: repsPerSet ?? 0)
            }
            if let rest = restBetweenSets {
                guard rest >= 0 && rest <= 600 else {
                    throw WorkoutServiceError.invalidRestValue(value: rest)
                }
            }
            
        case .time:
            guard let dur = duration, dur >= 1 && dur <= 3600 else {
                throw WorkoutServiceError.invalidDurationValue(value: duration ?? 0)
            }
        }
    }
    
    private func updatePositionsAfterRemoval(in workout: Workout, removedPosition: Int) {
        // Update positions for items and breaks after the removed position
        for item in workout.items where item.position > removedPosition {
            item.position -= 1
        }
        for breakItem in workout.breaks where breakItem.position > removedPosition {
            breakItem.position -= 1
        }
    }
}

