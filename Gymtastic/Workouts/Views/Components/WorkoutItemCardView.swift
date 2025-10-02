//
//  WorkoutItemCardView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct WorkoutItemCardView: View {
    let item: WorkoutItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Exercise Thumbnail
            if let exercise = item.exercise {
                if let thumbnailData = exercise.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.border)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(.textTertiary)
                            .font(.caption)
                    }
                }
                
                // Exercise Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text(item.configurationSummary)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    if let rest = item.restBetweenSetsSeconds, rest > 0 {
                        Text("Rest: \(rest)s")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                // Deleted exercise placeholder
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deleted Exercise")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                    
                    Text(item.configurationSummary)
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            // Position Badge
            Text("#\(item.position + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gymAccent)
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.shadowStandard, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        WorkoutItemCardView(
            item: WorkoutItem(
                exercise: Exercise(title: "Push Up", muscleGroups: [.chest]),
                position: 0,
                configurationType: .repetitions,
                sets: 3,
                repsPerSet: 12,
                restBetweenSetsSeconds: 60
            )
        )
        
        WorkoutItemCardView(
            item: WorkoutItem(
                exercise: Exercise(title: "Plank", muscleGroups: [.core]),
                position: 1,
                configurationType: .time,
                durationSeconds: 45
            )
        )
    }
    .padding()
}

