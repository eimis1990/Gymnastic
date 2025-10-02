//
//  Break.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftData
import Foundation

/// Represents a rest period between exercises in a workout
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

