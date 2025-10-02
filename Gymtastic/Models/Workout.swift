//
//  Workout.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftData
import Foundation

/// Represents a workout sequence item (exercise or break)
enum WorkoutSequenceItem: Identifiable {
    case exercise(WorkoutItem)
    case `break`(Break)
    
    var id: String {
        switch self {
        case .exercise(let item):
            return "exercise-\(item.id.uuidString)"
        case .break(let breakItem):
            return "break-\(breakItem.id.uuidString)"
        }
    }
}

/// Represents a complete training sequence created by the user
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
        let exerciseItems: [(position: Int, item: WorkoutSequenceItem)] = items.map {
            ($0.position, .exercise($0))
        }
        let breakItems: [(position: Int, item: WorkoutSequenceItem)] = breaks.map {
            ($0.position, .break($0))
        }
        return (exerciseItems + breakItems)
            .sorted { $0.position < $1.position }
            .map { $0.item }
    }
    
    var estimatedDurationFormatted: String {
        estimatedDuration.formattedDuration
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

