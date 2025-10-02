//
//  UpcomingItemRowView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct UpcomingItemRowView: View {
    let item: WorkoutSequenceItem
    let position: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Position Number
            Text("\(position)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
                .background(Color(.systemGray5))
                .clipShape(Circle())
            
            // Icon
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.body)
                .frame(width: 32)
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Quick Info
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var iconName: String {
        switch item {
        case .exercise:
            return "dumbbell.fill"
        case .break:
            return "timer"
        }
    }
    
    private var iconColor: Color {
        switch item {
        case .exercise:
            return .gymYellow
        case .break:
            return .blue
        }
    }
    
    private var title: String {
        switch item {
        case .exercise(let workoutItem):
            return workoutItem.exercise?.title ?? "Exercise"
        case .break:
            return "Break"
        }
    }
    
    private var subtitle: String {
        switch item {
        case .exercise(let workoutItem):
            return workoutItem.configurationSummary
        case .break(let breakItem):
            return breakItem.formattedDuration
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        UpcomingItemRowView(
            item: .exercise(WorkoutItem(
                exercise: Exercise(title: "Squat", muscleGroups: [.legs]),
                position: 1,
                configurationType: .repetitions,
                sets: 4,
                repsPerSet: 10,
                restBetweenSetsSeconds: 90
            )),
            position: 2
        )
        
        UpcomingItemRowView(
            item: .break(Break(durationSeconds: 120, position: 2)),
            position: 3
        )
        
        UpcomingItemRowView(
            item: .exercise(WorkoutItem(
                exercise: Exercise(title: "Plank", muscleGroups: [.core]),
                position: 3,
                configurationType: .time,
                durationSeconds: 45
            )),
            position: 4
        )
    }
    .padding()
}

