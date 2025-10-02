//
//  Exercise.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftData
import Foundation

/// Represents a single physical exercise in the user's library
@Model
final class Exercise {
    // MARK: - Identity
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Core Properties
    var title: String
    var exerciseDescription: String?
    var youtubeURL: String?
    
    // MARK: - Images
    var imageData: Data?
    var thumbnailData: Data?
    
    // MARK: - Categorization
    var muscleGroups: [String] // Array of MuscleGroup.rawValue
    
    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \WorkoutItem.exercise)
    var workoutItems: [WorkoutItem]?
    
    // MARK: - Computed Properties
    var muscleGroupsEnum: [MuscleGroup] {
        muscleGroups.compactMap { MuscleGroup(rawValue: $0) }
    }
    
    var isUsedInWorkouts: Bool {
        !(workoutItems?.isEmpty ?? true)
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        youtubeURL: String? = nil,
        imageData: Data? = nil,
        thumbnailData: Data? = nil,
        muscleGroups: [MuscleGroup] = []
    ) {
        self.id = id
        self.title = title
        self.exerciseDescription = description
        self.youtubeURL = youtubeURL
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.muscleGroups = muscleGroups.map { $0.rawValue }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

