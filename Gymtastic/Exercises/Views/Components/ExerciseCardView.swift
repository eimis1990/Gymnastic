//
//  ExerciseCardView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

/// Card view displaying exercise summary
struct ExerciseCardView: View {
    let exercise: Exercise
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail Image
            if let thumbnailData = exercise.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .clipped()
            } else {
                // Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Exercise Info
            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Muscle Groups
                if !exercise.muscleGroupsEnum.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(exercise.muscleGroupsEnum.prefix(2), id: \.self) { group in
                            MuscleGroupTag(muscleGroup: group)
                        }
                        
                        if exercise.muscleGroupsEnum.count > 2 {
                            Text("+\(exercise.muscleGroupsEnum.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Chevron (optional)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibility(
            label: "\(exercise.title), Muscle groups: \(exercise.muscleGroupsEnum.map { $0.rawValue }.joined(separator: ", "))",
            hint: "Tap to view exercise details"
        )
    }
}

// MARK: - Muscle Group Tag

struct MuscleGroupTag: View {
    let muscleGroup: MuscleGroup
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: muscleGroup.sfSymbolName)
                .font(.caption2)
            
            Text(muscleGroup.rawValue)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gymAccent.opacity(0.2))
        .foregroundColor(.primary)
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ExerciseCardView(
            exercise: Exercise(
                title: "Push Up",
                description: "Classic chest exercise",
                muscleGroups: [.chest, .triceps, .core]
            )
        )
        
        ExerciseCardView(
            exercise: Exercise(
                title: "Squat",
                muscleGroups: [.legs, .glutes]
            )
        )
    }
    .padding()
}

