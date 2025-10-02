//
//  WorkoutItem.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftData
import Foundation

/// Configuration type for exercise in workout
enum ConfigurationType: String, Codable {
    case repetitions
    case time
}

/// Represents an instance of an exercise within a specific workout
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

