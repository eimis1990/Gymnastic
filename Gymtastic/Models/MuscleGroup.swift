//
//  MuscleGroup.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// Predefined enumeration of muscle group categories
enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case glutes = "Glutes"
    case forearms = "Forearms"
    case calves = "Calves"
    case fullBody = "Full Body"
    
    var id: String { rawValue }
    
    /// SF Symbol name for visual representation
    var sfSymbolName: String {
        switch self {
        case .chest:
            return "figure.arms.open"
        case .back:
            return "figure.stand"
        case .shoulders:
            return "figure.arms.open"
        case .biceps:
            return "figure.strengthtraining.traditional"
        case .triceps:
            return "figure.strengthtraining.functional"
        case .legs:
            return "figure.walk"
        case .core:
            return "figure.core.training"
        case .glutes:
            return "figure.flexibility"
        case .forearms:
            return "hand.raised.fill"
        case .calves:
            return "figure.run"
        case .fullBody:
            return "figure.mixed.cardio"
        }
    }
}

