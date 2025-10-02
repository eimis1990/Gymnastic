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
            // Drag Handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.title3)
            
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
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // Exercise Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(item.configurationSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
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
                        .foregroundColor(.secondary)
                    
                    Text(item.configurationSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Position Badge
            Text("#\(item.position + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gymYellow)
                .cornerRadius(8)
        }
        .padding(12)
        .borderedCardStyle()
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

